// @vitest-environment jsdom
import { screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import { community, event } from "@/__tests__/support/fixtures";
import { renderInCommunity } from "@/__tests__/support/renderWithProviders";
import { CommunityHome } from "@/features/community/CommunityHome";

const upcoming = (events = [event()]) => ({ events: { listUpcoming: async () => events, listAll: async () => events } });

describe("CommunityHome", () => {
  it("shows the community hero and its upcoming events", async () => {
    renderInCommunity(<CommunityHome />, {
      community: community({ name: "Civic Lab", tagLine: "Talk it through" }),
      api: upcoming(),
    });
    expect(await screen.findByRole("heading", { name: "Civic Lab" })).toBeInTheDocument();
    expect(screen.getByText("Talk it through")).toBeInTheDocument();
    expect(await screen.findByText("Weekly chat")).toBeInTheDocument();
  });

  it("offers the edit button only to people who can edit the community", async () => {
    const { unmount } = renderInCommunity(<CommunityHome />, { status: "owner", api: upcoming() });
    expect(await screen.findByRole("link", { name: "Edit community" })).toBeInTheDocument();
    unmount();

    renderInCommunity(<CommunityHome />, { status: "member", api: upcoming() });
    await screen.findByRole("heading", { name: "Civic Lab" });
    expect(screen.queryByRole("link", { name: "Edit community" })).not.toBeInTheDocument();
  });

  it("shows an error when events fail to load", async () => {
    renderInCommunity(<CommunityHome />, {
      api: { events: { listUpcoming: async () => { throw new Error("boom"); }, listAll: async () => [] } },
    });
    expect(await screen.findByText("There was an error loading events.")).toBeInTheDocument();
  });
});
