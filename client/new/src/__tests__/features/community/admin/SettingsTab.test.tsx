// @vitest-environment jsdom
import { screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it, vi } from "vitest";
import type { Community } from "@/api/types";
import { community } from "@/__tests__/support/fixtures";
import { renderInCommunity } from "@/__tests__/support/renderWithProviders";
import { SettingsTab } from "@/features/community/admin/SettingsTab";
import { enableDevAdminSettings } from "@/utils/appInfo";

vi.mock("@/utils/appInfo", async (importOriginal) => ({
  ...(await importOriginal<typeof import("@/utils/appInfo")>()),
  enableDevAdminSettings: vi.fn(() => false),
}));

beforeEach(() => vi.mocked(enableDevAdminSettings).mockReturnValue(false));

const base = community();

function setup(over: Partial<Community> = {}, update = vi.fn<(community: Community, patch: object) => Promise<void>>(async () => {})) {
  const current = { ...base, ...over };
  const view = renderInCommunity(<SettingsTab />, {
    community: current,
    status: "admin",
    api: { communities: { getByDisplayId: async () => current, update } },
  });
  return { update, current, ...view };
}

const toggle = (name: string) => screen.findByRole("switch", { name });

describe("SettingsTab", () => {
  it("shows how the community is set up", async () => {
    setup({
      settings: { ...base.settings, dontAllowMembersToCreateMeetings: true, allowUnofficialTemplates: true, disableEmailDigests: true },
    });
    expect(await toggle("Allow members to create events")).not.toBeChecked();
    expect(screen.getByRole("switch", { name: "Allow members to create templates" })).toBeChecked();
    expect(screen.getByRole("switch", { name: "Require approval for new members" })).not.toBeChecked();
    // Stored the other way round.
    expect(screen.getByRole("switch", { name: "Enable weekly email digests of upcoming events" })).not.toBeChecked();
  });

  it("explains each switch", async () => {
    setup();
    await toggle("Chat");
    expect(screen.getByText(/Enables participant messaging on event landing pages/)).toBeInTheDocument();
    expect(screen.getByText(/Define default settings for events within your community/)).toBeInTheDocument();
  });

  it("treats event switches the community never set as on", async () => {
    setup({ eventSettings: { chat: false } });
    expect(await toggle("Chat")).not.toBeChecked();
    for (const name of ["Floating Chat", "Recording", "Odometer", "Agenda Preview"]) {
      expect(screen.getByRole("switch", { name })).toBeChecked();
    }
  });

  it("saves a flipped community switch together with the rest of the settings", async () => {
    const { update, current } = setup({
      settings: { ...base.settings, dontAllowMembersToCreateMeetings: true, featuredOrder: 3 },
    });
    await userEvent.click(await toggle("Allow members to create events"));
    await waitFor(() => expect(update).toHaveBeenCalledTimes(1));
    expect(update).toHaveBeenCalledWith(current, {
      settings: { ...current.settings, dontAllowMembersToCreateMeetings: false },
    });
    // What the platform team stored is kept as is.
    expect(vi.mocked(update).mock.calls[0]![1]).toMatchObject({ settings: { featuredOrder: 3 } });
  });

  it("flips the settings that are stored the other way round", async () => {
    const { update, current } = setup();
    await userEvent.click(await toggle("Enable weekly email digests of upcoming events"));
    await waitFor(() =>
      expect(update).toHaveBeenCalledWith(current, { settings: { ...current.settings, disableEmailDigests: true } }),
    );
  });

  it("saves a flipped event switch", async () => {
    const { update, current } = setup({ eventSettings: { chat: true, talkingTimer: true } });
    await userEvent.click(await toggle("Odometer"));
    await waitFor(() =>
      expect(update).toHaveBeenCalledWith(current, { eventSettings: { chat: true, talkingTimer: false } }),
    );
  });

  it("holds the switch while its change saves", async () => {
    let finish!: () => void;
    const update = vi.fn(() => new Promise<void>((resolve) => (finish = resolve)));
    setup({}, update);
    await userEvent.click(await toggle("Chat"));
    const row = screen.getByText("Chat").closest("div")!;
    expect(within(row).queryByRole("switch")).not.toBeInTheDocument();
    expect(within(row).getByRole("progressbar")).toBeInTheDocument();
    finish();
    expect(await toggle("Chat")).toBeInTheDocument();
    expect(update).toHaveBeenCalledTimes(1);
  });

  it("tells the admin when a change could not be saved", async () => {
    setup({}, vi.fn(async () => {
      throw new Error("offline");
    }));
    await userEvent.click(await toggle("Chat"));
    expect(await screen.findByText("Something went wrong. Please try again.")).toBeInTheDocument();
    expect(await toggle("Chat")).toBeInTheDocument();
  });

  it("leaves out the developer switches in production", async () => {
    setup();
    await toggle("Chat");
    expect(screen.queryByRole("heading", { name: "Developer Settings" })).not.toBeInTheDocument();
  });

  it("lists every switch, labeled from its name, for developers", async () => {
    vi.mocked(enableDevAdminSettings).mockReturnValue(true);
    const { update, current } = setup();
    expect(await screen.findByRole("heading", { name: "Developer Settings" })).toBeInTheDocument();
    expect(screen.getByRole("switch", { name: "Enable A/V Check" })).toBeChecked();
    expect(screen.getByRole("switch", { name: "Multiple People On Stage" })).not.toBeChecked();
    expect(screen.getByRole("switch", { name: "Reminder Emails" })).toBeInTheDocument();
    await userEvent.click(screen.getByRole("switch", { name: "Enable A/V Check" }));
    await waitFor(() =>
      expect(update).toHaveBeenCalledWith(current, { settings: { ...current.settings, enableAVCheck: false } }),
    );
  });
});
