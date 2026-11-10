// @vitest-environment jsdom
import { screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it, vi } from "vitest";
import { renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { ActionButton } from "@/components/ActionButton";
import { ThickOutlineButton } from "@/components/ThickOutlineButton";

describe("ThickOutlineButton", () => {
  it("is an ActionButton: shows its text and calls onPress", async () => {
    const user = userEvent.setup();
    const onPress = vi.fn();
    renderWithProviders(<ThickOutlineButton text="Cancel" onPress={onPress} />);

    await user.click(screen.getByRole("button", { name: "Cancel" }));

    expect(onPress).toHaveBeenCalledTimes(1);
  });

  it("has no minimum width and is 44px tall by default", () => {
    renderWithProviders(<ThickOutlineButton text="Go" onPress={vi.fn()} />);

    expect(screen.getByRole("button", { name: "Go" })).toHaveStyle({ minWidth: "0px", minHeight: "44px" });
  });

  it("lets callers override height and minWidth", () => {
    renderWithProviders(<ThickOutlineButton text="Big" height={60} minWidth={120} onPress={vi.fn()} />);

    expect(screen.getByRole("button", { name: "Big" })).toHaveStyle({ minWidth: "120px", minHeight: "60px" });
  });

  it("is an outline button: bordered, unlike a filled ActionButton", () => {
    renderWithProviders(
      <>
        <ThickOutlineButton text="Outlined" onPress={vi.fn()} />
        <ActionButton text="Filled" onPress={vi.fn()} />
      </>,
    );

    const outlined = screen.getByRole("button", { name: "Outlined" });
    const filled = screen.getByRole("button", { name: "Filled" });
    expect(getComputedStyle(outlined).borderStyle).toBe("solid");
    expect(getComputedStyle(outlined).backgroundColor).not.toBe(getComputedStyle(filled).backgroundColor);
  });
});
