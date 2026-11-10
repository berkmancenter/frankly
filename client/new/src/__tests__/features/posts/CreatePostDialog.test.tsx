// @vitest-environment jsdom
import { screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it, vi } from "vitest";
import type { ImageUploadProvider } from "@/utils/imageUpload";
import { community, thread } from "@/__tests__/support/fixtures";
import { renderInCommunity, type CommunityRenderOptions } from "@/__tests__/support/renderWithProviders";
import { CreatePostDialog } from "@/features/posts/CreatePostDialog";

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
const png = () => new File(["pixels"], "photo.png", { type: "image/png" });

let upload: ReturnType<typeof vi.fn<ImageUploadProvider["upload"]>>;

beforeEach(() => {
  upload = vi.fn<ImageUploadProvider["upload"]>(async () => ({ url: UPLOADED_URL }));
  uploadEnv.provider = { upload };
  uploadEnv.error = undefined;
});

function setup(
  props: Partial<Parameters<typeof CreatePostDialog>[0]> = {},
  options: CommunityRenderOptions = {},
) {
  const onClose = vi.fn();
  const view = renderInCommunity(<CreatePostDialog onClose={onClose} {...props} />, {
    ...options,
    api: {
      threads: { create: async () => thread({ id: "new" }), update: async () => thread() },
      ...options.api,
    } as CommunityRenderOptions["api"],
  });
  return { onClose, ...view };
}

const postText = () => screen.findByRole("textbox", { name: "Post text" });
const submit = (name: "Post" | "Update" = "Post") => screen.getByRole("button", { name });
const uploadDialog = () => screen.getByLabelText("Upload image");
const fileInput = () => uploadDialog().querySelector<HTMLInputElement>('input[type="file"]')!;

/** Opens the nested upload dialog and picks `file` in it. */
async function pickImage(user: ReturnType<typeof userEvent.setup>, file = png()) {
  await user.click(screen.getByRole("button", { name: "Attach image" }));
  await within(await screen.findByLabelText("Upload image")).findByText("or click to browse");
  await user.upload(fileInput(), file);
}

const uploadDialogGone = () =>
  waitFor(() => expect(screen.queryByLabelText("Upload image")).not.toBeInTheDocument());

