// @vitest-environment jsdom
import { screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it, vi } from "vitest";
import { renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { AppDialog } from "@/components/AppDialog";

describe("AppDialog", () => {
  it("renders its children in a dialog while open", () => {
    renderWithProviders(
      <AppDialog open onClose={vi.fn()}>
        <p>Dialog body</p>
      </AppDialog>,
    );

    expect(screen.getByRole("dialog")).toHaveTextContent("Dialog body");
  });

  it("renders nothing while closed", () => {
    renderWithProviders(
      <AppDialog open={false} onClose={vi.fn()}>
        <p>Dialog body</p>
      </AppDialog>,
    );

    expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
    expect(screen.queryByText("Dialog body")).not.toBeInTheDocument();
  });

  it("closes from the close button and from Escape", async () => {
    const user = userEvent.setup();
    const onClose = vi.fn();
    renderWithProviders(
      <AppDialog open onClose={onClose}>
        <p>Body</p>
      </AppDialog>,
    );

    await user.click(screen.getByRole("button", { name: "Close" }));
    expect(onClose).toHaveBeenCalledTimes(1);

    await user.keyboard("{Escape}");
    expect(onClose).toHaveBeenCalledTimes(2);
  });

  it("can hide the close button", () => {
    renderWithProviders(
      <AppDialog open onClose={vi.fn()} hideClose>
        <p>Body</p>
      </AppDialog>,
    );

    expect(screen.queryByRole("button", { name: "Close" })).not.toBeInTheDocument();
  });

  it("can relabel the close button", () => {
    renderWithProviders(
      <AppDialog open onClose={vi.fn()} closeLabel="Dismiss">
        <p>Body</p>
      </AppDialog>,
    );

    expect(screen.getByRole("button", { name: "Dismiss" })).toBeInTheDocument();
    expect(screen.queryByRole("button", { name: "Close" })).not.toBeInTheDocument();
  });

  it("closes when the backdrop is clicked", async () => {
    const user = userEvent.setup();
    const onClose = vi.fn();
    renderWithProviders(
      <AppDialog open onClose={onClose}>
        <p>Body</p>
      </AppDialog>,
    );

    // The backdrop is a presentational sibling of the dialog container; MUI listens on the container.
    const container = screen.getByRole("dialog").parentElement as HTMLElement;
    await user.click(container);

    await waitFor(() => expect(onClose).toHaveBeenCalled());
  });

  it("goes fullscreen on mobile only when fullscreenOnMobile is set", () => {
    const { unmount } = renderWithProviders(
      <AppDialog open onClose={vi.fn()} fullscreenOnMobile>
        <p>Body</p>
      </AppDialog>,
      { mobile: true },
    );
    expect(screen.getByRole("dialog")).toHaveStyle({ maxWidth: "none" });
    unmount();

    renderWithProviders(
      <AppDialog open onClose={vi.fn()} fullscreenOnMobile>
        <p>Body</p>
      </AppDialog>,
    );
    expect(screen.getByRole("dialog")).toHaveStyle({ maxWidth: "700px" });
  });

  it("is not fullscreen on mobile by default", () => {
    renderWithProviders(
      <AppDialog open onClose={vi.fn()} maxWidth={500}>
        <p>Body</p>
      </AppDialog>,
      { mobile: true },
    );
    expect(screen.getByRole("dialog")).toHaveStyle({ maxWidth: "500px" });
  });

  it("names the dialog with ariaLabel", () => {
    renderWithProviders(
      <AppDialog open onClose={vi.fn()} ariaLabel="Edit profile">
        <p>Body</p>
      </AppDialog>,
    );
    expect(screen.getByRole("dialog", { name: "Edit profile" })).toBeInTheDocument();
  });
});
