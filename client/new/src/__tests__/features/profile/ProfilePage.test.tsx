// @vitest-environment jsdom
import { screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it, vi } from "vitest";
import { anonymousSession } from "@/__tests__/support/fakeAuth";
import { community, event, me, membership, user } from "@/__tests__/support/fixtures";
import { renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { ProfilePage } from "@/features/profile/ProfilePage";

// `Upload` resolves an image host on import; none of these tests open the picker.
vi.mock("@/utils/imageUpload", async (importActual) => {
  const actual = await importActual<typeof import("@/utils/imageUpload")>();
  return { ...actual, resolveImageUploadProvider: () => ({ provider: { upload: async () => ({ url: "x" }) } }) };
});

const DAY = 24 * 60 * 60 * 1000;
const soon = new Date(Date.now() + 3 * DAY).toISOString();
const earlier = new Date(Date.now() - 3 * DAY).toISOString();

const ada = user({ about: "Mathematician", socialLinks: [{ platform: "twitter", url: "https://x.example/ada" }] });
const lab = community();
const book = community({ id: "c2", displayId: "book-club", name: "Book Club" });

function setup(route = "/profile", api: Record<string, unknown> = {}) {
  return renderWithProviders(<ProfilePage />, {
    route,
    api: {
      me: {
        get: async () =>
          me({
            user: ada,
            memberships: [
              membership({ communityId: "c1", status: "member" }),
              membership({ communityId: "c2", status: "owner" }),
            ],
          }),
      },
      communities: { listMine: async () => [lab, book] },
      events: {
        listMine: async () => [
          event({ id: "later", title: "Future talk", scheduledTime: soon }),
          event({ id: "earlier", title: "Past talk", scheduledTime: earlier }),
          event({ id: "canceled", title: "Canceled talk", status: "canceled", scheduledTime: soon }),
        ],
      },
      ...api,
    } as never,
  });
}

describe("ProfilePage", () => {
  it("asks an anonymous visitor to sign in", () => {
    renderWithProviders(<ProfilePage />, { route: "/profile", auth: anonymousSession() });
    expect(screen.getByText("Must be logged in to access this section")).toBeInTheDocument();
  });

  describe("my events", () => {
    it("opens on the events tab, split into upcoming and history", async () => {
      setup();
      expect(await screen.findByText("Future talk")).toBeInTheDocument();
      expect(screen.getByText("Past talk")).toBeInTheDocument();
      expect(screen.queryByText("Canceled talk")).not.toBeInTheDocument();
      expect(screen.getByRole("heading", { name: "UPCOMING" })).toBeInTheDocument();
      expect(screen.getByRole("heading", { name: "HISTORY" })).toBeInTheDocument();
    });

    it("says so when there are no events", async () => {
      setup("/profile", { events: { listMine: async () => [] } });
      expect(await screen.findAllByText("No events found")).toHaveLength(2);
    });

    it("explains when the events cannot be loaded", async () => {
      setup("/profile", { events: { listMine: async () => { throw new Error("offline"); } } });
      expect(await screen.findByRole("alert")).toHaveTextContent("Something went wrong loading your events.");
    });
  });

  it("opens the tab named in the URL, and changes it from the tab bar", async () => {
    setup("/profile?section=profile");
    expect(await screen.findByLabelText("Name")).toHaveValue("Ada Lovelace");
    await userEvent.click(screen.getByRole("tab", { name: "My Events" }));
    expect(await screen.findByText("Future talk")).toBeInTheDocument();
    expect(screen.getByRole("tab", { name: "My Events" })).toHaveAttribute("aria-selected", "true");
  });

  it("falls back to the events tab for an unknown section", async () => {
    setup("/profile?section=billing");
    expect(await screen.findByText("Future talk")).toBeInTheDocument();
  });

  describe("profile", () => {
    it("shows the saved profile, and only enables saving once something changes", async () => {
      setup("/profile?section=profile");
      expect(await screen.findByLabelText("About me")).toHaveValue("Mathematician");
      expect(screen.getByLabelText("Twitter URL")).toHaveValue("https://x.example/ada");
      expect(screen.getByRole("button", { name: "Update Profile" })).toBeDisabled();
      await userEvent.type(screen.getByLabelText("Name"), "!");
      expect(screen.getByRole("button", { name: "Update Profile" })).toBeEnabled();
    });

    it("saves the changes, dropping empty links", async () => {
      const updateMe = vi.fn(async () => ({ ...ada, displayName: "Ada L" }));
      setup("/profile?section=profile", { users: { updateMe } });
      const name = await screen.findByLabelText("Name");
      await userEvent.clear(name);
      await userEvent.type(name, "Ada L");
      await userEvent.type(screen.getByLabelText("Instagram URL"), "https://ig.example/ada");
      await userEvent.click(screen.getByRole("button", { name: "Update Profile" }));
      await waitFor(() =>
        expect(updateMe).toHaveBeenCalledWith({
          displayName: "Ada L",
          about: "Mathematician",
          socialLinks: [
            { platform: "instagram", url: "https://ig.example/ada" },
            { platform: "twitter", url: "https://x.example/ada" },
          ],
        }),
      );
      expect(await screen.findByText("Profile updated")).toBeInTheDocument();
    });

    it("refuses to save an empty name", async () => {
      setup("/profile?section=profile");
      await userEvent.clear(await screen.findByLabelText("Name"));
      expect(screen.getByRole("button", { name: "Update Profile" })).toBeDisabled();
    });

    it("says so when the save fails", async () => {
      setup("/profile?section=profile", { users: { updateMe: async () => { throw new Error("nope"); } } });
      await userEvent.type(await screen.findByLabelText("Name"), "!");
      await userEvent.click(screen.getByRole("button", { name: "Update Profile" }));
      expect(await screen.findByText("Something went wrong. Please try again.")).toBeInTheDocument();
    });

    it("previews the public profile", async () => {
      setup("/profile?section=profile", { users: { get: async () => ada } });
      await userEvent.click(await screen.findByRole("button", { name: "Preview" }));
      expect(await screen.findByText("Mathematician", { selector: "p" })).toBeInTheDocument();
    });
  });

  describe("tags and contact details", () => {
    const poetry = { id: "d1", title: "poetry" };

    it("shows the profile's tags and removes one", async () => {
      const removeFromMyProfile = vi.fn(async () => {});
      setup("/profile?section=profile", {
        tags: { listForUser: async () => [poetry], suggest: async () => [], removeFromMyProfile },
      });
      const chip = await screen.findByText("#poetry");
      await userEvent.click(chip.parentElement!.querySelector("svg")!);
      await waitFor(() => expect(removeFromMyProfile).toHaveBeenCalledWith("d1"));
    });

    it("adds a typed tag without its leading #", async () => {
      const addToMyProfile = vi.fn(async (title: string) => ({ id: "d2", title }));
      setup("/profile?section=profile", {
        tags: { listForUser: async () => [], suggest: async () => [], addToMyProfile },
      });
      await userEvent.type(await screen.findByLabelText("Add a tag"), "#gardening{Enter}");
      await waitFor(() => expect(addToMyProfile).toHaveBeenCalledWith("gardening"));
    });

    it("previews tags, a link per social platform and the user's own email", async () => {
      setup("/profile?section=profile", {
        users: { get: async () => ada, email: async () => "ada@example.com" },
        tags: { listForUser: async () => [poetry], suggest: async () => [] },
      });
      await userEvent.click(await screen.findByRole("button", { name: "Preview" }));
      expect(await screen.findByRole("link", { name: "twitter" })).toHaveAttribute("href", "https://x.example/ada");
      expect(await screen.findByRole("link", { name: "ada@example.com" })).toHaveAttribute(
        "href",
        "mailto:ada@example.com",
      );
      expect(screen.getAllByText("#poetry").length).toBeGreaterThan(0);
    });

    it("never turns a script link into a link", async () => {
      const sneaky = user({ socialLinks: [{ platform: "facebook", url: "javascript:alert(1)" }] });
      setup("/profile?section=profile", {
        users: { get: async () => sneaky, email: async () => undefined },
        tags: { listForUser: async () => [], suggest: async () => [] },
      });
      await userEvent.click(await screen.findByRole("button", { name: "Preview" }));
      await screen.findByRole("heading", { name: sneaky.displayName });
      expect(screen.queryByRole("link", { name: "facebook" })).not.toBeInTheDocument();
    });
  });

  describe("notifications", () => {
    const settings = { notifyAnnouncements: true, notifyEvents: true };

    it("shows the first community's settings, owners first", async () => {
      setup("/profile?section=notifications", { notifications: { get: async () => settings } });
      expect(await screen.findByText("Settings for Book Club")).toBeInTheDocument();
      expect(screen.getByLabelText("Notify me about new events")).toBeChecked();
    });

    it("opens the community named in the URL", async () => {
      setup("/profile?section=notifications&communityId=c1", { notifications: { get: async () => settings } });
      expect(await screen.findByText("Settings for Civic Lab")).toBeInTheDocument();
    });

    it("saves a change as soon as it is made", async () => {
      const update = vi.fn(async () => ({ ...settings, notifyEvents: false }));
      setup("/profile?section=notifications&communityId=c1", {
        notifications: { get: async () => settings, update },
      });
      await userEvent.click(await screen.findByLabelText("Notify me about new events"));
      await waitFor(() => expect(update).toHaveBeenCalledWith("c1", { notifyEvents: false }));
      await waitFor(() => expect(screen.getByLabelText("Notify me about new events")).not.toBeChecked());
    });

    it("explains when the user belongs to no communities", async () => {
      setup("/profile?section=notifications", { me: { get: async () => me({ user: ada }) } });
      expect(await screen.findByText("You aren't a member of any communities.")).toBeInTheDocument();
    });

    it("explains when the settings cannot be loaded", async () => {
      setup("/profile?section=notifications", {
        notifications: { get: async () => { throw new Error("offline"); } },
      });
      expect(await screen.findByRole("alert")).toHaveTextContent("Something went wrong loading notification settings.");
    });
  });
});

describe("ProfilePage title", () => {
  it('names the tab "Frankly - User Settings" and restores it on leaving', () => {
    document.title = "Before";
    const { unmount } = setup();
    expect(document.title).toBe("Frankly - User Settings");
    unmount();
    expect(document.title).toBe("Before");
  });
});
