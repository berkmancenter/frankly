// @vitest-environment jsdom
import { screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it, vi } from "vitest";
import type { EmotionVote } from "@/api/types";
import { renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { EMOTIONS, EmotionSection } from "@/features/posts/EmotionSection";

const ME = "u1";
const vote = (emotion: EmotionVote["emotion"], userId = "u2"): EmotionVote => ({ userId, emotion });

function setup(emotions: EmotionVote[] = [], { signedIn = true } = {}) {
  const onSelect = vi.fn();
  const view = renderWithProviders(
    <EmotionSection emotions={emotions} myUserId={signedIn ? ME : undefined} onSelect={onSelect} />,
  );
  return { onSelect, ...view };
}

/** The strip of distinct emoji shown beside the add button (decorative images, so found by src). */
const stripSources = (container: HTMLElement) =>
  [...container.querySelectorAll("img")]
    .map((img) => img.getAttribute("src"))
    .filter((src) => src?.includes("/emoji-"));

describe("EmotionSection", () => {
  it("shows only the add-reaction button when there are no reactions", () => {
    const { container } = setup();
    expect(screen.getByRole("button", { name: "Add reaction" })).toBeInTheDocument();
    expect(stripSources(container)).toEqual([]);
    expect(screen.queryByText(/^\d+$/)).not.toBeInTheDocument();
  });

  it("shows each distinct emoji once, plus the total number of reactions", () => {
    const { container } = setup([vote("heart"), vote("heart", "u3"), vote("thumbsUp", "u4")]);
    expect(stripSources(container)).toEqual(["/media/emoji-heart.png", "/media/emoji-thumbs-up.png"]);
    expect(screen.getByText("3")).toBeInTheDocument();
  });

  it("opens a picker with all seven reactions and nothing preselected", async () => {
    const user = userEvent.setup();
    setup([vote("heart")]);
    await user.click(screen.getByRole("button", { name: "Add reaction" }));

    for (const { label } of EMOTIONS) {
      expect(screen.getByRole("button", { name: label })).toHaveAttribute("aria-pressed", "false");
    }
    expect(EMOTIONS).toHaveLength(7);
  });

  it("reports the chosen reaction and closes the picker", async () => {
    const user = userEvent.setup();
    const { onSelect } = setup();
    await user.click(screen.getByRole("button", { name: "Add reaction" }));
    await user.click(screen.getByRole("button", { name: "Heart eyes" }));

    expect(onSelect).toHaveBeenCalledTimes(1);
    expect(onSelect).toHaveBeenCalledWith("heartEyes");
    await waitFor(() => expect(screen.queryByRole("button", { name: "Heart eyes" })).not.toBeInTheDocument());
  });

  it("marks the signed-in user's own reaction as pressed and toggles it off when picked again", async () => {
    const user = userEvent.setup();
    const { onSelect } = setup([vote("hundred", ME), vote("heart", "u2")]);
    await user.click(screen.getByRole("button", { name: "Add reaction" }));

    expect(screen.getByRole("button", { name: "100" })).toHaveAttribute("aria-pressed", "true");
    // Somebody else's reaction doesn't count as mine.
    expect(screen.getByRole("button", { name: "Heart" })).toHaveAttribute("aria-pressed", "false");

    await user.click(screen.getByRole("button", { name: "100" }));
    expect(onSelect).toHaveBeenCalledWith(null);
  });

  it("switches to a different reaction rather than clearing when another emoji is picked", async () => {
    const user = userEvent.setup();
    const { onSelect } = setup([vote("hundred", ME)]);
    await user.click(screen.getByRole("button", { name: "Add reaction" }));
    await user.click(screen.getByRole("button", { name: "Laughing" }));
    expect(onSelect).toHaveBeenCalledWith("laughWithTears");
  });

  it("treats every reaction as someone else's when nobody is signed in", async () => {
    const user = userEvent.setup();
    setup([vote("hundred", ME)], { signedIn: false });
    await user.click(screen.getByRole("button", { name: "Add reaction" }));
    expect(screen.getByRole("button", { name: "100" })).toHaveAttribute("aria-pressed", "false");
  });

  it("closes the picker with Escape without choosing anything", async () => {
    const user = userEvent.setup();
    const { onSelect } = setup();
    await user.click(screen.getByRole("button", { name: "Add reaction" }));
    expect(screen.getByRole("button", { name: "Thumbs up" })).toBeInTheDocument();

    await user.keyboard("{Escape}");
    await waitFor(() => expect(screen.queryByRole("button", { name: "Thumbs up" })).not.toBeInTheDocument());
    expect(onSelect).not.toHaveBeenCalled();
  });
});