describe("CreatePostDialog (new post)", () => {
  it("starts with an empty text box and the Post button disabled", async () => {
    setup();
    expect(await postText()).toHaveValue("");
    expect(screen.getByPlaceholderText("Type something")).toBe(screen.getByRole("textbox", { name: "Post text" }));
    expect(submit()).toBeDisabled();
  });

  it("shows the signed-in user's avatar", async () => {
    setup();
    await postText();
    // The user comes from the same query as the scope; its initial arrives once loaded.
    await waitFor(() => expect(screen.getByTitle("Ada Lovelace")).toBeInTheDocument());
  });

  it("enables Post once there is text, and disables it again for whitespace only", async () => {
    const user = userEvent.setup();
    setup();
    const box = await postText();

    await user.type(box, "Hi");
    expect(submit()).toBeEnabled();

    await user.clear(box);
    await user.type(box, "   ");
    expect(submit()).toBeDisabled();
  });

  it("creates the post with trimmed text, confirms with a toast and closes", async () => {
    const user = userEvent.setup();
    const { api, onClose } = setup();
    await user.type(await postText(), "  Hello neighbors  ");
    await user.click(submit());

    expect(await screen.findByText("Post has been created")).toBeInTheDocument();
    expect(onClose).toHaveBeenCalledTimes(1);
    expect(api.threads.create).toHaveBeenCalledTimes(1);
    expect(api.threads.create).toHaveBeenCalledWith("c1", { content: "Hello neighbors", imageUrl: undefined });
    expect(api.threads.update).not.toHaveBeenCalled();
  });

  it("creates the post in the community it is opened from", async () => {
    const user = userEvent.setup();
    const { api } = setup({}, { community: community({ id: "c9", displayId: "other" }) });
    await user.type(await postText(), "Elsewhere");
    await user.click(submit());

    await waitFor(() => expect(api.threads.create).toHaveBeenCalled());
    expect(vi.mocked(api.threads.create).mock.calls[0]![0]).toBe("c9");
  });

  it("keeps the dialog open with the draft and shows an error toast when creating fails", async () => {
    const user = userEvent.setup();
    const { api, onClose } = setup(
      {},
      {
        api: {
          threads: {
            create: async () => {
              throw new Error("offline");
            },
          },
        },
      },
    );
    await user.type(await postText(), "My draft");
    await user.click(submit());

    expect(await screen.findByText("Something went wrong. Please try again.")).toBeInTheDocument();
    expect(onClose).not.toHaveBeenCalled();
    expect(screen.queryByText("Post has been created")).not.toBeInTheDocument();
    expect(screen.getByRole("textbox", { name: "Post text" })).toHaveValue("My draft");
    await waitFor(() => expect(submit()).toBeEnabled());

    // Retrying works.
    vi.mocked(api.threads.create).mockResolvedValueOnce(thread());
    await user.click(submit());
    await waitFor(() => expect(onClose).toHaveBeenCalledTimes(1));
  });

  it("inserts the emoji shortcuts into the text, which also makes the post sendable", async () => {
    const user = userEvent.setup();
    const { api } = setup();
    const box = await postText();
    await user.type(box, "Love it ");
    await user.click(screen.getByRole("button", { name: "Insert Heart" }));
    await user.click(screen.getByRole("button", { name: "Insert Laughing" }));
    expect(box).toHaveValue("Love it ❤️😂");

    await user.click(submit());
    await waitFor(() => expect(api.threads.create).toHaveBeenCalled());
    expect(api.threads.create).toHaveBeenCalledWith("c1", { content: "Love it ❤️😂", imageUrl: undefined });
  });

  it("offers all seven emoji shortcuts mapped to the right characters", async () => {
    const user = userEvent.setup();
    setup();
    const box = await postText();
    const expected: [string, string][] = [
      ["Thumbs up", "👍"],
      ["Heart", "❤️"],
      ["100", "💯"],
      ["Exclamation", "❗"],
      ["Plus one", "➕"],
      ["Laughing", "😂"],
      ["Heart eyes", "😍"],
    ];
    for (const [label, char] of expected) {
      await user.clear(box);
      await user.click(screen.getByRole("button", { name: `Insert ${label}` }));
      expect(box).toHaveValue(char);
    }
  });

  it("closes without saving from the close button", async () => {
    const user = userEvent.setup();
    const { api, onClose } = setup();
    await user.type(await postText(), "Abandoned");
    await user.click(screen.getByRole("button", { name: "Close" }));

    expect(onClose).toHaveBeenCalledTimes(1);
    expect(api.threads.create).not.toHaveBeenCalled();
  });

  it("closes on Escape", async () => {
    const user = userEvent.setup();
    const { onClose } = setup();
    await postText();
    await user.keyboard("{Escape}");
    expect(onClose).toHaveBeenCalledTimes(1);
  });

  it("works on a phone", async () => {
    const user = userEvent.setup();
    const { api, onClose } = setup({}, { mobile: true });
    await user.type(await postText(), "From my phone");
    await user.click(submit());

    await waitFor(() => expect(onClose).toHaveBeenCalled());
    expect(api.threads.create).toHaveBeenCalledWith("c1", { content: "From my phone", imageUrl: undefined });
  });
});

