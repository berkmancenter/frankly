// @vitest-environment jsdom
import { screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useState } from "react";
import { describe, expect, it, vi } from "vitest";
import { renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { appTheme } from "@/theme/theme";
import { fontSizes } from "@/theme/tokens";
import { ConfirmDialogView, useConfirm, type ConfirmOptions } from "@/components/ConfirmDialog";

describe("ConfirmDialogView", () => {
  it("renders the title, texts and extra content, with a single Yes button by default", () => {
    renderWithProviders(
      <ConfirmDialogView
        open
        onResolve={vi.fn()}
        title="Delete post"
        mainText="This cannot be undone."
        subText="Replies are removed too."
      >
        <p>Extra detail</p>
      </ConfirmDialogView>,
    );

    expect(screen.getByRole("heading", { level: 2, name: "Delete post" })).toBeInTheDocument();
    expect(screen.getByText("This cannot be undone.")).toBeInTheDocument();
    expect(screen.getByText("Replies are removed too.")).toBeInTheDocument();
    expect(screen.getByText("Extra detail")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Yes" })).toBeInTheDocument();
    // Only Yes and the close icon: no cancel button unless asked for.
    expect(screen.getAllByRole("button")).toHaveLength(2);
  });

  it("renders nothing while closed", () => {
    renderWithProviders(<ConfirmDialogView open={false} onResolve={vi.fn()} title="Hidden" />);

    expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
  });

  it("resolves true from the confirm button and false from the cancel button", async () => {
    const user = userEvent.setup();
    const onResolve = vi.fn();
    renderWithProviders(
      <ConfirmDialogView open onResolve={onResolve} confirmText="Delete" cancelText="Keep it" />,
    );

    await user.click(screen.getByRole("button", { name: "Delete" }));
    expect(onResolve).toHaveBeenLastCalledWith(true);

    await user.click(screen.getByRole("button", { name: "Keep it" }));
    expect(onResolve).toHaveBeenLastCalledWith(false);
  });

  it("treats the close button and Escape as a cancel by default", async () => {
    const user = userEvent.setup();
    const onResolve = vi.fn();
    renderWithProviders(<ConfirmDialogView open onResolve={onResolve} title="Sure?" />);

    await user.click(screen.getByRole("button", { name: "Close" }));
    expect(onResolve).toHaveBeenLastCalledWith(false);

    await user.keyboard("{Escape}");
    expect(onResolve).toHaveBeenCalledTimes(2);
    expect(onResolve).toHaveBeenLastCalledWith(false);
  });

  it("sends the close button and Escape to onDismiss instead when it is provided", async () => {
    const user = userEvent.setup();
    const onResolve = vi.fn();
    const onDismiss = vi.fn();
    renderWithProviders(
      <ConfirmDialogView open onResolve={onResolve} onDismiss={onDismiss} cancelText="No" />,
    );

    await user.click(screen.getByRole("button", { name: "Close" }));
    await user.keyboard("{Escape}");
    expect(onDismiss).toHaveBeenCalledTimes(2);
    expect(onResolve).not.toHaveBeenCalled();

    // "No" is still an explicit answer, distinct from dismissing.
    await user.click(screen.getByRole("button", { name: "No" }));
    expect(onResolve).toHaveBeenCalledWith(false);
  });

  it("colors the confirm button as destructive only when asked", () => {
    renderWithProviders(<ConfirmDialogView open onResolve={vi.fn()} confirmText="Delete" destructive />);

    expect(screen.getByRole("button", { name: "Delete" })).toHaveStyle({
      backgroundColor: appTheme.palette.error.main,
    });
  });

  it("uses the primary color for a normal confirm button", () => {
    renderWithProviders(<ConfirmDialogView open onResolve={vi.fn()} confirmText="Okay" />);

    expect(screen.getByRole("button", { name: "Okay" })).toHaveStyle({
      backgroundColor: appTheme.palette.primary.main,
    });
  });

  it("uses a larger title on mobile", () => {
    const { unmount } = renderWithProviders(<ConfirmDialogView open onResolve={vi.fn()} title="Title" />);
    expect(screen.getByRole("heading", { name: "Title" })).toHaveStyle({ fontSize: `${fontSizes["2xl"]}px` });
    unmount();

    renderWithProviders(<ConfirmDialogView open onResolve={vi.fn()} title="Title" />, { mobile: true });
    expect(screen.getByRole("heading", { name: "Title" })).toHaveStyle({ fontSize: `${fontSizes["3xl"]}px` });
  });
});

function Harness({ options }: { options: ConfirmOptions }) {
  const { confirm, dialog } = useConfirm();
  const [answer, setAnswer] = useState("none");
  return (
    <>
      <button onClick={async () => setAnswer(String(await confirm(options)))}>Ask</button>
      <p data-testid="answer">{answer}</p>
      {dialog}
    </>
  );
}

describe("useConfirm", () => {
  const options: ConfirmOptions = { title: "Leave?", confirmText: "Leave", cancelText: "Stay" };

  it("shows no dialog until confirm() is called", () => {
    renderWithProviders(<Harness options={options} />);

    expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
  });

  it("resolves true when confirmed and closes the dialog", async () => {
    const user = userEvent.setup();
    renderWithProviders(<Harness options={options} />);

    await user.click(screen.getByRole("button", { name: "Ask" }));
    expect(screen.getByRole("heading", { name: "Leave?" })).toBeInTheDocument();
    await user.click(screen.getByRole("button", { name: "Leave" }));

    expect(await screen.findByText("true")).toBeInTheDocument();
    expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
  });

  it("resolves false when cancelled", async () => {
    const user = userEvent.setup();
    renderWithProviders(<Harness options={options} />);

    await user.click(screen.getByRole("button", { name: "Ask" }));
    await user.click(screen.getByRole("button", { name: "Stay" }));

    expect(await screen.findByText("false")).toBeInTheDocument();
    expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
  });

  it("resolves false when dismissed with the close button", async () => {
    const user = userEvent.setup();
    renderWithProviders(<Harness options={options} />);

    await user.click(screen.getByRole("button", { name: "Ask" }));
    await user.click(screen.getByRole("button", { name: "Close" }));

    expect(await screen.findByText("false")).toBeInTheDocument();
    expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
  });

  it("resolves a superseded confirm() as false when a new one starts", async () => {
    const results: boolean[] = [];
    let ask!: (opts: ConfirmOptions) => Promise<boolean>;
    function Capture() {
      const { confirm, dialog } = useConfirm();
      ask = confirm;
      return dialog;
    }
    renderWithProviders(<Capture />);

    const first = ask({ title: "First" }).then((r) => results.push(r));
    const second = ask({ title: "Second" });
    await first;

    expect(results).toEqual([false]);
    expect(await screen.findByRole("heading", { name: "Second" })).toBeInTheDocument();
    await userEvent.setup().click(screen.getByRole("button", { name: "Yes" }));
    await expect(second).resolves.toBe(true);
  });
});
