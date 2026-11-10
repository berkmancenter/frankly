// @vitest-environment jsdom
import { fireEvent, screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useLocation } from "react-router";
import { describe, expect, it, vi } from "vitest";
import type { Event, MembershipStatus, NewEventInput, Template } from "@/api/types";
import { community, event, template } from "@/__tests__/support/fixtures";
import { renderInCommunity } from "@/__tests__/support/renderWithProviders";
import { ClockContext } from "@/utils/clock";
import { useUpcomingEvents } from "@/queries/events";
import { useCommunityScope } from "@/scopes/CommunityScope";
import { useCreateEventDialog } from "@/features/events/CreateEventDialog";

type User = ReturnType<typeof userEvent.setup>;

/** "Now" is 9am on Tue Jan 15, 2030, local time, so calendar dates do not depend on the machine's zone. */
const NOW = new Date(2030, 0, 15, 9, 0);
const clock = { now: () => new Date(NOW) };

const dayLabel = (day: number) => new Date(2030, 0, day).toDateString();

const checkIn = template({ id: "t1", title: "Check-in", category: "Social" });
const debate = template({ id: "t2", title: "Town hall debate", category: "Civic" });
const retired = template({ id: "t3", title: "Retired format", status: "removed" });

/** Whatever component starts the flow owns the dialog; this one also shows the URL and the upcoming list. */
function Launcher() {
  const createEvent = useCreateEventDialog();
  const { pathname } = useLocation();
  const { community: c } = useCommunityScope();
  const upcoming = useUpcomingEvents(c.id);
  return (
    <ClockContext.Provider value={clock}>
      <button onClick={createEvent.open}>Open dialog</button>
      <p data-testid="location">{pathname}</p>
      <ul>
        {upcoming.data?.map((e) => (
          <li key={e.id}>{e.title}</li>
        ))}
      </ul>
      {createEvent.dialog}
    </ClockContext.Provider>
  );
}

interface SetupOptions {
  templates?: Template[];
  status?: MembershipStatus;
  mobile?: boolean;
  create?: (input: NewEventInput) => Promise<Event>;
}

function setup({ templates = [checkIn, debate], status = "member", mobile, create }: SetupOptions = {}) {
  const user = userEvent.setup();
  const created = vi.fn(
    create ??
      (async (input: NewEventInput) =>
        event({
          id: "new-event",
          title: "New event",
          communityId: input.communityId,
          templateId: input.templateId,
          scheduledTime: input.scheduledTime,
        })),
  );
  const listUpcoming = vi.fn(async () => [event({ id: "old", title: "Existing event" })]);
  const result = renderInCommunity(<Launcher />, {
    status,
    mobile,
    community: community({ id: "c1", displayId: "civic-lab" }),
    api: {
      templates: { list: async () => templates },
      events: { create: created, listUpcoming, listParticipants: async () => [] },
    },
  });
  return { ...result, user, create: created, listUpcoming };
}

const open = async (user: User) => {
  await user.click(await screen.findByRole("button", { name: "Open dialog" }));
  await screen.findByRole("heading", { name: "Choose Template" });
};
const next = (user: User) => user.click(screen.getByRole("button", { name: "Next" }));
const back = (user: User) => user.click(screen.getByRole("button", { name: "Back" }));
const chooseTemplate = (user: User, title: string) => user.click(screen.getByRole("button", { name: title }));
const chooseDay = (user: User, day: number) => user.click(screen.getByRole("button", { name: dayLabel(day) }));
const pathname = () => screen.getByTestId("location").textContent;

/** Opens the dialog and walks to the final "Select a time" step with a template and a day chosen. */
async function toTimeStep(user: User, { templateTitle = "Check-in", day = 16 } = {}) {
  await open(user);
  await chooseTemplate(user, templateTitle);
  await next(user);
  await next(user); // keep the default visibility
  await chooseDay(user, day);
  await next(user);
  await screen.findByRole("heading", { name: "Select a time" });
}

