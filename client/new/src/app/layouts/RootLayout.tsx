import { useQueryClient } from "@tanstack/react-query";
import { t } from "@lingui/core/macro";
import { useEffect, useState } from "react";
import { Outlet } from "react-router";
import { LoadingState } from "@/components/States";
import { useToast } from "@/components/Toast";
import { useAuthSession } from "@/features/auth/useAuthSession";
import { useMe } from "@/queries/me";
import { isDev } from "@/utils/dev";

/**
 * Root route element. Waits for the auth session (every visitor gets one, anonymous if they have
 * no account), then for the user's own data, before rendering anything. When the user changes,
 * for example after signing in, the server-state cache is dropped so nothing from the previous
 * user is shown.
 */
export function RootLayout() {
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
    return (
      <LoadingState
        height="100dvh"
        message={`Could not load your session.${isDev ? " Are you running the local proxy, and did you first authenticate with the Flutter app? " : ""}`}
      />
    );
  return <Outlet />;
}
