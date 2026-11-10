// @vitest-environment jsdom
import { screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it, vi } from "vitest";
import type { ImageUploadProvider } from "@/utils/imageUpload";
import { resource } from "@/__tests__/support/fixtures";
import { renderInCommunity, type CommunityRenderOptions } from "@/__tests__/support/renderWithProviders";
import { ResourceDialog } from "@/features/resources/ResourceDialog";

// `Upload` resolves its image host from the environment once, at module load. The getters let each
// test swap the provider (or remove it) without reloading modules.
const uploadEnv = vi.hoisted(() => ({
  provider: undefined as ImageUploadProvider | undefined,
  error: undefined as string | undefined,
}));

vi.mock("@/utils/imageUpload", async (importActual) => {
  const actual = await importActual<typeof import("@/utils/imageUpload")>();
  return {
    ...actual,
    resolveImageUploadProvider: () => ({
      get provider() {
        return uploadEnv.provider;
      },
      get error() {
        return uploadEnv.error;
      },
    }),
  };
});

const UPLOADED_URL = "https://img.example/uploaded.png";
const PREVIEW = { title: "Parks Guide", image: "https://img.example/preview.png" };
const png = () => new File(["pixels"], "photo.png", { type: "image/png" });

let upload: ReturnType<typeof vi.fn<ImageUploadProvider["upload"]>>;

beforeEach(() => {
  upload = vi.fn<ImageUploadProvider["upload"]>(async () => ({ url: UPLOADED_URL }));
  uploadEnv.provider = { upload };
  uploadEnv.error = undefined;
});

function setup(
  props: Partial<Parameters<typeof ResourceDialog>[0]> = {},
  options: CommunityRenderOptions = {},
) {
  const onClose = vi.fn();
  const view = renderInCommunity(<ResourceDialog onClose={onClose} {...props} />, {
    ...options,
    api: {
      ...options.api,
      // Merged per method so a test can override just one of them.
      resources: {
        preview: async () => PREVIEW,
        create: async () => resource({ id: "new" }),
        update: async () => resource(),
        ...(options.api as { resources?: object } | undefined)?.resources,
      },
    } as CommunityRenderOptions["api"],
  });
  return { onClose, ...view };
}

type User = ReturnType<typeof userEvent.setup>;

const urlBox = () => screen.findByRole("textbox", { name: "Resource URL" });
const post = () => screen.getByRole("button", { name: "Post" });
const loadLink = () => screen.getByRole("button", { name: "Load link" });
const uploadDialog = () => screen.getByLabelText("Upload image");
const fileInput = () => uploadDialog().querySelector<HTMLInputElement>('input[type="file"]')!;
const uploadDialogGone = () =>
  waitFor(() => expect(screen.queryByLabelText("Upload image")).not.toBeInTheDocument());
/** The `src` of the picture on the "Change image" button (a decorative <img>). */
const pictureSrc = () => within(screen.getByRole("button", { name: "Change image" })).queryByRole("presentation")?.getAttribute("src");

async function enterAndLoad(user: User, url = "https://example.com/guide") {
  await user.type(await urlBox(), url);
  await user.click(loadLink());
  await screen.findByText(PREVIEW.title);
}

