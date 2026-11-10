// @vitest-environment jsdom
import { screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it, vi } from "vitest";
import type { ImageUploadProvider } from "@/utils/imageUpload";
import type { Vote } from "@/api/api";
import type { DiscussionThread } from "@/api/types";
import { comment, thread, user as userFixture } from "@/__tests__/support/fixtures";
import { renderInCommunity, type CommunityRenderOptions } from "@/__tests__/support/renderWithProviders";
import { PostsPage } from "@/features/posts/PostsPage";

const ME = "u1";

// The real FAB renders into a slot owned by `AppScaffold`; a plain button stands in for it here.
vi.mock("@/components/layout/AppScaffold", async (importActual) => {
  const actual = await importActual<typeof import("@/components/layout/AppScaffold")>();
  const { createElement } = await import("react");
  return {
    ...actual,
    ScaffoldFab: ({ text, onClick }: { text: string; onClick: () => void }) =>
      createElement("button", { type: "button", onClick }, text),
  };
});

vi.mock("@/utils/imageUpload", async (importActual) => {
  const actual = await importActual<typeof import("@/utils/imageUpload")>();
  const provider: ImageUploadProvider = { upload: async () => ({ url: "https://img.example/up.png" }) };
  return { ...actual, resolveImageUploadProvider: () => ({ provider }) };
});

const posts = () => [
  thread({ id: "th1", creatorId: "u2", content: "First post about parks" }),
  thread({ id: "th2", creatorId: "u3", content: "Second post about buses", commentCount: 1 }),
];

const defaultApi = (list: DiscussionThread[] = posts()) => ({
  threads: { list: async () => list, listComments: async () => [] },
  users: {
    get: async (id: string) =>
      userFixture({ id, displayName: { u1: "Ada Lovelace", u2: "Grace Hopper", u3: "Alan Turing" }[id] ?? id }),
  },
});

/** A server that really records my vote, so the refetch after a vote agrees with the optimistic value. */
function votingServer() {
  let list = posts();
  return {
    list: async () => list,
    listComments: async () => [],
    vote: async (threadId: string, vote: Vote) => {
      list = list.map((t) =>
        t.id !== threadId
          ? t
          : {
              ...t,
              likedBy: [...t.likedBy.filter((u) => u !== ME), ...(vote === "like" ? [ME] : [])],
              dislikedBy: [...t.dislikedBy.filter((u) => u !== ME), ...(vote === "dislike" ? [ME] : [])],
            },
      );
      return list.find((t) => t.id === threadId)!;
    },
  };
}

function setup(options: CommunityRenderOptions = {}) {
  return renderInCommunity(<PostsPage />, {
    ...options,
    api: { ...defaultApi(), ...options.api } as CommunityRenderOptions["api"],
  });
}

/** The card for the post whose text is `text`. */
const cardOf = async (text: string) => within((await screen.findByText(text)).closest("article")!);

