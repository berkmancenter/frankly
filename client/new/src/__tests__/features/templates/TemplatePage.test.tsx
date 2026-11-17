// @vitest-environment jsdom
import { screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it, vi } from "vitest";
import type { MembershipStatus, Template } from "@/api/types";
import { community, event, template } from "@/__tests__/support/fixtures";
import { renderInCommunity } from "@/__tests__/support/renderWithProviders";
import { TemplatePage } from "@/features/templates/TemplatePage";

const current = template({
  id: "t1",
  title: "Check-in",
  description: "A weekly hello.",
  category: "Social",
  creatorId: "someone",
  agendaItems: [{ id: "i1", type: "text", title: "Welcome" }],
});
const other = template({ id: "t2", title: "Town Hall" });

function setup({
  status = "member" as MembershipStatus,
  fresh = current as Template,
  prePostEnabled = false,
  templates = {} as Record<string, unknown>,
  events = [] as ReturnType<typeof event>[],
} = {}) {
  return renderInCommunity(<TemplatePage />, {
    status,
    route: "/space/civic-lab/discuss/t1",
    path: "/space/:displayId/discuss/:templateId",
    api: {
      communities: {
        getByDisplayId: async () => community(),
        prePostEnabled: async () => prePostEnabled,
      },
      templates: {
        list: async () => [fresh, other],
        get: async () => fresh,
        updatePrePost: vi.fn(async () => {}),
        clearAgenda: vi.fn(async () => {}),
        ...templates,
      },
      events: { listForTemplate: async () => events, listParticipants: async () => [] },
      tags: { listForTemplates: async () => [{ templateId: "t1", tag: { id: "d1", title: "social" } }] },
    } as never,
  });
}

