// @vitest-environment jsdom
import { screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useLocation } from "react-router";
import { describe, expect, it } from "vitest";
import type { MembershipStatus } from "@/api/types";
import { event, me, membership, user } from "@/__tests__/support/fixtures";
import { renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { EventCard } from "@/components/events/EventCards";

function Location() {
  const { pathname } = useLocation();
  return <div data-testid="location">{pathname}</div>;
}

// 6:00 PM local on 2030-01-01 (a Tuesday), for 60 minutes.
const scheduledTime = new Date(2030, 0, 1, 18, 0).toISOString();

interface Options {
  status?: MembershipStatus;
  attended?: boolean;
  participants?: string[];
  mobile?: boolean;
}

function renderCard(over: Parameters<typeof event>[0] = {}, { status, attended = false, participants = [], mobile }: Options = {}) {
  const e = event({ scheduledTime, ...over });
  return renderWithProviders(
    <>
      <EventCard event={e} />
      <Location />
    </>,
    {
      mobile,
      route: "/space/civic-lab/discuss/upcoming",
      api: {
        me: { get: async () => me({ memberships: status ? [membership({ communityId: e.communityId, status })] : [] }) },
        events: {
          hasAttendedTemplate: async () => attended,
          listParticipants: async () =>
            participants.map((name, i) => ({
              user: user({ id: `p${i}`, displayName: name }),
              participant: { userId: `p${i}`, eventId: e.id, status: "active" as const, isPresent: false },
            })),
        },
      },
    },
  );
}

describe("EventCard", () => {
  it("shows the title and when the event happens", () => {
    renderCard({ title: "Weekly chat" });
    expect(screen.getByText("Weekly chat")).toBeInTheDocument();
    expect(screen.getByText("JAN")).toBeInTheDocument();
    expect(screen.getByText("Tue")).toBeInTheDocument();
    expect(screen.getByText("6:00p - 7:00p")).toBeInTheDocument();
  });

  it("falls back to a generic title and omits the date block when unscheduled", () => {
    renderCard({ title: undefined, scheduledTime: undefined });
    expect(screen.getByText("Scheduled event")).toBeInTheDocument();
    expect(screen.queryByText("JAN")).not.toBeInTheDocument();
  });

  it("links to the event page and navigates there on click", async () => {
    const user = userEvent.setup();
    renderCard({ id: "e9", templateId: "t3", communityDisplayId: "civic-lab" });
    const link = screen.getByRole("link");
    expect(link).toHaveAttribute("href", "/space/civic-lab/discuss/t3/e9");
    await user.click(link);
    expect(screen.getByTestId("location")).toHaveTextContent("/space/civic-lab/discuss/t3/e9");
  });

  it("labels livestream events", () => {
    renderCard({ eventType: "livestream" });
    expect(screen.getByText("Livestream")).toBeInTheDocument();
  });

  it("does not label hosted events as livestreams", () => {
    renderCard({ eventType: "hosted" });
    expect(screen.queryByText("Livestream")).not.toBeInTheDocument();
  });

  it("shows who is attending", async () => {
    renderCard({}, { participants: ["Grace", "Alan"] });
    expect(await screen.findByText("2 People")).toBeInTheDocument();
  });

  it("shows fewer avatars on a phone-width screen", async () => {
    const eight = ["A", "B", "C", "D", "E", "F", "G", "H"];
    const desktop = renderCard({}, { participants: eight });
    expect(await screen.findByText("+2")).toBeInTheDocument();
    desktop.unmount();

    renderCard({}, { participants: eight, mobile: true });
    expect(await screen.findByText("+5")).toBeInTheDocument();
  });

  describe("with a prerequisite", () => {
    const prerequisite = { prerequisiteTemplateId: "t0" };

    it("is locked until the prerequisite has been attended", async () => {
      const user = userEvent.setup();
      renderCard(prerequisite, { status: "member", attended: false, participants: ["Grace"] });
      expect(await screen.findByText("Prerequisite Required")).toBeInTheDocument();
      expect(screen.queryByRole("link")).not.toBeInTheDocument();
      // The participants are hidden while locked.
      expect(screen.queryByText("Grace")).not.toBeInTheDocument();
      await user.click(screen.getByText("Weekly chat"));
      expect(screen.getByTestId("location")).toHaveTextContent("/space/civic-lab/discuss/upcoming");
    });

    it("opens normally once the prerequisite has been attended", async () => {
      renderCard(prerequisite, { status: "member", attended: true, participants: ["Grace"] });
      expect(await screen.findByText("Grace")).toBeInTheDocument();
      expect(screen.getByRole("link")).toBeInTheDocument();
      expect(screen.queryByText("Prerequisite Required")).not.toBeInTheDocument();
    });

    it("is never locked for admins", async () => {
      const { api } = renderCard(prerequisite, { status: "admin", attended: false, participants: ["Grace"] });
      await waitFor(() => expect(api.events.hasAttendedTemplate).toHaveBeenCalledWith("t0"));
      expect(await screen.findByRole("link")).toBeInTheDocument();
      expect(screen.queryByText("Prerequisite Required")).not.toBeInTheDocument();
    });
  });

  it("is not locked when there is no prerequisite", () => {
    const { api } = renderCard({ prerequisiteTemplateId: undefined });
    expect(screen.getByRole("link")).toBeInTheDocument();
    expect(api.events.hasAttendedTemplate).not.toHaveBeenCalled();
  });
});
