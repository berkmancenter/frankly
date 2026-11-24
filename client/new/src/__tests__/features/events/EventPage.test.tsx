// @vitest-environment jsdom
import { screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it, vi } from "vitest";
import type { Event, MembershipStatus, Participant } from "@/api/types";
import { community, event, template, user } from "@/__tests__/support/fixtures";
import { renderInCommunity } from "@/__tests__/support/renderWithProviders";
import { EventPage } from "@/features/events/EventPage";
import { enableDevEventSettings } from "@/utils/appInfo";

vi.mock("@/utils/appInfo", async (importOriginal) => ({
  ...(await importOriginal<typeof import("@/utils/appInfo")>()),
  enableDevEventSettings: vi.fn(() => false),
}));

const going = (userId: string, status: Participant["status"] = "active", isPresent = false) => ({
  participant: { userId, eventId: "e1", status, isPresent },
  user: user({ id: userId, displayName: `Person ${userId}` }),
});

function setup(
  over: Partial<Event> = {},
  {
    participants = [] as ReturnType<typeof going>[],
    status = "member" as MembershipStatus,
    events = {} as Record<string, unknown>,
    api = {} as Record<string, unknown>,
  } = {},
) {
  const current = event({ id: "e1", title: "Weekly chat", creatorId: "host", ...over });
  return renderInCommunity(<EventPage />, {
    status,
    route: "/space/civic-lab/discuss/t1/e1",
    path: "/space/:displayId/discuss/:templateId/:eventId",
    api: {
      events: {
        get: async () => current,
        listParticipants: async () => participants,
        listUpcoming: async () => [],
        listMessages: async () => [],
        join: vi.fn(async () => {}),
        leave: vi.fn(async () => {}),
        cancel: vi.fn(async () => {}),
        ...events,
      },
      tags: { listForTemplates: async () => [] },
      users: { get: async (id: string) => user({ id, displayName: `Person ${id}` }) },
      ...api,
    } as never,
  });
}

// `Upload` resolves an image host on import; none of these tests open the picker.
vi.mock("@/utils/imageUpload", async (importActual) => {
  const actual = await importActual<typeof import("@/utils/imageUpload")>();
  return { ...actual, resolveImageUploadProvider: () => ({ provider: { upload: async () => ({ url: "x" }) } }) };
});

describe("EventPage", () => {
  it("shows the event's title, description and who is going", async () => {
    setup({ description: "Bring a friend." }, { participants: [going("u2")] });
    expect(await screen.findByRole("heading", { name: "Weekly chat" })).toBeInTheDocument();
    expect(screen.getByText("Bring a friend.")).toBeInTheDocument();
    expect(await screen.findByText("Person u2")).toBeInTheDocument();
  });

  it("says the event was not found when it fails to load", async () => {
    setup({}, { events: { get: async () => Promise.reject(new Error("nope")) } });
    expect(await screen.findByText("This event could not be found.")).toBeInTheDocument();
  });

  it("RSVPs without following the community when already a member", async () => {
    const { api } = setup();
    await userEvent.click(await screen.findByRole("button", { name: "RSVP" }));
    await waitFor(() => expect(api.events.join).toHaveBeenCalled());
    expect(vi.mocked(api.events.join).mock.calls[0]?.[1]).toEqual({ joinCommunity: false });
  });

  it("offers to follow the community when the visitor is not a member", async () => {
    const { api } = setup({}, { status: "nonmember" });
    await userEvent.click(await screen.findByRole("button", { name: "RSVP" }));
    await waitFor(() => expect(api.events.join).toHaveBeenCalled());
    expect(vi.mocked(api.events.join).mock.calls[0]?.[1]).toEqual({ joinCommunity: true });
  });

  it("counts down to the start for someone who is going, and lets them cancel", async () => {
    const { api } = setup({}, { participants: [going("u1")] });
    expect(await screen.findByRole("button", { name: /^Starts in \d+ Days$/ })).toBeInTheDocument();
    await userEvent.click(screen.getByRole("button", { name: "Cancel" }));
    await userEvent.click(await screen.findByRole("button", { name: "Yes, cancel" }));
    await waitFor(() => expect(api.events.leave).toHaveBeenCalled());
  });

  it("shows FULL when a hosted event has no seats left", async () => {
    setup({ maxParticipants: 1 }, { participants: [going("u2")] });
    expect(await screen.findByText("FULL")).toBeInTheDocument();
    expect(screen.queryByRole("button", { name: "RSVP" })).not.toBeInTheDocument();
  });

  it("explains a locked event and a removed participant", async () => {
    setup({ isLocked: true });
    expect(await screen.findByText("This event is locked")).toBeInTheDocument();
  });

  it("tells a removed participant they cannot rejoin", async () => {
    setup({}, { participants: [going("u1", "banned")] });
    expect(
      await screen.findByText("You were removed from this event and cannot rejoin."),
    ).toBeInTheDocument();
  });

  it("shows a canceled event without a way to join", async () => {
    setup({ status: "canceled" });
    expect(await screen.findByText("This event was canceled.")).toBeInTheDocument();
    expect(screen.queryByRole("button", { name: "RSVP" })).not.toBeInTheDocument();
  });

  it("lets the host cancel the event after confirming", async () => {
    const { api } = setup({ creatorId: "u1" }, { status: "facilitator" });
    await userEvent.click(await screen.findByRole("button", { name: "Show Options" }));
    await userEvent.click(await screen.findByRole("menuitem", { name: "Cancel Event" }));
    await userEvent.click(await screen.findByRole("button", { name: "Cancel Event" }));
    await waitFor(() => expect(api.events.cancel).toHaveBeenCalled());
  });

  it("hides event options from other members", async () => {
    setup({ creatorId: "someone-else" });
    await screen.findByRole("button", { name: "RSVP" });
    expect(screen.queryByRole("button", { name: "Show Options" })).not.toBeInTheDocument();
  });

  it("shows announcements to participants only", async () => {
    const messages = [{ id: "m1", creatorId: "u1", message: "Room changed", createdAt: "2030-01-01T10:00:00.000Z" }];
    setup({}, { participants: [going("u1")], events: { listMessages: async () => messages } });
    expect(await screen.findByText("Room changed")).toBeInTheDocument();
  });

  it("links to other upcoming events", async () => {
    const other = event({ id: "e2", title: "Book club" });
    setup({}, { events: { listUpcoming: async () => [other] } });
    expect(await screen.findByText("More Upcoming Events")).toBeInTheDocument();
    expect(screen.getByText("Book club")).toBeInTheDocument();
  });
});

