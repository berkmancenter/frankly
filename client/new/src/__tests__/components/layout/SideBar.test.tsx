// @vitest-environment jsdom
import { screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useLocation } from "react-router";
import { afterEach, describe, expect, it, vi } from "vitest";
import type { Community, MembershipStatus } from "@/api/types";
import { community, me, membership, user as userFixture } from "@/__tests__/support/fixtures";
import { renderInCommunity, renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { SideBar } from "@/components/layout/SideBar";

function Location() {
  const { pathname } = useLocation();
  return <div data-testid="location">{pathname}</div>;
}

const lab = community({ id: "c1", displayId: "civic-lab", name: "Civic Lab" });
const book = community({ id: "c2", displayId: "book-club", name: "Book Club" });

/** The api a signed-in user sees: they follow these communities with these statuses. */
function apiFor(memberships: [Community, MembershipStatus][], { isAppOwner = false } = {}) {
  return {
    me: {
      get: async () =>
        me({
          user: userFixture({ isAppOwner }),
          memberships: memberships.map(([c, status]) => membership({ communityId: c.id, status })),
        }),
    },
    communities: { listMine: async () => memberships.map(([c]) => c) },
    resources: { list: async () => [] },
  };
}

function renderSideBar(
  memberships: [Community, MembershipStatus][],
  { route = "/home", onClose = vi.fn(), isAppOwner = false } = {},
) {
  return {
    onClose,
    ...renderWithProviders(
      <>
        <SideBar onClose={onClose} />
        <Location />
      </>,
      { api: apiFor(memberships, { isAppOwner }), route },
    ),
  };
}

afterEach(() => vi.restoreAllMocks());

describe("SideBar", () => {
  it("shows a spinner while the user's communities load", () => {
    renderWithProviders(<SideBar onClose={() => {}} />, {
      api: { me: { get: async () => me() }, communities: { listMine: () => new Promise(() => {}) } },
    });
    expect(screen.getByRole("progressbar")).toBeInTheDocument();
  });

  it("lists the communities the user follows", async () => {
    renderSideBar([
      [lab, "member"],
      [book, "member"],
    ]);
    expect(await screen.findByText("Civic Lab")).toBeInTheDocument();
    expect(screen.getByText("Book Club")).toBeInTheDocument();
  });

  it("closes from the close button", async () => {
    const user = userEvent.setup();
    const { onClose } = renderSideBar([[lab, "member"]]);
    await user.click(screen.getByRole("button", { name: "Close" }));
    expect(onClose).toHaveBeenCalledTimes(1);
  });

  describe("a community's links", () => {
    it("are shown directly when it is the only community", async () => {
      renderSideBar([[lab, "member"]]);
      expect(await screen.findByRole("button", { name: "Events" })).toBeInTheDocument();
      expect(screen.getByRole("button", { name: "Posts" })).toBeInTheDocument();
      expect(screen.getByRole("button", { name: "Templates" })).toBeInTheDocument();
      // A single community cannot be collapsed.
      expect(screen.queryByRole("button", { name: "Collapse" })).not.toBeInTheDocument();
      expect(screen.queryByRole("button", { name: "Expand" })).not.toBeInTheDocument();
    });

    it("navigate and close the drawer", async () => {
      const user = userEvent.setup();
      const { onClose } = renderSideBar([[lab, "member"]]);
      await user.click(await screen.findByRole("button", { name: "Posts" }));
      expect(screen.getByTestId("location")).toHaveTextContent("/space/civic-lab/posts");
      expect(onClose).toHaveBeenCalledTimes(1);
    });

    it("open the community home from its name", async () => {
      const user = userEvent.setup();
      renderSideBar([[lab, "member"]]);
      await user.click(await screen.findByRole("button", { name: "Civic Lab" }));
      expect(screen.getByTestId("location").textContent).toBe("/space/civic-lab");
    });

    it("leave out Posts when discussions are disabled", async () => {
      const quiet = community({
        ...lab,
        settings: { ...lab.settings, enableDiscussionThreads: false },
      });
      renderSideBar([[quiet, "member"]]);
      await screen.findByRole("button", { name: "Events" });
      expect(screen.queryByRole("button", { name: "Posts" })).not.toBeInTheDocument();
    });

    it("include Resources and Admin, but not Unfollow, for admins", async () => {
      const user = userEvent.setup();
      renderSideBar([[lab, "admin"]]);
      expect(await screen.findByRole("button", { name: "Resources" })).toBeInTheDocument();
      expect(screen.queryByRole("button", { name: "Unfollow" })).not.toBeInTheDocument();
      await user.click(screen.getByRole("button", { name: "Admin" }));
      expect(screen.getByTestId("location")).toHaveTextContent("/space/civic-lab/admin/profile");
    });

    it("show a Follow button instead of links to people who do not follow it", async () => {
      renderSideBar([[lab, "nonmember"]]);
      expect(await screen.findByRole("button", { name: "Follow community" })).toBeInTheDocument();
      expect(screen.queryByRole("button", { name: "Events" })).not.toBeInTheDocument();
    });
  });

  describe("unfollowing", () => {
    it("asks for confirmation, then unfollows", async () => {
      const user = userEvent.setup();
      const { api } = renderWithProviders(<SideBar onClose={() => {}} />, {
        api: { ...apiFor([[lab, "member"]]), communities: { listMine: async () => [lab], unfollow: async () => {} } },
      });
      await user.click(await screen.findByRole("button", { name: "Unfollow" }));
      const dialog = await screen.findByRole("dialog");
      expect(within(dialog).getByText("Unfollow Civic Lab?")).toBeInTheDocument();
      await user.click(within(dialog).getByRole("button", { name: "Unfollow" }));
      await waitFor(() => expect(api.communities.unfollow).toHaveBeenCalledWith("c1"));
    });

    it("does nothing when the user cancels", async () => {
      const user = userEvent.setup();
      const { api } = renderWithProviders(<SideBar onClose={() => {}} />, {
        api: { ...apiFor([[lab, "member"]]), communities: { listMine: async () => [lab], unfollow: async () => {} } },
      });
      await user.click(await screen.findByRole("button", { name: "Unfollow" }));
      await user.click(await screen.findByRole("button", { name: "Cancel" }));
      await waitFor(() => expect(screen.queryByRole("dialog")).not.toBeInTheDocument());
      expect(api.communities.unfollow).not.toHaveBeenCalled();
    });
  });

  describe("with several communities", () => {
    const both: [Community, MembershipStatus][] = [
      [lab, "member"],
      [book, "member"],
    ];

    it("collapses all of them away from a community route", async () => {
      const user = userEvent.setup();
      renderSideBar(both, { route: "/home" });
      await screen.findByText("Civic Lab");
      expect(screen.getAllByRole("button", { name: "Expand" })).toHaveLength(2);
      expect(screen.queryByRole("button", { name: "Events" })).not.toBeInTheDocument();

      await user.click(screen.getAllByRole("button", { name: "Expand" })[0]!);
      expect(await screen.findByRole("button", { name: "Events" })).toBeInTheDocument();
      expect(screen.getByRole("button", { name: "Collapse" })).toBeInTheDocument();
    });

    it("puts the current community first and opens it", async () => {
      renderInCommunity(<SideBar onClose={() => {}} />, {
        community: book,
        route: "/space/book-club",
        api: {
          ...apiFor(both),
          // `api` replaces whole namespaces, so the scope's own lookup is restated here.
          communities: { getByDisplayId: async () => book, listMine: async () => both.map(([c]) => c) },
        },
      });
      // Only the current community's links are showing, and it is listed ahead of the other.
      expect(await screen.findByRole("button", { name: "Events" })).toBeInTheDocument();
      // The other community arrives with the list; it starts collapsed.
      expect(await screen.findByRole("button", { name: "Expand" })).toBeInTheDocument();
      expect(screen.getAllByRole("button", { name: "Collapse" })).toHaveLength(1);
      expect(screen.getAllByRole("button", { name: "Events" })).toHaveLength(1);
      const names = screen.getAllByRole("button", { name: /Civic Lab|Book Club/ }).map((b) => b.textContent);
      expect(names).toEqual(["Book Club", "Civic Lab"]);
    });
  });

  describe("start a community", () => {
    it("is offered to app owners and hands off to the new-space page", async () => {
      const user = userEvent.setup();
      const { onClose } = renderSideBar([[lab, "member"]], { isAppOwner: true });
      await user.click(await screen.findByRole("button", { name: "Start a community" }));
      expect(onClose).toHaveBeenCalledTimes(1);
      expect(screen.getByTestId("location")).toHaveTextContent("/newspace");
    });

    it("is not offered to everyone else", async () => {
      renderSideBar([[lab, "member"]]);
      await screen.findByText("Civic Lab");
      expect(screen.queryByText("Start a community")).not.toBeInTheDocument();
    });
  });

  describe("global links", () => {
    it("goes to Frankly Home and closes", async () => {
      const user = userEvent.setup();
      const { onClose } = renderSideBar([[lab, "member"]], { route: "/space/civic-lab" });
      await user.click(screen.getByRole("button", { name: "Frankly Home" }));
      expect(screen.getByTestId("location")).toHaveTextContent("/home");
      expect(onClose).toHaveBeenCalledTimes(1);
    });

    it.each(["Help Center", "About Frankly", "Privacy Policy"])("opens %s in a new tab", async (name) => {
      const user = userEvent.setup();
      const open = vi.spyOn(window, "open").mockImplementation(() => null);
      renderSideBar([[lab, "member"]]);
      await user.click(screen.getByRole("button", { name }));
      expect(open).toHaveBeenCalledWith("https://berkmancenter.github.io/frankly", "_blank", "noopener,noreferrer");
    });

    it("shows the license line and version", () => {
      renderSideBar([]);
      expect(screen.getByText(/Open-source deliberation software \(AGPL-3\.0\)/)).toBeInTheDocument();
      expect(screen.getByText(/v0\.1\.0/)).toBeInTheDocument();
    });
  });
});
