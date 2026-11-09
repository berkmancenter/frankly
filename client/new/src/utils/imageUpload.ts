/** What an uploaded image looks like once the provider has stored it. */
export interface UploadedImage {
  /** Public URL to save on the document (e.g. `Community.profileImageUrl`). */
  url: string;
}

export interface ImageUploadOptions {
  /** Called with 0-100 as bytes are sent, when the provider can report it. */
  onProgress?: (percent: number) => void;
  /** Abort to cancel an in-flight upload; the provider rejects with an `AbortError`. */
  signal?: AbortSignal;
}

/**
 * The seam between the `Upload` component and wherever images live. Cloudinary and Firebase
 * Storage are implemented below; S3 (presigned PUT) and the like only need to implement this one
 * method and be added to `resolveImageUploadProvider`.
 */
export interface ImageUploadProvider {
  upload(file: File, options?: ImageUploadOptions): Promise<UploadedImage>;
}

function abortError(): DOMException {
  return new DOMException("Upload aborted", "AbortError");
}

export function isAbortError(error: unknown): boolean {
  return error instanceof DOMException && error.name === "AbortError";
}

/**
 * Unsigned Cloudinary upload: the preset (configured in the Cloudinary console as "unsigned")
 * decides the folder, size limits and transformations, so no secret ships to the browser.
 * Uses XHR rather than `fetch` because `fetch` cannot report upload progress.
 */
export function cloudinaryProvider(config: {
  cloudName: string;
  uploadPreset: string;
}): ImageUploadProvider {
  const endpoint = `https://api.cloudinary.com/v1_1/${config.cloudName}/image/upload`;
  return {
    upload(file, { onProgress, signal } = {}) {
      return new Promise((resolve, reject) => {
        const xhr = new XMLHttpRequest();
        const form = new FormData();
        form.append("file", file);
        form.append("upload_preset", config.uploadPreset);

        xhr.open("POST", endpoint);
        xhr.upload.onprogress = (e) => {
          if (e.lengthComputable)
            onProgress?.(Math.round((e.loaded / e.total) * 100));
        };
        xhr.onload = () => {
          let body: { secure_url?: string; error?: { message?: string } } = {};
          try {
            body = JSON.parse(xhr.responseText);
          } catch {
            // Fall through to the generic error below.
          }
          if (xhr.status >= 200 && xhr.status < 300 && body.secure_url) {
            resolve({ url: body.secure_url });
          } else {
            reject(
              new Error(body.error?.message ?? `Upload failed (${xhr.status})`),
            );
          }
        };
        xhr.onerror = () => reject(new Error("Network error during upload"));
        xhr.onabort = () => reject(abortError());

        if (signal) {
          if (signal.aborted) return reject(abortError());
          signal.addEventListener("abort", () => xhr.abort(), { once: true });
        }
        xhr.send(form);
      });
    },
  };
}

/**
 * Firebase Storage upload to the web app's configured bucket. Needs Storage security rules that
 * allow the signed-in user to write under `uploads/images/`.
 */
export function firebaseStorageProvider(): ImageUploadProvider {
  return {
    async upload(file, { onProgress, signal } = {}) {
      // Loaded on demand so Cloudinary-only deployments don't ship the Storage SDK.
      const [
        { getStorage, ref, uploadBytesResumable, getDownloadURL },
        { getFirebaseClient },
      ] = await Promise.all([
        import("firebase/storage"),
        import("@/api/firebase"),
      ]);
      const storage = getStorage(getFirebaseClient().app);
      const safeName = file.name.replace(/[^\w.-]+/g, "_");
      const task = uploadBytesResumable(
        ref(storage, `uploads/images/${crypto.randomUUID()}-${safeName}`),
        file,
        { contentType: file.type },
      );
      if (signal?.aborted) task.cancel();
      signal?.addEventListener("abort", () => task.cancel(), { once: true });

      await new Promise<void>((resolve, reject) =>
        task.on(
          "state_changed",
          (s) =>
            onProgress?.(Math.round((s.bytesTransferred / s.totalBytes) * 100)),
          (e) => reject(e.code === "storage/canceled" ? abortError() : e),
          resolve,
        ),
      );
      return { url: await getDownloadURL(task.snapshot.ref) };
    },
  };
}

type ImageUploadEnv = Record<string, string | undefined>;

/** Either a ready provider or a human-readable reason there isn't one. */
export type ImageUploadProviderResult =
  | { provider: ImageUploadProvider; error?: undefined }
  | { provider?: undefined; error: string };

/**
 * Picks the image host from the environment:
 *
 * 1. `VITE_IMAGE_UPLOAD_PROVIDER` (`cloudinary` | `firebase`) if set. It must be fully configured.
 * 2. Otherwise Cloudinary, when `VITE_CLOUDINARY_CLOUD_NAME` and `VITE_CLOUDINARY_IMAGE_PRESET` are set.
 * 3. Otherwise Firebase Storage, when `VITE_FIREBASE_STORAGE_BUCKET` is set.
 * 4. Otherwise an error, which `Upload` shows in place of the drop zone.
 */
export function resolveImageUploadProvider(
  env: ImageUploadEnv = import.meta.env,
): ImageUploadProviderResult {
  const cloudName = env.VITE_CLOUDINARY_CLOUD_NAME;
  const uploadPreset = env.VITE_CLOUDINARY_IMAGE_PRESET;
  const cloudinary = (): ImageUploadProviderResult =>
    cloudName && uploadPreset
      ? { provider: cloudinaryProvider({ cloudName, uploadPreset }) }
      : {
          error:
            "Cloudinary isn't configured. Set VITE_CLOUDINARY_CLOUD_NAME and VITE_CLOUDINARY_IMAGE_PRESET.",
        };
  const firebase = (): ImageUploadProviderResult =>
    env.VITE_FIREBASE_STORAGE_BUCKET
      ? { provider: firebaseStorageProvider() }
      : {
          error:
            "Firebase Storage isn't configured. Set VITE_FIREBASE_STORAGE_BUCKET.",
        };

  const requested = env.VITE_IMAGE_UPLOAD_PROVIDER?.trim().toLowerCase();
  if (requested === "cloudinary") return cloudinary();
  if (requested === "firebase") return firebase();
  if (requested) {
    return {
      error: `Unknown VITE_IMAGE_UPLOAD_PROVIDER "${requested}". Use "cloudinary" or "firebase".`,
    };
  }

  if (cloudName && uploadPreset) return cloudinary();
  if (env.VITE_FIREBASE_STORAGE_BUCKET) return firebase();
  return {
    error:
      "No image upload provider is configured. Set the VITE_CLOUDINARY_* variables or VITE_FIREBASE_STORAGE_BUCKET.",
  };
}
