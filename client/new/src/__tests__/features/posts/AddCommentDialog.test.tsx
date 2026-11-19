// @vitest-environment jsdom
import { screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it, vi } from "vitest";
import { comment } from "@/__tests__/support/fixtures";
import { renderInCommunity, type CommunityRenderOptions } from "@/__tests__/support/renderWithProviders";
import { AddCommentDialog } from "@/features/posts/AddCommentDialog";

function setup(
  props: Partial<Parameters<typeof AddCommentDialog>[0]> = {},
  options: CommunityRenderOptions = {},
) {
  const onClose = vi.fn();
  const view = renderInCommunity(<AddCommentDialog thread={{ id: "th1" }} onClose={onClose} {...props} />, {
    ...options,
    api: { threads: { addComment: async () => comment() }, ...options.api } as CommunityRenderOptions["api"],
  });
  return { onClose, ...view };
}

const textbox = () => screen.findByRole("textbox", { name: "Comment" });
const submitButton = () => screen.getByRole("button", { name: "Add comment" });

describe("AddCommentDialog", () => {
  it("shows a titled dialog with an empty comment box", async () => {
    setup();
    expect(await screen.findByRole("heading", { name: "Add comment" })).toBeInTheDocument();
    expect(await textbox()).toHaveValue("");
    expect(submitButton()).toBeEnabled();
  });

  it("focuses the comment box so typing can start straight away", async () => {
    setup();
    expect(await textbox()).toHaveFocus();
  });

  it("sends the trimmed comment for the thread and closes", async () => {
    const user = userEvent.setup();
    const { api, onClose } = setup({ thread: { id: "th7" } });
    await user.type(await textbox(), "  Great idea!  ");
    await user.click(submitButton());

    await waitFor(() => expect(onClose).toHaveBeenCalledTimes(1));
    expect(api.threads.addComment).toHaveBeenCalledTimes(1);
    expect(api.threads.addComment).toHaveBeenCalledWith("th7", { comment: "Great idea!", replyToCommentId: undefined });
  });

  it("keeps multi-line comments intact", async () => {
    const user = userEvent.setup();
    const { api } = setup();
    await user.type(await textbox(), "First line{Enter}Second line");
    await user.click(submitButton());

    await waitFor(() => expect(api.threads.addComment).toHaveBeenCalled());
    expect(api.threads.addComment).toHaveBeenCalledWith("th1", {
      comment: "First line\nSecond line",
      replyToCommentId: undefined,
    });
  });

  it("sends the parent comment id when replying to a comment", async () => {
    const user = userEvent.setup();
    const { api, onClose } = setup({ replyToCommentId: "cm42" });
    await user.type(await textbox(), "I disagree");
    await user.click(submitButton());

    await waitFor(() => expect(onClose).toHaveBeenCalled());
    expect(api.threads.addComment).toHaveBeenCalledWith("th1", { comment: "I disagree", replyToCommentId: "cm42" });
  });

  it("refuses an empty comment, explaining why, without calling the API", async () => {
    const user = userEvent.setup();
    const { api, onClose } = setup();
    await textbox();
    expect(screen.queryByText("Comment cannot be empty")).not.toBeInTheDocument();

    await user.click(submitButton());

    expect(await screen.findByText("Comment cannot be empty")).toBeInTheDocument();
    expect(api.threads.addComment).not.toHaveBeenCalled();
    expect(onClose).not.toHaveBeenCalled();
  });

  it("treats a whitespace-only comment as empty", async () => {
    const user = userEvent.setup();
    const { api } = setup();
    await user.type(await textbox(), "   ");
    await user.click(submitButton());

    expect(await screen.findByText("Comment cannot be empty")).toBeInTheDocument();
    expect(api.threads.addComment).not.toHaveBeenCalled();
  });

  it("flags an empty box as an error once the user leaves it, and clears the error when they type", async () => {
    const user = userEvent.setup();
    setup();
    const box = await textbox();
    await user.tab(); // blur the autofocused box without typing anything
    expect(await screen.findByText("Comment cannot be empty")).toBeInTheDocument();
    expect(box).toBeInvalid();

    await user.type(box, "ok");
    expect(screen.queryByText("Comment cannot be empty")).not.toBeInTheDocument();
  });

  it("shows an error toast and stays open, keeping the draft, when the API fails", async () => {
    const user = userEvent.setup();
    const { api, onClose } = setup(
      {},
      {
        api: {
          threads: {
            addComment: async () => {
              throw new Error("offline");
            },
          },
        },
      },
    );
    await user.type(await textbox(), "My draft");
    await user.click(submitButton());

    expect(await screen.findByText("Something went wrong. Please try again.")).toBeInTheDocument();
    expect(api.threads.addComment).toHaveBeenCalledTimes(1);
    expect(onClose).not.toHaveBeenCalled();
    expect(screen.getByRole("textbox", { name: "Comment" })).toHaveValue("My draft");
    // The button is usable again for a retry.
    await waitFor(() => expect(submitButton()).toBeEnabled());
  });

  it("disables the button while the request is pending so it cannot be sent twice", async () => {
    const user = userEvent.setup();
    let resolve!: () => void;
    const pending = new Promise<ReturnType<typeof comment>>((res) => {
      resolve = () => res(comment());
    });
    const { api, onClose } = setup({}, { api: { threads: { addComment: () => pending } } });
    await user.type(await textbox(), "Once only");
    await user.click(submitButton());

    await waitFor(() => expect(submitButton()).toBeDisabled());
    expect(api.threads.addComment).toHaveBeenCalledTimes(1);
    expect(onClose).not.toHaveBeenCalled();
    resolve();
    await waitFor(() => expect(onClose).toHaveBeenCalledTimes(1));
  });

  it("closes without sending when the close button is pressed", async () => {
    const user = userEvent.setup();
    const { api, onClose } = setup();
    await user.type(await textbox(), "Never mind");
    await user.click(screen.getByRole("button", { name: "Close" }));

    expect(onClose).toHaveBeenCalledTimes(1);
    expect(api.threads.addComment).not.toHaveBeenCalled();
  });

  it("closes on Escape", async () => {
    const user = userEvent.setup();
    const { onClose } = setup();
    await textbox();
    await user.keyboard("{Escape}");
    expect(onClose).toHaveBeenCalledTimes(1);
  });

  it("works the same on a phone", async () => {
    const user = userEvent.setup();
    const { api, onClose } = setup({}, { mobile: true });
    await user.type(await textbox(), "From my phone");
    await user.click(submitButton());

    await waitFor(() => expect(onClose).toHaveBeenCalled());
    expect(api.threads.addComment).toHaveBeenCalledWith("th1", { comment: "From my phone", replyToCommentId: undefined });
  });
});