describe("participants", () => {
  const open = async () => userEvent.click(await screen.findByRole("button", { name: "See who is going" }));

  it("opens the full list, with the host first and then you", async () => {
    setup({ creatorId: "host" }, { participants: [going("u3"), going("u1"), going("host")] });
    await open();
    const dialog = await screen.findByRole("dialog");
    expect(await within(dialog).findByText("3 participants")).toBeInTheDocument();
    const names = (await within(dialog).findAllByRole("listitem")).map((item) => item.textContent);
    expect(names[0]).toContain("Person host");
    expect(names[1]).toContain("You");
  });

  it("lets the host remove someone, after confirming", async () => {
    const { api } = setup({ creatorId: "u1" }, { participants: [going("u1"), going("u2")] });
    await open();
    const dialog = await screen.findByRole("dialog");
    // The host cannot remove themself, so the only remove button is for u2.
    await userEvent.click(await within(dialog).findByRole("button", { name: "Remove participant" }));
    await userEvent.click(await screen.findByRole("button", { name: "Yes, cancel" }));
    await waitFor(() => expect(api.events.leave).toHaveBeenCalledWith(expect.objectContaining({ id: "e1" }), "u2"));
  });

  it("lets a member remove only themself", async () => {
    setup({ creatorId: "host" }, { participants: [going("host"), going("u1"), going("u2")] });
    await open();
    const dialog = await screen.findByRole("dialog");
    expect(await within(dialog).findAllByRole("button", { name: "Remove participant" })).toHaveLength(1);
  });

  it("offers no removal on a locked event", async () => {
    setup({ creatorId: "u1", isLocked: true }, { participants: [going("u1"), going("u2")] });
    await open();
    const dialog = await screen.findByRole("dialog");
    await within(dialog).findByText("2 participants");
    expect(within(dialog).queryByRole("button", { name: "Remove participant" })).not.toBeInTheDocument();
  });

  it("lists only the people in the room while the meeting is live", async () => {
    setup({ creatorId: "host" }, { participants: [going("host", "active", true), going("u2"), going("u3", "active", true)] });
    await open();
    const dialog = await screen.findByRole("dialog");
    await within(dialog).findByText("Person u3");
    expect(within(dialog).queryByText("Person u2")).not.toBeInTheDocument();
  });

  it("counts registrations for a hostless event, and only moderators can open the list", async () => {
    setup({ eventType: "hostless", registrationCount: 12 }, { participants: [going("u2")] });
    expect(await screen.findByText("12 Registrations")).toBeInTheDocument();
    expect(screen.queryByRole("button", { name: "See who is going" })).not.toBeInTheDocument();
  });
});

describe("announcements", () => {
  const messages = [{ id: "m1", creatorId: "u1", message: "Room changed", createdAt: "2030-01-01T10:00:00.000Z" }];

  it("lets a moderator write one", async () => {
    const sendMessage = vi.fn(async () => {});
    setup({ creatorId: "host" }, { status: "moderator", events: { sendMessage } });
    await userEvent.click(await screen.findByRole("button", { name: "Message Participants" }));
    const dialog = await screen.findByRole("dialog");
    await userEvent.click(within(dialog).getByRole("button", { name: "Send" }));
    expect(await within(dialog).findByText("Message cannot be empty")).toBeInTheDocument();
    await userEvent.type(within(dialog).getByLabelText("Message"), "See you soon");
    await userEvent.click(within(dialog).getByRole("button", { name: "Send" }));
    await waitFor(() => expect(sendMessage).toHaveBeenCalledWith(expect.objectContaining({ id: "e1" }), "See you soon"));
  });

  it("does not offer writing to an ordinary member", async () => {
    setup({ creatorId: "host" });
    await screen.findByRole("button", { name: "RSVP" });
    expect(screen.queryByRole("button", { name: "Message Participants" })).not.toBeInTheDocument();
  });

  it("lets a moderator delete one after confirming", async () => {
    const removeMessage = vi.fn(async () => {});
    setup({ creatorId: "host" }, { status: "moderator", events: { listMessages: async () => messages, removeMessage } });
    await userEvent.click(await screen.findByRole("button", { name: "Delete announcement" }));
    await userEvent.click(await screen.findByRole("button", { name: "Delete" }));
    await waitFor(() => expect(removeMessage).toHaveBeenCalledWith(expect.objectContaining({ id: "e1" }), "m1"));
  });

  it("says when there are none", async () => {
    setup({ creatorId: "host" }, { participants: [going("u1")] });
    expect(await screen.findByText("No announcements sent yet")).toBeInTheDocument();
  });
});

describe("tags", () => {
  it("shows the template's tags, up to five", async () => {
    const tags = Array.from({ length: 7 }, (_, i) => ({ templateId: "t1", tag: { id: `d${i}`, title: `tag${i}` } }));
    setup({}, { api: { tags: { listForTemplates: async () => [...tags, { templateId: "other", tag: { id: "x", title: "elsewhere" } }] } } });
    expect(await screen.findByText("#tag0 #tag1 #tag2 #tag3 #tag4")).toBeInTheDocument();
    expect(screen.queryByText(/elsewhere/)).not.toBeInTheDocument();
  });
});

