// @vitest-environment jsdom
import { screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useLocation } from "react-router";
import { describe, expect, it } from "vitest";
import { me, user as userFixture } from "@/__tests__/support/fixtures";
import { renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { ProfileMenu } from "@/components/layout/ProfileMenu";

function Location() {
  const { pathname, search } = useLocation();
  return <div data-testid="location">{`${pathname}${search}`}</div>;
}

const signedIn = { me: { get: async () => me({ user: userFixture({ displayName: "Ada Lovelace" }) }) } };

const renderMenu = (props: { menuAbove?: boolean } = {}) =>
  renderWithProviders(
    <>
      <ProfileMenu {...props} />
      <Location />
    </>,
    { api: signedIn, route: "/space/civic-lab" },
  );

describe("ProfileMenu", () => {
  it("renders nothing while there is no signed-in user", async () => {
    const { container, api } = renderWithProviders(<ProfileMenu />, {
      api: { me: { get: async () => { throw new Error("offline"); } } },
    });
    await waitFor(() => expect(api.me.get).toHaveBeenCalled());
    expect(container).toBeEmptyDOMElement();
  });

  it("shows the user's avatar as a button, with the menu closed", async () => {
    renderMenu();
    const button = await screen.findByRole("button", { name: "Profile Button" });
    expect(button).toHaveTextContent("A");
    expect(screen.queryByRole("menu")).not.toBeInTheDocument();
  });

  it("opens a menu with profile, events and sign out", async () => {
    const user = userEvent.setup();
    renderMenu();
    await user.click(await screen.findByRole("button", { name: "Profile Button" }));
    expect(await screen.findByRole("menu")).toBeInTheDocument();
    expect(screen.getAllByRole("menuitem").map((item) => item.textContent)).toEqual([
      "My Profile",
      "My Events",
      "Sign Out",
    ]);
  });

  it("navigates to the profile settings from 'My Profile' and closes the menu", async () => {
    const user = userEvent.setup();
    renderMenu();
    await user.click(await screen.findByRole("button", { name: "Profile Button" }));
    await user.click(await screen.findByRole("menuitem", { name: "My Profile" }));
    expect(screen.getByTestId("location")).toHaveTextContent("/settings?initialSection=profile");
    await waitFor(() => expect(screen.queryByRole("menu")).not.toBeInTheDocument());
  });

  it("navigates to the events settings from 'My Events'", async () => {
    const user = userEvent.setup();
    renderMenu({ menuAbove: true });
    await user.click(await screen.findByRole("button", { name: "Profile Button" }));
    await user.click(await screen.findByRole("menuitem", { name: "My Events" }));
    expect(screen.getByTestId("location")).toHaveTextContent("/settings?initialSection=events");
  });

  it("explains that sign-in is faked instead of signing out", async () => {
    const user = userEvent.setup();
    renderMenu();
    await user.click(await screen.findByRole("button", { name: "Profile Button" }));
    await user.click(await screen.findByRole("menuitem", { name: "Sign Out" }));
    expect(await screen.findByText(/Sign-in is faked/)).toBeInTheDocument();
    expect(screen.getByTestId("location")).toHaveTextContent("/space/civic-lab");
  });
});
