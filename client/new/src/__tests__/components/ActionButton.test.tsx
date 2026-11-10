// @vitest-environment jsdom
import { screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it, vi } from "vitest";
import { renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { ActionButton } from "@/components/ActionButton";

/** A promise the test settles by hand, to observe the in-flight state. */
function deferred<T = void>() {
  let resolve!: (value: T) => void;
  let reject!: (reason?: unknown) => void;
  const promise = new Promise<T>((res, rej) => {
    resolve = res;
    reject = rej;
  });
  return { promise, resolve, reject };
}

describe("ActionButton", () => {
  it("renders its text as a button and calls onPress when clicked", async () => {
    const user = userEvent.setup();
    const onPress = vi.fn();
    renderWithProviders(<ActionButton text="Save" onPress={onPress} />);

    await user.click(screen.getByRole("button", { name: "Save" }));

    expect(onPress).toHaveBeenCalledTimes(1);
  });

  it("renders children when there is no text, and ariaLabel overrides the accessible name", () => {
    renderWithProviders(
      <>
        <ActionButton onPress={vi.fn()}>
          <b>Custom</b> content
        </ActionButton>
        <ActionButton text="Visible" ariaLabel="Spoken" onPress={vi.fn()} />
      </>,
    );

    expect(screen.getByRole("button", { name: "Custom content" })).toBeEnabled();
    expect(screen.getByRole("button", { name: "Spoken" })).toHaveTextContent("Visible");
  });

  it("is disabled without an onPress handler or when disabled is set", async () => {
    // MUI sets `pointer-events: none` on disabled buttons; click through it to prove no handler runs.
    const user = userEvent.setup({ pointerEventsCheck: 0 });
    const onPress = vi.fn();
    renderWithProviders(
      <>
        <ActionButton text="Inert" />
        <ActionButton text="Off" disabled onPress={onPress} />
      </>,
    );

    expect(screen.getByRole("button", { name: "Inert" })).toBeDisabled();
    const off = screen.getByRole("button", { name: "Off" });
    expect(off).toBeDisabled();
    await user.click(off);
    expect(onPress).not.toHaveBeenCalled();
  });

  it("shows a spinner and ignores clicks while an async onPress is pending", async () => {
    const user = userEvent.setup({ pointerEventsCheck: 0 });
    const pending = deferred();
    const onPress = vi.fn(() => pending.promise);
    renderWithProviders(<ActionButton text="Send" onPress={onPress} />);
    const button = screen.getByRole("button", { name: "Send" });
    expect(screen.queryByRole("progressbar")).not.toBeInTheDocument();

    await user.click(button);

    expect(await screen.findByRole("progressbar")).toBeInTheDocument();
    expect(button).toBeDisabled();
    await user.click(button);
    expect(onPress).toHaveBeenCalledTimes(1);

    pending.resolve();
    await waitFor(() => expect(screen.queryByRole("progressbar")).not.toBeInTheDocument());
    expect(button).toBeEnabled();
    await user.click(button);
    expect(onPress).toHaveBeenCalledTimes(2);
  });

  it("does not show the spinner when hideLoadingIndicator is set, but still blocks clicks", async () => {
    const user = userEvent.setup();
    const pending = deferred();
    const onPress = vi.fn(() => pending.promise);
    renderWithProviders(<ActionButton text="Send" hideLoadingIndicator onPress={onPress} />);
    const button = screen.getByRole("button", { name: "Send" });

    await user.click(button);

    await waitFor(() => expect(button).toBeDisabled());
    expect(screen.queryByRole("progressbar")).not.toBeInTheDocument();
    pending.resolve();
    await waitFor(() => expect(button).toBeEnabled());
  });

  it("swallows a rejected onPress and becomes usable again", async () => {
    const user = userEvent.setup();
    const onPress = vi.fn().mockRejectedValue(new Error("nope"));
    renderWithProviders(<ActionButton text="Try" onPress={onPress} />);
    const button = screen.getByRole("button", { name: "Try" });

    await user.click(button);

    await waitFor(() => expect(button).toBeEnabled());
    expect(screen.queryByRole("progressbar")).not.toBeInTheDocument();
    await user.click(button);
    expect(onPress).toHaveBeenCalledTimes(2);
  });

  it("replaces the leading icon with the spinner while waiting", async () => {
    const user = userEvent.setup();
    const pending = deferred();
    renderWithProviders(
      <ActionButton text="Go" icon={<span data-testid="lead-icon" />} onPress={() => pending.promise} />,
    );
    expect(screen.getByTestId("lead-icon")).toBeInTheDocument();

    await user.click(screen.getByRole("button", { name: "Go" }));

    expect(await screen.findByRole("progressbar")).toBeInTheDocument();
    expect(screen.queryByTestId("lead-icon")).not.toBeInTheDocument();
    pending.resolve();
    expect(await screen.findByTestId("lead-icon")).toBeInTheDocument();
  });

  it("shows its tooltip on hover", async () => {
    const user = userEvent.setup();
    renderWithProviders(<ActionButton text="Share" tooltip="Share this page" onPress={vi.fn()} />);

    await user.hover(screen.getByRole("button", { name: "Share" }));

    expect(await screen.findByRole("tooltip")).toHaveTextContent("Share this page");
  });
});
