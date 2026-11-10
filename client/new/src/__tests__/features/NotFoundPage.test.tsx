// @vitest-environment jsdom
import { screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { Route, Routes, useLocation } from "react-router";
import { describe, expect, it, vi } from "vitest";
import { me } from "@/__tests__/support/fixtures";
import { renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { NotFoundPage } from "@/features/NotFoundPage";

const api = { me: { get: async () => me() } };

describe("NotFoundPage", () => {
  it("tells the visitor the URL was not found", () => {
    renderWithProviders(<NotFoundPage />, { api });
    expect(screen.getByText("This URL was not found")).toBeInTheDocument();
  });

  it("shows a custom message instead of the default", () => {
    renderWithProviders(<NotFoundPage message="That community does not exist" />, { api });
    expect(screen.getByText("That community does not exist")).toBeInTheDocument();
    expect(screen.queryByText("This URL was not found")).not.toBeInTheDocument();
  });

  it("is wrapped in the app chrome with a way back to Frankly home", () => {
    renderWithProviders(<NotFoundPage />, { api });
    const header = screen.getByRole("banner");
    expect(within(header).getByRole("link", { name: "Frankly home" })).toHaveAttribute("href", "/home");
    expect(within(header).getByRole("button", { name: "Show sidebar" })).toBeInTheDocument();
  });

  it("does not show community navigation, since it is outside any community", () => {
    renderWithProviders(<NotFoundPage />, { api });
    const header = screen.getByRole("banner");
    expect(within(header).queryByRole("button", { name: "Events" })).not.toBeInTheDocument();
    expect(within(header).queryByRole("button", { name: "Admin" })).not.toBeInTheDocument();
  });

  it("navigates home from the logo link", async () => {
    const user = userEvent.setup();
    function Where() {
      return <p>at {useLocation().pathname}</p>;
    }
    renderWithProviders(
      <Routes>
        <Route path="/home" element={<Where />} />
        <Route path="*" element={<NotFoundPage />} />
      </Routes>,
      { api, route: "/nowhere" },
    );
    expect(screen.getByText("This URL was not found")).toBeInTheDocument();

    await user.click(screen.getByRole("link", { name: "Frankly home" }));

    expect(await screen.findByText("at /home")).toBeInTheDocument();
  });

  describe("signed-in profile menu", () => {
    it("is in the top bar on desktop", async () => {
      renderWithProviders(<NotFoundPage />, { api });
      const profile = await screen.findByRole("button", { name: "Profile Button" });
      expect(within(screen.getByRole("banner")).getByRole("button", { name: "Profile Button" })).toBe(profile);
    });

    it("moves to the bottom bar on mobile", async () => {
      renderWithProviders(<NotFoundPage />, { api, mobile: true });
      const profile = await screen.findByRole("button", { name: "Profile Button" });
      expect(within(screen.getByRole("banner")).queryByRole("button", { name: "Profile Button" })).not.toBeInTheDocument();
      expect(screen.getAllByRole("button", { name: "Profile Button" })).toEqual([profile]);
    });

    it("opens a menu with the profile and events shortcuts", async () => {
      const user = userEvent.setup();
      renderWithProviders(<NotFoundPage />, { api });
      await user.click(await screen.findByRole("button", { name: "Profile Button" }));
      expect(screen.getByRole("menuitem", { name: "My Profile" })).toBeInTheDocument();
      expect(screen.getByRole("menuitem", { name: "My Events" })).toBeInTheDocument();
    });
  });

  it("still renders the message when the signed-in user cannot be loaded", async () => {
    const get = vi.fn(async () => {
      throw new Error("offline");
    });
    renderWithProviders(<NotFoundPage />, { api: { me: { get } } });
    await waitFor(() => expect(get).toHaveBeenCalled());

    expect(screen.getByText("This URL was not found")).toBeInTheDocument();
    expect(screen.queryByRole("button", { name: "Profile Button" })).not.toBeInTheDocument();
  });
});
