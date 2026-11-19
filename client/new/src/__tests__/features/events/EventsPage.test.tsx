// @vitest-environment jsdom
import { act, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import type { ReactNode } from "react";
import { describe, expect, it, vi } from "vitest";
import type { Event, MembershipStatus } from "@/api/types";
import { event, template } from "@/__tests__/support/fixtures";
import { renderInCommunity } from "@/__tests__/support/renderWithProviders";
import { ClockContext } from "@/utils/clock";
import { EventsPage } from "@/features/events/EventsPage";

/** "Now" is 9am on Jan 1, 2030, local time, so every date below is independent of the machine's zone. */
const NOW = new Date(2030, 0, 1, 9, 0);
const clock = { now: () => new Date(NOW) };

/** An ISO timestamp for `hour`:00 local time on the given day (`month` is 1-based). */
const at = (year: number, month: number, day: number, hour = 18) =>
  new Date(year, month - 1, day, hour, 0).toISOString();

/** The accessible name of a date-strip button (`Date#toDateString`). */
const dayLabel = (year: number, month: number, day: number) => new Date(year, month - 1, day).toDateString();

const weekly = event({ id: "e1", title: "Weekly chat", scheduledTime: at(2030, 1, 3) });
const potluck = event({ id: "e2", title: "Potluck planning", scheduledTime: at(2030, 1, 10) });
const lateNight = event({ id: "e3", title: "Late night debate", scheduledTime: at(2030, 1, 3, 22) });

interface PageOptions {
  events?: Event[] | Promise<Event[]>;
  status?: MembershipStatus;
  /** Active templates in the community (a member needs one to create events). */
  withTemplate?: boolean;
  mobile?: boolean;
  listUpcoming?: () => Promise<Event[]>;
}

function renderPage({ events = [weekly, potluck], status = "member", withTemplate = true, mobile, listUpcoming }: PageOptions = {}) {
  const list = listUpcoming ?? vi.fn(async () => events);
  const wrap = (ui: ReactNode) => <ClockContext.Provider value={clock}>{ui}</ClockContext.Provider>;
  return {
    ...renderInCommunity(wrap(<EventsPage />), {
      status,
      mobile,
      api: {
        events: { listUpcoming: list, listParticipants: async () => [] },
        templates: { list: async () => (withTemplate ? [template()] : []) },
      },
    }),
    listUpcoming: list,
  };
}

/** The scope shows its own spinner first; the page is up once its search box is. */
const pageReady = () => screen.findByRole("textbox", { name: "Search events" });

const cardTitles = () => screen.queryAllByRole("link").map((l) => l.textContent ?? "");

describe("EventsPage", () => {
  describe("loading, error and empty states", () => {
    it("shows a spinner while the events load, then the events", async () => {
      let resolve!: (e: Event[]) => void;
      renderPage({ listUpcoming: () => new Promise<Event[]>((r) => (resolve = r)) });
      await pageReady();
      expect(screen.getByRole("progressbar")).toBeInTheDocument();
      expect(screen.queryByRole("link")).not.toBeInTheDocument();

      await act(async () => resolve([weekly]));
      expect(await screen.findByRole("link", { name: /Weekly chat/ })).toBeInTheDocument();
      expect(screen.queryByRole("progressbar")).not.toBeInTheDocument();
    });

    it("shows an error when the events fail to load", async () => {
      renderPage({
        listUpcoming: async () => {
          throw new Error("boom");
        },
      });
      expect(await screen.findByText("Something went wrong loading events.")).toBeInTheDocument();
      expect(screen.queryByRole("link")).not.toBeInTheDocument();
    });

    it("shows the empty state when there are no upcoming events", async () => {
      renderPage({ events: [] });
      expect(await screen.findByRole("heading", { name: "No events" })).toBeInTheDocument();
      expect(screen.getByText("When new events are added, you'll see them here.")).toBeInTheDocument();
    });

    it("loads the events of the current community", async () => {
      const { listUpcoming } = renderPage();
      await screen.findByRole("link", { name: /Weekly chat/ });
      expect(listUpcoming).toHaveBeenCalledWith("c1");
    });
  });

  describe("event list", () => {
    it("lists every upcoming event as a link to its page", async () => {
      renderPage();
      const weeklyLink = await screen.findByRole("link", { name: /Weekly chat/ });
      expect(weeklyLink).toHaveAttribute("href", "/space/civic-lab/discuss/t1/e1");
      expect(screen.getByRole("link", { name: /Potluck planning/ })).toHaveAttribute(
        "href",
        "/space/civic-lab/discuss/t1/e2",
      );
    });

    it("shows a placeholder title for an event without one", async () => {
      renderPage({ events: [event({ id: "e9", title: undefined, scheduledTime: at(2030, 1, 4) })] });
      expect(await screen.findByRole("link", { name: /Scheduled event/ })).toBeInTheDocument();
    });

    it("shows at most 100 events", async () => {
      const many = Array.from({ length: 105 }, (_, i) =>
        event({ id: `e${i}`, title: `Event ${i}`, scheduledTime: at(2030, 1, 5) }),
      );
      renderPage({ events: many });
      await screen.findByRole("link", { name: /Event 0$/ });
      expect(screen.getAllByRole("link")).toHaveLength(100);
      expect(screen.queryByRole("link", { name: /Event 104$/ })).not.toBeInTheDocument();
    }, 20_000);

    it("works at phone width", async () => {
      renderPage({ mobile: true });
      expect(await screen.findByRole("link", { name: /Weekly chat/ })).toBeInTheDocument();
      expect(screen.getByRole("textbox", { name: "Search events" })).toBeInTheDocument();
    });
  });

  describe("search", () => {
    it("filters events by title, ignoring case", async () => {
      const user = userEvent.setup();
      renderPage();
      await screen.findByRole("link", { name: /Weekly chat/ });

      await user.type(screen.getByRole("textbox", { name: "Search events" }), "POTLUCK");

      expect(screen.getByRole("link", { name: /Potluck planning/ })).toBeInTheDocument();
      expect(screen.queryByRole("link", { name: /Weekly chat/ })).not.toBeInTheDocument();
    });

    it("matches part of a title", async () => {
      const user = userEvent.setup();
      renderPage();
      await screen.findByRole("link", { name: /Weekly chat/ });

      await user.type(screen.getByRole("textbox", { name: "Search events" }), "ly ch");

      expect(screen.getAllByRole("link")).toHaveLength(1);
      expect(screen.getByRole("link", { name: /Weekly chat/ })).toBeInTheDocument();
    });

    it("shows the empty state when nothing matches, and the events again once cleared", async () => {
      const user = userEvent.setup();
      renderPage();
      await screen.findByRole("link", { name: /Weekly chat/ });
      const box = screen.getByRole("textbox", { name: "Search events" });

      await user.type(box, "zzz");
      expect(screen.getByRole("heading", { name: "No events" })).toBeInTheDocument();
      expect(screen.queryByRole("link")).not.toBeInTheDocument();

      await user.clear(box);
      expect(screen.getAllByRole("link")).toHaveLength(2);
    });

    it("never matches an event with no title unless the search is empty", async () => {
      const user = userEvent.setup();
      renderPage({ events: [event({ id: "e9", title: undefined, scheduledTime: at(2030, 1, 4) })] });
      await screen.findByRole("link", { name: /Scheduled event/ });

      await user.type(screen.getByRole("textbox", { name: "Search events" }), "scheduled");

      expect(screen.queryByRole("link")).not.toBeInTheDocument();
    });
  });

  describe("date strip", () => {
    const stripButtons = () => screen.getAllByRole("button", { name: /^[A-Z][a-z]{2} [A-Z][a-z]{2} \d{2} \d{4}$/ });

    it("covers today and the next 90 days", async () => {
      renderPage();
      await screen.findByRole("link", { name: /Weekly chat/ });

      const buttons = stripButtons();
      expect(buttons).toHaveLength(91);
      expect(buttons[0]).toHaveAccessibleName(dayLabel(2030, 1, 1));
      expect(buttons[90]).toHaveAccessibleName(dayLabel(2030, 4, 1));
    });

    it("enables only the days that have an event", async () => {
      renderPage();
      await screen.findByRole("link", { name: /Weekly chat/ });

      expect(screen.getByRole("button", { name: dayLabel(2030, 1, 3) })).toBeEnabled();
      expect(screen.getByRole("button", { name: dayLabel(2030, 1, 10) })).toBeEnabled();
      expect(screen.getByRole("button", { name: dayLabel(2030, 1, 4) })).toBeDisabled();
      expect(stripButtons().filter((b) => !(b as HTMLButtonElement).disabled)).toHaveLength(2);
    });

    it("disables every day while there are no events", async () => {
      renderPage({ events: [] });
      await screen.findByRole("heading", { name: "No events" });
      expect(stripButtons().every((b) => (b as HTMLButtonElement).disabled)).toBe(true);
    });

    it("filters the list to one day and back", async () => {
      const user = userEvent.setup();
      renderPage({ events: [weekly, potluck, lateNight] });
      await screen.findByRole("link", { name: /Weekly chat/ });
      const jan3 = screen.getByRole("button", { name: dayLabel(2030, 1, 3) });
      expect(jan3).toHaveAttribute("aria-pressed", "false");

      await user.click(jan3);
      expect(jan3).toHaveAttribute("aria-pressed", "true");
      expect(cardTitles().join("|")).toMatch(/Weekly chat/);
      expect(cardTitles().join("|")).toMatch(/Late night debate/);
      expect(screen.queryByRole("link", { name: /Potluck planning/ })).not.toBeInTheDocument();

      await user.click(jan3);
      expect(jan3).toHaveAttribute("aria-pressed", "false");
      expect(screen.getAllByRole("link")).toHaveLength(3);
    });

    it("switches from one selected day to another", async () => {
      const user = userEvent.setup();
      renderPage();
      await screen.findByRole("link", { name: /Weekly chat/ });

      await user.click(screen.getByRole("button", { name: dayLabel(2030, 1, 3) }));
      await user.click(screen.getByRole("button", { name: dayLabel(2030, 1, 10) }));

      expect(screen.getByRole("button", { name: dayLabel(2030, 1, 3) })).toHaveAttribute("aria-pressed", "false");
      expect(screen.getByRole("button", { name: dayLabel(2030, 1, 10) })).toHaveAttribute("aria-pressed", "true");
      expect(screen.getAllByRole("link")).toHaveLength(1);
      expect(screen.getByRole("link", { name: /Potluck planning/ })).toBeInTheDocument();
    });

    it("combines with the search", async () => {
      const user = userEvent.setup();
      renderPage({ events: [weekly, potluck, lateNight] });
      await screen.findByRole("link", { name: /Weekly chat/ });

      await user.click(screen.getByRole("button", { name: dayLabel(2030, 1, 3) }));
      await user.type(screen.getByRole("textbox", { name: "Search events" }), "late");

      expect(screen.getAllByRole("link")).toHaveLength(1);
      expect(screen.getByRole("link", { name: /Late night debate/ })).toBeInTheDocument();

      await user.clear(screen.getByRole("textbox", { name: "Search events" }));
      await user.type(screen.getByRole("textbox", { name: "Search events" }), "potluck");
      // Potluck is on another day than the selected one.
      expect(screen.getByRole("heading", { name: "No events" })).toBeInTheDocument();
    });

    it("lists events past the strip but gives them no day button", async () => {
      const far = event({ id: "far", title: "Next season kickoff", scheduledTime: at(2030, 4, 15) });
      renderPage({ events: [weekly, far] });

      expect(await screen.findByRole("link", { name: /Next season kickoff/ })).toBeInTheDocument();
      expect(screen.queryByRole("button", { name: dayLabel(2030, 4, 15) })).not.toBeInTheDocument();
    });

    it("leaves unscheduled events out of every day but still lists them", async () => {
      const user = userEvent.setup();
      renderPage({
        events: [weekly, event({ id: "tbd", title: "Date to be decided", scheduledTime: undefined })],
      });
      expect(await screen.findByRole("link", { name: /Date to be decided/ })).toBeInTheDocument();
      expect(stripButtons().filter((b) => !(b as HTMLButtonElement).disabled)).toHaveLength(1);

      await user.click(screen.getByRole("button", { name: dayLabel(2030, 1, 3) }));

      expect(screen.queryByRole("link", { name: /Date to be decided/ })).not.toBeInTheDocument();
    });
  });

  describe("creating an event", () => {
    it("offers 'Create an event' in the empty state to someone who can create events", async () => {
      renderPage({ events: [], status: "member" });
      expect(await screen.findByRole("button", { name: "Create an event" })).toBeInTheDocument();
    });

    it("opens the create-event dialog from the empty state", async () => {
      const user = userEvent.setup();
      renderPage({ events: [], status: "member" });

      await user.click(await screen.findByRole("button", { name: "Create an event" }));

      expect(await screen.findByRole("heading", { name: "Choose Template" })).toBeInTheDocument();
    });

    it("closes the dialog again and keeps the page", async () => {
      const user = userEvent.setup();
      renderPage({ events: [], status: "member" });
      await user.click(await screen.findByRole("button", { name: "Create an event" }));
      await screen.findByRole("heading", { name: "Choose Template" });

      await user.click(screen.getByRole("button", { name: "Close" }));

      await waitFor(() => expect(screen.queryByRole("heading", { name: "Choose Template" })).not.toBeInTheDocument());
      expect(screen.getByRole("heading", { name: "No events" })).toBeInTheDocument();
    });

    it("shows no button to someone who cannot create events", async () => {
      renderPage({ events: [], status: "banned" });
      await screen.findByRole("heading", { name: "No events" });
      expect(screen.queryByRole("button", { name: "Create an event" })).not.toBeInTheDocument();
    });

    it("shows no button to a member when the community has no templates yet", async () => {
      renderPage({ events: [], status: "member", withTemplate: false });
      await screen.findByRole("heading", { name: "No events" });
      expect(screen.queryByRole("button", { name: "Create an event" })).not.toBeInTheDocument();
    });

    it("lets a moderator create the first event even without templates", async () => {
      renderPage({ events: [], status: "moderator", withTemplate: false });
      expect(await screen.findByRole("button", { name: "Create an event" })).toBeInTheDocument();
    });

    it("also offers the button when a search matches nothing", async () => {
      const user = userEvent.setup();
      renderPage({ status: "member" });
      await screen.findByRole("link", { name: /Weekly chat/ });

      await user.type(screen.getByRole("textbox", { name: "Search events" }), "zzz");

      expect(screen.getByRole("button", { name: "Create an event" })).toBeInTheDocument();
    });
  });
});