describe("ResourceDialog (new resource)", () => {
  it("starts with just the URL box and a disabled Post button", async () => {
    setup();
    expect(await urlBox()).toHaveValue("");
    expect(screen.getByPlaceholderText("Paste or enter URL")).toBeInTheDocument();
    expect(post()).toBeDisabled();
    expect(screen.queryByRole("button", { name: "Load link" })).not.toBeInTheDocument();
    expect(screen.queryByRole("button", { name: "Change image" })).not.toBeInTheDocument();
  });

  it("offers to load the link only once a URL has been typed", async () => {
    const user = userEvent.setup();
    setup();
    const box = await urlBox();
    await user.type(box, "   ");
    expect(screen.queryByRole("button", { name: "Load link" })).not.toBeInTheDocument();

    await user.type(box, "https://example.com");
    expect(loadLink()).toBeInTheDocument();
  });

  it("looks up the trimmed URL and shows its title and picture, enabling Post", async () => {
    const user = userEvent.setup();
    const { api } = setup();
    await user.type(await urlBox(), "  https://example.com/guide  ");
    await user.click(loadLink());

    expect(await screen.findByText("Parks Guide")).toBeInTheDocument();
    expect(api.resources.preview).toHaveBeenCalledTimes(1);
    expect(api.resources.preview).toHaveBeenCalledWith("https://example.com/guide");
    expect(pictureSrc()).toBe(PREVIEW.image);
    expect(post()).toBeEnabled();
    // The URL is now loaded, so the check button goes away.
    expect(screen.queryByRole("button", { name: "Load link" })).not.toBeInTheDocument();
  });

  it("shows a spinner while the link is being looked up", async () => {
    const user = userEvent.setup();
    let finish!: (value: typeof PREVIEW) => void;
    setup(
      {},
      { api: { resources: { preview: () => new Promise<typeof PREVIEW>((resolve) => (finish = resolve)) } } },
    );
    await user.type(await urlBox(), "https://example.com");
    await user.click(loadLink());

    expect(await screen.findByRole("progressbar")).toBeInTheDocument();
    expect(post()).toBeDisabled();

    finish(PREVIEW);
    await screen.findByText("Parks Guide");
    expect(screen.queryByRole("progressbar")).not.toBeInTheDocument();
  });

  it("adds the resource with the looked-up details, confirms with a toast and closes", async () => {
    const user = userEvent.setup();
    const { api, onClose } = setup();
    await enterAndLoad(user, "https://example.com/guide");
    await user.click(post());

    expect(await screen.findByText("Resource added")).toBeInTheDocument();
    expect(onClose).toHaveBeenCalledTimes(1);
    expect(api.resources.create).toHaveBeenCalledTimes(1);
    expect(api.resources.create).toHaveBeenCalledWith("c1", {
      url: "https://example.com/guide",
      title: "Parks Guide",
      image: PREVIEW.image,
    });
    expect(api.resources.update).not.toHaveBeenCalled();
  });

  it("can add a link that has no preview picture", async () => {
    const user = userEvent.setup();
    const { api } = setup({}, { api: { resources: { preview: async () => ({ title: "Plain page" }) } } });
    await user.type(await urlBox(), "https://example.com/plain");
    await user.click(loadLink());
    await screen.findByText("Plain page");
    expect(pictureSrc()).toBeUndefined();
    await user.click(post());

    await waitFor(() => expect(api.resources.create).toHaveBeenCalled());
    expect(api.resources.create).toHaveBeenCalledWith("c1", {
      url: "https://example.com/plain",
      title: "Plain page",
      image: undefined,
    });
  });

  it("shows the lookup's error message and keeps Post disabled when the link cannot be loaded", async () => {
    const user = userEvent.setup();
    setup(
      {},
      {
        api: {
          resources: {
            preview: async () => {
              throw new Error("That page could not be reached.");
            },
          },
        },
      },
    );
    await user.type(await urlBox(), "https://nowhere.invalid");
    await user.click(loadLink());

    expect(await screen.findByText("That page could not be reached.")).toBeInTheDocument();
    expect(screen.getByRole("textbox", { name: "Resource URL" })).toBeInvalid();
    expect(post()).toBeDisabled();
    expect(screen.queryByRole("progressbar")).not.toBeInTheDocument();
    // The check button remains so the user can try again.
    expect(loadLink()).toBeInTheDocument();
  });

  it("falls back to a generic message when the failure has no message", async () => {
    const user = userEvent.setup();
    setup({}, { api: { resources: { preview: () => Promise.reject("nope") } } });
    await user.type(await urlBox(), "https://example.com");
    await user.click(loadLink());
    expect(await screen.findByText("Could not load that link.")).toBeInTheDocument();
  });

  it("clears the error when a retry succeeds", async () => {
    const user = userEvent.setup();
    const { api } = setup();
    vi.mocked(api.resources.preview).mockRejectedValueOnce(new Error("Temporarily unavailable"));
    await user.type(await urlBox(), "https://example.com");
    await user.click(loadLink());
    expect(await screen.findByText("Temporarily unavailable")).toBeInTheDocument();

    await user.click(loadLink());
    expect(await screen.findByText("Parks Guide")).toBeInTheDocument();
    expect(screen.queryByText("Temporarily unavailable")).not.toBeInTheDocument();
    expect(screen.getByRole("textbox", { name: "Resource URL" })).toBeValid();
  });

  it("hides the details and disables Post again when the URL is edited after loading", async () => {
    const user = userEvent.setup();
    setup();
    await enterAndLoad(user);
    await user.type(screen.getByRole("textbox", { name: "Resource URL" }), "/more");

    expect(screen.queryByText("Parks Guide")).not.toBeInTheDocument();
    expect(post()).toBeDisabled();
    expect(loadLink()).toBeInTheDocument();
  });

  it("looks up the new URL when the user changes it and reloads", async () => {
    const user = userEvent.setup();
    const { api } = setup();
    await enterAndLoad(user, "https://example.com/one");
    vi.mocked(api.resources.preview).mockResolvedValueOnce({ title: "Second page", image: "https://img.example/2.png" });
    const box = screen.getByRole("textbox", { name: "Resource URL" });
    await user.clear(box);
    await user.type(box, "https://example.com/two");
    await user.click(loadLink());
    expect(await screen.findByText("Second page")).toBeInTheDocument();
    await user.click(post());

    await waitFor(() => expect(api.resources.create).toHaveBeenCalled());
    expect(api.resources.create).toHaveBeenCalledWith("c1", {
      url: "https://example.com/two",
      title: "Second page",
      image: "https://img.example/2.png",
    });
  });

  it("lets the user rename the resource before posting", async () => {
    const user = userEvent.setup();
    const { api } = setup();
    await enterAndLoad(user);
    await user.click(screen.getByRole("button", { name: "Edit title" }));
    const title = screen.getByRole("textbox", { name: "Resource title" });
    expect(title).toHaveValue("Parks Guide");
    await user.clear(title);
    await user.type(title, "Our Park Handbook");
    await user.click(screen.getByRole("button", { name: "Save title" }));

    expect(screen.getByText("Our Park Handbook")).toBeInTheDocument();
    expect(screen.queryByRole("textbox", { name: "Resource title" })).not.toBeInTheDocument();
    await user.click(post());
    await waitFor(() => expect(api.resources.create).toHaveBeenCalled());
    expect(api.resources.create).toHaveBeenCalledWith("c1", {
      url: "https://example.com/guide",
      title: "Our Park Handbook",
      image: PREVIEW.image,
    });
  });

  it("will not post a resource whose title has been cleared", async () => {
    const user = userEvent.setup();
    setup();
    await enterAndLoad(user);
    await user.click(screen.getByRole("button", { name: "Edit title" }));
    await user.clear(screen.getByRole("textbox", { name: "Resource title" }));
    expect(post()).toBeDisabled();

    await user.type(screen.getByRole("textbox", { name: "Resource title" }), "   ");
    expect(post()).toBeDisabled();

    await user.type(screen.getByRole("textbox", { name: "Resource title" }), "Named");
    expect(post()).toBeEnabled();
  });

  it("keeps the dialog open with an error toast when adding fails, and can be retried", async () => {
    const user = userEvent.setup();
    const { api, onClose } = setup(
      {},
      {
        api: {
          resources: {
            create: async () => {
              throw new Error("denied");
            },
          },
        },
      },
    );
    await enterAndLoad(user);
    await user.click(post());

    expect(await screen.findByText("Something went wrong. Please try again.")).toBeInTheDocument();
    expect(screen.queryByText("Resource added")).not.toBeInTheDocument();
    expect(onClose).not.toHaveBeenCalled();
    expect(screen.getByText("Parks Guide")).toBeInTheDocument();

    vi.mocked(api.resources.create).mockResolvedValueOnce(resource());
    await waitFor(() => expect(post()).toBeEnabled());
    await user.click(post());
    await waitFor(() => expect(onClose).toHaveBeenCalledTimes(1));
  });

  it("closes without saving from the close button", async () => {
    const user = userEvent.setup();
    const { api, onClose } = setup();
    await enterAndLoad(user);
    await user.click(screen.getByRole("button", { name: "Close" }));

    expect(onClose).toHaveBeenCalledTimes(1);
    expect(api.resources.create).not.toHaveBeenCalled();
  });

  it("works on a phone", async () => {
    const user = userEvent.setup();
    const { api, onClose } = setup({}, { mobile: true });
    await enterAndLoad(user);
    await user.click(post());

    await waitFor(() => expect(onClose).toHaveBeenCalled());
    expect(api.resources.create).toHaveBeenCalled();
  });
});