describe("TemplatePage", () => {
  it("introduces the template, its tags, and what else the community offers", async () => {
    setup();
    expect(await screen.findByRole("heading", { name: "Check-in" })).toBeInTheDocument();
    expect(screen.getByText("A weekly hello.")).toBeInTheDocument();
    expect(await screen.findByText("#social")).toBeInTheDocument();
    expect(screen.getByText("More from Civic Lab")).toBeInTheDocument();
    expect(screen.getByRole("link", { name: "Town Hall" })).toHaveAttribute("href", "/space/civic-lab/discuss/t2");
    expect(screen.queryByRole("link", { name: "Check-in" })).not.toBeInTheDocument();
  });

  it("says when it could not be loaded", async () => {
    setup({ templates: { get: async () => Promise.reject(new Error("nope")) } });
    expect(await screen.findByText("This template could not be found.")).toBeInTheDocument();
  });

  it("shows the next event, and all of them in the Upcoming Events tab", async () => {
    setup({ events: [event({ id: "e1", title: "Monday chat" }), event({ id: "e2", title: "Tuesday chat" })] });
    expect(await screen.findByText("Monday chat")).toBeInTheDocument();
    expect(screen.queryByText("Tuesday chat")).not.toBeInTheDocument();
    await userEvent.click(screen.getByRole("tab", { name: "Upcoming Events" }));
    expect(await screen.findByText("Tuesday chat")).toBeInTheDocument();
  });

  it("says when nothing is coming up", async () => {
    setup();
    expect(await screen.findByText("No upcoming events.")).toBeInTheDocument();
  });

  it("shows the agenda, which only its editors can clear", async () => {
    const view = setup();
    await userEvent.click(await screen.findByRole("tab", { name: "Agenda" }));
    expect(await screen.findByText("Welcome")).toBeInTheDocument();
    expect(screen.queryByRole("button", { name: "Clear all" })).not.toBeInTheDocument();
    view.unmount();

    const clearAgenda = vi.fn(async () => {});
    setup({ status: "moderator", templates: { clearAgenda } });
    await userEvent.click(await screen.findByRole("tab", { name: "Agenda" }));
    await userEvent.click(await screen.findByRole("button", { name: "Clear all" }));
    await userEvent.click(await screen.findByRole("button", { name: "Delete" }));
    await waitFor(() => expect(clearAgenda).toHaveBeenCalledWith(expect.objectContaining({ id: "t1" })));
  });

  it("lets an editor change, duplicate and add steps with the same editor as an event", async () => {
    const upsertAgendaItem = vi.fn<(template: Template, item: unknown) => Promise<void>>(async () => {});
    setup({
      status: "moderator",
      fresh: template({ ...current, agendaItems: [{ id: "i1", type: "text", title: "Welcome", content: "Hi", timeInSeconds: 300 }] }),
      templates: { upsertAgendaItem },
    });
    await userEvent.click(await screen.findByRole("tab", { name: "Agenda" }));
    // Steps start open on a template.
    await userEvent.click(await screen.findByRole("button", { name: "Edit Item" }));
    const title = screen.getByLabelText("Title");
    await userEvent.clear(title);
    await userEvent.type(title, "Hello");
    await userEvent.click(screen.getByRole("button", { name: "Save Agenda Item" }));
    await waitFor(() =>
      expect(upsertAgendaItem).toHaveBeenCalledWith(
        expect.objectContaining({ id: "t1" }),
        { id: "i1", type: "text", title: "Hello", content: "Hi", timeInSeconds: 300 },
      ),
    );
    await userEvent.click(await screen.findByRole("button", { name: "Duplicate Item" }));
    expect(await screen.findAllByRole("heading", { name: /Welcome|Hello/ })).toHaveLength(2);
  });

  it("has a CTAs tab only for admins of a community with the cards turned on", async () => {
    const view = setup({ status: "admin", prePostEnabled: false });
    await screen.findByRole("tab", { name: "About" });
    expect(screen.queryByRole("tab", { name: "CTAs" })).not.toBeInTheDocument();
    view.unmount();

    const view2 = setup({ status: "member", prePostEnabled: true });
    await screen.findByRole("tab", { name: "About" });
    expect(screen.queryByRole("tab", { name: "CTAs" })).not.toBeInTheDocument();
    view2.unmount();

    setup({ status: "admin", prePostEnabled: true });
    expect(await screen.findByRole("tab", { name: "CTAs" })).toBeInTheDocument();
  });

  it("adds a pre-event card behind an Add button", async () => {
    const updatePrePost = vi.fn(async () => {});
    setup({ status: "admin", prePostEnabled: true, templates: { updatePrePost } });
    await userEvent.click(await screen.findByRole("tab", { name: "CTAs" }));
    await userEvent.click(await screen.findByRole("button", { name: "Add Pre-event" }));
    await waitFor(() =>
      expect(updatePrePost).toHaveBeenCalledWith(expect.objectContaining({ id: "t1" }), "pre", { headline: "", message: "", links: [] }),
    );
  });

  it("starts an event from the template", async () => {
    setup();
    await userEvent.click(await screen.findByRole("button", { name: "Create event" }));
    expect(await screen.findByText("Select a day")).toBeInTheDocument();
  });

  it("offers every kind of event to create: hosted, hostless and livestream", async () => {
    setup();
    const group = await screen.findByRole("radiogroup", { name: "Type of event" });
    expect(within(group).getAllByRole("radio").map((radio) => (radio as HTMLInputElement).value)).toEqual([
      "hosted",
      "hostless",
      "livestream",
    ]);
    expect(within(group).getByRole("radio", { name: "Hosted" })).toBeChecked();
    await userEvent.click(within(group).getByRole("radio", { name: "Livestream" }));
    await userEvent.click(screen.getByRole("button", { name: "Create event" }));
    expect(await screen.findByText("Select a day")).toBeInTheDocument();
  });

  it("leaves out hostless where the community has turned it off", async () => {
    renderInCommunity(<TemplatePage />, {
      community: community({ settings: { ...community().settings, enableHostless: false } }),
      route: "/space/civic-lab/discuss/t1",
      path: "/space/:displayId/discuss/:templateId",
      api: {
        templates: { list: async () => [current], get: async () => current },
        events: { listForTemplate: async () => [], listParticipants: async () => [] },
        tags: { listForTemplates: async () => [] },
      } as never,
    });
    const group = await screen.findByRole("radiogroup", { name: "Type of event" });
    expect(within(group).queryByRole("radio", { name: "Hostless" })).not.toBeInTheDocument();
    expect(within(group).getByRole("radio", { name: "Livestream" })).toBeInTheDocument();
  });

  it("holds back event creation while a prerequisite is unmet", async () => {
    setup({ fresh: template({ ...current, prerequisiteTemplateId: "t0" }) });
    expect(await screen.findByText("Prerequisite required")).toBeInTheDocument();
    expect(within(screen.getByRole("main")).getByRole("button", { name: "Create event" })).toBeDisabled();
  });
});