describe("CreateEventDialog", () => {
  describe("opening and closing", () => {
    it("is not shown until the launcher opens it", async () => {
      setup();
      await screen.findByRole("button", { name: "Open dialog" });
      expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
    });

    it("opens on the template step without a step counter", async () => {
      const { user } = setup();
      await open(user);
      expect(screen.getByRole("dialog")).toBeInTheDocument();
      expect(screen.queryByText(/STEP \d OF 4/)).not.toBeInTheDocument();
      expect(screen.queryByRole("button", { name: "Back" })).not.toBeInTheDocument();
    });

    it("closes from the close button", async () => {
      const { user } = setup();
      await open(user);
      await user.click(screen.getByRole("button", { name: "Close" }));
      expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
    });

    it("closes with Escape", async () => {
      const { user } = setup();
      await open(user);
      await user.keyboard("{Escape}");
      expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
    });

    it("starts over each time it is reopened", async () => {
      const { user } = setup();
      await open(user);
      await chooseTemplate(user, "Check-in");
      await next(user);
      expect(screen.getByRole("heading", { name: "Public or private?" })).toBeInTheDocument();
      await user.click(screen.getByRole("button", { name: "Close" }));

      await open(user);

      expect(screen.getByRole("heading", { name: "Choose Template" })).toBeInTheDocument();
      expect(screen.getByRole("button", { name: "Check-in" })).toHaveAttribute("aria-pressed", "false");
      expect(screen.getByRole("button", { name: "Next" })).toBeDisabled();
    });

    it("is full screen on a phone and a card on desktop", async () => {
      const mobile = setup({ mobile: true });
      await open(mobile.user);
      expect(screen.getByRole("dialog").className).toContain("paperFullScreen");
      mobile.unmount();

      const desktop = setup();
      await open(desktop.user);
      expect(screen.getByRole("dialog").className).not.toContain("paperFullScreen");
    });
  });

  describe("step 1: choose a template", () => {
    it("lists the community's active templates only", async () => {
      const { user } = setup({ templates: [checkIn, debate, retired] });
      await open(user);
      expect(screen.getByRole("button", { name: "Check-in" })).toBeInTheDocument();
      expect(screen.getByRole("button", { name: "Town hall debate" })).toBeInTheDocument();
      expect(screen.queryByRole("button", { name: "Retired format" })).not.toBeInTheDocument();
    });

    it("cannot continue until a template is chosen", async () => {
      const { user } = setup();
      await open(user);
      expect(screen.getByRole("button", { name: "Next" })).toBeDisabled();

      await chooseTemplate(user, "Check-in");

      expect(screen.getByRole("button", { name: "Next" })).toBeEnabled();
    });

    it("marks only the chosen template as selected, and switches on a second choice", async () => {
      const { user } = setup();
      await open(user);

      await chooseTemplate(user, "Check-in");
      expect(screen.getByRole("button", { name: "Check-in" })).toHaveAttribute("aria-pressed", "true");
      expect(screen.getByRole("button", { name: "Town hall debate" })).toHaveAttribute("aria-pressed", "false");

      await chooseTemplate(user, "Town hall debate");
      expect(screen.getByRole("button", { name: "Check-in" })).toHaveAttribute("aria-pressed", "false");
      expect(screen.getByRole("button", { name: "Town hall debate" })).toHaveAttribute("aria-pressed", "true");
    });

    it("filters templates by the search box, ignoring case", async () => {
      const { user } = setup();
      await open(user);

      await user.type(screen.getByRole("textbox", { name: "Search templates" }), "TOWN");

      expect(screen.getByRole("button", { name: "Town hall debate" })).toBeInTheDocument();
      expect(screen.queryByRole("button", { name: "Check-in" })).not.toBeInTheDocument();
    });

    it("filters by category chips and clears the filter on a second click", async () => {
      const { user } = setup();
      await open(user);

      await user.click(screen.getByRole("button", { name: "Civic" }));
      expect(screen.getByRole("button", { name: "Town hall debate" })).toBeInTheDocument();
      expect(screen.queryByRole("button", { name: "Check-in" })).not.toBeInTheDocument();

      await user.click(screen.getByRole("button", { name: "Civic" }));
      expect(screen.getByRole("button", { name: "Check-in" })).toBeInTheDocument();
      expect(screen.getByRole("button", { name: "Town hall debate" })).toBeInTheDocument();
    });

    it("shows no category chips when no template has a category", async () => {
      const { user } = setup({ templates: [template({ id: "t9", title: "Plain" })] });
      await open(user);
      expect(screen.getByRole("button", { name: "Plain" })).toBeInTheDocument();
      // Behind the modal dialog, the only buttons are close, the template tile and (disabled) next.
      expect(screen.getAllByRole("button")).toHaveLength(3);
    });

    it("says so when no template matches, for someone who cannot create templates", async () => {
      const { user } = setup({ status: "member" });
      await open(user);

      await user.type(screen.getByRole("textbox", { name: "Search templates" }), "zzz");

      expect(screen.getByText("No templates found.")).toBeInTheDocument();
    });

    it("keeps the chosen template when a later search hides it", async () => {
      const { user } = setup();
      await open(user);
      await chooseTemplate(user, "Check-in");
      await user.type(screen.getByRole("textbox", { name: "Search templates" }), "town");

      expect(screen.queryByRole("button", { name: "Check-in" })).not.toBeInTheDocument();
      expect(screen.getByRole("button", { name: "Next" })).toBeEnabled();
    });

    it("lets a moderator start creating a new template, which hands off to the templates page", async () => {
      const { user } = setup({ status: "moderator" });
      await open(user);

      await user.click(screen.getByRole("button", { name: "Create a new template" }));

      expect(pathname()).toBe("/space/civic-lab/discuss");
    });

    it("does not offer new-template creation to a plain member", async () => {
      const { user } = setup({ status: "member" });
      await open(user);
      expect(screen.queryByRole("button", { name: "Create a new template" })).not.toBeInTheDocument();
    });

    it("does not say 'No templates found' next to the create tile when the user can create templates", async () => {
      const { user } = setup({ status: "owner", templates: [] });
      await open(user);
      expect(screen.getByRole("button", { name: "Create a new template" })).toBeInTheDocument();
      expect(screen.queryByText("No templates found.")).not.toBeInTheDocument();
    });
  });

  describe("step 2: public or private", () => {
    it("shows the step counter, defaults to private, and lets the host switch", async () => {
      const { user } = setup();
      await open(user);
      await chooseTemplate(user, "Check-in");
      await next(user);

      expect(screen.getByRole("heading", { name: "Public or private?" })).toBeInTheDocument();
      expect(screen.getByText("STEP 2 OF 4")).toBeInTheDocument();
      const privateOption = screen.getByRole("radio", { name: "I'll share this with a private group" });
      const publicOption = screen.getByRole("radio", { name: "Allow the community to join" });
      expect(privateOption).toBeChecked();
      expect(publicOption).not.toBeChecked();

      await user.click(publicOption);
      expect(publicOption).toBeChecked();
      expect(privateOption).not.toBeChecked();
    });

    it("can always continue", async () => {
      const { user } = setup();
      await open(user);
      await chooseTemplate(user, "Check-in");
      await next(user);
      expect(screen.getByRole("button", { name: "Next" })).toBeEnabled();
    });
  });

  describe("step 3: select a day", () => {
    const toDayStep = async (user: User) => {
      await open(user);
      await chooseTemplate(user, "Check-in");
      await next(user);
      await next(user);
      await screen.findByRole("heading", { name: "Select a day" });
    };

    it("cannot continue until a day is chosen", async () => {
      const { user } = setup();
      await toDayStep(user);
      expect(screen.getByText("STEP 3 OF 4")).toBeInTheDocument();
      expect(screen.getByRole("button", { name: "Next" })).toBeDisabled();

      await chooseDay(user, 20);

      expect(screen.getByRole("button", { name: dayLabel(20) })).toHaveAttribute("aria-pressed", "true");
      expect(screen.getByRole("button", { name: "Next" })).toBeEnabled();
    });

    it("shows the current month and does not allow days in the past", async () => {
      const { user } = setup();
      await toDayStep(user);

      expect(screen.getByText("January 2030")).toBeInTheDocument();
      expect(screen.getByRole("button", { name: dayLabel(14) })).toBeDisabled();
      expect(screen.getByRole("button", { name: dayLabel(15) })).toBeEnabled(); // today
      expect(screen.getByRole("button", { name: "Previous month" })).toBeDisabled();
    });

    it("lets the host page forward to a later month and pick a day there", async () => {
      const { user } = setup();
      await toDayStep(user);

      await user.click(screen.getByRole("button", { name: "Next month" }));
      expect(screen.getByText("February 2030")).toBeInTheDocument();
      await user.click(screen.getByRole("button", { name: new Date(2030, 1, 5).toDateString() }));

      expect(screen.getByRole("button", { name: "Next" })).toBeEnabled();
    });
  });

  describe("step 4: select a time", () => {
    it("starts at 6:00 PM, shows the time zone and offers 'Create Event'", async () => {
      const { user } = setup();
      await toTimeStep(user);

      expect(screen.getByText("STEP 4 OF 4")).toBeInTheDocument();
      expect(screen.getByRole("textbox", { name: "Hour" })).toHaveValue("06");
      expect(screen.getByRole("textbox", { name: "Minute" })).toHaveValue("00");
      expect(screen.getByRole("button", { name: "PM" })).toHaveAttribute("aria-pressed", "true");
      expect(screen.getByText(/^Time shown in /)).toBeInTheDocument();
      expect(screen.getByRole("button", { name: "Create Event" })).toBeEnabled();
      expect(screen.queryByRole("button", { name: "Next" })).not.toBeInTheDocument();
    });

    it("rejects a time that has already passed today", async () => {
      const { user } = setup();
      await toTimeStep(user, { day: 15 }); // today; it is 9:00 AM

      await user.click(screen.getByRole("button", { name: "AM" })); // 6:00 AM
      expect(screen.getByText("Please choose a time in the future.")).toBeInTheDocument();
      expect(screen.getByRole("button", { name: "Create Event" })).toBeDisabled();

      await user.click(screen.getByRole("button", { name: "PM" }));
      expect(screen.queryByText("Please choose a time in the future.")).not.toBeInTheDocument();
      expect(screen.getByRole("button", { name: "Create Event" })).toBeEnabled();
    });

    it("rejects a time equal to now, and accepts one a minute later", async () => {
      const { user } = setup();
      await toTimeStep(user, { day: 15 });
      await user.click(screen.getByRole("button", { name: "AM" }));
      fireEvent.change(screen.getByRole("textbox", { name: "Hour" }), { target: { value: "9" } });
      fireEvent.change(screen.getByRole("textbox", { name: "Minute" }), { target: { value: "0" } });
      // 9:00 AM is exactly now: not in the future.
      expect(screen.getByText("Please choose a time in the future.")).toBeInTheDocument();

      fireEvent.change(screen.getByRole("textbox", { name: "Minute" }), { target: { value: "1" } });
      expect(screen.queryByText("Please choose a time in the future.")).not.toBeInTheDocument();
      expect(screen.getByRole("button", { name: "Create Event" })).toBeEnabled();
    });

    it("clamps the hour to 1-12 and the minute to 0-59", async () => {
      const { user } = setup();
      await toTimeStep(user);

      fireEvent.change(screen.getByRole("textbox", { name: "Hour" }), { target: { value: "99" } });
      fireEvent.change(screen.getByRole("textbox", { name: "Minute" }), { target: { value: "75" } });

      expect(screen.getByRole("textbox", { name: "Hour" })).toHaveValue("12");
      expect(screen.getByRole("textbox", { name: "Minute" })).toHaveValue("59");
    });
  });

  describe("navigating between steps", () => {
    it("goes back through every step and remembers earlier choices", async () => {
      const { user } = setup();
      await toTimeStep(user, { templateTitle: "Town hall debate", day: 18 });

      await back(user);
      expect(screen.getByRole("heading", { name: "Select a day" })).toBeInTheDocument();
      expect(screen.getByRole("button", { name: dayLabel(18) })).toHaveAttribute("aria-pressed", "true");

      await back(user);
      expect(screen.getByRole("heading", { name: "Public or private?" })).toBeInTheDocument();

      await back(user);
      expect(screen.getByRole("heading", { name: "Choose Template" })).toBeInTheDocument();
      expect(screen.getByRole("button", { name: "Town hall debate" })).toHaveAttribute("aria-pressed", "true");
      expect(screen.queryByRole("button", { name: "Back" })).not.toBeInTheDocument();
    });

    it("keeps the chosen time when stepping back and forward", async () => {
      const { user } = setup();
      await toTimeStep(user);
      await user.click(screen.getByRole("button", { name: "AM" }));

      await back(user);
      await next(user);

      expect(screen.getByRole("button", { name: "AM" })).toHaveAttribute("aria-pressed", "true");
    });
  });

  describe("creating the event", () => {
    it("sends the choices to the api, then closes and opens the new event", async () => {
      const { user, create } = setup();
      await toTimeStep(user, { templateTitle: "Town hall debate", day: 16 });

      await user.click(screen.getByRole("button", { name: "Create Event" }));

      await waitFor(() => expect(create).toHaveBeenCalledTimes(1));
      expect(create).toHaveBeenCalledWith({
        communityId: "c1",
        templateId: "t2",
        scheduledTime: new Date(2030, 0, 16, 18, 0).toISOString(),
        durationInMinutes: 60,
        eventType: "hosted",
        isPublic: false,
      });
      await waitFor(() => expect(screen.queryByRole("dialog")).not.toBeInTheDocument());
      expect(pathname()).toBe("/space/civic-lab/discuss/t2/new-event");
    });

    it("creates a public event when the host allows the community to join", async () => {
      const { user, create } = setup();
      await open(user);
      await chooseTemplate(user, "Check-in");
      await next(user);
      await user.click(screen.getByRole("radio", { name: "Allow the community to join" }));
      await next(user);
      await chooseDay(user, 22);
      await next(user);

      await user.click(screen.getByRole("button", { name: "Create Event" }));

      await waitFor(() => expect(create).toHaveBeenCalled());
      expect(create.mock.calls[0]![0]).toMatchObject({ templateId: "t1", isPublic: true });
    });

    it("sends the time the host picked, converted to an ISO timestamp", async () => {
      const { user, create } = setup();
      await toTimeStep(user, { day: 17 });
      await user.click(screen.getByRole("button", { name: "AM" }));
      fireEvent.change(screen.getByRole("textbox", { name: "Hour" }), { target: { value: "7" } });
      fireEvent.change(screen.getByRole("textbox", { name: "Minute" }), { target: { value: "30" } });

      await user.click(screen.getByRole("button", { name: "Create Event" }));

      await waitFor(() => expect(create).toHaveBeenCalled());
      expect(create.mock.calls[0]![0].scheduledTime).toBe(new Date(2030, 0, 17, 7, 30).toISOString());
    });

    it.each([
      ["PM", 12],
      ["AM", 0],
    ])("treats 12 %s as hour %i of the day", async (meridiem, hour24) => {
      const { user, create } = setup();
      await toTimeStep(user, { day: 17 });
      fireEvent.change(screen.getByRole("textbox", { name: "Hour" }), { target: { value: "12" } });
      await user.click(screen.getByRole("button", { name: meridiem }));

      await user.click(screen.getByRole("button", { name: "Create Event" }));

      await waitFor(() => expect(create).toHaveBeenCalledTimes(1));
      expect(create.mock.calls[0]![0].scheduledTime).toBe(new Date(2030, 0, 17, hour24, 0).toISOString());
    });

    it("refreshes the community's upcoming events after creating", async () => {
      const { user, listUpcoming } = setup();
      expect(await screen.findByText("Existing event")).toBeInTheDocument();
      expect(listUpcoming).toHaveBeenCalledTimes(1);
      await toTimeStep(user);

      await user.click(screen.getByRole("button", { name: "Create Event" }));

      await waitFor(() => expect(listUpcoming).toHaveBeenCalledTimes(2));
    });

    it("shows an error toast and stays on the last step when creating fails, then lets the host retry", async () => {
      let attempts = 0;
      const { user, create } = setup({
        create: async (input) => {
          attempts += 1;
          if (attempts === 1) throw new Error("denied");
          return event({ id: "second-try", templateId: input.templateId });
        },
      });
      await toTimeStep(user);

      await user.click(screen.getByRole("button", { name: "Create Event" }));

      expect(await screen.findByText("Something went wrong creating the event. Please try again.")).toBeInTheDocument();
      expect(screen.getByRole("dialog")).toBeInTheDocument();
      expect(screen.getByRole("heading", { name: "Select a time" })).toBeInTheDocument();
      expect(pathname()).toBe("/");

      await waitFor(() => expect(screen.getByRole("button", { name: "Create Event" })).toBeEnabled());
      await user.click(screen.getByRole("button", { name: "Create Event" }));

      await waitFor(() => expect(pathname()).toBe("/space/civic-lab/discuss/t1/second-try"));
      expect(create).toHaveBeenCalledTimes(2);
    });

    it("does not call the api before the last step", async () => {
      const { user, create } = setup();
      await open(user);
      await chooseTemplate(user, "Check-in");
      await next(user);
      await next(user);
      await chooseDay(user, 16);
      await next(user);
      expect(create).not.toHaveBeenCalled();
    });

    it("disables the button with a spinner while the request is in flight", async () => {
      let resolve!: (e: Event) => void;
      const { user, create } = setup({ create: () => new Promise<Event>((r) => (resolve = r)) });
      await toTimeStep(user);

      await user.click(screen.getByRole("button", { name: "Create Event" }));

      await waitFor(() => expect(screen.getByRole("button", { name: "Create Event" })).toBeDisabled());
      expect(create).toHaveBeenCalledTimes(1);
      expect(within(screen.getByRole("dialog")).getByRole("progressbar")).toBeInTheDocument();
      resolve(event({ id: "new-event", templateId: "t1" }));
      await waitFor(() => expect(pathname()).toBe("/space/civic-lab/discuss/t1/new-event"));
    });
  });
});
