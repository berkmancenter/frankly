// @vitest-environment jsdom
import { i18n } from "@lingui/core";
import { I18nProvider } from "@lingui/react";
import { useTheme } from "@mui/material/styles";
import { ThemeProvider } from "@mui/material/styles";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { act, render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { createMemoryRouter, RouterProvider, type RouteObject } from "react-router";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { BackendProvider } from "@/api/ApiProvider";
import type { Community, MembershipStatus } from "@/api/types";
import { ToastProvider } from "@/components/Toast";
import { community, me, membership, template } from "@/__tests__/support/fixtures";
import { createFakeApi } from "@/__tests__/support/fakeApi";
import { appTheme } from "@/theme/theme";
import { CommunityLayout, type CommunityRouteHandle } from "@/app/layouts/CommunityLayout";

i18n.load("en", {});
i18n.activate("en");

// `CommunityLayout` reads route `handle`s through `useMatches`, which needs a data router, so
// it cannot be mounted with the memory-router helper in `renderWithProviders`.

function PrimaryColor() {
  return <p data-testid="primary">{useTheme().palette.primary.main}</p>;
}

interface Options {
  community?: Community;
  status?: MembershipStatus;
  hasTemplates?: boolean;
  mobile?: boolean;
  route?: string;
  handle?: CommunityRouteHandle;
  communityError?: boolean;
}

function renderLayout({
  community: c = community(),
  status = "member",
  hasTemplates = true,
  mobile = false,
  route = "/space/civic-lab",
  handle,
  communityError = false,
}: Options = {}) {
  vi.mocked(window.matchMedia).mockImplementation((query: string) => ({
    matches: mobile && query.includes("max-width"),
    media: query,
    onchange: null,
    addEventListener: vi.fn(),
    removeEventListener: vi.fn(),
    addListener: vi.fn(),
    removeListener: vi.fn(),
    dispatchEvent: vi.fn(),
  }));
  const api = createFakeApi({
    me: { get: async () => me({ memberships: [membership({ communityId: c.id, status })] }) },
    communities: {
      getByDisplayId: async (id: string) => {
        if (communityError || id !== c.displayId) throw new Error("not found");
        return c;
      },
      listMine: async () => [c],
    },
    templates: { list: async () => (hasTemplates ? [template({ communityId: c.id })] : []) },
    resources: { list: async () => [] },
    announcements: { list: async () => [] },
  });
  const routes: RouteObject[] = [
    {
      path: "space/:displayId",
      element: <CommunityLayout />,
      children: [
        {
          index: true,
          handle,
          element: (
            <>
              <p>Page body</p>
              <PrimaryColor />
            </>
          ),
        },
        { path: "posts", element: <p>Posts body</p> },
      ],
    },
  ];
  const router = createMemoryRouter(routes, { initialEntries: [route] });
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false, gcTime: Infinity } },
  });
  const result = render(
    <QueryClientProvider client={queryClient}>
      <BackendProvider backend={{ api }}>
        <ThemeProvider theme={appTheme}>
          <ToastProvider>
            <I18nProvider i18n={i18n}>
              <RouterProvider router={router} />
            </I18nProvider>
          </ToastProvider>
        </ThemeProvider>
      </BackendProvider>
    </QueryClientProvider>,
  );
  return { ...result, router, api };
}

/**
 * The scope fetches templates only after the community arrives, and `canCreateEvent` depends on
 * them, so "the button is absent" is only meaningful once that query has been answered.
 */
async function templatesSettled(api: Awaited<ReturnType<typeof renderLayout>>["api"]) {
  await waitFor(() => expect(api.templates.list).toHaveBeenCalled());
  await act(async () => {
    await new Promise((resolve) => setTimeout(resolve, 0));
  });
}