describe("PostsPage", () => {
  beforeEach(() => vi.clearAllMocks());

  it("shows a spinner while the posts load", async () => {
    setup({ api: { threads: { list: () => new Promise(() => {}) } } });
    // The scope's own spinner is replaced by the page's once the community has loaded.
    await screen.findByRole("button", { name: "Create post" });
    expect(screen.getByRole("progressbar")).toBeInTheDocument();
    expect(screen.queryByRole("article")).not.toBeInTheDocument();
  });

  it("shows an error message when the posts cannot be loaded", async () => {
    setup({
      api: {
        threads: {
          list: async () => {
            throw new Error("boom");
          },
        },
      },
    });
    expect(await screen.findByRole("alert")).toHaveTextContent("Something went wrong loading posts.");
    expect(screen.queryByRole("article")).not.toBeInTheDocument();
  });

  it("lists every post with its author, text and comment count", async () => {
    setup();
    expect(await screen.findByText("First post about parks")).toBeInTheDocument();
    expect(screen.getByText("Second post about buses")).toBeInTheDocument();
    expect(screen.getAllByRole("article")).toHaveLength(2);
    expect(await screen.findByText("Grace Hopper")).toBeInTheDocument();
    expect(await screen.findByText("Alan Turing")).toBeInTheDocument();
    expect(screen.getByText("No Comments")).toBeInTheDocument();
    expect(screen.getByText("1 Comment")).toBeInTheDocument();
  });

  it("lists the posts in the order the server returned them", async () => {
    setup();
    await screen.findByText("First post about parks");
    const texts = screen.getAllByRole("article").map((a) => a.textContent ?? "");
    expect(texts[0]).toContain("First post about parks");
    expect(texts[1]).toContain("Second post about buses");
  });

  it("lists the posts in a single column on a phone", async () => {
    setup({ mobile: true });
    expect(await screen.findByText("First post about parks")).toBeInTheDocument();
    expect(screen.getByText("Second post about buses")).toBeInTheDocument();
    expect(screen.getAllByRole("article")).toHaveLength(2);
  });

  describe("when there are no posts", () => {
    it("shows an empty state with a way to write the first post", async () => {
      const user = userEvent.setup();
      setup({ api: defaultApi([]) });

      expect(await screen.findByRole("heading", { name: "No posts" })).toBeInTheDocument();
      expect(screen.queryByRole("article")).not.toBeInTheDocument();

      await user.click(screen.getByRole("button", { name: "Create a post" }));
      expect(await screen.findByRole("textbox", { name: "Post text" })).toBeInTheDocument();
    });
  });

  describe("creating a post", () => {
    it("opens the composer from the floating button", async () => {
      const user = userEvent.setup();
      setup();
      await screen.findByText("First post about parks");
      expect(screen.queryByRole("textbox", { name: "Post text" })).not.toBeInTheDocument();

      await user.click(screen.getByRole("button", { name: "Create post" }));
      expect(await screen.findByRole("textbox", { name: "Post text" })).toBeInTheDocument();
    });

    it("sends the post, closes the composer, and the new post shows up in the list", async () => {
      const user = userEvent.setup();
      let list = posts();
      const { api } = setup({
        api: {
          threads: {
            list: async () => list,
            listComments: async () => [],
            create: async (_communityId: string, input: { content: string }) => {
              const created = thread({ id: "th3", creatorId: ME, content: input.content });
              list = [created, ...list];
              return created;
            },
          },
        },
      });
      await screen.findByText("First post about parks");
      await user.click(screen.getByRole("button", { name: "Create post" }));
      await user.type(await screen.findByRole("textbox", { name: "Post text" }), "Brand new post");
      await user.click(screen.getByRole("button", { name: "Post" }));

      expect(await screen.findByText("Post has been created")).toBeInTheDocument();
      expect(api.threads.create).toHaveBeenCalledWith("c1", { content: "Brand new post", imageUrl: undefined });
      expect(await screen.findByText("Brand new post")).toBeInTheDocument();
      expect(screen.getAllByRole("article")).toHaveLength(3);
      await waitFor(() => expect(screen.queryByRole("textbox", { name: "Post text" })).not.toBeInTheDocument());
    });

    it("lets the first post replace the empty state", async () => {
      const user = userEvent.setup();
      let list: DiscussionThread[] = [];
      setup({
        api: {
          threads: {
            list: async () => list,
            listComments: async () => [],
            create: async (_communityId: string, input: { content: string }) => {
              const created = thread({ id: "th1", creatorId: ME, content: input.content });
              list = [created];
              return created;
            },
          },
        },
      });
      await user.click(await screen.findByRole("button", { name: "Create a post" }));
      await user.type(await screen.findByRole("textbox", { name: "Post text" }), "Hello world");
      await user.click(screen.getByRole("button", { name: "Post" }));

      expect(await screen.findByRole("article")).toHaveTextContent("Hello world");
      expect(screen.queryByRole("heading", { name: "No posts" })).not.toBeInTheDocument();
    });

    it("closes the composer without posting when it is dismissed", async () => {
      const user = userEvent.setup();
      const { api } = setup();
      await screen.findByText("First post about parks");
      await user.click(screen.getByRole("button", { name: "Create post" }));
      await user.type(await screen.findByRole("textbox", { name: "Post text" }), "Never mind");
      await user.click(screen.getByRole("button", { name: "Close" }));

      await waitFor(() => expect(screen.queryByRole("textbox", { name: "Post text" })).not.toBeInTheDocument());
      expect(api.threads.create).not.toHaveBeenCalled();
    });

    it("starts each new composer empty", async () => {
      const user = userEvent.setup();
      setup();
      await screen.findByText("First post about parks");
      await user.click(screen.getByRole("button", { name: "Create post" }));
      await user.type(await screen.findByRole("textbox", { name: "Post text" }), "Draft");
      await user.click(screen.getByRole("button", { name: "Close" }));
      await waitFor(() => expect(screen.queryByRole("textbox", { name: "Post text" })).not.toBeInTheDocument());

      await user.click(screen.getByRole("button", { name: "Create post" }));
      expect(await screen.findByRole("textbox", { name: "Post text" })).toHaveValue("");
    });
  });

  describe("commenting", () => {
    it("opens the comment dialog for the post whose Reply box was pressed", async () => {
      const user = userEvent.setup();
      const { api } = setup({
        api: { threads: { list: async () => posts(), listComments: async () => [], addComment: async () => comment() } },
      });
      const second = await cardOf("Second post about buses");
      await user.click(second.getByRole("button", { name: /Reply/ }));
      await user.type(await screen.findByRole("textbox", { name: "Comment" }), "Buses are late");
      await user.click(screen.getByRole("button", { name: "Add comment" }));

      await waitFor(() => expect(api.threads.addComment).toHaveBeenCalled());
      expect(api.threads.addComment).toHaveBeenCalledWith("th2", { comment: "Buses are late", replyToCommentId: undefined });
    });

    it("closes the dialog and refreshes the post's comments and count after commenting", async () => {
      const user = userEvent.setup();
      let comments: ReturnType<typeof comment>[] = [];
      let list = posts();
      setup({
        api: {
          threads: {
            list: async () => list,
            listComments: async (threadId: string) => (threadId === "th1" ? comments : []),
            addComment: async (_threadId: string, input: { comment: string }) => {
              const added = comment({ id: "cm9", threadId: "th1", comment: input.comment });
              comments = [added];
              list = list.map((t) => (t.id === "th1" ? { ...t, commentCount: 1 } : t));
              return added;
            },
          },
        },
      });
      const first = await cardOf("First post about parks");
      expect(first.getByText("No Comments")).toBeInTheDocument();
      await user.click(first.getByRole("button", { name: /Reply/ }));
      await user.type(await screen.findByRole("textbox", { name: "Comment" }), "Lovely parks");
      await user.click(screen.getByRole("button", { name: "Add comment" }));

      await waitFor(() => expect(screen.queryByRole("textbox", { name: "Comment" })).not.toBeInTheDocument());
      const refreshed = await cardOf("First post about parks");
      expect(await refreshed.findByText("1 Comment")).toBeInTheDocument();
      // The new comment is now the preview under the post.
      expect(await refreshed.findByText("Lovely parks")).toBeInTheDocument();
    });

    it("closes the comment dialog without sending anything when dismissed", async () => {
      const user = userEvent.setup();
      const { api } = setup();
      const first = await cardOf("First post about parks");
      await user.click(first.getByRole("button", { name: /Reply/ }));
      await screen.findByRole("textbox", { name: "Comment" });
      await user.click(screen.getByRole("button", { name: "Close" }));

      await waitFor(() => expect(screen.queryByRole("textbox", { name: "Comment" })).not.toBeInTheDocument());
      expect(api.threads.addComment).not.toHaveBeenCalled();
    });
  });

  describe("voting and reacting", () => {
    it("updates the score immediately, before the server answers, then settles on the server's value", async () => {
      const user = userEvent.setup();
      let release!: () => void;
      const gate = new Promise<void>((resolve) => (release = resolve));
      let list = posts();
      const { api } = setup({
        api: {
          threads: {
            list: async () => list,
            listComments: async () => [],
            vote: async () => {
              await gate;
              list = list.map((t) => (t.id === "th1" ? { ...t, likedBy: [ME, "u9"] } : t));
              return list[0]!;
            },
          },
        },
      });
      const first = await cardOf("First post about parks");
      await waitFor(() => expect(first.getByText("0")).toBeInTheDocument());

      await user.click(first.getByRole("button", { name: "Like" }));

      // Optimistic: one like (mine) is shown while the request is still pending.
      await waitFor(() => expect(first.getByText("1")).toBeInTheDocument());
      expect(first.getByRole("button", { name: "Like" })).toHaveAttribute("aria-pressed", "true");
      expect(api.threads.vote).toHaveBeenCalledWith("th1", "like");

      release();
      // Server truth (two likes) replaces the guess after the refetch.
      await waitFor(() => expect(first.getByText("2")).toBeInTheDocument());
    });

    it("shows a dislike right away and lets me take it back", async () => {
      const user = userEvent.setup();
      const { api } = setup({ api: { threads: votingServer() } });
      const first = await cardOf("First post about parks");
      await user.click(first.getByRole("button", { name: "Dislike" }));
      await waitFor(() => expect(first.getByText("-1")).toBeInTheDocument());
      expect(first.getByRole("button", { name: "Dislike" })).toHaveAttribute("aria-pressed", "true");

      await user.click(first.getByRole("button", { name: "Dislike" }));
      expect(api.threads.vote).toHaveBeenLastCalledWith("th1", "neutral");
      await waitFor(() => expect(first.getByText("0")).toBeInTheDocument());
    });

    it("goes back to the original score when a vote is rejected", async () => {
      const user = userEvent.setup();
      let fail!: () => void;
      const gate = new Promise<DiscussionThread>((_resolve, reject) => (fail = () => reject(new Error("offline"))));
      setup({
        api: { threads: { list: async () => posts(), listComments: async () => [], vote: () => gate } },
      });
      const first = await cardOf("First post about parks");
      await waitFor(() => expect(first.getByText("0")).toBeInTheDocument());
      await user.click(first.getByRole("button", { name: "Like" }));
      await waitFor(() => expect(first.getByText("1")).toBeInTheDocument());

      fail();

      await waitFor(() => expect(first.getByText("0")).toBeInTheDocument());
      expect(first.getByRole("button", { name: "Like" })).toHaveAttribute("aria-pressed", "false");
    });

    it("shows my reaction on the post straight away and sends it", async () => {
      const user = userEvent.setup();
      let release!: () => void;
      const gate = new Promise<void>((resolve) => (release = resolve));
      const { api } = setup({
        api: {
          threads: {
            list: async () => posts(),
            listComments: async () => [],
            setEmotion: async () => {
              await gate;
              return thread();
            },
          },
        },
      });
      const first = await cardOf("First post about parks");
      await user.click(first.getByRole("button", { name: "Add reaction" }));
      await user.click(screen.getByRole("button", { name: "Heart" }));

      expect(api.threads.setEmotion).toHaveBeenCalledWith("th1", "heart");
      // The strip of emoji + total appears before the server has answered.
      await waitFor(() => expect(first.getByText("1")).toBeInTheDocument());
      expect(first.getAllByRole("presentation").some((img) => img.getAttribute("src") === "/media/emoji-heart.png")).toBe(
        true,
      );
      release();
    });

    it("keeps votes on one post from affecting the others", async () => {
      const user = userEvent.setup();
      setup({ api: { threads: votingServer() } });
      const first = await cardOf("First post about parks");
      const second = await cardOf("Second post about buses");
      await user.click(first.getByRole("button", { name: "Like" }));

      await waitFor(() => expect(first.getByText("1")).toBeInTheDocument());
      expect(second.getByRole("button", { name: "Like" })).toHaveAttribute("aria-pressed", "false");
      expect(second.queryByText("1")).not.toBeInTheDocument();
    });
  });
});
