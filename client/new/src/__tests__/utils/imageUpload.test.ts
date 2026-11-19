import { i18n } from "@lingui/core";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import {
  cloudinaryProvider,
  firebaseStorageProvider,
  isAbortError,
  resolveImageUploadProvider,
  type ImageUploadProviderResult,
} from "@/utils/imageUpload";

// The Firebase provider loads the Storage SDK and the app's Firebase client on demand. Neither
// should run for real here, so both are replaced.
const fb = vi.hoisted(() => ({
  getStorage: vi.fn(),
  ref: vi.fn(),
  uploadBytesResumable: vi.fn(),
  getDownloadURL: vi.fn(),
}));
vi.mock("firebase/storage", () => fb);
vi.mock("@/api/firebase", () => ({ getFirebaseClient: () => ({ app: "the-app" }) }));

const photo = () => new File(["pixels"], "photo.png", { type: "image/png" });

/** The slice of `XMLHttpRequest` that the Cloudinary provider uses, driven by the test. */
class FakeXHR {
  static instances: FakeXHR[] = [];
  method = "";
  url = "";
  body: unknown;
  status = 0;
  responseText = "";
  upload: { onprogress: ((e: { lengthComputable: boolean; loaded: number; total: number }) => void) | null } = {
    onprogress: null,
  };
  onload: (() => void) | null = null;
  onerror: (() => void) | null = null;
  onabort: (() => void) | null = null;
  open = vi.fn((method: string, url: string) => {
    this.method = method;
    this.url = url;
  });
  send = vi.fn((body: unknown) => {
    this.body = body;
  });
  abort = vi.fn(() => this.onabort?.());

  constructor() {
    FakeXHR.instances.push(this);
  }

  respond(status: number, body: unknown) {
    this.status = status;
    this.responseText = typeof body === "string" ? body : JSON.stringify(body);
    this.onload?.();
  }

  progress(loaded: number, total: number, lengthComputable = true) {
    this.upload.onprogress?.({ lengthComputable, loaded, total });
  }
}

/** The only XHR the provider created. */
const xhr = () => {
  expect(FakeXHR.instances).toHaveLength(1);
  return FakeXHR.instances[0]!;
};

beforeEach(() => {
  FakeXHR.instances = [];
  vi.stubGlobal("XMLHttpRequest", FakeXHR);
});

afterEach(() => {
  vi.unstubAllGlobals();
  vi.unstubAllEnvs();
});

describe("isAbortError", () => {
  it("recognizes only an AbortError DOMException", () => {
    expect(isAbortError(new DOMException("stop", "AbortError"))).toBe(true);
    expect(isAbortError(new DOMException("other", "NetworkError"))).toBe(false);
    expect(isAbortError(new Error("AbortError"))).toBe(false);
    expect(isAbortError("AbortError")).toBe(false);
    expect(isAbortError(undefined)).toBe(false);
  });
});

