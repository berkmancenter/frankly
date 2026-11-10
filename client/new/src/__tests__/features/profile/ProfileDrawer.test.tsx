// @vitest-environment jsdom
import { act, screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useState } from "react";
import { describe, expect, it, vi } from "vitest";
import type { MemberDetails, MembershipStatus, PublicUser } from "@/api/types";
import { community, membership, user } from "@/__tests__/support/fixtures";
import { renderInCommunity, renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { ProfileDrawer } from "@/features/profile/ProfileDrawer";

const ada = user({ id: "u2", displayName: "Ada Lovelace", about: "First programmer." });

const memberOf = (u: PublicUser, status: MembershipStatus): MemberDetails => ({
  user: u,
  membership: membership({ userId: u.id, status }),
});

describe("ProfileDrawer", () => {
  describe("outside a community", () => {
    it("shows the user's name and about text", async () => {
      const get = vi.fn(async () => ada);
      renderWithProviders(<ProfileDrawer userId="u2" onClose={() => {}} />, { api: { users: { get } } });

      expect(await screen.findByRole("heading", { name: "Ada Lovelace" })).toBeInTheDocument();
      expect(screen.getByText("First programmer.")).toBeInTheDocument();
      expect(get).toHaveBeenCalledWith("u2");
    });

    it("shows a spinner while the user loads", async () => {
      let resolve!: (u: PublicUser) => void;
      const get = vi.fn(() => new Promise<PublicUser>((r) => (resolve = r)));
      renderWithProviders(<ProfileDrawer userId="u2" onClose={() => {}} />, { api: { users: { get } } });

      expect(screen.getByRole("progressbar")).toBeInTheDocument();
      expect(screen.queryByRole("heading")).not.toBeInTheDocument();
      // The way out is available even before the profile arrives.
      expect(screen.getByRole("button", { name: "Close" })).toBeInTheDocument();

      await act(async () => resolve(ada));
      expect(await screen.findByRole("heading", { name: "Ada Lovelace" })).toBeInTheDocument();
      expect(screen.queryByRole("progressbar")).not.toBeInTheDocument();
    });

    it("omits the about text when the user has none", async () => {
      renderWithProviders(<ProfileDrawer userId="u2" onClose={() => {}} />, {
        api: { users: { get: async () => user({ id: "u2", displayName: "Ada Lovelace" }) } },
      });
      await screen.findByRole("heading", { name: "Ada Lovelace" });
      // Only the heading's text and the avatar's initial are in the profile.
      expect(screen.queryByText("First programmer.")).not.toBeInTheDocument();
    });

    it("shows the profile picture when there is one, otherwise the initial", async () => {
      const withImage = user({ id: "u2", displayName: "Ada Lovelace", imageUrl: "https://example.com/ada.png" });
      const { unmount } = renderWithProviders(<ProfileDrawer userId="u2" onClose={() => {}} />, {
        api: { users: { get: async () => withImage } },
      });
      const avatar = await screen.findByTitle("Ada Lovelace");
      expect(avatar.querySelector("img")).toHaveAttribute("src", "https://example.com/ada.png");
      unmount();

      renderWithProviders(<ProfileDrawer userId="u2" onClose={() => {}} />, { api: { users: { get: async () => ada } } });
      const initialAvatar = await screen.findByTitle("Ada Lovelace");
      expect(initialAvatar.querySelector("img")).toBeNull();
      expect(initialAvatar).toHaveTextContent("A");
    });

    it("does not show a role or look up members", async () => {
      const listMembers = vi.fn(async () => [memberOf(ada, "moderator")]);
      renderWithProviders(<ProfileDrawer userId="u2" onClose={() => {}} />, {
        api: { users: { get: async () => ada }, communities: { listMembers } },
      });
      await screen.findByRole("heading", { name: "Ada Lovelace" });

      expect(screen.queryByText("Moderator")).not.toBeInTheDocument();
      expect(listMembers).not.toHaveBeenCalled();
    });

    it("renders at phone width too", async () => {
      renderWithProviders(<ProfileDrawer userId="u2" onClose={() => {}} />, {
        api: { users: { get: async () => ada } },
        mobile: true,
      });
      expect(await screen.findByRole("heading", { name: "Ada Lovelace" })).toBeInTheDocument();
    });
  });

  describe("inside a community", () => {
    const render = (members: MemberDetails[] | (() => Promise<MemberDetails[]>)) => {
      const c = community({ id: "c1" });
      return renderInCommunity(<ProfileDrawer userId="u2" onClose={() => {}} />, {
        community: c,
        api: {
          users: { get: async () => ada },
          // `renderInCommunity` replaces whole namespaces, so keep the community lookup it needs.
          communities: {
            getByDisplayId: async () => c,
            listMembers: typeof members === "function" ? members : async () => members,
          },
        },
      });
    };

    it.each<[MembershipStatus, string]>([
      ["owner", "Owner"],
      ["admin", "Admin"],
      ["moderator", "Moderator"],
      ["facilitator", "Facilitator"],
      ["member", "Member"],
      ["banned", "Banned"],
    ])("shows the user's %s role as %s", async (status, label) => {
      render([memberOf(ada, status)]);
      expect(await screen.findByText(label)).toBeInTheDocument();
      expect(screen.getByRole("heading", { name: "Ada Lovelace" })).toBeInTheDocument();
    });

    it("asks for the members of the current community", async () => {
      const listMembers = vi.fn(async () => [memberOf(ada, "member")]);
      render(listMembers);
      await screen.findByText("Member");
      expect(listMembers).toHaveBeenCalledWith("c1");
    });

    it("shows the role of the viewed user, not of other members", async () => {
      render([memberOf(user({ id: "u1" }), "owner"), memberOf(ada, "facilitator")]);
      expect(await screen.findByText("Facilitator")).toBeInTheDocument();
      expect(screen.queryByText("Owner")).not.toBeInTheDocument();
    });

    it("shows no role for someone who is not in the member list", async () => {
      const listMembers = vi.fn(async () => [memberOf(user({ id: "u1" }), "owner")]);
      render(listMembers);
      await screen.findByRole("heading", { name: "Ada Lovelace" });
      await waitFor(() => expect(listMembers).toHaveBeenCalled());
      expect(screen.queryByText("Owner")).not.toBeInTheDocument();
      expect(screen.queryByText("Non-member")).not.toBeInTheDocument();
    });

    it("still shows the profile when the member list fails to load", async () => {
      const listMembers = vi.fn(async () => {
        throw new Error("boom");
      });
      render(listMembers);
      expect(await screen.findByRole("heading", { name: "Ada Lovelace" })).toBeInTheDocument();
      await waitFor(() => expect(listMembers).toHaveBeenCalled());
      expect(screen.getByText("First programmer.")).toBeInTheDocument();
    });

    it("shows the role next to the name and before the about text", async () => {
      render([memberOf(ada, "moderator")]);
      const heading = await screen.findByRole("heading", { name: "Ada Lovelace" });
      const role = await screen.findByText("Moderator");
      const about = screen.getByText("First programmer.");
      expect(heading.compareDocumentPosition(role) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
      expect(role.compareDocumentPosition(about) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
    });
  });

  describe("closing", () => {
    it("calls onClose from the close button", async () => {
      const onClose = vi.fn();
      const u = userEvent.setup();
      renderWithProviders(<ProfileDrawer userId="u2" onClose={onClose} />, { api: { users: { get: async () => ada } } });
      await screen.findByRole("heading", { name: "Ada Lovelace" });

      await u.click(screen.getByRole("button", { name: "Close" }));

      expect(onClose).toHaveBeenCalledTimes(1);
    });

    it("calls onClose when Escape is pressed", async () => {
      const onClose = vi.fn();
      const u = userEvent.setup();
      renderWithProviders(<ProfileDrawer userId="u2" onClose={onClose} />, { api: { users: { get: async () => ada } } });
      await screen.findByRole("heading", { name: "Ada Lovelace" });

      await u.keyboard("{Escape}");

      expect(onClose).toHaveBeenCalledTimes(1);
    });

    it("can be closed while the profile is still loading", async () => {
      const onClose = vi.fn();
      const u = userEvent.setup();
      renderWithProviders(<ProfileDrawer userId="u2" onClose={onClose} />, {
        api: { users: { get: () => new Promise<PublicUser>(() => {}) } },
      });

      await u.click(screen.getByRole("button", { name: "Close" }));

      expect(onClose).toHaveBeenCalledTimes(1);
    });
  });

  it("switches to another user's profile when the userId changes", async () => {
    const get = vi.fn(async (id: string) => user({ id, displayName: id === "u2" ? "Ada Lovelace" : "Grace Hopper" }));
    const u = userEvent.setup();
    function Switcher() {
      const [id, setId] = useState("u2");
      return (
        <>
          <button onClick={() => setId("u3")}>Next</button>
          <ProfileDrawer userId={id} onClose={() => {}} />
        </>
      );
    }
    renderWithProviders(<Switcher />, { api: { users: { get } } });
    expect(await screen.findByRole("heading", { name: "Ada Lovelace" })).toBeInTheDocument();

    // The drawer is modal, so the button behind it is aria-hidden; reach it by hidden query.
    await u.click(screen.getByRole("button", { name: "Next", hidden: true }));

    expect(await screen.findByRole("heading", { name: "Grace Hopper" })).toBeInTheDocument();
    expect(within(document.body).queryByRole("heading", { name: "Ada Lovelace" })).not.toBeInTheDocument();
  });

  it("stops showing a spinner when the user fails to load", async () => {
    const get = vi.fn(async () => {
      throw new Error("not found");
    });
    renderWithProviders(<ProfileDrawer userId="ghost" onClose={() => {}} />, { api: { users: { get } } });
    await waitFor(() => expect(get).toHaveBeenCalled());
    await waitFor(() => expect(screen.queryByRole("progressbar")).not.toBeInTheDocument());
  });
});