describe("ResourceDialog (changing the picture)", () => {
  async function openUpload(user: User) {
    await user.click(screen.getByRole("button", { name: "Change image" }));
    await within(await screen.findByLabelText("Upload image")).findByText("or click to browse");
  }

  it("uploads a new picture in a nested dialog, shows it, and keeps the outer dialog open", async () => {
    const user = userEvent.setup();
    const { onClose } = setup();
    await enterAndLoad(user);
    await openUpload(user);
    const file = png();
    await user.upload(fileInput(), file);

    await uploadDialogGone();
    expect(upload).toHaveBeenCalledTimes(1);
    expect(upload.mock.calls[0]![0]).toBe(file);
    await waitFor(() => expect(pictureSrc()).toBe(UPLOADED_URL));
    expect(onClose).not.toHaveBeenCalled();
    expect(screen.getByRole("textbox", { name: "Resource URL" })).toHaveValue("https://example.com/guide");
    expect(screen.getByText("Parks Guide")).toBeInTheDocument();
  });

  it("posts the replacement picture instead of the previewed one", async () => {
    const user = userEvent.setup();
    const { api } = setup();
    await enterAndLoad(user);
    await openUpload(user);
    await user.upload(fileInput(), png());
    await uploadDialogGone();
    await user.click(post());

    await waitFor(() => expect(api.resources.create).toHaveBeenCalled());
    expect(api.resources.create).toHaveBeenCalledWith("c1", {
      url: "https://example.com/guide",
      title: "Parks Guide",
      image: UPLOADED_URL,
    });
  });

  it("closing the nested dialog leaves the picture and the outer dialog as they were", async () => {
    const user = userEvent.setup();
    const { onClose } = setup();
    await enterAndLoad(user);
    await openUpload(user);
    await user.click(within(uploadDialog()).getByRole("button", { name: "Close" }));

    await uploadDialogGone();
    expect(onClose).not.toHaveBeenCalled();
    expect(upload).not.toHaveBeenCalled();
    expect(pictureSrc()).toBe(PREVIEW.image);
    expect(screen.getByText("Parks Guide")).toBeInTheDocument();
  });

  it("shows the upload error inside the nested dialog and keeps the old picture", async () => {
    const user = userEvent.setup();
    upload.mockRejectedValueOnce(new Error("Upload failed (500)"));
    setup();
    await enterAndLoad(user);
    await openUpload(user);
    await user.upload(fileInput(), png());

    expect(await within(uploadDialog()).findByRole("alert")).toHaveTextContent("Upload failed (500)");
    await user.click(within(uploadDialog()).getByRole("button", { name: "Close" }));
    await uploadDialogGone();
    expect(pictureSrc()).toBe(PREVIEW.image);
  });

  it("explains that uploads are not configured when there is no image host", async () => {
    const user = userEvent.setup();
    uploadEnv.provider = undefined;
    uploadEnv.error = "No image upload provider is configured.";
    const { onClose } = setup();
    await enterAndLoad(user);
    await user.click(screen.getByRole("button", { name: "Change image" }));

    const nested = await screen.findByLabelText("Upload image");
    expect(within(nested).getByRole("alert")).toHaveTextContent("No image upload provider is configured.");
    expect(nested.querySelector('input[type="file"]')).not.toBeInTheDocument();
    expect(onClose).not.toHaveBeenCalled();
  });
});

