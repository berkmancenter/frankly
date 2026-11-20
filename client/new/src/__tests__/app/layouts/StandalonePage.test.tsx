// @vitest-environment jsdom
import { screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import { me } from "@/__tests__/support/fixtures";
import { renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { StandalonePage } from "@/app/layouts/StandalonePage";

const api = { me: { get: async () => me() }, communities: { listMine: async () => [] } };

describe("StandalonePage", () => {
  it("shows the page inside the app scaffold", () => {
    renderWithProviders(<StandalonePage>Hello there</StandalonePage>, { api });
    expect(screen.getByText("Hello there")).toBeInTheDocument();
    expect(screen.getByRole("link", { name: "Frankly home" })).toBeInTheDocument();
  });

  it("keeps the profile menu in the top bar on wide screens", async () => {
    renderWithProviders(<StandalonePage>Hello there</StandalonePage>, { api });
    const profile = await screen.findByRole("button", { name: "Profile Button" });
    expect(screen.getByRole("banner")).toContainElement(profile);
  });

  it("moves the profile menu into a bottom bar on phone-width screens", async () => {
    renderWithProviders(<StandalonePage>Hello there</StandalonePage>, { api, mobile: true });
    const profile = await screen.findByRole("button", { name: "Profile Button" });
    expect(screen.getByRole("banner")).not.toContainElement(profile);
  });
});
