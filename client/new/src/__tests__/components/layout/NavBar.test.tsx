// @vitest-environment jsdom
import { screen, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useLocation } from "react-router";
import { describe, expect, it, vi } from "vitest";
import type { Community, CommunitySettings, MembershipStatus } from "@/api/types";
import { community, me, resource } from "@/__tests__/support/fixtures";
import { renderInCommunity, renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { NavBar } from "@/components/layout/NavBar";

function Location() {
  const { pathname, search } = useLocation();
  return <div data-testid="location">{`${pathname}${search}`}</div>;
}

const settings = (over: Partial<CommunitySettings>): Community["settings"] => ({
  ...community().settings,
  ...over,
});

interface Options {
  status?: MembershipStatus;
  community?: Community;
  mobile?: boolean;
  route?: string;
  resources?: ReturnType<typeof resource>[];
  onMenuClick?: () => void;
}

function renderInSpace({
  status = "member",
  community: c = community(),
  mobile,
  route = "/space/civic-lab/discuss/upcoming",
  resources = [],
  onMenuClick = vi.fn(),
}: Options = {}) {
  return {
    onMenuClick,
    ...renderInCommunity(
      <>
        <NavBar onMenuClick={onMenuClick} />
        <Location />
      </>,
      {
        community: c,
        status,
        mobile,
        route,
        api: {
          resources: { list: async () => resources },
          announcements: { list: async () => [] },
        },
      },
    ),
  };
}

const navLabels = () =>
  screen
    .queryAllByRole("button")
    .map((b) => b.textContent || b.getAttribute("aria-label"))
    .filter(Boolean);

describe("NavBar outside a community", () => {
  it("shows the Frankly logo and the profile menu, but no community links", async () => {
    renderWithProviders(<NavBar onMenuClick={() => {}} />, { api: { me: { get: async () => me() } } });
    expect(screen.getByRole("link", { name: "Frankly home" })).toHaveAttribute("href", "/home");
    expect(await screen.findByRole("button", { name: "Profile Button" })).toBeInTheDocument();
    for (const name of ["Events", "Posts", "Resources", "Templates", "Admin"]) {
      expect(screen.queryByRole("button", { name })).not.toBeInTheDocument();
    }
  });

  it("opens the sidebar from the menu button", async () => {
    const user = userEvent.setup();
    const onMenuClick = vi.fn();
    renderWithProviders(<NavBar onMenuClick={onMenuClick} />);
    await user.click(screen.getByRole("button", { name: "Show sidebar" }));
    expect(onMenuClick).toHaveBeenCalledTimes(1);
  });
});

describe("NavBar in a community on a wide screen", () => {
  it("shows the community's name and its section links to a member", async () => {
    renderInSpace({ status: "member" });
    expect(await screen.findByRole("button", { name: "Civic Lab" })).toBeInTheDocument();
    expect(navLabels()).toEqual(
      expect.arrayContaining(["Events", "Posts", "Templates", "Show Announcements Button", "Show sidebar"]),
    );
    // No resources yet and a member cannot add any: the tab is hidden.
    expect(screen.queryByRole("button", { name: "Resources" })).not.toBeInTheDocument();
    expect(screen.queryByRole("button", { name: "Admin" })).not.toBeInTheDocument();
    expect(screen.queryByRole("button", { name: "Follow community" })).not.toBeInTheDocument();
  });

  it("navigates when a link is clicked", async () => {
    const user = userEvent.setup();
    renderInSpace({ status: "member" });
    await user.click(await screen.findByRole("button", { name: "Posts" }));
    expect(screen.getByTestId("location")).toHaveTextContent("/space/civic-lab/posts");
    await user.click(screen.getByRole("button", { name: "Templates" }));
    expect(screen.getByTestId("location")).toHaveTextContent("/space/civic-lab/discuss");
    await user.click(screen.getByRole("button", { name: "Events" }));
    expect(screen.getByTestId("location")).toHaveTextContent("/space/civic-lab/discuss/upcoming");
    await user.click(screen.getByRole("button", { name: "Civic Lab" }));
    expect(screen.getByTestId("location").textContent).toBe("/space/civic-lab");
  });

  it("hides Posts when discussions are turned off", async () => {
    renderInSpace({ community: community({ settings: settings({ enableDiscussionThreads: false }) }) });
    await screen.findByRole("button", { name: "Events" });
    expect(screen.queryByRole("button", { name: "Posts" })).not.toBeInTheDocument();
  });

  it("shows Resources once the community has some", async () => {
    renderInSpace({ resources: [resource()] });
    expect(await screen.findByRole("button", { name: "Resources" })).toBeInTheDocument();
  });

  it("always shows Resources and the Admin button to admins", async () => {
    const user = userEvent.setup();
    renderInSpace({ status: "admin" });
    expect(await screen.findByRole("button", { name: "Resources" })).toBeInTheDocument();
    await user.click(screen.getByRole("button", { name: "Admin" }));
    expect(screen.getByTestId("location")).toHaveTextContent("/space/civic-lab/admin/profile");
  });

  it("offers non-members a Follow button instead of the announcements bell", async () => {
    renderInSpace({ status: "nonmember" });
    expect(await screen.findByRole("button", { name: "Follow community" })).toBeInTheDocument();
    expect(screen.queryByRole("button", { name: "Show Announcements Button" })).not.toBeInTheDocument();
  });
});

describe("NavBar in a community on a phone-width screen", () => {
  it("replaces the text links with icon buttons", async () => {
    const user = userEvent.setup();
    renderInSpace({ status: "member", mobile: true });
    const events = await screen.findByRole("button", { name: "Events" });
    // Icon buttons carry no visible text.
    expect(events.textContent).toBe("");
    expect(screen.queryByRole("button", { name: "Civic Lab" })).not.toBeInTheDocument();
    expect(screen.queryByRole("button", { name: "Show Announcements Button" })).not.toBeInTheDocument();
    expect(screen.queryByRole("button", { name: "Profile Button" })).not.toBeInTheDocument();
    await user.click(screen.getByRole("button", { name: "Posts" }));
    expect(screen.getByTestId("location")).toHaveTextContent("/space/civic-lab/posts");
  });

  it("shows only the Follow button to non-members", async () => {
    renderInSpace({ status: "nonmember", mobile: true });
    expect(await screen.findByRole("button", { name: "Follow community" })).toBeInTheDocument();
    expect(screen.queryByRole("button", { name: "Events" })).not.toBeInTheDocument();
  });

  it("still shows the Admin button to admins", async () => {
    renderInSpace({ status: "admin", mobile: true });
    expect(await screen.findByRole("button", { name: "Admin" })).toBeInTheDocument();
  });
});

describe("NavBar onboarding banner", () => {
  const onboarding = (over: Partial<Community> = {}) =>
    community({ isOnboardingOverviewEnabled: true, onboardingSteps: [], ...over });

  it("appears for admins on the community home and can be dismissed", async () => {
    const user = userEvent.setup();
    renderInSpace({ status: "admin", community: onboarding(), route: "/space/civic-lab" });
    const banner = await screen.findByRole("region", { name: "Community onboarding" });
    expect(within(banner).getByText("Brand your space")).toBeInTheDocument();
    await user.click(within(banner).getByRole("button", { name: "Dismiss onboarding" }));
    expect(screen.queryByRole("region", { name: "Community onboarding" })).not.toBeInTheDocument();
  });

  it("is hidden away from the community home", async () => {
    renderInSpace({ status: "admin", community: onboarding(), route: "/space/civic-lab/posts" });
    await screen.findByRole("button", { name: "Admin" });
    expect(screen.queryByRole("region", { name: "Community onboarding" })).not.toBeInTheDocument();
  });

  it("is hidden from members, who cannot act on it", async () => {
    renderInSpace({ status: "member", community: onboarding(), route: "/space/civic-lab" });
    await screen.findByRole("button", { name: "Events" });
    expect(screen.queryByRole("region", { name: "Community onboarding" })).not.toBeInTheDocument();
  });

  it("is hidden when the overview is disabled or already complete", async () => {
    const { unmount } = renderInSpace({
      status: "admin",
      community: onboarding({ isOnboardingOverviewEnabled: false }),
      route: "/space/civic-lab",
    });
    await screen.findByRole("button", { name: "Admin" });
    expect(screen.queryByRole("region", { name: "Community onboarding" })).not.toBeInTheDocument();
    unmount();

    renderInSpace({
      status: "admin",
      community: onboarding({ onboardingSteps: ["brandSpace", "createTemplate", "hostEvent", "inviteSomeone"] }),
      route: "/space/civic-lab",
    });
    await screen.findByRole("button", { name: "Admin" });
    expect(screen.queryByRole("region", { name: "Community onboarding" })).not.toBeInTheDocument();
  });
});