describe("ResourceDialog (editing a resource)", () => {
  const existing = resource({
    id: "r1",
    title: "Handbook",
    url: "https://example.com/handbook",
    image: "https://img.example/handbook.png",
  });

  it("is prefilled with the resource and ready to save, without a lookup", async () => {
    const { api } = setup({ resource: existing });
    expect(await urlBox()).toHaveValue("https://example.com/handbook");
    expect(screen.getByText("Handbook")).toBeInTheDocument();
    expect(pictureSrc()).toBe("https://img.example/handbook.png");
    expect(post()).toBeEnabled();
    expect(screen.queryByRole("button", { name: "Load link" })).not.toBeInTheDocument();
    expect(api.resources.preview).not.toHaveBeenCalled();
  });

  it("saves changes through update (not create), toasts and closes", async () => {
    const user = userEvent.setup();
    const { api, onClose } = setup({ resource: existing });
    await urlBox();
    await user.click(screen.getByRole("button", { name: "Edit title" }));
    const title = screen.getByRole("textbox", { name: "Resource title" });
    await user.clear(title);
    await user.type(title, "Updated Handbook");
    await user.click(screen.getByRole("button", { name: "Save title" }));
    await user.click(post());

    expect(await screen.findByText("Resource updated")).toBeInTheDocument();
    expect(onClose).toHaveBeenCalledTimes(1);
    expect(api.resources.update).toHaveBeenCalledWith("c1", "r1", {
      url: "https://example.com/handbook",
      title: "Updated Handbook",
      image: "https://img.example/handbook.png",
    });
    expect(api.resources.create).not.toHaveBeenCalled();
  });

  it("requires the new URL to be looked up before saving a changed link", async () => {
    const user = userEvent.setup();
    const { api } = setup({ resource: existing });
    const box = await urlBox();
    await user.clear(box);
    await user.type(box, "https://example.com/new-handbook");

    expect(post()).toBeDisabled();
    expect(screen.queryByText("Handbook")).not.toBeInTheDocument();

    vi.mocked(api.resources.preview).mockResolvedValueOnce({ title: "New Handbook", image: "https://img.example/new.png" });
    await user.click(loadLink());
    expect(await screen.findByText("New Handbook")).toBeInTheDocument();
    await user.click(post());

    await waitFor(() => expect(api.resources.update).toHaveBeenCalled());
    expect(api.resources.update).toHaveBeenCalledWith("c1", "r1", {
      url: "https://example.com/new-handbook",
      title: "New Handbook",
      image: "https://img.example/new.png",
    });
  });

  it("returns to the saved link when the URL is typed back to what it was", async () => {
    const user = userEvent.setup();
    setup({ resource: existing });
    const box = await urlBox();
    await user.type(box, "x");
    expect(post()).toBeDisabled();

    await user.type(box, "{Backspace}");
    expect(post()).toBeEnabled();
    expect(screen.getByText("Handbook")).toBeInTheDocument();
  });

  it("can keep the link but change just its picture", async () => {
    const user = userEvent.setup();
    const { api } = setup({ resource: existing });
    await urlBox();
    await user.click(screen.getByRole("button", { name: "Change image" }));
    await within(await screen.findByLabelText("Upload image")).findByText("or click to browse");
    await user.upload(fileInput(), png());
    await uploadDialogGone();
    await user.click(post());

    await waitFor(() => expect(api.resources.update).toHaveBeenCalled());
    expect(api.resources.update).toHaveBeenCalledWith("c1", "r1", {
      url: "https://example.com/handbook",
      title: "Handbook",
      image: UPLOADED_URL,
    });
  });

  it("shows an error toast and stays open when saving fails", async () => {
    const user = userEvent.setup();
    const { onClose } = setup(
      { resource: existing },
      {
        api: {
          resources: {
            update: async () => {
              throw new Error("denied");
            },
          },
        },
      },
    );
    await urlBox();
    await user.click(post());

    expect(await screen.findByText("Something went wrong. Please try again.")).toBeInTheDocument();
    expect(screen.queryByText("Resource updated")).not.toBeInTheDocument();
    expect(onClose).not.toHaveBeenCalled();
  });
});
