import { Outlet } from 'react-router';
import { LoadingState } from '@/components/States';
import { useMe } from '@/queries/me';

/**
 * Root route element. Waits for the (fake) session before rendering anything — the port of
 * `InitialLoadingWidget`. Auth is out of scope: there is always a local user.
 */
export function RootLayout() {
  const me = useMe();
  if (me.isPending) return <LoadingState height="100dvh" />;
  if (me.isError) return <LoadingState height="100dvh" message="Could not load your session." />;
  return <Outlet />;
}
