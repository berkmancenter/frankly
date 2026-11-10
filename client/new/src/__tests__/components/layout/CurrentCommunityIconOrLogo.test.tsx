// @vitest-environment jsdom
import { screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import { community } from "@/__tests__/support/fixtures";
import { renderInCommunity, renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { CurrentCommunityIconOrLogo } from "@/components/layout/CurrentCommunityIconOrLogo";

describe("CurrentCommunityIconOrLogo", () => {
  it("shows the Frankly logo and BETA pill, linking home, outside a community", () => {
    renderWithProviders(<CurrentCommunityIconOrLogo />);
    expect(screen.getByRole("link", { name: "Frankly home" })).toHaveAttribute("href", "/home");
    expect(screen.getByRole("img", { name: "Frankly Logo" })).toBeInTheDocument();
    expect(screen.getByText("BETA")).toBeInTheDocument();
  });

  it("shows the community's icon, linking to its home, inside a community", async () => {
    renderInCommunity(<CurrentCommunityIconOrLogo />, {
      community: community({ name: "Civic Lab", displayId: "civic-lab" }),
    });
    const link = await screen.findByRole("link", { name: "Civic Lab" });
    expect(link).toHaveAttribute("href", "/space/civic-lab");
    expect(screen.queryByText("BETA")).not.toBeInTheDocument();
    // No profile picture: the circle falls back to the community's initial.
    expect(link).toHaveTextContent("C");
  });

  it("uses the community's picture when it has one", async () => {
    const { container } = renderInCommunity(<CurrentCommunityIconOrLogo />, {
      community: community({ profileImageUrl: "https://example.com/logo.png" }),
    });
    await screen.findByRole("link", { name: "Civic Lab" });
    expect(container.querySelector("img")).toHaveAttribute("src", "https://example.com/logo.png");
  });

  it("renders on a phone-width screen too", () => {
    renderWithProviders(<CurrentCommunityIconOrLogo />, { mobile: true });
    expect(screen.getByRole("link", { name: "Frankly home" })).toBeInTheDocument();
  });
});