describe("CommunityLayout", () => {
  beforeEach(() => {
    document.title = "Frankly";
  });

  it("shows a spinner, then the matched page inside the community's nav bar", async () => {
    renderLayout();
    expect(screen.getByRole("progressbar")).toBeInTheDocument();
    expect(await screen.findByText("Page body")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Civic Lab" })).toBeInTheDocument();
  });

  it("shows an error when the community cannot be loaded", async () => {
    renderLayout({ communityError: true });
    expect(await screen.findByText("Something went wrong loading the community.")).toBeInTheDocument();
    expect(screen.queryByText("Page body")).not.toBeInTheDocument();
  });

  it("titles the browser tab with the community's name", async () => {
    const { unmount } = renderLayout({ community: community({ name: "Civic Lab" }) });
    await screen.findByText("Page body");
    expect(document.title).toBe("Civic Lab");
    unmount();
    expect(document.title).toBe("Frankly");
  });

  it("themes the page with the community's colors", async () => {
    renderLayout({ community: community({ themeDarkColor: "AA0000", themeLightColor: "FFEEEE" }) });
    expect(await screen.findByTestId("primary")).toHaveTextContent("#AA0000");
  });

  it("renders child routes in place as you navigate within the community", async () => {
    const { router } = renderLayout();
    await screen.findByText("Page body");
    await router.navigate("/space/civic-lab/posts");
    expect(await screen.findByText("Posts body")).toBeInTheDocument();
    expect(screen.queryByText("Page body")).not.toBeInTheDocument();
    // The scope persists across child routes, so the nav bar does not reload.
    expect(screen.getByRole("button", { name: "Civic Lab" })).toBeInTheDocument();
  });

  describe("on a wide screen", () => {
    it("has no bottom navigation", async () => {
      renderLayout();
      await screen.findByText("Page body");
      expect(screen.queryByRole("navigation", { name: "Bottom navigation" })).not.toBeInTheDocument();
    });

    it("offers a floating 'Create an event' button on pages that ask for it, and opens the dialog", async () => {
      const user = userEvent.setup();
      renderLayout({ handle: { createEventFab: true } });
      await user.click(await screen.findByRole("button", { name: "Create an event" }));
      expect(await screen.findByRole("heading", { name: "Choose Template" })).toBeInTheDocument();
    });

    it("has no floating button on pages that do not ask for it", async () => {
      const { api } = renderLayout({ handle: undefined });
      await screen.findByText("Page body");
      await templatesSettled(api);
      expect(screen.queryByRole("button", { name: "Create an event" })).not.toBeInTheDocument();
    });

    it("hides the floating button from people who cannot create events", async () => {
      const { api } = renderLayout({ handle: { createEventFab: true }, status: "banned" });
      await screen.findByText("Page body");
      await templatesSettled(api);
      expect(screen.queryByRole("button", { name: "Create an event" })).not.toBeInTheDocument();
    });

    it("hides the floating button when there is no template to host and the user cannot make one", async () => {
      const { api } = renderLayout({ handle: { createEventFab: true }, hasTemplates: false, status: "member" });
      await screen.findByText("Page body");
      await templatesSettled(api);
      expect(screen.queryByRole("button", { name: "Create an event" })).not.toBeInTheDocument();
    });
  });

  describe("on a phone-width screen", () => {
    it("has a bottom navigation bar instead of a floating button", async () => {
      renderLayout({ mobile: true, handle: { createEventFab: true } });
      const nav = await screen.findByRole("navigation", { name: "Bottom navigation" });
      expect(nav).toBeInTheDocument();
      // The only 'Create an event' control is the one in the bottom bar.
      // (Templates load after the community, so the button appears a moment later.)
      const buttons = await screen.findAllByRole("button", { name: "Create an event" });
      expect(buttons).toHaveLength(1);
      expect(nav).toContainElement(buttons[0]!);
    });

    it("leaves the create-event button out of the bottom bar when the page does not ask for it", async () => {
      const { api } = renderLayout({ mobile: true });
      await screen.findByRole("navigation", { name: "Bottom navigation" });
      await templatesSettled(api);
      expect(screen.queryByRole("button", { name: "Create an event" })).not.toBeInTheDocument();
    });

    it("opens the create-event dialog from the bottom bar", async () => {
      const user = userEvent.setup();
      renderLayout({ mobile: true, handle: { createEventFab: true } });
      await user.click(await screen.findByRole("button", { name: "Create an event" }));
      expect(await screen.findByRole("heading", { name: "Choose Template" })).toBeInTheDocument();
    });
  });
});
