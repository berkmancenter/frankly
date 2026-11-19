import CssBaseline from "@mui/material/CssBaseline";
import { ThemeProvider } from "@mui/material/styles";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { lazy, Suspense, useState } from "react";
import { RouterProvider } from "react-router";
import { BackendProvider } from "@/api/ApiProvider";
import { isConfigFailure } from "@/api/backendFailure";
import { ToastProvider } from "@/components/Toast";
import { appTheme } from "@/theme/theme";

import { I18nProvider } from "@lingui/react";
import { i18n } from "@lingui/core";

import { createAppRouter } from "./router";

// Opt in with `?devtools` so the floating button never covers the UI being reviewed.
const devtoolsRequested =
  import.meta.env.DEV &&
  new URLSearchParams(window.location.search).has("devtools");

const ReactQueryDevtools = devtoolsRequested
  ? lazy(() =>
      import("@tanstack/react-query-devtools").then((m) => ({
        default: m.ReactQueryDevtools,
      })),
    )
  : () => null;

/**
 * Composition root. Everything here is *infrastructure*, not application state:
 *   QueryClient  – the server-state cache (TanStack Query)
 *   Backend      – the injected Firebase-backed `Api`
 *   Theme/Toast  – presentation services
 *   Router       – URL = source of truth for navigation state
 * Feature state is created lower down by scopes, keyed by route params.
 */
export function App() {
  const [queryClient] = useState(
    () =>
      new QueryClient({
        defaultOptions: {
          queries: {
            staleTime: 15_000,
            // Unobserved queries are garbage-collected after this: "auto-disposed" server state.
            gcTime: 5 * 60_000,
            // One retry for a flaky network; none for a backend that is misconfigured.
            retry: (count, error) => count < 1 && !isConfigFailure(error),
            refetchOnWindowFocus: false,
          },
        },
      }),
  );
  const [router] = useState(() => createAppRouter());

  return (
    <QueryClientProvider client={queryClient}>
      <BackendProvider>
        <ThemeProvider theme={appTheme}>
          <CssBaseline />
          <ToastProvider>
            <I18nProvider i18n={i18n}>
              <RouterProvider router={router} />
            </I18nProvider>
          </ToastProvider>
        </ThemeProvider>
      </BackendProvider>
      <Suspense fallback={null}>
        <ReactQueryDevtools
          initialIsOpen={false}
          buttonPosition="bottom-left"
        />
      </Suspense>
    </QueryClientProvider>
  );
}
