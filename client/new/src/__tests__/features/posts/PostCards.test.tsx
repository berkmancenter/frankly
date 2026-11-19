// @vitest-environment jsdom
import { screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useLocation } from "react-router";
import { describe, expect, it, vi } from "vitest";
import { comment, thread, user } from "@/__tests__/support/fixtures";
import { renderInCommunity, type CommunityRenderOptions } from "@/__tests__/support/renderWithProviders";
import { PostPreviewCard, VoteCluster } from "@/features/posts/PostCards";

const ME = "u1"; // the signed-in user in `renderInCommunity`

function LocationProbe() {
  return <p data-testid="location">{useLocation().pathname}</p>;
}

const baseApi = {
  users: { get: async (id: string) => user({ id, displayName: id === "u2" ? "Grace Hopper" : "Ada Lovelace" }) },
  threads: { listComments: async () => [] },
};

function renderCard(
  props: Partial<Parameters<typeof PostPreviewCard>[0]> = {},
  options: CommunityRenderOptions = {},
) {
  const onReply = vi.fn();
  const posted = props.thread ?? thread({ id: "th1", creatorId: "u2", content: "Let's talk about parks" });
  const view = renderInCommunity(
    <>
      <PostPreviewCard thread={posted} onReply={onReply} {...props} />
      <LocationProbe />
    </>,
    { ...options, api: { ...baseApi, ...options.api } as CommunityRenderOptions["api"] },
  );
  return { onReply, thread: posted, ...view };
}

describe("VoteCluster", () => {
  function renderVotes(t = thread({ id: "th1" }), options: CommunityRenderOptions = {}) {
    return renderInCommunity(<VoteCluster thread={t} />, {
      ...options,
      api: { threads: { vote: async () => t }, ...options.api } as CommunityRenderOptions["api"],
    });
  }

  it("shows the net score: likes minus dislikes", async () => {
    renderVotes(thread({ likedBy: ["u2", "u3", "u4"], dislikedBy: ["u5"] }));
    expect(await screen.findByText("2")).toBeInTheDocument();
  });

  it("can show a negative score", async () => {
    renderVotes(thread({ likedBy: [], dislikedBy: ["u2", "u3"] }));
    expect(await screen.findByText("-2")).toBeInTheDocument();
  });

  it("abbreviates large scores", async () => {
    renderVotes(thread({ likedBy: Array.from({ length: 1200 }, (_, i) => `liker${i}`) }));
    expect(await screen.findByText("1.2K")).toBeInTheDocument();
  });

  it("shows neither button pressed when I have not voted", async () => {
    renderVotes(thread({ likedBy: ["u2"], dislikedBy: ["u3"] }));
    expect(await screen.findByRole("button", { name: "Like" })).toHaveAttribute("aria-pressed", "false");
    expect(screen.getByRole("button", { name: "Dislike" })).toHaveAttribute("aria-pressed", "false");
  });

  it("shows Like pressed when I already liked the post", async () => {
    renderVotes(thread({ likedBy: [ME] }));
    await waitFor(() => expect(screen.getByRole("button", { name: "Like" })).toHaveAttribute("aria-pressed", "true"));
    expect(screen.getByRole("button", { name: "Dislike" })).toHaveAttribute("aria-pressed", "false");
  });

  it("shows Dislike pressed when I already disliked the post", async () => {
    renderVotes(thread({ dislikedBy: [ME] }));
    await waitFor(() =>
      expect(screen.getByRole("button", { name: "Dislike" })).toHaveAttribute("aria-pressed", "true"),
    );
    expect(screen.getByRole("button", { name: "Like" })).toHaveAttribute("aria-pressed", "false");
  });

  it("sends a like, then a neutral vote when the like is undone", async () => {
    const user = userEvent.setup();
    const { api } = renderVotes(thread({ id: "th1", likedBy: [ME] }));
    const like = await screen.findByRole("button", { name: "Like" });
    await waitFor(() => expect(like).toHaveAttribute("aria-pressed", "true"));

    await user.click(like);
    expect(api.threads.vote).toHaveBeenCalledWith("th1", "neutral");
  });

  it("sends a like when I have not voted yet", async () => {
    const user = userEvent.setup();
    const { api } = renderVotes(thread({ id: "th1" }));
    await user.click(await screen.findByRole("button", { name: "Like" }));
    expect(api.threads.vote).toHaveBeenCalledWith("th1", "like");
  });

  it("sends a dislike, or a neutral vote when the dislike is undone", async () => {
    const user = userEvent.setup();
    const first = renderVotes(thread({ id: "th1" }));
    await user.click(await screen.findByRole("button", { name: "Dislike" }));
    expect(first.api.threads.vote).toHaveBeenCalledWith("th1", "dislike");
    first.unmount();

    const second = renderVotes(thread({ id: "th1", dislikedBy: [ME] }));
    const dislike = await screen.findByRole("button", { name: "Dislike" });
    await waitFor(() => expect(dislike).toHaveAttribute("aria-pressed", "true"));
    await user.click(dislike);
    expect(second.api.threads.vote).toHaveBeenCalledWith("th1", "neutral");
  });
});