describe("editing", () => {
  const host = { status: "facilitator" as MembershipStatus };

  it("saves only what changed", async () => {
    const update = vi.fn(async (current: Event) => current);
    setup({ creatorId: "u1" }, { ...host, events: { update } });
    await userEvent.click(await screen.findByRole("button", { name: "Edit event" }));
    const title = await screen.findByLabelText("Title");
    await userEvent.clear(title);
    await userEvent.type(title, "Renamed");
    await userEvent.click(screen.getByRole("button", { name: "Save Event" }));
    await waitFor(() => expect(update).toHaveBeenCalledWith(expect.objectContaining({ id: "e1" }), { title: "Renamed" }));
  });

  it("can change an event to a livestream", async () => {
    const update = vi.fn(async (current: Event) => current);
    setup({ creatorId: "u1" }, { ...host, events: { update } });
    await userEvent.click(await screen.findByRole("button", { name: "Edit event" }));
    const types = await screen.findAllByRole("radio");
    expect(types.map((radio) => (radio as HTMLInputElement).value)).toEqual(["hosted", "hostless", "livestream"]);
    await userEvent.click(screen.getByRole("radio", { name: "Livestream" }));
    await userEvent.click(screen.getByRole("button", { name: "Save Event" }));
    await waitFor(() => expect(update).toHaveBeenCalledWith(expect.objectContaining({ id: "e1" }), { eventType: "livestream" }));
  });

  it("offers a livestream the other types too", async () => {
    setup({ creatorId: "u1", eventType: "livestream", hasLiveStream: true }, host);
    await userEvent.click(await screen.findByRole("button", { name: "Edit event" }));
    expect(await screen.findByRole("radio", { name: "Livestream" })).toBeChecked();
    expect(screen.getByRole("radio", { name: "Hosted" })).not.toBeChecked();
  });

  it("will not save without a title", async () => {
    const update = vi.fn(async (current: Event) => current);
    setup({ creatorId: "u1" }, { ...host, events: { update } });
    await userEvent.click(await screen.findByRole("button", { name: "Edit event" }));
    await userEvent.clear(await screen.findByLabelText("Title"));
    await userEvent.click(screen.getByRole("button", { name: "Save Event" }));
    expect(await screen.findByText("Title cannot be empty")).toBeInTheDocument();
    expect(update).not.toHaveBeenCalled();
  });

  it("asks before throwing away edits", async () => {
    setup({ creatorId: "u1" }, host);
    await userEvent.click(await screen.findByRole("button", { name: "Edit event" }));
    await userEvent.type(await screen.findByLabelText("Description"), "More");
    await userEvent.click(screen.getByRole("button", { name: "Close edit" }));
    await userEvent.click(await screen.findByRole("button", { name: "Discard" }));
    await waitFor(() => expect(screen.queryByLabelText("Description")).not.toBeInTheDocument());
  });

  it("changes event settings and marks what differs from the default", async () => {
    const updateSettings = vi.fn(async (current: Event) => current);
    setup({ creatorId: "u1", eventSettings: { chat: true } }, { ...host, events: { updateSettings } });
    await userEvent.click(await screen.findByRole("button", { name: "Event Settings" }));
    const drawer = await screen.findByRole("presentation");
    // A dot marks a switch that differs from the default.
    expect(within(drawer).getAllByTestId("CircleIcon")).toHaveLength(1);
    await userEvent.click(within(drawer).getByRole("switch", { name: "Recording" }));
    await userEvent.click(within(drawer).getByRole("button", { name: "Save Settings" }));
    await waitFor(() =>
      expect(updateSettings).toHaveBeenCalledWith(
        expect.objectContaining({ id: "e1" }),
        expect.objectContaining({ chat: true, alwaysRecord: true }),
      ),
    );
  });

  it("refreshes from the template after confirming, but not for an event with no template", async () => {
    const refreshFromTemplate = vi.fn(async () => {});
    const view = setup({ creatorId: "u1" }, { status: "moderator", events: { refreshFromTemplate } });
    await userEvent.click(await screen.findByRole("button", { name: "Show Options" }));
    await userEvent.click(await screen.findByRole("menuitem", { name: "Refresh Template" }));
    await userEvent.click(await screen.findByRole("button", { name: "Yes, refresh" }));
    await waitFor(() => expect(refreshFromTemplate).toHaveBeenCalled());
    view.unmount();

    setup({ creatorId: "u1", templateId: "misc" }, { status: "moderator" });
    await userEvent.click(await screen.findByRole("button", { name: "Show Options" }));
    expect(screen.queryByRole("menuitem", { name: "Refresh Template" })).not.toBeInTheDocument();
  });

  it("duplicates an event into the create dialog, ready to pick a day", async () => {
    setup(
      { creatorId: "u1" },
      { status: "moderator", api: { templates: { list: async () => [template({ id: "t1" })] } } },
    );
    await userEvent.click(await screen.findByRole("button", { name: "Show Options" }));
    await userEvent.click(await screen.findByRole("menuitem", { name: "Duplicate Event" }));
    expect(await screen.findByText("Public or private?")).toBeInTheDocument();
  });
});

