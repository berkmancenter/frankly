// @vitest-environment jsdom
import { screen, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useLocation } from "react-router";
import { describe, expect, it } from "vitest";
import { me, template } from "@/__tests__/support/fixtures";
import { renderInCommunity, renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { CommunityBottomNavBar, HomeBottomNavBar } from "@/components/layout/BottomNavBar";

function Location() {
  const { pathname, search } = useLocation();
  return <div data-testid="location">{`${pathname}${search}`}</div>;
}

const signedIn = { me: { get: async () => me() } };

describe("HomeBottomNavBar", () => {
  it("offers just the profile menu", async () => {
    renderWithProviders(<HomeBottomNavBar />, { api: signedIn, mobile: true });
    expect(await screen.findByRole("button", { name: "Profile Button" })).toBeInTheDocument();
    expect(screen.queryByRole("button", { name: "My events" })).not.toBeInTheDocument();
  });
});

describe("CommunityBottomNavBar", () => {
  it("has a labeled navigation landmark with my events and the profile menu", async () => {
    renderInCommunity(<CommunityBottomNavBar showCreateEventButton={false} />, { mobile: true });
    const nav = await screen.findByRole("navigation", { name: "Bottom navigation" });
    expect(within(nav).getByRole("button", { name: "My events" })).toBeInTheDocument();
    expect(await within(nav).findByRole("button", { name: "Profile Button" })).toBeInTheDocument();
    expect(within(nav).queryByRole("button", { name: "Create an event" })).not.toBeInTheDocument();
  });

  it("goes to my events in settings", async () => {
    const user = userEvent.setup();
    renderInCommunity(
      <>
        <CommunityBottomNavBar showCreateEventButton={false} />
        <Location />
      </>,
      { mobile: true },
    );
    await user.click(await screen.findByRole("button", { name: "My events" }));
    expect(screen.getByTestId("location")).toHaveTextContent("/settings?initialSection=events");
  });

  it("shows the create-event button on request and opens the create-event dialog", async () => {
    const user = userEvent.setup();
    renderInCommunity(<CommunityBottomNavBar showCreateEventButton />, {
      mobile: true,
      api: { templates: { list: async () => [template()] } },
    });
    await user.click(await screen.findByRole("button", { name: "Create an event" }));
    expect(await screen.findByRole("heading", { name: "Choose Template" })).toBeInTheDocument();
  });
});