describe("PostPreviewCard", () => {
  it("shows the author, the post text and a reply prompt", async () => {
    renderCard();
    expect(await screen.findByText("Grace Hopper")).toBeInTheDocument();
    expect(screen.getByText("Let's talk about parks")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: /Reply/ })).toBeInTheDocument();
  });

  it("shows the attached picture only when the post has one", async () => {
    const { container, unmount } = renderCard({
      thread: thread({ creatorId: "u2", imageUrl: "https://img.example/park.png" }),
    });
    await screen.findByText("Grace Hopper");
    expect(container.querySelector('img[src="https://img.example/park.png"]')).toBeInTheDocument();
    unmount();

    const without = renderCard({ thread: thread({ creatorId: "u2", content: "Text only" }) });
    await screen.findByText("Grace Hopper");
    expect(without.container.querySelector('img[src^="https://img.example"]')).not.toBeInTheDocument();
  });

  it.each([
    [0, "No Comments"],
    [1, "1 Comment"],
    [3, "3 Comments"],
  ])("labels %i comments as %s", async (commentCount, label) => {
    renderCard({ thread: thread({ creatorId: "u2", commentCount }) });
    expect(await screen.findByText(label)).toBeInTheDocument();
  });

  it("previews the latest comment that has not been deleted", async () => {
    renderCard(
      {},
      {
        api: {
          threads: {
            listComments: async () => [
              comment({ id: "c1", comment: "Removed by a moderator", deleted: true }),
              comment({ id: "c2", comment: "I agree with the parks idea" }),
              comment({ id: "c3", comment: "An older comment" }),
            ],
          },
        },
      },
    );
    expect(await screen.findByText("I agree with the parks idea")).toBeInTheDocument();
    expect(screen.getByText("See more")).toBeInTheDocument();
    expect(screen.queryByText("Removed by a moderator")).not.toBeInTheDocument();
    expect(screen.queryByText("An older comment")).not.toBeInTheDocument();
  });

  it("shows no comment preview when there are no comments or all are deleted", async () => {
    renderCard(
      {},
      { api: { threads: { listComments: async () => [comment({ comment: "Gone", deleted: true })] } } },
    );
    await screen.findByText("Grace Hopper");
    await waitFor(() => expect(screen.queryByText("See more")).not.toBeInTheDocument());
    expect(screen.queryByText("Gone")).not.toBeInTheDocument();
  });

  it("hands the post to onReply when the reply box is pressed, without opening the post", async () => {
    const user = userEvent.setup();
    const { onReply, thread: posted } = renderCard();
    await user.click(await screen.findByRole("button", { name: /Reply/ }));

    expect(onReply).toHaveBeenCalledTimes(1);
    expect(onReply).toHaveBeenCalledWith(posted);
    // Still on the page the card was rendered at.
    expect(screen.getByTestId("location").textContent).toBe("/");
  });

  it("opens the post page when the card itself is pressed", async () => {
    const user = userEvent.setup();
    renderCard();
    await user.click(await screen.findByText("Let's talk about parks"));
    expect(screen.getByTestId("location")).toHaveTextContent("/space/civic-lab/post/th1");
  });

  it("does not open the post when voting", async () => {
    const user = userEvent.setup();
    const { api } = renderCard({}, { api: { threads: { listComments: async () => [], vote: async () => thread() } } });
    await user.click(await screen.findByRole("button", { name: "Like" }));

    expect(api.threads.vote).toHaveBeenCalledWith("th1", "like");
    expect(screen.getByTestId("location").textContent).not.toContain("/post/");
  });

  it("opens the author's profile instead of the post when the author is pressed", async () => {
    const user = userEvent.setup();
    renderCard();
    await user.click(await screen.findByText("Grace Hopper"));

    expect(screen.getByTestId("location").textContent).not.toContain("/post/");
    // The profile drawer repeats the name as a heading.
    expect(await screen.findByRole("heading", { name: "Grace Hopper" })).toBeInTheDocument();
  });

  it("sets my reaction through the picker without opening the post", async () => {
    const user = userEvent.setup();
    const { api } = renderCard(
      {},
      { api: { threads: { listComments: async () => [], setEmotion: async () => thread() } } },
    );
    await user.click(await screen.findByRole("button", { name: "Add reaction" }));
    await user.click(screen.getByRole("button", { name: "Heart" }));

    expect(api.threads.setEmotion).toHaveBeenCalledWith("th1", "heart");
    expect(screen.getByTestId("location").textContent).not.toContain("/post/");
  });

  it("clears my reaction when I pick the one I already chose", async () => {
    const user = userEvent.setup();
    const { api } = renderCard(
      { thread: thread({ id: "th1", creatorId: "u2", emotions: [{ userId: ME, emotion: "heart" }] }) },
      { api: { threads: { listComments: async () => [], setEmotion: async () => thread() } } },
    );
    await user.click(await screen.findByRole("button", { name: "Add reaction" }));
    const heart = screen.getByRole("button", { name: "Heart" });
    await waitFor(() => expect(heart).toHaveAttribute("aria-pressed", "true"));

    await user.click(heart);
    expect(api.threads.setEmotion).toHaveBeenCalledWith("th1", null);
  });

  it("shows the reactions already on the post with their total", async () => {
    renderCard({
      thread: thread({
        creatorId: "u2",
        emotions: [
          { userId: "u3", emotion: "heart" },
          { userId: "u4", emotion: "heart" },
        ],
      }),
    });
    const card = (await screen.findByText("Grace Hopper")).closest("article")!;
    expect(within(card).getByText("2")).toBeInTheDocument();
  });

  it("still renders the post when the comments fail to load", async () => {
    renderCard(
      {},
      {
        api: {
          threads: {
            listComments: async () => {
              throw new Error("boom");
            },
          },
        },
      },
    );
    expect(await screen.findByText("Let's talk about parks")).toBeInTheDocument();
    expect(screen.queryByText("See more")).not.toBeInTheDocument();
  });

  it("falls back to an anonymous author when the author cannot be loaded", async () => {
    renderCard(
      {},
      {
        api: {
          users: {
            get: async (id: string) => {
              if (id === "u2") throw new Error("gone");
              return user({ id });
            },
          },
        },
      },
    );
    expect(await screen.findByText("Anonymous")).toBeInTheDocument();
  });

  it("renders the same content on a phone", async () => {
    renderCard(
      { thread: thread({ creatorId: "u2", commentCount: 2, imageUrl: "https://img.example/park.png" }) },
      { mobile: true },
    );
    expect(await screen.findByText("Grace Hopper")).toBeInTheDocument();
    expect(screen.getByText("2 Comments")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: /Reply/ })).toBeInTheDocument();
  });
});
