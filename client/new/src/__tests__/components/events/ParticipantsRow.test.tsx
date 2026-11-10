// @vitest-environment jsdom
import { screen, waitFor } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import type { ParticipantWithUser } from "@/api/api";
import { me, user } from "@/__tests__/support/fixtures";
import { renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { ParticipantsRow } from "@/components/events/ParticipantsRow";

/** Participants `u1`, `u2`, ... in the given order. */
const people = (...names: string[]): ParticipantWithUser[] =>
  names.map((name, i) => ({
    user: user({ id: `u${i + 1}`, displayName: name }),
    participant: { userId: `u${i + 1}`, eventId: "e1", status: "active", isPresent: false },
  }));

/** The event was created by `u2`; the signed-in user is `meId` (default: a bystander). */
function renderRow(
  participants: ParticipantWithUser[],
  { meId = "bystander", ...props }: { meId?: string; iconSize?: number; maxAvatars?: number } = {},
) {
  return renderWithProviders(<ParticipantsRow event={{ id: "e1", creatorId: "u2" }} {...props} />, {
    api: {
      me: { get: async () => me({ user: user({ id: meId }) }) },
      events: { listParticipants: async () => participants },
    },
  });
}

/** Avatars carry the person's name as their title. */
const avatarNames = () => screen.getAllByTitle(/.+/).map((el) => el.getAttribute("title"));

describe("ParticipantsRow", () => {
  it("renders nothing when the event has no participants", async () => {
    const { container, api } = renderRow([]);
    await waitFor(() => expect(api.events.listParticipants).toHaveBeenCalledWith("e1"));
    expect(container).toBeEmptyDOMElement();
  });

  it("names the participant when there is just one, and it is not you", async () => {
    renderRow(people("Grace"));
    expect(await screen.findByText("Grace")).toBeInTheDocument();
    expect(avatarNames()).toEqual(["Grace"]);
  });

  it("reads 'You' when you are the only participant", async () => {
    renderRow(people("Ada"), { meId: "u1" });
    expect(await screen.findByText("You")).toBeInTheDocument();
  });

  it("reads 'You + N' when others joined too", async () => {
    renderRow(people("Ada", "Grace", "Alan"), { meId: "u1" });
    expect(await screen.findByText("You + 2")).toBeInTheDocument();
  });

  it("reads 'N People' for several participants when you are not one of them", async () => {
    renderRow(people("Ada", "Grace", "Alan"));
    expect(await screen.findByText("3 People")).toBeInTheDocument();
    expect(avatarNames()).toHaveLength(3);
  });

  it("caps the avatars and counts the rest as '+N'", async () => {
    renderRow(people("Ada", "Grace", "Alan", "Edsger", "Barbara"), { maxAvatars: 3 });
    expect(await screen.findByText("+2")).toBeInTheDocument();
    expect(avatarNames()).toHaveLength(3);
  });

  it("keeps you and the event's creator among the avatars when some are cut", async () => {
    // You are Ada (u1) and the creator is Grace (u2): with room for two, they are the two shown.
    renderRow(people("Ada", "Grace", "Alan", "Edsger", "Barbara"), { meId: "u1", maxAvatars: 2 });
    expect(await screen.findByText("You + 4")).toBeInTheDocument();
    expect(avatarNames()).toEqual(["Grace", "Ada"]);
  });
});
