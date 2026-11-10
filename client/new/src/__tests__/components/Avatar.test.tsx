// @vitest-environment jsdom
import { screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import { Avatar } from "@/components/Avatar";
import { renderWithProviders } from "@/__tests__/support/renderWithProviders";

describe("Avatar", () => {
  it("renders", () => {
    renderWithProviders(<Avatar name="Ada Lovelace" size={42} />);
    expect(screen.getByText(/A/)).toBeInTheDocument();
  });
});
