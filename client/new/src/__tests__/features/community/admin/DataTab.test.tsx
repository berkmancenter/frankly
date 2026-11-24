// @vitest-environment jsdom
import { screen, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it } from "vitest";
import type { Event, Participant } from "@/api/types";
import { event } from "@/__tests__/support/fixtures";
import { renderInCommunity } from "@/__tests__/support/renderWithProviders";
import { DataTab } from "@/features/community/admin/DataTab";

const future = "2099-01-01T18:00:00.000Z";
const past = "2020-01-01T18:00:00.000Z";

const going = (eventId: string, count: number) =>
  Array.from({ length: count }, (_, i) => ({
    participant: { userId: `u${i}`, eventId, status: "active", isPresent: false } satisfies Participant,
    user: { id: `u${i}`, displayName: `Person ${i}` },
  }));

function setup(events: Event[], registered: Record<string, number> = {}, api: object = {}) {
  return renderInCommunity(<DataTab />, {
    status: "admin",
    api: {
      events: {
        listAll: async () => events,
        listParticipants: async (id: string) => going(id, registered[id] ?? 0),
        recordingSessions: async () => [],
        ...api,
      },
    },
  });
}

const rows = () => screen.getAllByRole("link").map((link) => link.textContent);

describe("DataTab", () => {
  it("shows the empty page when the community has no events", async () => {
    setup([]);
    expect(await screen.findByText("No events")).toBeInTheDocument();
  });

  it("explains when the events cannot be loaded", async () => {
    setup([], {}, {
      listAll: async () => {
        throw new Error("offline");
      },
    });
    expect(await screen.findByRole("alert")).toHaveTextContent("Something went wrong loading events.");
  });

  it("describes each event: when, how many registered, who can see it, and how it runs", async () => {
    setup(
      [
        event({ id: "a", title: "Open house", scheduledTime: future, isPublic: true, eventType: "hosted" }),
        event({ id: "b", title: "Private salon", scheduledTime: future, isPublic: false, eventType: "hostless" }),
        event({ id: "c", title: "Big stream", scheduledTime: future, isPublic: true, eventType: "livestream" }),
        event({ id: "d", scheduledTime: future, title: undefined }),
      ],
      { a: 3 },
    );
    const open = (await screen.findByText("Open house")).closest("a")!;
    expect(within(open).getByText("3 Registered")).toBeInTheDocument();
    expect(within(open).getByText("Public")).toBeInTheDocument();
    expect(within(open).getByText("Hosted")).toBeInTheDocument();
    expect(within(open).getByText(/Jan 1 2099, \d+:00(AM|PM)/)).toBeInTheDocument();
    const salon = screen.getByText("Private salon").closest("a")!;
    expect(within(salon).getByText("Private")).toBeInTheDocument();
    expect(within(salon).getByText("Hostless")).toBeInTheDocument();
    expect(within(screen.getByText("Big stream").closest("a")!).getByText("Livestream")).toBeInTheDocument();
    expect(screen.getByText("NO TITLE")).toBeInTheDocument();
  });

  it("links each event to its page", async () => {
    setup([event({ id: "e9", templateId: "t7", title: "Open house", scheduledTime: future })]);
    expect((await screen.findByText("Open house")).closest("a")).toHaveAttribute(
      "href",
      "/space/civic-lab/discuss/t7/e9",
    );
  });

  it("offers a download for events that are over or have people signed up, not for empty future ones", async () => {
    setup(
      [
        event({ id: "over", title: "Over", scheduledTime: past }),
        event({ id: "popular", title: "Popular", scheduledTime: future }),
        event({ id: "empty", title: "Empty", scheduledTime: future }),
      ],
      { popular: 2 },
    );
    await screen.findByText("Over");
    await screen.findByText("2 Registered");
    expect(screen.getAllByRole("button", { name: "Data Download" })).toHaveLength(2);
  });

  it("opens the data dialog for the event", async () => {
    setup([event({ id: "popular", title: "Popular", scheduledTime: future })], { popular: 2 });
    await userEvent.click(await screen.findByRole("button", { name: "Data Download" }));
    expect(await screen.findByRole("dialog", { name: "Select Data" })).toBeInTheDocument();
    await userEvent.click(screen.getByRole("button", { name: "Cancel" }));
    expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
  });

  it("pages through the events five at a time", async () => {
    const many = Array.from({ length: 7 }, (_, i) => event({ id: `e${i}`, title: `Event ${i}`, scheduledTime: future }));
    setup(many);
    await screen.findByText("Event 0");
    expect(screen.getByText("7 Events")).toBeInTheDocument();
    expect(screen.getByText("1 - 5 of 7")).toBeInTheDocument();
    expect(rows()).toHaveLength(5);
    expect(screen.getByRole("button", { name: "Previous page" })).toBeDisabled();

    await userEvent.click(screen.getByRole("button", { name: "Next page" }));
    expect(screen.getByText("6 - 7 of 7")).toBeInTheDocument();
    expect(screen.getByText("Event 5")).toBeInTheDocument();
    expect(screen.queryByText("Event 0")).not.toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Next page" })).toBeDisabled();

    await userEvent.click(screen.getByRole("button", { name: "Previous page" }));
    expect(screen.getByText("Event 0")).toBeInTheDocument();
  });
});
