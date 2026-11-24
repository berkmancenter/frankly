// @vitest-environment jsdom
import { act, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { Route, Routes } from "react-router";
import { me } from "@/__tests__/support/fixtures";
import { anonymousSession, authUser, createFakeAuth } from "@/__tests__/support/fakeAuth";
import { renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { RootLayout } from "@/app/layouts/RootLayout";

// The real catalog loads through a dynamic import, which is not what these tests are about
// (and which the test that stubs `location` would break).
vi.mock("@/app/i18n", async (importOriginal) => ({
  ...(await importOriginal<typeof import("@/app/i18n")>()),
  dynamicActivate: vi.fn(async () => {}),
}));

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
    expect(message.textContent).toBe("Could not load your session. Please try again.");
  });

  describe("when the backend cannot be reached", () => {
    it("explains a session that could not be established, instead of spinning", async () => {
      renderWithProviders(page, {
        auth: {
          status: "error",
          user: null,
          failure: { kind: "network", code: "network-request-failed", message: "offline" },
        },
      });
      expect(await screen.findByRole("heading", { name: "We can't reach the server" })).toBeInTheDocument();
      expect(screen.getByText("network-request-failed: offline")).toBeInTheDocument();
      expect(screen.queryByRole("progressbar")).not.toBeInTheDocument();
      expect(screen.queryByText("Child page")).not.toBeInTheDocument();
    });

    it("says the backend is misconfigured when its settings are wrong", async () => {
      renderWithProviders(page, {
        auth: {
          status: "error",
          user: null,
          failure: { kind: "config", code: "invalid-api-key", message: "bad key" },
        },
      });
      expect(await screen.findByRole("heading", { name: "The app can't connect to its backend" })).toBeInTheDocument();
    });

    it("explains a user whose data cannot be loaded because the service is unreachable", async () => {
      vi.spyOn(console, "error").mockImplementation(() => {});
      renderWithProviders(page, {
        api: {
          me: {
            get: async () => {
              throw Object.assign(new Error("Failed to get document because the client is offline."), {
                code: "unavailable",
              });
            },
          },
        },
      });
      expect(await screen.findByRole("heading", { name: "We can't reach the server" }, { timeout: 3000 })).toBeInTheDocument();
    });

    it("retries by reloading the page", async () => {
      const reload = vi.fn();
      vi.stubGlobal("location", { ...window.location, reload });
      renderWithProviders(page, {
        auth: { status: "error", user: null, failure: { kind: "service", code: "internal-error", message: "" } },
      });
      await userEvent.click(await screen.findByRole("button", { name: "Try again" }));
      expect(reload).toHaveBeenCalledTimes(1);
      vi.unstubAllGlobals();
    });
  });

  describe("auth session", () => {
    it("waits for the visitor to be signed in, without asking for their data yet", () => {
      const { api } = renderWithProviders(page, { auth: { status: "loading", user: null } });
      expect(screen.getByRole("progressbar")).toBeInTheDocument();
      expect(api.me.get).not.toHaveBeenCalled();
    });

    it("tells a signed-out visitor to refresh", async () => {
      renderWithProviders(page, { auth: { status: "signedOut", user: null } });
      expect(await screen.findByText("You have been signed out. Please refresh to sign back in")).toBeInTheDocument();
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