describe("CreatePostDialog (attaching an image)", () => {
  it("shows no picture until one is attached", async () => {
    setup();
    await postText();
    expect(screen.queryByRole("img", { name: "Attached" })).not.toBeInTheDocument();
    expect(screen.queryByRole("button", { name: "Remove image" })).not.toBeInTheDocument();
    expect(screen.queryByLabelText("Upload image")).not.toBeInTheDocument();
  });

  it("opens a second dialog with the upload zone on top of the post dialog", async () => {
    const user = userEvent.setup();
    setup();
    await postText();
    await user.click(screen.getByRole("button", { name: "Attach image" }));

    const nested = await screen.findByLabelText("Upload image");
    expect(within(nested).getByText("Drag and drop an image here")).toBeInTheDocument();
    expect(within(nested).getByText("or click to browse")).toBeInTheDocument();
  });

  it("uploads the chosen file, shows it in the post, closes only the nested dialog and keeps the draft", async () => {
    const user = userEvent.setup();
    const { onClose } = setup();
    await user.type(await postText(), "Look at this");
    const file = png();
    await pickImage(user, file);

    await uploadDialogGone();
    expect(upload).toHaveBeenCalledTimes(1);
    expect(upload.mock.calls[0]![0]).toBe(file);
    expect(await screen.findByRole("img", { name: "Attached" })).toHaveAttribute("src", UPLOADED_URL);
    expect(onClose).not.toHaveBeenCalled();
    expect(screen.getByRole("textbox", { name: "Post text" })).toHaveValue("Look at this");
  });

  it("sends the uploaded image URL with the post", async () => {
    const user = userEvent.setup();
    const { api } = setup();
    await user.type(await postText(), "With a picture");
    await pickImage(user);
    await uploadDialogGone();
    await user.click(submit());

    await waitFor(() => expect(api.threads.create).toHaveBeenCalled());
    expect(api.threads.create).toHaveBeenCalledWith("c1", { content: "With a picture", imageUrl: UPLOADED_URL });
  });

  it("can remove an attached image again before posting", async () => {
    const user = userEvent.setup();
    const { api } = setup();
    await user.type(await postText(), "Changed my mind");
    await pickImage(user);
    await uploadDialogGone();
    await user.click(await screen.findByRole("button", { name: "Remove image" }));

    expect(screen.queryByRole("img", { name: "Attached" })).not.toBeInTheDocument();
    await user.click(submit());
    await waitFor(() => expect(api.threads.create).toHaveBeenCalled());
    expect(api.threads.create).toHaveBeenCalledWith("c1", { content: "Changed my mind", imageUrl: undefined });
  });

  it("closing the nested dialog without choosing leaves the post dialog open and unchanged", async () => {
    const user = userEvent.setup();
    const { onClose } = setup();
    await user.type(await postText(), "Still writing");
    await user.click(screen.getByRole("button", { name: "Attach image" }));
    const nested = await screen.findByLabelText("Upload image");
    await user.click(within(nested).getByRole("button", { name: "Close" }));

    await uploadDialogGone();
    expect(onClose).not.toHaveBeenCalled();
    expect(upload).not.toHaveBeenCalled();
    expect(screen.getByRole("textbox", { name: "Post text" })).toHaveValue("Still writing");
    expect(screen.queryByRole("img", { name: "Attached" })).not.toBeInTheDocument();
  });

  it("closing only the nested dialog with Escape does not close the post dialog", async () => {
    const user = userEvent.setup();
    const { onClose } = setup();
    await postText();
    await user.click(screen.getByRole("button", { name: "Attach image" }));
    await screen.findByLabelText("Upload image");
    await user.keyboard("{Escape}");

    await uploadDialogGone();
    expect(onClose).not.toHaveBeenCalled();
    expect(screen.getByRole("textbox", { name: "Post text" })).toBeInTheDocument();
  });

  it("shows the provider's message and keeps the nested dialog open when the upload fails", async () => {
    const user = userEvent.setup();
    upload.mockRejectedValueOnce(new Error("Network error during upload"));
    setup();
    await postText();
    await pickImage(user);

    expect(await within(uploadDialog()).findByRole("alert")).toHaveTextContent("Network error during upload");
    expect(screen.queryByRole("img", { name: "Attached" })).not.toBeInTheDocument();

    // Picking another file after the failure works.
    await user.upload(fileInput(), png());
    await uploadDialogGone();
    expect(await screen.findByRole("img", { name: "Attached" })).toHaveAttribute("src", UPLOADED_URL);
  });

  it("rejects a file that is not an image without calling the provider", async () => {
    const user = userEvent.setup({ applyAccept: false });
    setup();
    await postText();
    await user.click(screen.getByRole("button", { name: "Attach image" }));
    await within(await screen.findByLabelText("Upload image")).findByText("or click to browse");
    await user.upload(fileInput(), new File(["text"], "notes.txt", { type: "text/plain" }));

    expect(await within(uploadDialog()).findByRole("alert")).toHaveTextContent("That file type isn't supported.");
    expect(upload).not.toHaveBeenCalled();
  });

  it("explains that uploads are not configured when no image host is set up", async () => {
    const user = userEvent.setup();
    uploadEnv.provider = undefined;
    uploadEnv.error = "No image upload provider is configured.";
    const { onClose } = setup();
    await postText();
    await user.click(screen.getByRole("button", { name: "Attach image" }));

    const nested = await screen.findByLabelText("Upload image");
    expect(within(nested).getByRole("alert")).toHaveTextContent("No image upload provider is configured.");
    expect(within(nested).queryByText("or click to browse")).not.toBeInTheDocument();
    expect(nested.querySelector('input[type="file"]')).not.toBeInTheDocument();
    expect(onClose).not.toHaveBeenCalled();
  });

  it("can attach an image on a phone", async () => {
    const user = userEvent.setup();
    setup({}, { mobile: true });
    await postText();
    await user.click(screen.getByRole("button", { name: "Attach image" }));
    expect(await within(await screen.findByLabelText("Upload image")).findByText("Choose a photo")).toBeInTheDocument();
    await user.upload(fileInput(), png());

    await uploadDialogGone();
    expect(await screen.findByRole("img", { name: "Attached" })).toHaveAttribute("src", UPLOADED_URL);
  });
});

