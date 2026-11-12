// @vitest-environment jsdom
import { act, screen, waitFor } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { Route, Routes } from "react-router";
import { me } from "@/__tests__/support/fixtures";
import { anonymousSession, authUser, createFakeAuth } from "@/__tests__/support/fakeAuth";
import { renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { RootLayout } from "@/app/layouts/RootLayout";

const page = (
  <Routes>
    <Route element={<RootLayout />}>
      <Route index element={<p>Child page</p>} />
    </Route>
  </Routes>
);

describe("RootLayout", () => {
  beforeEach(() => {
    // RootLayout logs the session error; keep the test output clean.
    vi.spyOn(console, "log").mockImplementation(() => {});
  });
  afterEach(() => vi.restoreAllMocks());

  it("shows a spinner and none of the page while the session loads", () => {
    renderWithProviders(page, { api: { me: { get: () => new Promise(() => {}) } } });
    expect(screen.getByRole("progressbar")).toBeInTheDocument();
    expect(screen.queryByText("Child page")).not.toBeInTheDocument();
  });

  it("renders the matched child route once the session has loaded", async () => {
    renderWithProviders(page, { api: { me: { get: async () => me() } } });
    expect(await screen.findByText("Child page")).toBeInTheDocument();
    expect(screen.queryByRole("progressbar")).not.toBeInTheDocument();
  });

  it("explains that the session could not be loaded, instead of rendering the page", async () => {
    renderWithProviders(page, {
      api: {
        me: {
          get: async () => {
            throw new Error("unauthenticated");
          },
        },
      },
    });
    expect(await screen.findByText(/Could not load your session\./)).toBeInTheDocument();
    expect(screen.queryByText("Child page")).not.toBeInTheDocument();
  });

  it("does not print 'false' after the message outside development", async () => {
    renderWithProviders(page, {
      api: {
        me: {
          get: async () => {
            throw new Error("unauthenticated");
          },
        },
      },
    });
    const message = await screen.findByText(/Could not load your session\./);
    expect(message.textContent).toBe("Could not load your session.");
  });

  describe("auth session", () => {
    it("waits for the visitor to be signed in, without asking for their data yet", () => {
      const { api } = renderWithProviders(page, { auth: { status: "loading", user: null } });
      expect(screen.getByRole("progressbar")).toBeInTheDocument();
      expect(api.me.get).not.toHaveBeenCalled();
    });

    it("tells a signed-out visitor to refresh", () => {
      renderWithProviders(page, { auth: { status: "signedOut", user: null } });
      expect(screen.getByText("You have been signed out. Please refresh to sign back in")).toBeInTheDocument();
      expect(screen.queryByText("Child page")).not.toBeInTheDocument();
    });

    it("shows the page to an anonymous visitor", async () => {
      renderWithProviders(page, { api: { me: { get: async () => me() } }, auth: anonymousSession() });
      expect(await screen.findByText("Child page")).toBeInTheDocument();
    });

    it("starts over with fresh data when the user changes, so nothing of the last user shows", async () => {
      const get = vi
        .fn()
        .mockResolvedValueOnce(me())
        .mockResolvedValue(me());
      const auth = createFakeAuth(anonymousSession());
      renderWithProviders(page, { api: { me: { get } }, auth });
      expect(await screen.findByText("Child page")).toBeInTheDocument();
      expect(get).toHaveBeenCalledTimes(1);

      act(() => auth.setSession({ user: authUser({ id: "user-2" }) }));
      await waitFor(() => expect(get).toHaveBeenCalledTimes(2));
      expect(await screen.findByText("Child page")).toBeInTheDocument();
    });

    it("tells the visitor when a Google sign-in came back with an error", async () => {
      renderWithProviders(page, {
        api: { me: { get: async () => me() } },
        auth: { redirectError: "popup closed" },
      });
      expect(await screen.findByText("Something went wrong. Please try again.")).toBeInTheDocument();
    });
  });
});
