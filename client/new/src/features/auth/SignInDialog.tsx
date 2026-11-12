import {
  useCallback,
  useRef,
  useState,
  type ReactElement,
} from "react";
import { useAuthService } from "@/api/ApiProvider";
import { isRegistered } from "@/api/auth";
import { AppDialog } from "@/components/AppDialog";
import { SignInForm } from "./SignInForm";

export function SignInDialog({
  open,
  showSignUp = true,
  onClose,
}: {
  open: boolean;
  showSignUp?: boolean;
  onClose: () => void;
}) {
  return (
    <AppDialog
      open={open}
      onClose={onClose}
      maxWidth={400}
      padding={40}
      fullscreenOnMobile
      ariaLabel="Sign in"
    >
      <SignInForm showSignUp={showSignUp} onSignedIn={onClose} />
    </AppDialog>
  );
}

/**
 * The opener owns the dialog (see "No imperative dialog stack" in the README): render `dialog`
 * somewhere and call `open()`. The returned promise settles when the dialog closes, however it
 * closed; check the session to find out whether the visitor signed in.
 */
export function useSignInDialog(): {
  open: (options?: { newUser?: boolean }) => Promise<void>;
  dialog: ReactElement | null;
} {
  const [request, setRequest] = useState<{ showSignUp: boolean } | null>(null);
  const settle = useRef<(() => void) | null>(null);

  const open = useCallback(
    ({ newUser = true }: { newUser?: boolean } = {}) =>
      new Promise<void>((resolve) => {
        settle.current = resolve;
        setRequest({ showSignUp: newUser });
      }),
    [],
  );
  const close = useCallback(() => {
    setRequest(null);
    settle.current?.();
    settle.current = null;
  }, []);

  return {
    open,
    dialog: request ? (
      <SignInDialog open showSignUp={request.showSignUp} onClose={close} />
    ) : null,
  };
}

/**
 * Port of `guardSignedIn`: runs `action` for a registered user; an anonymous visitor is asked to
 * sign in or sign up first, and `action` runs only if they do. Resolves to `undefined` when it
 * did not run.
 */
export function useGuardSignedIn(): {
  guard: <T>(action: () => Promise<T> | T) => Promise<T | undefined>;
  dialog: ReactElement | null;
} {
  const auth = useAuthService();
  const { open, dialog } = useSignInDialog();
  const guard = useCallback(
    async <T,>(action: () => Promise<T> | T) => {
      if (!isRegistered(auth.getSession())) await open();
      return isRegistered(auth.getSession()) ? await action() : undefined;
    },
    [auth, open],
  );
  return { guard, dialog };
}
