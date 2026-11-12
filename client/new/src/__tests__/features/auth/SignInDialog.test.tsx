// @vitest-environment jsdom
import { screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it, vi } from "vitest";
import { anonymousSession, authUser, type FakeAuth } from "@/__tests__/support/fakeAuth";
import { renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { useGuardSignedIn } from "@/features/auth/SignInDialog";

function Guarded({ action }: { action: () => void }) {
  const { guard, dialog } = useGuardSignedIn();
  return (
    <>
      <button onClick={() => void guard(action)}>Do it</button>
      {dialog}
    </>
  );
}

/** Registering "succeeds" the way Firebase does: the session now has a registered user. */
const signUpSucceeds = (auth: FakeAuth) =>
  auth.registerWithEmail.mockImplementation(async () => {
    auth.setSession({ user: authUser() });
  });

describe("useGuardSignedIn", () => {
  it("runs the action straight away for a registered user", async () => {
    const action = vi.fn();
    renderWithProviders(<Guarded action={action} />);
    await userEvent.click(screen.getByRole("button", { name: "Do it" }));
    expect(action).toHaveBeenCalledTimes(1);
    expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
  });

  it("asks an anonymous visitor to sign in first, and does not run the action if they give up", async () => {
    const action = vi.fn();
    const user = userEvent.setup();
    renderWithProviders(<Guarded action={action} />, { auth: anonymousSession() });
    await user.click(screen.getByRole("button", { name: "Do it" }));
    expect(await screen.findByRole("dialog")).toBeInTheDocument();
    await user.click(screen.getByRole("button", { name: "Close" }));
    await waitFor(() => expect(screen.queryByRole("dialog")).not.toBeInTheDocument());
    expect(action).not.toHaveBeenCalled();
  });

  it("runs the action once the visitor has signed up", async () => {
    const action = vi.fn();
    const user = userEvent.setup();
    const { auth } = renderWithProviders(<Guarded action={action} />, { auth: anonymousSession() });
    signUpSucceeds(auth);
    await user.click(screen.getByRole("button", { name: "Do it" }));
    await user.type(await screen.findByLabelText("Your Name"), "Ada");
    await user.type(screen.getByLabelText("Email"), "ada@example.com");
    await user.type(screen.getByLabelText("Password"), "Abcdefghijkl1");
    await user.click(screen.getAllByRole("button", { name: "Sign Up" })[0]!);
    await waitFor(() => expect(action).toHaveBeenCalledTimes(1));
    expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
  });
});