describe("cloudinaryProvider", () => {
  const provider = () => cloudinaryProvider({ cloudName: "demo", uploadPreset: "unsigned-preset" });

  it("posts the file and preset to the cloud's image upload endpoint", () => {
    const file = photo();
    void provider().upload(file);

    const request = xhr();
    expect(request.open).toHaveBeenCalledWith("POST", "https://api.cloudinary.com/v1_1/demo/image/upload");
    const form = request.body as FormData;
    expect(form).toBeInstanceOf(FormData);
    expect(form.get("upload_preset")).toBe("unsigned-preset");
    expect((form.get("file") as File).name).toBe("photo.png");
    expect(request.send).toHaveBeenCalledTimes(1);
  });

  it("resolves with the secure_url from a successful response", async () => {
    const result = provider().upload(photo());

    xhr().respond(200, { secure_url: "https://res.cloudinary.com/demo/image/upload/v1/abc.png", public_id: "abc" });

    await expect(result).resolves.toEqual({ url: "https://res.cloudinary.com/demo/image/upload/v1/abc.png" });
  });

  it("reports upload progress as a rounded percentage, skipping unknown totals", () => {
    const onProgress = vi.fn();
    void provider().upload(photo(), { onProgress });
    const request = xhr();

    request.progress(1, 3);
    request.progress(2, 3);
    request.progress(3, 3);
    request.progress(500, 0, false);

    expect(onProgress.mock.calls).toEqual([[33], [67], [100]]);
  });

  it("does not need an onProgress callback", () => {
    void provider().upload(photo());

    expect(() => xhr().progress(1, 2)).not.toThrow();
  });

  it("rejects with Cloudinary's own error message", async () => {
    const result = provider().upload(photo());

    xhr().respond(400, { error: { message: "Upload preset not found" } });

    await expect(result).rejects.toThrow("Upload preset not found");
  });

  it.each([
    ["a non-JSON server error", 502, "<html>Bad gateway</html>", "Upload failed (502)"],
    ["a JSON error without a message", 500, {}, "Upload failed (500)"],
    ["a success status without a secure_url", 200, { public_id: "abc" }, "Upload failed (200)"],
    ["an empty success body", 200, "", "Upload failed (200)"],
    ["a secure_url on an error status", 404, { secure_url: "https://x.test/a.png" }, "Upload failed (404)"],
  ])("rejects with a generic message for %s", async (_name, status, body, message) => {
    const result = provider().upload(photo());

    xhr().respond(status, body);

    await expect(result).rejects.toThrow(message);
  });

  it("rejects when the network fails", async () => {
    const result = provider().upload(photo());

    xhr().onerror?.();

    await expect(result).rejects.toThrow("Network error during upload");
  });

  it("aborts the request when the signal fires, rejecting with an AbortError", async () => {
    const controller = new AbortController();
    const result = provider().upload(photo(), { signal: controller.signal });
    const request = xhr();

    controller.abort();

    expect(request.abort).toHaveBeenCalledTimes(1);
    const error = await result.catch((e: unknown) => e);
    expect(isAbortError(error)).toBe(true);
  });

  it("rejects immediately, without sending, when the signal is already aborted", async () => {
    const controller = new AbortController();
    controller.abort();

    const result = provider().upload(photo(), { signal: controller.signal });

    expect(isAbortError(await result.catch((e: unknown) => e))).toBe(true);
    expect(xhr().send).not.toHaveBeenCalled();
  });

  it("ignores a late abort once the upload has finished", async () => {
    const controller = new AbortController();
    const result = provider().upload(photo(), { signal: controller.signal });
    xhr().respond(200, { secure_url: "https://cdn.test/a.png" });
    await expect(result).resolves.toEqual({ url: "https://cdn.test/a.png" });

    expect(() => controller.abort()).not.toThrow();
    await expect(result).resolves.toEqual({ url: "https://cdn.test/a.png" });
  });
});

/** A Firebase upload task the test can drive. */
function controllableTask() {
  const handlers: { next?: (s: { bytesTransferred: number; totalBytes: number }) => void; error?: (e: { code: string }) => void; complete?: () => void } = {};
  return {
    handlers,
    cancel: vi.fn(),
    snapshot: { ref: "snapshot-ref" },
    on: vi.fn((_event: string, next: typeof handlers.next, error: typeof handlers.error, complete: typeof handlers.complete) => {
      Object.assign(handlers, { next, error, complete });
    }),
  };
}

/** A task that has already finished uploading by the time `on` is called. */
function finishedTask() {
  const task = controllableTask();
  task.on.mockImplementation((_event, _next, _error, complete) => {
    queueMicrotask(() => complete?.());
  });
  return task;
}

