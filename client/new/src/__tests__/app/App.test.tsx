// @vitest-environment jsdom
import { i18n } from "@lingui/core";
import { render, screen, waitFor } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import type { Api } from "@/api/api";
import { createFakeApi } from "@/__tests__/support/fakeApi";
import { anonymousSession, createFakeAuth } from "@/__tests__/support/fakeAuth";
import { community, event, me, membership } from "@/__tests__/support/fixtures";
import { App } from "@/app/App";

const mocks = vi.hoisted(() => ({
  createFirebaseBackend: vi.fn(),
  dynamicActivate: vi.fn(),
}));

// Never touch Firebase or load the real message catalogs.
vi.mock("@/api/firebaseBackend", () => ({
  createFirebaseBackend: mocks.createFirebaseBackend,
}));
vi.mock("@/app/i18n", () => ({
  defaultLocale: "en",
  dynamicActivate: mocks.dynamicActivate,
}));

// `I18nProvider` renders nothing until a locale is active, which the real `dynamicActivate` would do.
i18n.load("en", {});
i18n.activate("en");

const lab = community({ id: "c1", displayId: "civic-lab", name: "Civic Lab" });

const signedIn = {
  me: {
    get: async () =>
      me({
        memberships: [membership({ communityId: "c1", status: "member" })],
      }),
  },
  communities: { getByDisplayId: async () => lab, listMine: async () => [lab] },
  templates: { list: async () => [] },
  events: {
    listUpcoming: async () => [event({ title: "Weekly chat" })],
    listAll: async () => [],
  },
  resources: { list: async () => [] },
  announcements: { list: async () => [] },
};

function renderApp(
  path: string,
  api: Parameters<typeof createFakeApi>[0] = signedIn,
): Api {
  const fake = createFakeApi(api);
  mocks.createFirebaseBackend.mockReturnValue({
    api: fake,
    auth: createFakeAuth(),
  });
  // The app owns a browser router, so the URL is set up the way a visit would.
  window.history.pushState({}, "", path);
  render(<App />);
  return fake;
}

describe("App", () => {
  beforeEach(() => {
    mocks.createFirebaseBackend.mockReset();
    mocks.dynamicActivate.mockReset();
  });

  afterEach(() => {
    vi.unstubAllEnvs();
    vi.unstubAllGlobals();
    vi.restoreAllMocks();
  });

  it("waits for the session before showing anything", async () => {
    renderApp("/space/civic-lab", {
      ...signedIn,
      me: { get: () => new Promise(() => {}) },
    });
    // The locale spinner is replaced by the session spinner, so wait for the catalog first.
    await waitFor(() => expect(mocks.dynamicActivate).toHaveBeenCalled());
    await waitFor(() =>
      expect(screen.getByRole("progressbar")).toBeInTheDocument(),
    );
    expect(screen.queryByText("Civic Lab")).not.toBeInTheDocument();
  });

  it("serves a community page from the URL, through the layout and backend", async () => {
    const api = renderApp("/space/civic-lab");
    expect(
      await screen.findByRole("heading", { name: "Civic Lab" }),
    ).toBeInTheDocument();
    expect(await screen.findByText("Weekly chat")).toBeInTheDocument();
    expect(mocks.createFirebaseBackend).toHaveBeenCalledTimes(1);
    expect(api.communities.getByDisplayId).toHaveBeenCalledWith("civic-lab");
  });

  it("shows the events page at its own URL", async () => {
    renderApp("/space/civic-lab/discuss/upcoming");
    expect(await screen.findByText("Weekly chat")).toBeInTheDocument();
  });

  it("asks a visitor without an account to sign up at the root", async () => {
    mocks.createFirebaseBackend.mockReset();
    mocks.createFirebaseBackend.mockReturnValue({
      api: createFakeApi(signedIn),
      auth: createFakeAuth(anonymousSession()),
    });
    window.history.pushState({}, "", "/");
    render(<App />);
    expect(
      await screen.findByRole("heading", { name: "New to Frankly?" }),
    ).toBeInTheDocument();
  });

  it("shows 'not migrated' instead of reloading for a page Flutter owns", async () => {
    const reload = vi.fn();
    // Set the URL first: the stub copies `window.location`, and the router reads the path from it.
    window.history.pushState({}, "", "/settings");
    vi.stubGlobal("location", { ...window.location, replace: reload });
    renderApp("/settings");
    expect(
      await screen.findByText(/This page is not in the React app yet/),
    ).toBeInTheDocument();
    expect(reload).not.toHaveBeenCalled();
  });

  it("explains when the session cannot be loaded", async () => {
    vi.spyOn(console, "log").mockImplementation(() => {});
    renderApp("/space/civic-lab", {
      ...signedIn,
      me: {
        get: async () => {
          throw new Error("unauthenticated");
        },
      },
    });
    // The app's query client retries once, one second later, before giving up.
    expect(
      await screen.findByText(/Could not load your session\./, undefined, {
        timeout: 3000,
      }),
    ).toBeInTheDocument();
  });

  it("loads the default locale's catalog on mount", async () => {
    renderApp("/space/civic-lab");
    await waitFor(() =>
      expect(mocks.dynamicActivate).toHaveBeenCalledWith("en"),
    );
    await screen.findByRole("heading", { name: "Civic Lab" });
  });

  it("marks the page as the React app", async () => {
    renderApp("/space/civic-lab");
    await screen.findByRole("heading", { name: "Civic Lab" });
    expect(screen.queryByText("React App")).toBeInTheDocument();
  });

  it("shows the 'React App' marker in development", async () => {
    vi.stubEnv("NODE_ENV", "development");
    renderApp("/space/civic-lab");
    expect(await screen.findByText("React App")).toBeInTheDocument();
  });
});
