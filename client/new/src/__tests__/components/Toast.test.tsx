// @vitest-environment jsdom
import { act, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { afterEach, describe, expect, it, vi } from "vitest";
import { ToastProvider, useToast } from "@/components/Toast";

/** Buttons that raise each kind of toast; extra messages can be queued via `many`. */
function Trigger({ many = [] }: { many?: string[] }) {
  const toast = useToast();
  return (
    <>
      <button onClick={() => toast.show("Plain message")}>show</button>
      <button onClick={() => toast.success("It worked")}>success</button>
      <button onClick={() => toast.error("It broke")}>error</button>
      <button onClick={() => many.forEach((m) => toast.show(m))}>many</button>
    </>
  );
}

const renderToasts = (many?: string[]) =>
  render(
    <ToastProvider>
      <Trigger many={many} />
    </ToastProvider>,
  );

afterEach(() => vi.useRealTimers());

describe("Toast", () => {
  it("shows nothing until a toast is raised", () => {
    renderToasts();

    expect(screen.queryByRole("alert")).not.toBeInTheDocument();
  });

  it("shows a regular toast without a status icon", async () => {
    const user = userEvent.setup();
    renderToasts();

    await user.click(screen.getByRole("button", { name: "show" }));

    const alert = await screen.findByRole("alert");
    expect(alert).toHaveTextContent("Plain message");
    expect(alert.querySelector("svg[data-testid='SuccessOutlinedIcon'], svg[data-testid='ErrorOutlineIcon']")).toBeNull();
  });

  it("shows success and error toasts with their own icons", async () => {
    const user = userEvent.setup();
    renderToasts();

    await user.click(screen.getByRole("button", { name: "success" }));
    const success = await screen.findByRole("alert");
    expect(success).toHaveTextContent("It worked");
    expect(success.querySelector("[data-testid='SuccessOutlinedIcon']")).toBeInTheDocument();

    await user.click(within(success).getByRole("button", { name: "Close" }));
    await waitFor(() => expect(screen.queryByRole("alert")).not.toBeInTheDocument());

    await user.click(screen.getByRole("button", { name: "error" }));
    const error = await screen.findByRole("alert");
    expect(error).toHaveTextContent("It broke");
    expect(error.querySelector("[data-testid='ErrorOutlineIcon']")).toBeInTheDocument();
  });

  it("dismisses from the close button", async () => {
    const user = userEvent.setup();
    renderToasts();
    await user.click(screen.getByRole("button", { name: "show" }));
    expect(await screen.findByText("Plain message")).toBeInTheDocument();

    await user.click(screen.getByRole("button", { name: "Close" }));

    await waitFor(() => expect(screen.queryByText("Plain message")).not.toBeInTheDocument());
  });

  it("hides itself after four seconds", async () => {
    vi.useFakeTimers();
    renderToasts();
    fireEvent.click(screen.getByRole("button", { name: "show" }));
    expect(screen.getByText("Plain message")).toBeInTheDocument();

    await act(() => vi.advanceTimersByTimeAsync(3900));
    expect(screen.getByText("Plain message")).toBeInTheDocument();

    // Auto-hide fires at 4s; the exit transition is scheduled once React re-renders, so it needs
    // its own advance.
    await act(() => vi.advanceTimersByTimeAsync(200));
    await act(() => vi.advanceTimersByTimeAsync(500));
    expect(screen.queryByText("Plain message")).not.toBeInTheDocument();
  });

  it("stays up when the user clicks elsewhere on the page", async () => {
    const user = userEvent.setup();
    renderToasts();
    await user.click(screen.getByRole("button", { name: "show" }));
    expect(await screen.findByText("Plain message")).toBeInTheDocument();

    await user.click(document.body);
    await new Promise((resolve) => setTimeout(resolve, 400));

    expect(screen.getByText("Plain message")).toBeInTheDocument();
  });

  it("shows queued toasts one at a time, in order", async () => {
    const user = userEvent.setup();
    renderToasts(["First", "Second"]);

    await user.click(screen.getByRole("button", { name: "many" }));

    expect(await screen.findByText("First")).toBeInTheDocument();
    expect(screen.queryByText("Second")).not.toBeInTheDocument();

    await user.click(screen.getByRole("button", { name: "Close" }));

    expect(await screen.findByText("Second")).toBeInTheDocument();
    expect(screen.queryByText("First")).not.toBeInTheDocument();
  });

  it("throws a helpful error when useToast is used outside the provider", () => {
    const quiet = vi.spyOn(console, "error").mockImplementation(() => {});

    expect(() => render(<Trigger />)).toThrow("useToast must be used inside <ToastProvider>");

    quiet.mockRestore();
  });
});