describe("firebaseStorageProvider", () => {
  beforeEach(() => {
    for (const fn of Object.values(fb)) fn.mockReset();
    fb.getStorage.mockReturnValue("storage");
    fb.ref.mockImplementation((_storage: unknown, path: string) => ({ path }));
    fb.getDownloadURL.mockResolvedValue("https://firebasestorage.test/photo.png");
  });

  it("uploads under uploads/images with a unique, sanitized name and the file's content type", async () => {
    fb.uploadBytesResumable.mockReturnValue(finishedTask());
    const file = new File(["pixels"], "my photo (1).png", { type: "image/png" });

    const result = await firebaseStorageProvider().upload(file);

    expect(fb.getStorage).toHaveBeenCalledWith("the-app");
    const path = fb.ref.mock.calls[0]![1] as string;
    expect(path).toMatch(/^uploads\/images\/[0-9a-f-]{36}-my_photo_1_\.png$/);
    expect(fb.uploadBytesResumable).toHaveBeenCalledWith({ path }, file, { contentType: "image/png" });
    expect(fb.getDownloadURL).toHaveBeenCalledWith("snapshot-ref");
    expect(result).toEqual({ url: "https://firebasestorage.test/photo.png" });
  });

  it("reports progress as a rounded percentage", async () => {
    const task = controllableTask();
    fb.uploadBytesResumable.mockReturnValue(task);
    const onProgress = vi.fn();

    const result = firebaseStorageProvider().upload(photo(), { onProgress });
    await vi.waitFor(() => expect(task.on).toHaveBeenCalled());
    task.handlers.next?.({ bytesTransferred: 1, totalBytes: 3 });
    task.handlers.next?.({ bytesTransferred: 3, totalBytes: 3 });
    task.handlers.complete?.();
    await result;

    expect(onProgress.mock.calls).toEqual([[33], [100]]);
  });

  it("rejects with the Storage error", async () => {
    const task = controllableTask();
    fb.uploadBytesResumable.mockReturnValue(task);

    const result = firebaseStorageProvider().upload(photo());
    await vi.waitFor(() => expect(task.on).toHaveBeenCalled());
    task.handlers.error?.({ code: "storage/unauthorized" });

    await expect(result).rejects.toEqual({ code: "storage/unauthorized" });
  });

  it("cancels the task when the signal fires, rejecting with an AbortError", async () => {
    const task = controllableTask();
    task.cancel.mockImplementation(() => task.handlers.error?.({ code: "storage/canceled" }));
    fb.uploadBytesResumable.mockReturnValue(task);
    const controller = new AbortController();

    const result = firebaseStorageProvider().upload(photo(), { signal: controller.signal });
    await vi.waitFor(() => expect(task.on).toHaveBeenCalled());
    controller.abort();

    expect(task.cancel).toHaveBeenCalledTimes(1);
    expect(isAbortError(await result.catch((e: unknown) => e))).toBe(true);
  });

  it("cancels straight away when the signal is already aborted", async () => {
    const task = controllableTask();
    task.cancel.mockImplementation(() => queueMicrotask(() => task.handlers.error?.({ code: "storage/canceled" })));
    fb.uploadBytesResumable.mockReturnValue(task);
    const controller = new AbortController();
    controller.abort();

    const result = await firebaseStorageProvider()
      .upload(photo(), { signal: controller.signal })
      .catch((e: unknown) => e);

    expect(task.cancel).toHaveBeenCalled();
    expect(isAbortError(result)).toBe(true);
  });
});

