// @vitest-environment jsdom
import { screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it, vi } from "vitest";
import { useLocation } from "react-router";
import { anonymousSession } from "@/__tests__/support/fakeAuth";
import { community } from "@/__tests__/support/fixtures";
import { renderInCommunity } from "@/__tests__/support/renderWithProviders";
import { CommunityAdminPage } from "@/features/community/admin/CommunityAdminPage";

// Each tab has its own tests.
vi.mock("@/features/community/admin/OverviewTab", () => ({ OverviewTab: () => <div>profile content</div> }));
vi.mock("@/features/community/admin/MembersTab", () => ({ MembersTab: () => <div>members content</div> }));
vi.mock("@/features/community/admin/DataTab", () => ({ DataTab: () => <div>data content</div> }));
vi.mock("@/features/community/admin/SettingsTab", () => ({ SettingsTab: () => <div>settings content</div> }));

function Location() {
  return <div data-testid="location">{useLocation().pathname}</div>;
}

const page = (
  <>
    <CommunityAdminPage />
    <Location />
  </>
);
const route = (tab?: string) => (tab ? `/space/civic-lab/admin/${tab}` : "/space/civic-lab/admin");
const options = { path: "/space/:displayId/admin/:tab?", community: community({ name: "Civic Lab" }) };

describe("CommunityAdminPage", () => {
  it("tells anyone but an admin that the section is not theirs", async () => {
    renderInCommunity(page, { ...options, status: "moderator", route: route() });
    expect(
      await screen.findByText("Must be logged in and an admin to access this section"),
    ).toBeInTheDocument();
    expect(screen.queryByRole("tab")).not.toBeInTheDocument();
  });

  it("asks a visitor without an account to sign in", async () => {
    renderInCommunity(page, { ...options, status: "nonmember", auth: anonymousSession(), route: route() });
    expect(await screen.findByRole("dialog", { name: "Sign in" })).toBeInTheDocument();
  });

  it("shows an admin the four tabs, on the profile tab first", async () => {
    renderInCommunity(page, { ...options, status: "admin", route: route() });
    expect(await screen.findByRole("heading", { name: "Manage Community" })).toBeInTheDocument();
    expect(screen.getAllByRole("tab").map((tab) => tab.textContent)).toEqual([
      "Profile",
      "Members",
      "Event Data",
      "Settings",
    ]);
    expect(screen.getByRole("tab", { name: "Profile" })).toHaveAttribute("aria-selected", "true");
    expect(screen.getByText("profile content")).toBeInTheDocument();
  });

  it.each([
    ["members", "members content"],
    ["data", "data content"],
    ["settings", "settings content"],
  ])("opens the %s tab straight from the address", async (tab, content) => {
    renderInCommunity(page, { ...options, status: "admin", route: route(tab) });
    expect(await screen.findByText(content)).toBeInTheDocument();
  });

  it("falls back to the profile tab for a tab it does not know", async () => {
    renderInCommunity(page, { ...options, status: "admin", route: route("nonsense") });
    expect(await screen.findByText("profile content")).toBeInTheDocument();
  });

  it("switches tabs in place and moves the address without navigating", async () => {
    const replaceState = vi.spyOn(window.history, "replaceState");
    renderInCommunity(page, { ...options, status: "owner", route: route() });
    await userEvent.click(await screen.findByRole("tab", { name: "Members" }));
    expect(screen.getByText("members content")).toBeInTheDocument();
    expect(screen.queryByText("profile content")).not.toBeInTheDocument();
    expect(replaceState).toHaveBeenLastCalledWith(window.history.state, "", "/space/civic-lab/admin/members");
    // The router did not move.
    expect(screen.getByTestId("location")).toHaveTextContent("/space/civic-lab/admin");
    replaceState.mockRestore();
  });

  it("goes back to the community home from the community's name", async () => {
    renderInCommunity(page, { ...options, status: "admin", route: route() });
    await userEvent.click(await screen.findByRole("button", { name: /Civic Lab/ }));
    // The admin route no longer matches, so the page is gone.
    expect(screen.queryByRole("heading", { name: "Manage Community" })).not.toBeInTheDocument();
  });
});
