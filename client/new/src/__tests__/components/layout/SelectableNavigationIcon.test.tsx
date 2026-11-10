// @vitest-environment jsdom
import { screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it, vi } from "vitest";
import { renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { SelectableNavigationIcon } from "@/components/layout/SelectableNavigationIcon";

describe("SelectableNavigationIcon", () => {
  it("is a button named by its label that reports clicks", async () => {
    const user = userEvent.setup();
    const onClick = vi.fn();
    renderWithProviders(
      <SelectableNavigationIcon label="Events" selected={false} icon={<span>icon</span>} onClick={onClick} />,
    );
    await user.click(screen.getByRole("button", { name: "Events" }));
    expect(onClick).toHaveBeenCalledTimes(1);
  });

  it("draws the selection indicator only while selected", () => {
    const icon = <span>icon</span>;
    const unselected = renderWithProviders(<SelectableNavigationIcon label="Events" selected={false} icon={icon} />);
    // Without the indicator the wrapper holds just the button.
    expect(unselected.container.firstElementChild?.children).toHaveLength(1);
    unselected.unmount();

    const selected = renderWithProviders(<SelectableNavigationIcon label="Events" selected icon={icon} />);
    expect(selected.container.firstElementChild?.children).toHaveLength(2);
  });
});
