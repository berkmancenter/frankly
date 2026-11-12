import { useSyncExternalStore } from "react";
import { useAuthService } from "@/api/ApiProvider";
import { isRegistered, type AuthSession } from "@/api/auth";

/** The current auth session; re-renders when it changes. */
export function useAuthSession(): AuthSession {
  const auth = useAuthService();
  return useSyncExternalStore(auth.subscribe, auth.getSession);
}

/** Whether the visitor has an account (as opposed to the anonymous placeholder user). */
export function useIsRegistered(): boolean {
  return isRegistered(useAuthSession());
}
