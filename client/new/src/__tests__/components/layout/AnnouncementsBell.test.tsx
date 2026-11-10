// @vitest-environment jsdom
import { screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it, vi } from "vitest";
import type { Announcement, MembershipStatus } from "@/api/types";
import { announcement } from "@/__tests__/support/fixtures";
import { renderInCommunity } from "@/__tests__/support/renderWithProviders";
import { AnnouncementsBell } from "@/components/layout/AnnouncementsBell";

function renderBell(
  announcements: Announcement[] | (() => Promise<Announcement[]>) = [],
  { status = "member", extra = {} }: { status?: MembershipStatus; extra?: Record<string, unknown> } = {},
) {
  const list = typeof announcements === "function" ? announcements : async () => announcements;
  return renderInCommunity(<AnnouncementsBell />, {
    status,
    api: { announcements: { list, ...extra } } as never,
  });
}

async function openBell(user: ReturnType<typeof userEvent.setup>) {
  await user.click(await screen.findByRole("button", { name: "Show Announcements Button" }));
}

describe("AnnouncementsBell", () => {
  it("stays closed until the bell is clicked, then lists the community's announcements", async () => {
    const user = userEvent.setup();
    renderBell([
      announcement({ id: "a1", title: "Potluck", message: "Bring a dish", createdDate: new Date(2026, 10, 4, 12, 15).toISOString() }),
      announcement({ id: "a2", message: "No title here" }),
    ]);
    expect(screen.queryByText("Announcements")).not.toBeInTheDocument();
    await openBell(user);
    expect(await screen.findByText("Potluck")).toBeInTheDocument();
    expect(screen.getByText("Bring a dish")).toBeInTheDocument();
    // An untitled announcement falls back to a generic heading.
    expect(screen.getByText("Announcement")).toBeInTheDocument();
    expect(screen.getByText("No title here")).toBeInTheDocument();
    // The timestamp is shown for the one that has a creation date.
    expect(screen.getByText(/Nov 4, 2026,? 12:15\s?PM/)).toBeInTheDocument();
  });

  it("says so when there are no announcements", async () => {
    const user = userEvent.setup();
    renderBell([]);
    await openBell(user);
    expect(await screen.findByText("No announcements yet.")).toBeInTheDocument();
  });

  it("shows an error when announcements fail to load", async () => {
    const user = userEvent.setup();
    renderBell(async () => {
      throw new Error("boom");
    });
    await openBell(user);
    expect(await screen.findByText("There was an error while loading Announcements")).toBeInTheDocument();
  });

  it("gives members no way to create or delete announcements", async () => {
    const user = userEvent.setup();
    renderBell([announcement()], { status: "member" });
    await openBell(user);
    await screen.findByText("Welcome!");
    expect(screen.queryByRole("button", { name: "New Announcement" })).not.toBeInTheDocument();
    expect(screen.queryByRole("button", { name: "Delete announcement" })).not.toBeInTheDocument();
  });

  it("lets admins delete an announcement after confirming", async () => {
    const user = userEvent.setup();
    const remove = vi.fn(async () => {});
    const { api } = renderBell([announcement({ id: "a1", title: "Potluck" })], {
      status: "admin",
      extra: { remove },
    });
    await openBell(user);
    await user.click(await screen.findByRole("button", { name: "Delete announcement" }));
    await user.click(await screen.findByRole("button", { name: "Yes" }));
    await waitFor(() => expect(api.announcements.remove).toHaveBeenCalledWith("c1", "a1"));
    expect(await screen.findByText("Announcement deleted")).toBeInTheDocument();
  });

  it("does not delete when the admin answers No", async () => {
    const user = userEvent.setup();
    const remove = vi.fn(async () => {});
    const { api } = renderBell([announcement()], { status: "admin", extra: { remove } });
    await openBell(user);
    await user.click(await screen.findByRole("button", { name: "Delete announcement" }));
    await user.click(await screen.findByRole("button", { name: "No" }));
    await waitFor(() => expect(screen.queryByRole("button", { name: "No" })).not.toBeInTheDocument());
    expect(api.announcements.remove).not.toHaveBeenCalled();
  });

  describe("creating an announcement", () => {
    async function openCreateDialog(user: ReturnType<typeof userEvent.setup>) {
      await openBell(user);
      await user.click(await screen.findByRole("button", { name: "New Announcement" }));
      return screen.findByRole("dialog");
    }

    it("closes the popover and opens a form whose Create button needs a message", async () => {
      const user = userEvent.setup();
      renderBell([], { status: "admin" });
      const dialog = await openCreateDialog(user);
      expect(within(dialog).getByText("Create New Announcement")).toBeInTheDocument();
      expect(within(dialog).getByRole("button", { name: "Create" })).toBeDisabled();
      await user.type(within(dialog).getByLabelText("Enter a message"), "   ");
      expect(within(dialog).getByRole("button", { name: "Create" })).toBeDisabled();
      await user.type(within(dialog).getByLabelText("Enter a message"), "Hello");
      expect(within(dialog).getByRole("button", { name: "Create" })).toBeEnabled();
    });

    it("submits the trimmed title and message, then confirms and closes", async () => {
      const user = userEvent.setup();
      const create = vi.fn(async () => {});
      const { api } = renderBell([], { status: "admin", extra: { create } });
      const dialog = await openCreateDialog(user);
      await user.type(within(dialog).getByLabelText("Enter a title"), "  Potluck ");
      await user.type(within(dialog).getByLabelText("Enter a message"), " Bring a dish  ");
      await user.click(within(dialog).getByRole("button", { name: "Create" }));
      await waitFor(() =>
        expect(api.announcements.create).toHaveBeenCalledWith("c1", { title: "Potluck", message: "Bring a dish" }),
      );
      expect(await screen.findByText("Announcement created")).toBeInTheDocument();
      await waitFor(() => expect(screen.queryByRole("dialog")).not.toBeInTheDocument());
    });

    it("omits the title when it is left blank", async () => {
      const user = userEvent.setup();
      const create = vi.fn(async () => {});
      const { api } = renderBell([], { status: "admin", extra: { create } });
      const dialog = await openCreateDialog(user);
      await user.type(within(dialog).getByLabelText("Enter a message"), "Just a message");
      await user.click(within(dialog).getByRole("button", { name: "Create" }));
      await waitFor(() =>
        expect(api.announcements.create).toHaveBeenCalledWith("c1", { title: undefined, message: "Just a message" }),
      );
    });

    it("keeps the form open and shows an error toast when creating fails", async () => {
      const user = userEvent.setup();
      const create = vi.fn(async () => {
        throw new Error("nope");
      });
      renderBell([], { status: "admin", extra: { create } });
      const dialog = await openCreateDialog(user);
      await user.type(within(dialog).getByLabelText("Enter a message"), "Hello");
      await user.click(within(dialog).getByRole("button", { name: "Create" }));
      expect(await screen.findByText("Something went wrong. Please try again.")).toBeInTheDocument();
      expect(screen.getByRole("dialog")).toBeInTheDocument();
    });
  });
});
