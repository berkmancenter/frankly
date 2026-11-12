// @vitest-environment jsdom
import { screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it, vi } from "vitest";
import { anonymousSession } from "@/__tests__/support/fakeAuth";
import { renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { AuthError } from "@/api/auth";
import { SignInForm } from "@/features/auth/SignInForm";

const STRONG = "Abcdefghijkl1";

function setup(props: { showSignUp?: boolean; onSignedIn?: () => void } = {}) {
  const user = userEvent.setup();
  const result = renderWithProviders(<SignInForm {...props} />, { auth: anonymousSession() });
  const field = (label: string) => screen.getByLabelText(label);
  return { user, field, ...result };
}

describe("SignInForm", () => {
  it("starts on sign-up by default and on log-in when asked", () => {
    const first = setup();
    expect(screen.getByRole("heading", { name: "New to Frankly?" })).toBeInTheDocument();
    expect(first.field("Your Name")).toBeInTheDocument();
    first.unmount();

    setup({ showSignUp: false });
    expect(screen.getByRole("heading", { name: "Log into Frankly" })).toBeInTheDocument();
    expect(screen.queryByLabelText("Your Name")).not.toBeInTheDocument();
  });

  it("switches between sign-up and log-in", async () => {
    const { user } = setup();
    await user.click(screen.getByRole("button", { name: "Login" }));
    expect(screen.getByRole("heading", { name: "Log into Frankly" })).toBeInTheDocument();
    await user.click(screen.getByRole("button", { name: "Sign Up" }));
    expect(screen.getByRole("heading", { name: "New to Frankly?" })).toBeInTheDocument();
  });

  it("registers with the trimmed name and email, then reports success", async () => {
    const onSignedIn = vi.fn();
    const { user, field, auth } = setup({ onSignedIn });
    await user.type(field("Your Name"), "  Ada Lovelace ");
    await user.type(field("Email"), " ada@example.com ");
    await user.type(field("Password"), STRONG);
    await user.click(screen.getAllByRole("button", { name: "Sign Up" })[0]!);
    await waitFor(() => expect(onSignedIn).toHaveBeenCalledTimes(1));
    expect(auth.registerWithEmail).toHaveBeenCalledWith({
      displayName: "Ada Lovelace",
      email: "ada@example.com",
      password: STRONG,
    });
  });

  it("explains every problem and calls nothing when the sign-up form is invalid", async () => {
    const { user, field, auth } = setup();
    await user.type(field("Email"), "not-an-email");
    await user.type(field("Password"), "short");
    await user.click(screen.getAllByRole("button", { name: "Sign Up" })[0]!);
    expect(await screen.findByText("Please enter a valid name")).toBeInTheDocument();
    expect(screen.getByText("Please enter a valid email address.")).toBeInTheDocument();
    expect(screen.getByText("Please enter a password")).toBeInTheDocument();
    expect(auth.registerWithEmail).not.toHaveBeenCalled();
  });

  it("only asks for a non-empty password when logging in, since old accounts predate the rules", async () => {
    const onSignedIn = vi.fn();
    const { user, field, auth } = setup({ showSignUp: false, onSignedIn });
    await user.type(field("Email"), "ada@example.com");
    await user.type(field("Password"), "weak");
    await user.click(screen.getByRole("button", { name: "Log In" }));
    await waitFor(() => expect(onSignedIn).toHaveBeenCalled());
    expect(auth.signInWithEmail).toHaveBeenCalledWith("ada@example.com", "weak");
  });

  it("submits with Enter from a field", async () => {
    const { user, field, auth } = setup({ showSignUp: false });
    await user.type(field("Email"), "ada@example.com");
    await user.type(field("Password"), "secret{Enter}");
    await waitFor(() => expect(auth.signInWithEmail).toHaveBeenCalledTimes(1));
  });

  it("shows a wrong-credentials explanation and does not close", async () => {
    const onSignedIn = vi.fn();
    const { user, field, auth } = setup({ showSignUp: false, onSignedIn });
    auth.signInWithEmail.mockRejectedValue(new AuthError("invalid-credential"));
    await user.type(field("Email"), "ada@example.com");
    await user.type(field("Password"), "wrong");
    await user.click(screen.getByRole("button", { name: "Log In" }));
    expect(await screen.findByRole("alert")).toHaveTextContent(
      /Your email and password combination don’t match a Frankly account\./,
    );
    expect(onSignedIn).not.toHaveBeenCalled();
  });

  it("offers to log in when the address is already registered", async () => {
    const { user, field, auth } = setup();
    auth.registerWithEmail.mockRejectedValue(new AuthError("email-already-in-use"));
    await user.type(field("Your Name"), "Ada");
    await user.type(field("Email"), "ada@example.com");
    await user.type(field("Password"), STRONG);
    await user.click(screen.getAllByRole("button", { name: "Sign Up" })[0]!);
    await user.click(await screen.findByRole("button", { name: "logging in" }));
    expect(screen.getByRole("heading", { name: "Log into Frankly" })).toBeInTheDocument();
    expect(screen.queryByRole("alert")).not.toBeInTheDocument();
  });

  it("offers to sign up when there is no such account", async () => {
    const { user, field, auth } = setup({ showSignUp: false });
    auth.signInWithEmail.mockRejectedValue(new AuthError("user-not-found"));
    await user.type(field("Email"), "ada@example.com");
    await user.type(field("Password"), "x");
    await user.click(screen.getByRole("button", { name: "Log In" }));
    await user.click(await screen.findByRole("button", { name: "signing up" }));
    expect(screen.getByRole("heading", { name: "New to Frankly?" })).toBeInTheDocument();
  });

  it("falls back to a generic message for an unknown failure", async () => {
    const { user, field, auth } = setup({ showSignUp: false });
    auth.signInWithEmail.mockRejectedValue(new Error("boom"));
    await user.type(field("Email"), "ada@example.com");
    await user.type(field("Password"), "x");
    await user.click(screen.getByRole("button", { name: "Log In" }));
    expect(await screen.findByRole("alert")).toHaveTextContent(/something went wrong/);
  });

  it("sends a password reset to the typed email and says so", async () => {
    const { user, field, auth } = setup({ showSignUp: false });
    await user.type(field("Email"), " ada@example.com ");
    await user.click(screen.getByRole("button", { name: "reset your password" }));
    expect(auth.sendPasswordReset).toHaveBeenCalledWith("ada@example.com");
    expect(await screen.findByRole("status")).toHaveTextContent(
      "Password reset link sent to ada@example.com",
    );
  });

  it("asks for an email when resetting without one", async () => {
    const { user, auth } = setup({ showSignUp: false });
    auth.sendPasswordReset.mockRejectedValue(new AuthError("email-missing-pw"));
    await user.click(screen.getByRole("button", { name: "reset your password" }));
    expect(await screen.findByRole("alert")).toHaveTextContent("Please enter a valid email address.");
  });

  it("continues with Google", async () => {
    const { user, auth } = setup();
    await user.click(screen.getByRole("button", { name: "Sign up with Google" }));
    expect(auth.signInWithGoogle).toHaveBeenCalledTimes(1);
  });

  it("toggles password visibility", async () => {
    const { user, field } = setup();
    expect(field("Password")).toHaveAttribute("type", "password");
    await user.click(screen.getByRole("button", { name: "Show Password" }));
    expect(field("Password")).toHaveAttribute("type", "text");
    await user.click(screen.getByRole("button", { name: "Hide password" }));
    expect(field("Password")).toHaveAttribute("type", "password");
  });
});
