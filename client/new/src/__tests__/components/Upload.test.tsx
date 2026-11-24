// @vitest-environment jsdom
import { act, fireEvent, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it, vi } from "vitest";
import type { ImageUploadOptions, ImageUploadProvider, ImageUploadProviderResult, UploadedImage } from "@/utils/imageUpload";
import { renderWithProviders, type RenderOptions } from "@/__tests__/support/renderWithProviders";

// `Upload` resolves its provider once, when the module loads. Each test picks the outcome
// (a fake provider, or a "not configured" error) and then imports a fresh copy of the component.
const holder = vi.hoisted(() => ({ result: undefined as ImageUploadProviderResult | undefined }));
vi.mock("@/utils/imageUpload", async (importOriginal) => ({
  ...(await importOriginal<typeof import("@/utils/imageUpload")>()),
  resolveImageUploadProvider: () => holder.result,
}));

const png = () => new File(["pixels"], "photo.png", { type: "image/png" });
const abortError = () => new DOMException("Upload aborted", "AbortError");

/** A provider whose uploads stay in flight until the test settles them. */
function controllableProvider() {
  const calls: { file: File; options: ImageUploadOptions; resolve: (image: UploadedImage) => void; reject: (e: unknown) => void }[] = [];
  const upload = vi.fn(
    (file: File, options: ImageUploadOptions = {}) =>
      new Promise<UploadedImage>((resolve, reject) => {
        calls.push({ file, options, resolve, reject });
        options.signal?.addEventListener("abort", () => reject(abortError()));
      }),
  );
  return { provider: { upload } satisfies ImageUploadProvider, upload, calls };
}

async function renderUpload(
  result: ImageUploadProviderResult,
  props: Partial<{ onUploaded: (image: UploadedImage, file: File) => void; accept: string; maxBytes: number }> = {},
  options: RenderOptions = {},
) {
  holder.result = result;
  vi.resetModules();
  const { Upload } = await import("@/components/Upload");
  const onUploaded = props.onUploaded ?? vi.fn();
  const view = renderWithProviders(<Upload {...props} onUploaded={onUploaded} />, options);
  const input = () => view.container.querySelector<HTMLInputElement>('input[type="file"]')!;
  return { ...view, onUploaded, input };
}

beforeEach(() => {
  holder.result = undefined;
});

