import Box from "@mui/material/Box";
import { useQueryClient } from "@tanstack/react-query";
import { t } from "@lingui/core/macro";
import { Trans } from "@lingui/react/macro";
import { useEffect, useState } from "react";
import { Outlet } from "react-router";
import { describeBackendFailure } from "@/api/backendFailure";
import { BackendUnavailable } from "@/components/BackendUnavailable";
import { LoadingState } from "@/components/States";
import { useToast } from "@/components/Toast";
import { useAuthSession } from "@/features/auth/useAuthSession";
import { useMe } from "@/queries/me";
import { colors } from "@/theme/tokens";
import { defaultLocale, dynamicActivate } from "../i18n";

/** True once the default locale's catalog has loaded (or failed to, so the app still opens). */
function useLocaleReady() {
  const [ready, setReady] = useState(false);
  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        await dynamicActivate(defaultLocale);
      } catch (error) {
        console.error("Could not load the locale catalog", error);
      } finally {
        if (!cancelled) setReady(true);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, []);
  return ready;
}

/** Corner ribbon that marks this page as the React app rather than the Flutter one. */
function ReactAppRibbon() {
  return (
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
      <Trans>React App</Trans>
    </Box>
  );
}

/**
 * Root route element. First waits for the locale catalog, since nothing can be worded before it
 * loads. Then waits for the auth session (every visitor gets one, anonymous if they have
 * no account), then for the user's own data, before rendering anything. When the user changes,
 * for example after signing in, the server-state cache is dropped so nothing from the previous
 * user is shown.
 */
export function RootLayout() {
  const localeReady = useLocaleReady();
  if (!localeReady) return <LoadingState height="100dvh" />;
  return (
    <>
      <ReactAppRibbon />
      <SessionGate />
    </>
  );
}

function SessionGate() {
  const session = useAuthSession();
  const queryClient = useQueryClient();
  const toast = useToast();

  const uid = session.user?.id ?? null;
  const [syncedUid, setSyncedUid] = useState(uid);
  useEffect(() => {
    if (syncedUid !== uid) {
      queryClient.clear();
      setSyncedUid(uid);
    }
  }, [uid, syncedUid, queryClient]);

  const { redirectError } = session;
  useEffect(() => {
    if (redirectError) {
      toast.error(
        t({
          id: "somethingWentWrongTryAgain",
          message: "Something went wrong. Please try again.",
        }),
      );
    }
  }, [redirectError, toast]);

  if (session.status === "error" && session.failure) {
    return <BackendUnavailable failure={session.failure} />;
  }
  if (session.status === "signedOut") {
    return (
      <LoadingState
        height="100dvh"
        message={t({
          id: "signedOutRefreshPrompt",
          message: "You have been signed out. Please refresh to sign back in",
        })}
      />
    );
  }
  if (session.status === "loading" || syncedUid !== uid) {
    return <LoadingState height="100dvh" />;
  }
  return <SessionBoundary />;
}

function SessionBoundary() {
  const me = useMe();
  if (me.isPending) return <LoadingState height="100dvh" />;
  if (me.isError)
    return <BackendUnavailable failure={describeBackendFailure(me.error)} />;
  return <Outlet />;
}
