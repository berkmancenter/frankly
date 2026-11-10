// @vitest-environment jsdom
import { screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import { renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { FacebookF, LinkedInIn, XLogo } from "@/components/BrandIcons";

describe("BrandIcons", () => {
  it.each([
    ["Facebook", FacebookF, "0 0 320 512"],
    ["X", XLogo, "0 0 24 24"],
    ["LinkedIn", LinkedInIn, "0 0 448 512"],
  ])("%s renders an svg glyph with its own viewBox", (name, Icon, viewBox) => {
    renderWithProviders(<Icon titleAccess={name} />);

    const svg = screen.getByRole("img", { name });
    expect(svg.tagName.toLowerCase()).toBe("svg");
    expect(svg).toHaveAttribute("viewBox", viewBox);
    expect(svg.querySelector("path")).toHaveAttribute("d");
  });

  it("is decorative (hidden from assistive tech) unless given a title", () => {
    const { container } = renderWithProviders(<FacebookF />);

    expect(container.querySelector("svg")).toHaveAttribute("aria-hidden", "true");
    expect(screen.queryByRole("img")).not.toBeInTheDocument();
  });
});