describe("Upload", () => {
  it("shows the configuration error instead of the drop zone when no provider is set up", async () => {
    const { container } = await renderUpload({
      error: { id: "No image upload provider is configured." },
    });

    expect(screen.getByRole("alert")).toHaveTextContent("No image upload provider is configured.");
    expect(container.querySelector('input[type="file"]')).not.toBeInTheDocument();
    expect(screen.queryByRole("button")).not.toBeInTheDocument();
  });

  it("invites a drag and drop or click on desktop", async () => {
    await renderUpload({ provider: controllableProvider().provider });

    expect(screen.getByText("Drag and drop an image here")).toBeInTheDocument();
    expect(screen.getByText("or click to browse")).toBeInTheDocument();
  });

  it("offers just a photo picker on mobile", async () => {
    await renderUpload({ provider: controllableProvider().provider }, {}, { mobile: true });

    expect(screen.getByText("Choose a photo")).toBeInTheDocument();
    expect(screen.queryByText(/drag and drop/i)).not.toBeInTheDocument();
    expect(screen.queryByText("or click to browse")).not.toBeInTheDocument();
  });

  it("opens the file picker when the zone is clicked, restricted to images by default", async () => {
    const user = userEvent.setup();
    const { input } = await renderUpload({ provider: controllableProvider().provider });
    const picker = vi.spyOn(input(), "click");

    await user.click(screen.getByRole("button"));

    expect(picker).toHaveBeenCalledTimes(1);
    expect(input()).toHaveAttribute("accept", "image/*");
  });

  it("uploads the chosen file and hands the stored image to onUploaded", async () => {
    const user = userEvent.setup();
    const { provider, upload, calls } = controllableProvider();
    const { input, onUploaded } = await renderUpload({ provider });
    const file = png();

    await user.upload(input(), file);

    expect(upload).toHaveBeenCalledWith(file, expect.objectContaining({ onProgress: expect.any(Function) }));
    expect(onUploaded).not.toHaveBeenCalled();
    await act(async () => calls[0]!.resolve({ url: "https://cdn.test/photo.png" }));

    expect(onUploaded).toHaveBeenCalledWith({ url: "https://cdn.test/photo.png" }, file);
    await waitFor(() => expect(screen.queryByRole("progressbar")).not.toBeInTheDocument());
  });

  it("uploads a file dropped on the zone (desktop)", async () => {
    const { provider, upload } = controllableProvider();
    await renderUpload({ provider });
    const file = png();

    fireEvent.drop(screen.getByRole("button"), { dataTransfer: { files: [file] } });

    await waitFor(() => expect(upload).toHaveBeenCalledWith(file, expect.anything()));
  });

  it("ignores drops on mobile, where the zone is only a button", async () => {
    const { provider, upload } = controllableProvider();
    await renderUpload({ provider }, {}, { mobile: true });

    fireEvent.drop(screen.getByRole("button"), { dataTransfer: { files: [png()] } });

    expect(upload).not.toHaveBeenCalled();
  });

  it("reports progress with a cancel button while uploading, and locks the zone", async () => {
    const user = userEvent.setup();
    const { provider, calls } = controllableProvider();
    const { input } = await renderUpload({ provider });
    expect(screen.queryByRole("progressbar")).not.toBeInTheDocument();

    await user.upload(input(), png());
    const bar = await screen.findByRole("progressbar");
    expect(bar).toHaveAttribute("aria-valuenow", "0");

    act(() => calls[0]!.options.onProgress?.(40));
    expect(screen.getByRole("progressbar")).toHaveAttribute("aria-valuenow", "40");
    expect(screen.getByRole("button", { name: /Drag and drop/ })).toHaveAttribute("aria-disabled", "true");
    expect(screen.getByRole("button", { name: "Cancel" })).toBeInTheDocument();
  });

  it("cancels an in-flight upload quietly: no error and no onUploaded", async () => {
    const user = userEvent.setup();
    const { provider, calls } = controllableProvider();
    const { input, onUploaded } = await renderUpload({ provider });
    await user.upload(input(), png());

    await user.click(await screen.findByRole("button", { name: "Cancel" }));

    expect(calls[0]!.options.signal?.aborted).toBe(true);
    await waitFor(() => expect(screen.queryByRole("progressbar")).not.toBeInTheDocument());
    expect(screen.queryByRole("alert")).not.toBeInTheDocument();
    expect(onUploaded).not.toHaveBeenCalled();
  });

  it("aborts the upload if the component unmounts mid-flight", async () => {
    const user = userEvent.setup();
    const { provider, calls } = controllableProvider();
    const { input, unmount } = await renderUpload({ provider });
    await user.upload(input(), png());
    await screen.findByRole("progressbar");

    unmount();

    expect(calls[0]!.options.signal?.aborted).toBe(true);
  });

  it("shows the provider's error message and lets the user try again", async () => {
    const user = userEvent.setup();
    const { provider, calls } = controllableProvider();
    const { input, onUploaded } = await renderUpload({ provider });

    await user.upload(input(), png());
    await act(async () => calls[0]!.reject(new Error("Cloudinary says no")));
    expect(await screen.findByRole("alert")).toHaveTextContent("Cloudinary says no");
    expect(onUploaded).not.toHaveBeenCalled();

    await user.upload(input(), png());
    expect(screen.queryByRole("alert")).not.toBeInTheDocument();
    await act(async () => calls[1]!.resolve({ url: "https://cdn.test/ok.png" }));
    expect(onUploaded).toHaveBeenCalledTimes(1);
  });

  it("falls back to a generic message when the failure is not an Error", async () => {
    const user = userEvent.setup();
    const { provider, calls } = controllableProvider();
    const { input } = await renderUpload({ provider });

    await user.upload(input(), png());
    await act(async () => calls[0]!.reject("weird"));

    expect(await screen.findByRole("alert")).toHaveTextContent("Upload failed");
  });

  it("ignores a second drop while one upload is in flight", async () => {
    const { provider, upload } = controllableProvider();
    await renderUpload({ provider });
    const zone = screen.getByRole("button");

    fireEvent.drop(zone, { dataTransfer: { files: [png()] } });
    await waitFor(() => expect(upload).toHaveBeenCalledTimes(1));
    fireEvent.drop(zone, { dataTransfer: { files: [png()] } });

    expect(upload).toHaveBeenCalledTimes(1);
  });

  describe("validation (nothing is sent to the provider)", () => {
    it("rejects a file that is not an image", async () => {
      const user = userEvent.setup({ applyAccept: false });
      const { provider, upload } = controllableProvider();
      const { input } = await renderUpload({ provider });

      await user.upload(input(), new File(["hello"], "notes.txt", { type: "text/plain" }));

      expect(await screen.findByRole("alert")).toHaveTextContent("That file type isn't supported.");
      expect(upload).not.toHaveBeenCalled();
    });

    it("rejects a file over the size limit (10 MB by default)", async () => {
      const user = userEvent.setup();
      const { provider, upload } = controllableProvider();
      const { input } = await renderUpload({ provider });
      const big = new File([new Uint8Array(10 * 1024 * 1024 + 1)], "big.png", { type: "image/png" });

      await user.upload(input(), big);

      expect(await screen.findByRole("alert")).toHaveTextContent("That file is too large (max 10 MB).");
      expect(upload).not.toHaveBeenCalled();
    });

    it("honors a custom maxBytes", async () => {
      const user = userEvent.setup();
      const { provider, upload } = controllableProvider();
      const { input } = await renderUpload({ provider }, { maxBytes: 2 * 1024 * 1024 });
      const big = new File([new Uint8Array(3 * 1024 * 1024)], "big.png", { type: "image/png" });

      await user.upload(input(), big);

      expect(await screen.findByRole("alert")).toHaveTextContent("max 2 MB");
      expect(upload).not.toHaveBeenCalled();
    });

    it.each([
      ["image/png,image/jpeg", "a.jpg", "image/jpeg", true],
      ["image/png,image/jpeg", "a.gif", "image/gif", false],
      [".png, .jpg", "SHOUT.PNG", "", true],
      [".png, .jpg", "a.gif", "image/gif", false],
      ["image/*", "a.svg", "image/svg+xml", true],
    ])("with accept=%s, %s (%s) allowed: %s", async (accept, name, type, allowed) => {
      const user = userEvent.setup({ applyAccept: false });
      const { provider, upload } = controllableProvider();
      const { input } = await renderUpload({ provider }, { accept });

      await user.upload(input(), new File(["x"], name, { type }));

      if (allowed) {
        await waitFor(() => expect(upload).toHaveBeenCalledTimes(1));
        expect(screen.queryByRole("alert")).not.toBeInTheDocument();
      } else {
        expect(await screen.findByRole("alert")).toHaveTextContent("That file type isn't supported.");
        expect(upload).not.toHaveBeenCalled();
      }
    });

    it("clears a validation error once a valid file is chosen", async () => {
      const user = userEvent.setup({ applyAccept: false });
      const { provider, upload } = controllableProvider();
      const { input } = await renderUpload({ provider });

      await user.upload(input(), new File(["hello"], "notes.txt", { type: "text/plain" }));
      expect(await screen.findByRole("alert")).toBeInTheDocument();
      await user.upload(input(), png());

      await waitFor(() => expect(upload).toHaveBeenCalledTimes(1));
      expect(screen.queryByRole("alert")).not.toBeInTheDocument();
    });
  });
});
