import { i18n } from "@lingui/core";
import { I18nProvider } from "@lingui/react";
import { ThemeProvider } from "@mui/material/styles";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { render, type RenderResult } from "@testing-library/react";
import type { ReactElement, ReactNode } from "react";
import { MemoryRouter, Route, Routes } from "react-router";
import { vi } from "vitest";
import type { Api } from "@/api/api";
import { BackendProvider } from "@/api/ApiProvider";
import type { Community, MembershipStatus } from "@/api/types";
import { ToastProvider } from "@/components/Toast";
import { CommunityScope } from "@/scopes/CommunityScope";
import { appTheme } from "@/theme/theme";
import { community as communityFixture, me as meFixture, membership } from "@/__tests__/support/fixtures";
import { createFakeApi } from "@/__tests__/support/fakeApi";

i18n.load("en", {});
i18n.activate("en");

export interface RenderOptions {
  /** Data the component reads or writes; unstubbed methods reject. */
  api?: Parameters<typeof createFakeApi>[0];
  /** Initial URL (default "/"). */
  route?: string;
  /** Route pattern the component is mounted at, so `useParams` works (default: everywhere). */
  path?: string;
  /** Render as a phone-width viewport (`useIsMobile` is true). */
  mobile?: boolean;
}

export interface RenderResultWithApi extends RenderResult {
  api: Api;
  queryClient: QueryClient;
}

function setMobile(mobile: boolean) {
  // `useIsMobile` is `(max-width: …)`; every other query stays false.
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
}

/**
 * Renders under the same providers as `App`: theme, toasts, i18n (English, no catalog),
 * TanStack Query (no retries), the injected fake backend, and a memory router.
 */
export function renderWithProviders(
  ui: ReactElement,
  { api: apiOverrides, route = "/", path, mobile = false }: RenderOptions = {},
): RenderResultWithApi {
  setMobile(mobile);
  const api = createFakeApi(apiOverrides);
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false, gcTime: Infinity }, mutations: { retry: false } },
  });
  const content: ReactNode = path ? (
    <Routes>
      <Route path={path} element={ui} />
    </Routes>
  ) : (
    ui
  );
  const result = render(
    <QueryClientProvider client={queryClient}>
      <BackendProvider backend={{ api }}>
        <ThemeProvider theme={appTheme}>
          <ToastProvider>
            <I18nProvider i18n={i18n}>
              <MemoryRouter initialEntries={[route]}>{content}</MemoryRouter>
            </I18nProvider>
          </ToastProvider>
        </ThemeProvider>
      </BackendProvider>
    </QueryClientProvider>,
  );
  return { ...result, api, queryClient };
}

export interface CommunityRenderOptions extends RenderOptions {
  community?: Community;
  /** The signed-in user's status in the community (default "member"). */
  status?: MembershipStatus;
}

/**
 * For components that call `useCommunityScope()`: wraps `ui` in the real `<CommunityScope>`,
 * fed by a stubbed community, membership and (empty) templates. The scope shows a spinner until
 * its queries resolve, so `await screen.findBy…` the first thing you expect.
 */
export function renderInCommunity(
  ui: ReactElement,
  { community = communityFixture(), status = "member", api, ...rest }: CommunityRenderOptions = {},
): RenderResultWithApi {
  return renderWithProviders(
    <CommunityScope displayId={community.displayId}>{ui}</CommunityScope>,
    {
      ...rest,
      api: {
        me: { get: async () => meFixture({ memberships: [membership({ communityId: community.id, status })] }) },
        communities: { getByDisplayId: async () => community },
        templates: { list: async () => [] },
        ...api,
      } as RenderOptions["api"],
    },
  );
}
