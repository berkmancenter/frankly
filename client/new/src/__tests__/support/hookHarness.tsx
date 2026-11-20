import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { renderHook, type RenderHookResult } from "@testing-library/react";
import type { ReactNode } from "react";
import type { Api } from "@/api/api";
import { BackendProvider } from "@/api/ApiProvider";
import { createFakeApi } from "@/__tests__/support/fakeApi";
import { createFakeAuth } from "@/__tests__/support/fakeAuth";

export interface QueryHookHarness<T, P> extends RenderHookResult<T, P> {
  api: Api;
  queryClient: QueryClient;
}

/**
 * Renders a query hook under the pieces it needs (TanStack Query without retries, plus the
 * injected fake backend) and nothing else, so hook tests do not drag in the theme or router.
 * Pass `queryClient` to share a cache between two renders, and `initialProps` (then
 * `rerender(next)`) to change a hook argument.
 */
export function renderQueryHook<T, P = undefined>(
  hook: (props: P) => T,
  {
    api: apiOverrides,
    queryClient = new QueryClient({
      defaultOptions: { queries: { retry: false, gcTime: Infinity }, mutations: { retry: false } },
    }),
    initialProps,
  }: { api?: Parameters<typeof createFakeApi>[0]; queryClient?: QueryClient; initialProps?: P } = {},
): QueryHookHarness<T, P> {
  const api = createFakeApi(apiOverrides);
  const wrapper = ({ children }: { children: ReactNode }) => (
    <QueryClientProvider client={queryClient}>
      <BackendProvider backend={{ api, auth: createFakeAuth() }}>{children}</BackendProvider>
    </QueryClientProvider>
  );
  return { ...renderHook(hook, { wrapper, initialProps: initialProps as P }), api, queryClient };
}