describe("resolveImageUploadProvider", () => {
  const cloudinaryEnv = { VITE_CLOUDINARY_CLOUD_NAME: "demo", VITE_CLOUDINARY_IMAGE_PRESET: "preset" };
  const firebaseEnv = { VITE_FIREBASE_STORAGE_BUCKET: "frankly.appspot.com" };

  /** Which host the provider writes to, found by running an upload against the fakes. */
  async function hostOf(result: ImageUploadProviderResult): Promise<string> {
    if (!result.provider)
      throw new Error(`expected a provider, got: ${i18n._(result.error!)}`);
    fb.uploadBytesResumable.mockReset();
    fb.uploadBytesResumable.mockReturnValue(finishedTask());
    fb.getDownloadURL.mockResolvedValue("https://firebasestorage.test/x.png");
    const pending = result.provider.upload(photo());
    if (FakeXHR.instances.length > 0) {
      const request = xhr();
      request.respond(200, { secure_url: "https://cdn.test/x.png" });
      await pending;
      return request.url.includes("cloudinary.com") ? "cloudinary" : "unknown";
    }
    await pending;
    return fb.uploadBytesResumable.mock.calls.length ? "firebase" : "unknown";
  }

  describe("without VITE_IMAGE_UPLOAD_PROVIDER", () => {
    it("reports that nothing is configured", () => {
      const result = resolveImageUploadProvider({});

      expect(result.provider).toBeUndefined();
      expect(i18n._(result.error!)).toMatch(/^No image upload provider is configured/);
    });

    it("uses Cloudinary when its cloud name and preset are set", async () => {
      expect(await hostOf(resolveImageUploadProvider(cloudinaryEnv))).toBe("cloudinary");
      expect(xhr().url).toBe("https://api.cloudinary.com/v1_1/demo/image/upload");
    });

    it("uses Firebase Storage when only a bucket is set", async () => {
      expect(await hostOf(resolveImageUploadProvider(firebaseEnv))).toBe("firebase");
    });

    it("prefers Cloudinary when both are configured", async () => {
      expect(await hostOf(resolveImageUploadProvider({ ...cloudinaryEnv, ...firebaseEnv }))).toBe("cloudinary");
    });

    it("needs both Cloudinary values, falling back to Firebase otherwise", async () => {
      const onlyName = resolveImageUploadProvider({ VITE_CLOUDINARY_CLOUD_NAME: "demo", ...firebaseEnv });
      expect(await hostOf(onlyName)).toBe("firebase");

      const onlyPreset = resolveImageUploadProvider({ VITE_CLOUDINARY_IMAGE_PRESET: "preset" });
      expect(onlyPreset.provider).toBeUndefined();
      expect(i18n._(onlyPreset.error!)).toMatch(/^No image upload provider is configured/);
    });

    it("treats empty values as unset", () => {
      const result = resolveImageUploadProvider({
        VITE_CLOUDINARY_CLOUD_NAME: "",
        VITE_CLOUDINARY_IMAGE_PRESET: "",
        VITE_FIREBASE_STORAGE_BUCKET: "",
        VITE_IMAGE_UPLOAD_PROVIDER: "",
      });

      expect(i18n._(result.error!)).toMatch(/^No image upload provider is configured/);
    });

    it("ignores a blank VITE_IMAGE_UPLOAD_PROVIDER and picks automatically", async () => {
      expect(await hostOf(resolveImageUploadProvider({ ...cloudinaryEnv, VITE_IMAGE_UPLOAD_PROVIDER: "   " }))).toBe(
        "cloudinary",
      );
    });
  });

  describe("with VITE_IMAGE_UPLOAD_PROVIDER", () => {
    it("forces Firebase even when Cloudinary is fully configured", async () => {
      const env = { ...cloudinaryEnv, ...firebaseEnv, VITE_IMAGE_UPLOAD_PROVIDER: "firebase" };

      expect(await hostOf(resolveImageUploadProvider(env))).toBe("firebase");
    });

    it("forces Cloudinary even when Firebase is configured too", async () => {
      const env = { ...cloudinaryEnv, ...firebaseEnv, VITE_IMAGE_UPLOAD_PROVIDER: "cloudinary" };

      expect(await hostOf(resolveImageUploadProvider(env))).toBe("cloudinary");
    });

    it("is trimmed and case-insensitive", async () => {
      expect(await hostOf(resolveImageUploadProvider({ ...cloudinaryEnv, VITE_IMAGE_UPLOAD_PROVIDER: "  Cloudinary " }))).toBe(
        "cloudinary",
      );
    });

    it("does not fall back to Firebase when the requested Cloudinary setup is incomplete", () => {
      const result = resolveImageUploadProvider({
        VITE_IMAGE_UPLOAD_PROVIDER: "cloudinary",
        VITE_CLOUDINARY_CLOUD_NAME: "demo",
        ...firebaseEnv,
      });

      expect(result.provider).toBeUndefined();
      expect(i18n._(result.error!)).toBe(
        "Cloudinary isn't configured. Set VITE_CLOUDINARY_CLOUD_NAME and VITE_CLOUDINARY_IMAGE_PRESET.",
      );
    });

    it("does not fall back to Cloudinary when the requested Firebase bucket is missing", () => {
      const result = resolveImageUploadProvider({ ...cloudinaryEnv, VITE_IMAGE_UPLOAD_PROVIDER: "firebase" });

      expect(result.provider).toBeUndefined();
      expect(i18n._(result.error!)).toBe("Firebase Storage isn't configured. Set VITE_FIREBASE_STORAGE_BUCKET.");
    });

    it("rejects an unknown provider, naming it in lower case", () => {
      const result = resolveImageUploadProvider({ ...cloudinaryEnv, VITE_IMAGE_UPLOAD_PROVIDER: "S3" });

      expect(result.provider).toBeUndefined();
      expect(i18n._(result.error!)).toBe('Unknown VITE_IMAGE_UPLOAD_PROVIDER "s3". Use "cloudinary" or "firebase".');
    });
  });

  it("reads import.meta.env when no environment is passed", async () => {
    vi.stubEnv("VITE_IMAGE_UPLOAD_PROVIDER", "");
    vi.stubEnv("VITE_FIREBASE_STORAGE_BUCKET", "");
    vi.stubEnv("VITE_CLOUDINARY_CLOUD_NAME", "from-env");
    vi.stubEnv("VITE_CLOUDINARY_IMAGE_PRESET", "preset");

    const result = resolveImageUploadProvider();
    expect(await hostOf(result)).toBe("cloudinary");
    expect(xhr().url).toContain("/v1_1/from-env/");

    vi.stubEnv("VITE_CLOUDINARY_CLOUD_NAME", "");
    expect(i18n._(resolveImageUploadProvider().error!)).toMatch(/^No image upload provider is configured/);
  });
});