describe("CreatePostDialog (editing a post)", () => {
  const existing = thread({
    id: "th1",
    content: "Original text",
    imageUrl: "https://img.example/old.png",
    creatorId: "u1",
  });

  it("is prefilled with the post's text and picture and offers Update instead of Post", async () => {
    setup({ thread: existing });
    expect(await postText()).toHaveValue("Original text");
    expect(screen.getByRole("img", { name: "Attached" })).toHaveAttribute("src", "https://img.example/old.png");
    expect(submit("Update")).toBeEnabled();
    expect(screen.queryByRole("button", { name: "Post" })).not.toBeInTheDocument();
  });

  it("saves the edited text through update (not create), toasts and closes", async () => {
    const user = userEvent.setup();
    const { api, onClose } = setup({ thread: existing });
    const box = await postText();
    await user.clear(box);
    await user.type(box, "  Edited text ");
    await user.click(submit("Update"));

    expect(await screen.findByText("Post has been updated")).toBeInTheDocument();
    expect(onClose).toHaveBeenCalledTimes(1);
    expect(api.threads.update).toHaveBeenCalledWith("th1", {
      content: "Edited text",
      imageUrl: "https://img.example/old.png",
    });
    expect(api.threads.create).not.toHaveBeenCalled();
  });

  it("will not save once the text has been cleared", async () => {
    const user = userEvent.setup();
    setup({ thread: existing });
    await user.clear(await postText());
    expect(submit("Update")).toBeDisabled();
  });

  it("explicitly clears the picture on the server when it is removed", async () => {
    const user = userEvent.setup();
    const { api } = setup({ thread: existing });
    await postText();
    await user.click(screen.getByRole("button", { name: "Remove image" }));
    await user.click(submit("Update"));

    await waitFor(() => expect(api.threads.update).toHaveBeenCalled());
    // The `imageUrl` key must be present (even if undefined): the API treats a missing key as
    // "leave unchanged" and a present one as "delete the field".
    expect(vi.mocked(api.threads.update).mock.calls[0]![1]).toStrictEqual({
      content: "Original text",
      imageUrl: undefined,
    });
  });

  it("replaces the picture with a newly uploaded one", async () => {
    const user = userEvent.setup();
    const { api } = setup({ thread: existing });
    await postText();
    await pickImage(user);
    await uploadDialogGone();
    expect(await screen.findByRole("img", { name: "Attached" })).toHaveAttribute("src", UPLOADED_URL);
    await user.click(submit("Update"));

    await waitFor(() => expect(api.threads.update).toHaveBeenCalled());
    expect(api.threads.update).toHaveBeenCalledWith("th1", { content: "Original text", imageUrl: UPLOADED_URL });
  });

  it("shows an error toast and stays open when the update fails", async () => {
    const user = userEvent.setup();
    const { onClose } = setup(
      { thread: existing },
      {
        api: {
          threads: {
            update: async () => {
              throw new Error("denied");
            },
          },
        },
      },
    );
    await postText();
    await user.click(submit("Update"));

    expect(await screen.findByText("Something went wrong. Please try again.")).toBeInTheDocument();
    expect(screen.queryByText("Post has been updated")).not.toBeInTheDocument();
    expect(onClose).not.toHaveBeenCalled();
  });
});

describe("CreatePostDialog (accessibility)", () => {
  it("names the nested upload dialog for assistive technology", async () => {
    const user = userEvent.setup();
    setup();
    await postText();
    await user.click(screen.getByRole("button", { name: "Attach image" }));
    await screen.findByLabelText("Upload image");
    expect(screen.getByRole("dialog", { name: "Upload image" })).toBeInTheDocument();
  });
});
