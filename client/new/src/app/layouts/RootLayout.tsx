import { Outlet } from "react-router";
import { LoadingState } from "@/components/States";
import { useMe } from "@/queries/me";
import { isDev } from "@/utils/dev";

/**
 * Root route element. Waits for the session before rendering anything.
 */
export function RootLayout() {
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