describe("pre- and post-event cards", () => {
  const card = {
    headline: "Before you come",
    message: "Take this survey",
    links: [{ buttonText: "Survey", url: "https://forms.example/s", attributes: [{ type: "userId" as const, queryParam: "uid" }] }],
  };
  const withPrePost = (enabled: boolean) => ({
    communities: { getByDisplayId: async () => community(), prePostEnabled: async () => enabled },
  });

  it("shows the host's message right after signing up", async () => {
    setup({ preEventCard: card }, { api: withPrePost(true) });
    await userEvent.click(await screen.findByRole("button", { name: "RSVP" }));
    expect(await screen.findByText("Before you come")).toBeInTheDocument();
    expect(screen.getByText("Take this survey")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Survey" })).toBeInTheDocument();
  });

  it("stays quiet when the community has the cards turned off", async () => {
    const { api } = setup({ preEventCard: card }, { api: withPrePost(false) });
    await userEvent.click(await screen.findByRole("button", { name: "RSVP" }));
    await waitFor(() => expect(api.events.join).toHaveBeenCalled());
    expect(screen.queryByText("Before you come")).not.toBeInTheDocument();
  });

  it("lets a participant read the cards in a CTAs tab, only once there is something in them", async () => {
    setup({ postEventCard: card }, { participants: [going("u1")] });
    await userEvent.click(await screen.findByRole("tab", { name: "CTAs" }));
    expect(await screen.findByText("Take this survey")).toBeInTheDocument();
  });

  it("has no CTAs tab for a participant when the host wrote nothing", async () => {
    setup({}, { participants: [going("u1")] });
    await screen.findByRole("tab", { name: "About" });
    expect(screen.queryByRole("tab", { name: "CTAs" })).not.toBeInTheDocument();
  });

  const hostTab = async (events: Record<string, unknown>, over: Partial<Event> = {}) => {
    setup({ creatorId: "u1", ...over }, { status: "facilitator", events });
    await userEvent.click(await screen.findByRole("tab", { name: "CTAs" }));
  };

  it("offers a host an add button for each card that does not exist yet", async () => {
    const updatePrePost = vi.fn(async () => {});
    await hostTab({ updatePrePost });
    expect(await screen.findByRole("button", { name: "Add Post-event" })).toBeInTheDocument();
    await userEvent.click(screen.getByRole("button", { name: "Add Pre-event" }));
    await waitFor(() =>
      expect(updatePrePost).toHaveBeenCalledWith(expect.objectContaining({ id: "e1" }), "pre", { headline: "", message: "", links: [] }),
    );
  });

  it("shows an existing card to read, opens it for editing with a link preview, and saves", async () => {
    const updatePrePost = vi.fn(async () => {});
    await hostTab({ updatePrePost }, { preEventCard: card });
    expect(await screen.findByText("Take this survey")).toBeInTheDocument();
    expect(screen.queryByRole("button", { name: "Add Pre-event" })).not.toBeInTheDocument();
    await userEvent.click(screen.getByRole("button", { name: "Edit card" }));
    const headline = await screen.findByLabelText("Enter Headline");
    await userEvent.clear(headline);
    await userEvent.type(headline, "Welcome");
    expect(screen.getByText(/forms\.example\/s\?uid=%7BuserId%7D/)).toBeInTheDocument();
    await userEvent.click(screen.getByRole("button", { name: "Save" }));
    await waitFor(() =>
      expect(updatePrePost).toHaveBeenCalledWith(
        expect.objectContaining({ id: "e1" }),
        "pre",
        expect.objectContaining({ headline: "Welcome" }),
      ),
    );
  });

  it("edits with icon buttons: save stays off until something changes, and delete asks first", async () => {
    const updatePrePost = vi.fn(async () => {});
    await hostTab({ updatePrePost }, { preEventCard: card });
    await userEvent.click(await screen.findByRole("button", { name: "Edit card" }));
    const save = await screen.findByRole("button", { name: "Save" });
    expect(save).toBeDisabled();
    await userEvent.type(screen.getByLabelText("Enter Headline"), "!");
    expect(save).toBeEnabled();
    // While editing, delete lives beside save rather than in the title bar.
    await userEvent.click(screen.getByRole("button", { name: "Delete card" }));
    await userEvent.click(await screen.findByRole("button", { name: "Delete" }));
    await waitFor(() => expect(updatePrePost).toHaveBeenCalledWith(expect.objectContaining({ id: "e1" }), "pre", null));
  });

  it("opens a brand-new card straight into editing", async () => {
    await hostTab({}, { preEventCard: { headline: "", message: "", links: [] } });
    expect(await screen.findByLabelText("Enter Headline")).toBeInTheDocument();
  });

  it("deletes a card after confirming, and can fold it away", async () => {
    const updatePrePost = vi.fn(async () => {});
    await hostTab({ updatePrePost }, { preEventCard: card });
    await userEvent.click(await screen.findByRole("button", { name: "Collapse" }));
    expect(screen.queryByText("Take this survey")).not.toBeInTheDocument();
    await userEvent.click(screen.getByRole("button", { name: "Delete card" }));
    await userEvent.click(await screen.findByRole("button", { name: "Delete" }));
    await waitFor(() => expect(updatePrePost).toHaveBeenCalledWith(expect.objectContaining({ id: "e1" }), "pre", null));
  });

  it("shows a participant only the cards that have something in them", async () => {
    setup({ postEventCard: card }, { participants: [going("u1")] });
    await userEvent.click(await screen.findByRole("tab", { name: "CTAs" }));
    expect(await screen.findByText("Post-event")).toBeInTheDocument();
    expect(screen.queryByText("Pre-event")).not.toBeInTheDocument();
    expect(screen.queryByRole("button", { name: "Edit card" })).not.toBeInTheDocument();
  });
});

describe("sign-up questions", () => {
  const surveyQuestions = [
    {
      id: "q1",
      title: "How do you feel?",
      type: "multipleChoice" as const,
      options: [
        { id: "a", title: "Great" },
        { id: "b", title: "Fine" },
      ],
      answers: [],
    },
    { id: "q2", title: "Anything else?", type: "freeText" as const, options: [], answers: [] },
  ];

  it("asks them before signing someone up, and sends the answers", async () => {
    const { api } = setup({ surveyQuestions });
    await userEvent.click(await screen.findByRole("button", { name: "RSVP" }));
    const dialog = await screen.findByRole("dialog");
    expect(api.events.join).not.toHaveBeenCalled();
    await userEvent.click(within(dialog).getByRole("button", { name: "Fine" }));
    await userEvent.type(within(dialog).getByRole("textbox", { name: "Anything else?" }), "No");
    await userEvent.click(within(dialog).getByRole("button", { name: "Finish" }));
    await waitFor(() => expect(api.events.join).toHaveBeenCalled());
    expect(vi.mocked(api.events.join).mock.calls[0]?.[1]).toMatchObject({
      survey: [
        { questionId: "q1", answerOptionId: "b" },
        { questionId: "q2", freeText: "No" },
      ],
    });
  });

  it("does not sign up someone who closes the questions", async () => {
    const { api } = setup({ surveyQuestions });
    await userEvent.click(await screen.findByRole("button", { name: "RSVP" }));
    await userEvent.click(await within(await screen.findByRole("dialog")).findByRole("button", { name: "Close" }));
    await waitFor(() => expect(screen.queryByRole("dialog")).not.toBeInTheDocument());
    expect(api.events.join).not.toHaveBeenCalled();
  });

  it("will not finish until every question is answered", async () => {
    const { api } = setup({ surveyQuestions });
    await userEvent.click(await screen.findByRole("button", { name: "RSVP" }));
    const dialog = await screen.findByRole("dialog");
    await userEvent.click(within(dialog).getByRole("button", { name: "Great" }));
    // The button is inert until everything is answered, so the click is allowed to land on it.
    await userEvent.setup({ pointerEventsCheck: 0 }).click(within(dialog).getByRole("button", { name: "Finish" }));
    expect(api.events.join).not.toHaveBeenCalled();
    expect(screen.getByRole("dialog")).toBeInTheDocument();
  });
});

describe("agenda", () => {
  const agendaItems = [
    { id: "i1", type: "text" as const, title: "Welcome", content: "Say hello", timeInSeconds: 300 },
    { id: "i2", type: "poll" as const, title: "Vote", pollAnswers: ["Yes", "No"] },
  ];
  const openTo = (agendaPreview: boolean) => ({
    api: { communities: { getByDisplayId: async () => community({ eventSettings: { agendaPreview } }) } },
  });

  it("shows participants the planned agenda when previews are on", async () => {
    setup({ agendaItems }, openTo(true));
    await userEvent.click(await screen.findByRole("tab", { name: "Agenda" }));
    expect(await screen.findByText("Welcome")).toBeInTheDocument();
    expect(screen.getByText("5:00")).toBeInTheDocument();
    // Steps start folded away on an event.
    expect(screen.queryByText("Yes")).not.toBeInTheDocument();
    await userEvent.click(screen.getAllByRole("button", { name: "Expand" })[1]!);
    expect(screen.getByText("Yes")).toBeInTheDocument();
  });

  it("keeps it from participants when previews are off, but not from the host", async () => {
    const view = setup({ agendaItems, creatorId: "host" }, openTo(false));
    await screen.findByRole("tab", { name: "About" });
    expect(screen.queryByRole("tab", { name: "Agenda" })).not.toBeInTheDocument();
    view.unmount();

    setup({ agendaItems, creatorId: "u1" }, { ...openTo(false), status: "facilitator" });
    expect(await screen.findByRole("tab", { name: "Agenda" })).toBeInTheDocument();
  });

  it("lets a host clear the agenda after confirming", async () => {
    const clearAgenda = vi.fn(async () => {});
    setup({ agendaItems, creatorId: "u1" }, { ...openTo(false), status: "facilitator", events: { clearAgenda } });
    await userEvent.click(await screen.findByRole("tab", { name: "Agenda" }));
    await userEvent.click(await screen.findByRole("button", { name: "Clear all" }));
    await userEvent.click(await screen.findByRole("button", { name: "Delete" }));
    await waitFor(() => expect(clearAgenda).toHaveBeenCalled());
  });
});

describe("developer settings", () => {
  const openSettings = async () =>
    userEvent.click(await screen.findByRole("button", { name: "Event Settings" }));

  it("lists every switch outside production, and saves them with the rest", async () => {
    vi.mocked(enableDevEventSettings).mockReturnValue(true);
    const updateSettings = vi.fn(async (current: Event) => current);
    setup({ creatorId: "u1" }, { status: "facilitator", events: { updateSettings } });
    await openSettings();
    expect(await screen.findByText("Developer Settings")).toBeInTheDocument();
    await userEvent.click(screen.getByRole("switch", { name: "enablePrerequisites" }));
    await userEvent.click(screen.getByRole("button", { name: "Save Settings" }));
    await waitFor(() =>
      expect(updateSettings).toHaveBeenCalledWith(
        expect.objectContaining({ id: "e1" }),
        expect.objectContaining({ enablePrerequisites: true }),
      ),
    );
  });

  it("is absent in production", async () => {
    vi.mocked(enableDevEventSettings).mockReturnValue(false);
    setup({ creatorId: "u1" }, { status: "facilitator" });
    await openSettings();
    await screen.findByText("Save Settings");
    expect(screen.queryByText("Developer Settings")).not.toBeInTheDocument();
  });
});

describe("edit template notice", () => {
  beforeEach(() => localStorage.clear());

  it("points a moderator to the template, and stays hidden once dismissed", async () => {
    const view = setup({ templateId: "t1" }, { status: "moderator" });
    const link = await screen.findByRole("link", { name: "edit the template." });
    expect(link).toHaveAttribute("href", "/space/civic-lab/discuss/t1");
    await userEvent.click(screen.getByRole("button", { name: "Hide this notice" }));
    expect(screen.queryByRole("note")).not.toBeInTheDocument();
    view.unmount();

    setup({ templateId: "t1" }, { status: "moderator" });
    await screen.findByRole("heading", { name: "Weekly chat" });
    expect(screen.queryByRole("note")).not.toBeInTheDocument();
  });

  it("is not shown to members, or for an event without a template", async () => {
    const view = setup({ templateId: "t1" });
    await screen.findByRole("heading", { name: "Weekly chat" });
    expect(screen.queryByRole("note")).not.toBeInTheDocument();
    view.unmount();

    setup({ templateId: "misc" }, { status: "moderator" });
    await screen.findByRole("heading", { name: "Weekly chat" });
    expect(screen.queryByRole("note")).not.toBeInTheDocument();
  });
});

describe("agenda editing", () => {
  const agendaItems = [
    { id: "i1", type: "text" as const, title: "Welcome", content: "Say hello", timeInSeconds: 300 },
    { id: "i2", type: "poll" as const, content: "Vote", pollAnswers: ["Yes", "No"], timeInSeconds: 60 },
  ];
  const editor = async (events: Record<string, unknown>) => {
    setup({ agendaItems, creatorId: "u1" }, { status: "facilitator", events });
    await userEvent.click(await screen.findByRole("tab", { name: "Agenda" }));
  };
  const open = async (title: string) => {
    const heading = await screen.findByRole("heading", { name: title });
    await userEvent.click(within(heading.closest("li")!).getByRole("button", { name: "Expand" }));
    return heading.closest("li")!;
  };

  it("edits a step and saves it", async () => {
    const upsertAgendaItem = vi.fn(async () => {});
    await editor({ upsertAgendaItem });
    const step = await open("Welcome");
    await userEvent.click(within(step).getByRole("button", { name: "Edit Item" }));
    const title = within(step).getByLabelText("Title");
    await userEvent.clear(title);
    await userEvent.type(title, "Hello");
    await userEvent.click(within(step).getByRole("button", { name: "Save Agenda Item" }));
    await waitFor(() =>
      expect(upsertAgendaItem).toHaveBeenCalledWith(
        expect.objectContaining({ id: "e1" }),
        { id: "i1", type: "text", title: "Hello", content: "Say hello", timeInSeconds: 300 },
      ),
    );
  });

  it("will not save a step that is missing something", async () => {
    const upsertAgendaItem = vi.fn(async () => {});
    await editor({ upsertAgendaItem });
    await userEvent.click(await screen.findByRole("button", { name: "Add agenda item" }));
    const steps = await screen.findAllByRole("listitem");
    await userEvent.click(within(steps.at(-1)!).getByRole("button", { name: "Save Agenda Item" }));
    expect(upsertAgendaItem).not.toHaveBeenCalled();
    expect(await screen.findByText("Title is required")).toBeInTheDocument();
  });

  it("adds a new step, here a poll", async () => {
    const upsertAgendaItem = vi.fn(async () => {});
    await editor({ upsertAgendaItem });
    await userEvent.click(await screen.findByRole("button", { name: "Add agenda item" }));
    const steps = await screen.findAllByRole("listitem");
    const fresh = steps.at(-1)!;
    await userEvent.click(within(fresh).getByRole("combobox", { name: "Type of agenda item" }));
    await userEvent.click(await screen.findByRole("option", { name: "Poll" }));
    await userEvent.type(within(fresh).getByLabelText("Poll Question"), "Lunch?");
    await userEvent.click(within(fresh).getByRole("button", { name: "Add option" }));
    await userEvent.type(within(fresh).getByRole("textbox", { name: "Option 1" }), "Pizza");
    await userEvent.click(within(fresh).getByRole("button", { name: "Save Agenda Item" }));
    await waitFor(() =>
      expect(upsertAgendaItem).toHaveBeenCalledWith(
        expect.objectContaining({ id: "e1" }),
        expect.objectContaining({ type: "poll", content: "Lunch?", pollAnswers: ["Pizza"] }),
      ),
    );
  });

  it("duplicates a step into an unsaved copy that saves under a new id", async () => {
    const upsertAgendaItem = vi.fn<(event: Event, item: unknown) => Promise<void>>(async () => {});
    await editor({ upsertAgendaItem });
    const step = await open("Welcome");
    await userEvent.click(within(step).getByRole("button", { name: "Duplicate Item" }));
    const copies = await screen.findAllByRole("heading", { name: "Welcome" });
    expect(copies).toHaveLength(2);
    // The copy opens for editing, and "Add agenda item" waits until it is dealt with.
    expect(screen.queryByRole("button", { name: "Add agenda item" })).not.toBeInTheDocument();
    const copy = copies[1]!.closest("li")!;
    await userEvent.click(within(copy).getByRole("button", { name: "Save Agenda Item" }));
    await waitFor(() => expect(upsertAgendaItem).toHaveBeenCalled());
    const saved = vi.mocked(upsertAgendaItem).mock.calls[0]![1] as { id: string; title: string };
    expect(saved.title).toBe("Welcome");
    expect(saved.id).not.toBe("i1");
  });

  it("drops an unsaved copy on cancel", async () => {
    await editor({});
    const step = await open("Welcome");
    await userEvent.click(within(step).getByRole("button", { name: "Duplicate Item" }));
    const copy = (await screen.findAllByRole("heading", { name: "Welcome" }))[1]!.closest("li")!;
    await userEvent.click(within(copy).getByRole("button", { name: "Cancel" }));
    await waitFor(() => expect(screen.getAllByRole("heading", { name: "Welcome" })).toHaveLength(1));
  });

  it("asks before discarding edits", async () => {
    await editor({});
    const step = await open("Welcome");
    await userEvent.click(within(step).getByRole("button", { name: "Edit Item" }));
    await userEvent.type(within(step).getByLabelText("Title"), "!");
    await userEvent.click(within(step).getByRole("button", { name: "Cancel" }));
    await userEvent.click(await screen.findByRole("button", { name: "Yes" }));
    await waitFor(() => expect(within(step).queryByLabelText("Title")).not.toBeInTheDocument());
  });

  it("deletes a step after confirming", async () => {
    const deleteAgendaItem = vi.fn(async () => {});
    await editor({ deleteAgendaItem });
    const step = await open("Welcome");
    await userEvent.click(within(step).getByRole("button", { name: "Edit Item" }));
    await userEvent.click(within(step).getByRole("button", { name: "Delete Agenda Item" }));
    await userEvent.click(await screen.findByRole("button", { name: "Delete" }));
    await waitFor(() => expect(deleteAgendaItem).toHaveBeenCalledWith(expect.objectContaining({ id: "e1" }), "i1"));
  });

  it("moves a step down", async () => {
    const reorderAgenda = vi.fn(async () => {});
    await editor({ reorderAgenda });
    const [first] = await screen.findAllByRole("button", { name: "Move down" });
    await userEvent.click(first!);
    await waitFor(() => expect(reorderAgenda).toHaveBeenCalledWith(expect.objectContaining({ id: "e1" }), ["i2", "i1"]));
  });

  it("is read-only for an ordinary participant", async () => {
    setup(
      { agendaItems },
      { participants: [going("u1")], api: { communities: { getByDisplayId: async () => community({ eventSettings: { agendaPreview: true } }) } } },
    );
    await userEvent.click(await screen.findByRole("tab", { name: "Agenda" }));
    await screen.findByRole("heading", { name: "Welcome" });
    expect(screen.queryByRole("button", { name: "Add agenda item" })).not.toBeInTheDocument();
    expect(screen.queryByRole("button", { name: "Move down" })).not.toBeInTheDocument();
  });
});

describe("breakouts", () => {
  const smart = { assignmentMethod: "smartMatch" as const, targetParticipants: 8 };
  const bySize = { assignmentMethod: "targetPerRoom" as const, targetParticipants: 8 };
  const withFlag = (allow: boolean) => ({
    api: { communities: { getByDisplayId: async () => community({ allowAdditionalRegistrationField: allow }) } },
    status: "facilitator" as MembershipStatus,
  });
  const choice = (id: string, title: string) => ({
    id,
    title,
    type: "multipleChoice" as const,
    options: [
      { id: `${id}a`, title: "Yes" },
      { id: `${id}b`, title: "No" },
    ],
    answers: [
      { id: `${id}x`, options: [{ id: `${id}a`, title: "Yes" }] },
      { id: `${id}y`, options: [{ id: `${id}b`, title: "No" }] },
    ],
  });

  it("shows editors by-size breakouts with a target size, and no questions", async () => {
    setup({ creatorId: "u1", breakout: bySize }, withFlag(false));
    await userEvent.click(await screen.findByRole("tab", { name: "Agenda" }));
    expect(await screen.findByRole("heading", { name: "Add breakouts" })).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "By Size" })).toBeEnabled();
    expect(screen.getByRole("slider", { name: "Target Size?" })).toHaveValue("8");
    expect(screen.queryByText("Matching questions")).not.toBeInTheDocument();
  });

  it("saves a new target size once the slider is released", async () => {
    const updateBreakoutSettings = vi.fn(async () => {});
    setup({ creatorId: "u1", breakout: bySize }, { ...withFlag(false), events: { updateBreakoutSettings } });
    await userEvent.click(await screen.findByRole("tab", { name: "Agenda" }));
    const slider = await screen.findByRole("slider", { name: "Target Size?" });
    slider.focus();
    await userEvent.keyboard("{ArrowRight}");
    await waitFor(() =>
      expect(updateBreakoutSettings).toHaveBeenCalledWith(expect.objectContaining({ id: "e1" }), { targetParticipants: 9 }),
    );
  });

  it("shows the defaults when nothing is defined yet", async () => {
    setup({ creatorId: "u1" }, withFlag(false));
    await userEvent.click(await screen.findByRole("tab", { name: "Agenda" }));
    expect(await screen.findByRole("slider", { name: "Target Size?" })).toHaveValue("8");
  });

  it("is not shown to people who cannot edit the event", async () => {
    setup(
      {},
      { participants: [going("u1")], api: { communities: { getByDisplayId: async () => community({ eventSettings: { agendaPreview: true } }) } } },
    );
    await userEvent.click(await screen.findByRole("tab", { name: "Agenda" }));
    await screen.findByRole("heading", { name: "Agenda" });
    expect(screen.queryByRole("heading", { name: "Add breakouts" })).not.toBeInTheDocument();
  });

  it("switches to smart match, which brings the matching questions", async () => {
    const updateBreakoutSettings = vi.fn(async () => {});
    setup({ creatorId: "u1", breakout: bySize }, { ...withFlag(false), events: { updateBreakoutSettings } });
    await userEvent.click(await screen.findByRole("tab", { name: "Agenda" }));
    await userEvent.click(await screen.findByRole("button", { name: "Smart Match" }));
    await waitFor(() =>
      expect(updateBreakoutSettings).toHaveBeenCalledWith(expect.objectContaining({ id: "e1" }), { assignmentMethod: "smartMatch" }),
    );
  });

  it("shows the matching questions under smart match, and no free-text option without the community flag", async () => {
    setup({ creatorId: "u1", breakout: smart, surveyQuestions: [choice("q1", "Cook?")] }, withFlag(false));
    await userEvent.click(await screen.findByRole("tab", { name: "Agenda" }));
    expect(await screen.findByText("Matching questions")).toBeInTheDocument();
    expect(screen.queryByText(/one free text question/)).not.toBeInTheDocument();
    const card = screen.getByText("Cook?").closest("li")!;
    await userEvent.click(within(card).getByRole("button", { name: "Edit Item" }));
    expect(within(card).queryByRole("combobox", { name: "Question type" })).not.toBeInTheDocument();
  });

  it("offers the free-text type and its notice where the community allows it", async () => {
    setup({ creatorId: "u1", breakout: smart, surveyQuestions: [choice("q1", "Cook?")] }, withFlag(true));
    await userEvent.click(await screen.findByRole("tab", { name: "Agenda" }));
    expect(await screen.findByText("You can add one free text question. All other questions must be multiple choice.")).toBeInTheDocument();
    const card = screen.getByText("Cook?").closest("li")!;
    await userEvent.click(within(card).getByRole("button", { name: "Edit Item" }));
    expect(within(card).getByRole("combobox", { name: "Question type" })).toBeInTheDocument();
  });

  it("adds a question with Yes and No answers and saves it", async () => {
    const saveSurveyQuestions = vi.fn<(event: Event, questions: unknown) => Promise<void>>(async () => {});
    setup({ creatorId: "u1", breakout: smart }, { ...withFlag(true), events: { saveSurveyQuestions } });
    await userEvent.click(await screen.findByRole("tab", { name: "Agenda" }));
    await userEvent.click(await screen.findByRole("button", { name: "Add a question" }));
    await userEvent.type(await screen.findByLabelText("Enter Question 1"), "Do you cook?");
    await userEvent.click(screen.getByRole("button", { name: "Save question" }));
    await waitFor(() =>
      expect(saveSurveyQuestions).toHaveBeenCalledWith(
        expect.objectContaining({ id: "e1" }),
        [expect.objectContaining({ title: "Do you cook?", type: "multipleChoice" })],
      ),
    );
    const [saved] = vi.mocked(saveSurveyQuestions).mock.calls[0]![1] as { options: { title: string }[] }[];
    expect(saved!.options.map((option) => option.title)).toEqual(["Yes", "No"]);
  });

  it("will not save a question with no wording", async () => {
    const saveSurveyQuestions = vi.fn(async () => {});
    setup({ creatorId: "u1", breakout: smart }, { ...withFlag(true), events: { saveSurveyQuestions } });
    await userEvent.click(await screen.findByRole("tab", { name: "Agenda" }));
    await userEvent.click(await screen.findByRole("button", { name: "Add a question" }));
    await userEvent.click(await screen.findByRole("button", { name: "Save question" }));
    expect(await screen.findByText("Please complete all your questions and answers!")).toBeInTheDocument();
    expect(saveSurveyQuestions).not.toHaveBeenCalled();
  });

  it("will not add another question over an unfinished one", async () => {
    setup({ creatorId: "u1", breakout: smart }, withFlag(true));
    await userEvent.click(await screen.findByRole("tab", { name: "Agenda" }));
    await userEvent.click(await screen.findByRole("button", { name: "Add a question" }));
    await userEvent.click(await screen.findByRole("button", { name: "Add a question" }));
    expect(await screen.findByText("Please complete previous question and both answers")).toBeInTheDocument();
    expect(screen.getAllByLabelText(/^Enter Question/)).toHaveLength(1);
  });

  it("allows only one free-text question", async () => {
    const free = { ...choice("q1", "Why?"), type: "freeText" as const, options: [], answers: [] };
    setup({ creatorId: "u1", surveyQuestions: [free, choice("q2", "Cook?")], breakout: smart }, withFlag(true));
    await userEvent.click(await screen.findByRole("tab", { name: "Agenda" }));
    const cards = await screen.findAllByText(/Why\?|Cook\?/);
    expect(cards).toHaveLength(2);
    const second = screen.getByText("Cook?").closest("li")!;
    await userEvent.click(within(second).getByRole("button", { name: "Edit Item" }));
    await userEvent.click(within(second).getByRole("combobox", { name: "Question type" }));
    expect(await screen.findByRole("option", { name: "Free text" })).toHaveAttribute("aria-disabled", "true");
  });

  it("deletes a question after confirming", async () => {
    const saveSurveyQuestions = vi.fn(async () => {});
    setup(
      { creatorId: "u1", surveyQuestions: [choice("q1", "Cook?")], breakout: smart },
      { ...withFlag(true), events: { saveSurveyQuestions } },
    );
    await userEvent.click(await screen.findByRole("tab", { name: "Agenda" }));
    const card = (await screen.findByText("Cook?")).closest("li")!;
    await userEvent.click(within(card).getByRole("button", { name: "Edit Item" }));
    await userEvent.click(within(card).getByRole("button", { name: "Delete question" }));
    await userEvent.click(await screen.findByRole("button", { name: "Delete" }));
    await waitFor(() => expect(saveSurveyQuestions).toHaveBeenCalledWith(expect.objectContaining({ id: "e1" }), []));
  });

  it("offers a livestream an optional definition instead", async () => {
    const saveSurveyQuestions = vi.fn(async () => {});
    setup({ creatorId: "u1", eventType: "livestream" }, { ...withFlag(true), events: { saveSurveyQuestions } });
    await userEvent.click(await screen.findByRole("tab", { name: "Agenda" }));
    expect(screen.queryByText("Matching questions")).not.toBeInTheDocument();
    expect(screen.queryByRole("slider")).not.toBeInTheDocument();
    await userEvent.click(await screen.findByRole("button", { name: "Define Breakouts (Optional)" }));
    await waitFor(() => expect(saveSurveyQuestions).toHaveBeenCalledWith(expect.objectContaining({ id: "e1" }), []));
  });
});
