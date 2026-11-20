// @vitest-environment jsdom
import { screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import { renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { PrerequisiteBadge } from "@/components/misc";

describe("PrerequisiteBadge", () => {
  it("tells the user a prerequisite is required", () => {
    renderWithProviders(<PrerequisiteBadge />);

    expect(screen.getByText("Prerequisite Required")).toBeInTheDocument();
  });
});
