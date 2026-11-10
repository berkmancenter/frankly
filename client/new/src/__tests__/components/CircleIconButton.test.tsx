// @vitest-environment jsdom
import { screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it, vi } from "vitest";
import { renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { CircleIconButton } from "@/components/CircleIconButton";

describe("CircleIconButton", () => {
  it("is a button named by its tooltip that fires onClick", async () => {
    const user = userEvent.setup();
    const onClick = vi.fn();
    renderWithProviders(
      <CircleIconButton icon={<svg data-testid="glyph" />} tooltip="Add post" onClick={onClick} />,
    );

    const button = screen.getByRole("button", { name: "Add post" });
    expect(screen.getByTestId("glyph")).toBeInTheDocument();
    await user.click(button);

    expect(onClick).toHaveBeenCalledTimes(1);
  });

  it("shows the tooltip text on hover", async () => {
    const user = userEvent.setup();
    renderWithProviders(<CircleIconButton icon={<svg />} tooltip="Add post" />);

    await user.hover(screen.getByRole("button", { name: "Add post" }));

    expect(await screen.findByRole("tooltip")).toHaveTextContent("Add post");
  });

  it("is sized as a 44px circle by default and honors size", () => {
    renderWithProviders(
      <>
        <CircleIconButton icon={<svg />} tooltip="Default" />
        <CircleIconButton icon={<svg />} tooltip="Big" size={60} />
      </>,
    );

    expect(screen.getByRole("button", { name: "Default" })).toHaveStyle({ width: "44px", height: "44px" });
    expect(screen.getByRole("button", { name: "Big" })).toHaveStyle({ width: "60px", height: "60px" });
  });

  it("renders as a link when given an href", () => {
    renderWithProviders(<CircleIconButton icon={<svg />} tooltip="Docs" href="https://example.com/docs" />);

    expect(screen.getByRole("link", { name: "Docs" })).toHaveAttribute("href", "https://example.com/docs");
  });
});
