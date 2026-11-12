import CssBaseline from "@mui/material/CssBaseline";
import { ThemeProvider } from "@mui/material/styles";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { lazy, Suspense, useEffect, useState } from "react";
import { RouterProvider } from "react-router";
import { BackendProvider } from "@/api/ApiProvider";
import { ToastProvider } from "@/components/Toast";
import { appTheme } from "@/theme/theme";
import Box from "@mui/material/Box";

import { I18nProvider } from "@lingui/react";
import { i18n } from "@lingui/core";
import { defaultLocale, dynamicActivate } from "./i18n";

import { createAppRouter } from "./router";
import { colors } from "@/theme/tokens";

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
            retry: 1,
            refetchOnWindowFocus: false,
          },
        },
      }),
  );
  const [router] = useState(() => createAppRouter());

  useEffect(() => {
    // Dynamically load the catalogs;
    // this keeps the initial bundle small and only loads the necessary locale.
    dynamicActivate(defaultLocale);
  }, []);

  return (
    <QueryClientProvider client={queryClient}>
      <BackendProvider>
        <ThemeProvider theme={appTheme}>
          <CssBaseline />
          <ToastProvider>
            <I18nProvider i18n={i18n}>
              <Box
                sx={{
                  position: "fixed",
                  top: "3rem",
                  right: "-8rem",
                  zIndex: 1300,
                  transition: "transform 0.3s ease-in-out",
                  transform: "rotate(45deg)",
                  width: "400px",
                  textAlign: "center",
                  paddingY: "0.5rem",
                  backgroundColor: "rgba(255, 94, 0, 0.95)",
                  color: colors.onPrimary,
                  fontWeight: "bold",
                }}
                onMouseEnter={(e) => {
                  (e.currentTarget as HTMLDivElement).style.transform =
                    "rotate(45deg) scale(1.4)";
                }}
                onMouseLeave={(e) => {
                  (e.currentTarget as HTMLDivElement).style.transform =
                    "rotate(45deg) scale(1)";
                }}
              >
                React App
              </Box>

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
