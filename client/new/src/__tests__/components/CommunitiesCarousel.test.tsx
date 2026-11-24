// @vitest-environment jsdom
import { screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import { community } from "@/__tests__/support/fixtures";
import { renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { CommunitiesCarousel } from "@/components/CommunitiesCarousel";

function renderCarousel(...communities: ReturnType<typeof community>[]) {
  return renderWithProviders(<CommunitiesCarousel communities={communities} />);
}

describe("CommunitiesCarousel", () => {
  it("links a card to each community's home", () => {
    renderCarousel(
      community({ id: "1", displayId: "civic-lab", name: "Civic Lab" }),
      community({ id: "2", displayId: "book-club", name: "Book Club" }),
    );
    expect(screen.getByRole("link", { name: /Civic Lab/ })).toHaveAttribute("href", "/space/civic-lab");
    expect(screen.getByRole("link", { name: /Book Club/ })).toHaveAttribute("href", "/space/book-club");
  });

  it("describes a community by its tag line, falling back to its description", () => {
    renderCarousel(
      community({ id: "1", name: "A", tagLine: "Talk it through", description: "Long text" }),
      community({ id: "2", name: "B", tagLine: undefined, description: "Just a description" }),
    );
    expect(screen.getByText("Talk it through")).toBeInTheDocument();
    expect(screen.queryByText("Long text")).not.toBeInTheDocument();
    expect(screen.getByText("Just a description")).toBeInTheDocument();
  });

  it("puts the banner behind the card when there is one", () => {
    const { container } = renderCarousel(
      community({ id: "1", name: "A", bannerImageUrl: "https://img.test/banner.png" }),
      community({ id: "2", name: "B", bannerImageUrl: "   " }),
    );
    const banners = container.querySelectorAll('img[src="https://img.test/banner.png"]');
    expect(banners).toHaveLength(1);
  });

  it("paints a card without a banner in the community's dark color", () => {
    renderCarousel(community({ id: "1", name: "A", themeDarkColor: "336699" }));
    expect(screen.getByRole("link")).toHaveStyle({ backgroundColor: "#336699" });
  });
});
