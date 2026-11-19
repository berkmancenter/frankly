// @vitest-environment jsdom
import { screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import { renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { ConstrainedBody } from "@/components/ConstrainedBody";

describe("ConstrainedBody", () => {
  it("renders its children inside a column capped at the 1100px desktop width", () => {
    renderWithProviders(
      <ConstrainedBody data-testid="outer">
        <p>Content</p>
      </ConstrainedBody>,
    );

    const column = screen.getByText("Content").parentElement as HTMLElement;
    expect(column).toHaveStyle({ maxWidth: "1100px", width: "100%" });
    expect(screen.getByTestId("outer")).toContainElement(column);
  });

  it("honors maxWidth and the side gutters (20px by default)", () => {
    renderWithProviders(
      <>
        <ConstrainedBody data-testid="default">
          <p>Default</p>
        </ConstrainedBody>
        <ConstrainedBody data-testid="custom" maxWidth={600} paddingLeft={8} paddingRight={32}>
          <p>Custom</p>
        </ConstrainedBody>
      </>,
    );

    expect(screen.getByTestId("default")).toHaveStyle({ paddingLeft: "20px", paddingRight: "20px" });
    expect(screen.getByTestId("custom")).toHaveStyle({ paddingLeft: "8px", paddingRight: "32px" });
    expect(screen.getByText("Custom").parentElement).toHaveStyle({ maxWidth: "600px" });
  });

  it("merges a caller's sx and forwards other props to the outer element", () => {
    renderWithProviders(
      <ConstrainedBody aria-label="page body" sx={{ marginTop: "7px" }}>
        <p>Content</p>
      </ConstrainedBody>,
    );

    // The caller's style adds to the centering styles rather than replacing them.
    expect(screen.getByLabelText("page body")).toHaveStyle({ marginTop: "7px", justifyContent: "center" });
  });
});
