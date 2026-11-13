import { FirebaseError } from "firebase/app";
import { t } from "@lingui/core/macro";
import {
  GoogleAuthProvider,
  browserSessionPersistence,
  createUserWithEmailAndPassword,
  getRedirectResult,
  onAuthStateChanged,
  sendEmailVerification,
  sendPasswordResetEmail,
  setPersistence,
  signInAnonymously,
  signInWithEmailAndPassword,
  signInWithRedirect,
  signOut,
  type Auth,
  type User,
} from "firebase/auth";
import { doc, runTransaction, type Firestore } from "firebase/firestore";
import { defaultDisplayName, uidToInt } from "@/utils/users";
import { describeBackendFailure } from "./backendFailure";
import {
  AuthError,
  type AuthService,
  type AuthSession,
  type AuthUser,
} from "./auth";

/**
 * Flutter keeps "is this a returning visitor" in shared preferences, which on the web is
 * `localStorage["flutter.is-returning-user"]`. Using the same key lets the two apps agree
 * when a visitor moves between them.
 */
const RETURNING_USER_KEY = "flutter.is-returning-user";

/** How long to wait for Firebase to restore a returning user before signing in anonymously. */
const RETURNING_USER_TIMEOUT_MS = 8_000;

/** How long to wait for any session at all before reporting that the backend cannot be reached. */
const STARTUP_TIMEOUT_MS = 20_000;

export interface FirebaseAuthServiceOptions {
  /**
   * Keep the session in `sessionStorage` instead of IndexedDB. Flutter does this against the
   * emulator ("avoid logout across hard reloads"); both apps must agree or they will not
   * see each other's user.
   */
  sessionPersistence?: boolean;
  /** For tests. */
  storage?: Pick<Storage, "getItem" | "setItem">;
  returningUserTimeoutMs?: number;
  startupTimeoutMs?: number;
  reload?: () => void;
  origin?: string;
}

function toAuthUser(user: User): AuthUser {
  return {
    id: user.uid,
    email: user.email,
    emailVerified: user.emailVerified,
    isAnonymous: user.isAnonymous,
    displayName: user.displayName,
    photoUrl: user.photoURL,
  };
}

const sameUser = (a: AuthUser | null, b: AuthUser | null) =>
  a === b ||
  (!!a &&
    !!b &&
    a.id === b.id &&
    a.email === b.email &&
    a.emailVerified === b.emailVerified &&
    a.isAnonymous === b.isAnonymous &&
    a.displayName === b.displayName &&
    a.photoUrl === b.photoUrl);

/** Firebase failures become `AuthError`s carrying the code without the `auth/` prefix. */
async function wrapAuthErrors<T>(action: () => Promise<T>): Promise<T> {
  try {
    return await action();
  } catch (error) {
    if (error instanceof FirebaseError) {
      throw new AuthError(error.code.replace(/^auth\//, ""), error.message);
    }
    throw error;
  }
}

export function createFirebaseAuthService(
  client: { auth: Auth; firestore: Firestore },
  options: FirebaseAuthServiceOptions = {},
): AuthService {
  const { auth, firestore } = client;
  const storage = options.storage ?? safeLocalStorage();
  const timeoutMs = options.returningUserTimeoutMs ?? RETURNING_USER_TIMEOUT_MS;
  const startupTimeoutMs = options.startupTimeoutMs ?? STARTUP_TIMEOUT_MS;
  const reload = options.reload ?? (() => window.location.reload());
  const origin = options.origin ?? window.location.origin;

  let session: AuthSession = {
    status: "loading",
    user: null,
    redirectError: null,
  };
  const listeners = new Set<() => void>();
  let started = false;
  let signingInAnonymously = false;
  let returningUserTimer: ReturnType<typeof setTimeout> | undefined;
  /** Name typed at sign-up, used when the auth-state callback creates the public profile. */
  let registrationName: string | null = null;

  const isReturningUser = () => {
    try {
      return storage.getItem(RETURNING_USER_KEY) === "true";
    } catch {
      return false;
    }
  };
  const setReturningUser = (value: boolean) => {
    try {
      storage.setItem(RETURNING_USER_KEY, String(value));
    } catch {
      /* private mode: the visitor is just treated as new next time */
    }
  };

  function publish(next: Partial<AuthSession>) {
    const merged = { ...session, ...next };
    if (
      merged.status === session.status &&
      merged.redirectError === session.redirectError &&
      merged.failure === session.failure &&
      sameUser(merged.user, session.user)
    ) {
      return;
    }
    session = merged;
    listeners.forEach((listener) => listener());
  }

  /** Creates `publicUser/{uid}` for a new account; backfills `agoraId` on older ones. */
  async function ensurePublicUser(user: User) {
    const ref = doc(firestore, "publicUser", user.uid);
    const agoraId = uidToInt(user.uid);
    await runTransaction(firestore, async (tx) => {
      const snapshot = await tx.get(ref);
      if (!snapshot.exists()) {
        tx.set(ref, {
          id: user.uid,
          agoraId,
          displayName: defaultDisplayName({
            uid: user.uid,
            registrationName,
            profileName: user.displayName,
            email: user.email,
          }),
          imageUrl: user.photoURL || `https://picsum.photos/seed/${user.uid}/80`,
        });
      } else if (snapshot.data().agoraId !== agoraId) {
        tx.set(ref, { agoraId }, { merge: true });
      }
    });
  }

  async function handleUserSignedIn(user: User) {
    setReturningUser(true);
    clearTimeout(returningUserTimer);

    // A verification finished on Firebase's hosted page only shows up after a reload.
    if (!user.isAnonymous && !user.emailVerified) {
      try {
        await user.reload();
      } catch {
        /* the verify-email flow deals with a dead session */
      }
    }

    // Publish before the Firestore write: it can hang when the browser blocks Firestore's
    // WebChannel, and the UI must not wait on it.
    publish({ status: "signedIn", user: toAuthUser(user), failure: undefined });

    if (!user.isAnonymous) {
      try {
        await ensurePublicUser(user);
      } catch (error) {
        console.error("Could not create the public profile", error);
      } finally {
        registrationName = null;
      }
    }
  }

  async function signInAnonymouslyOnce() {
    if (signingInAnonymously) return;
    signingInAnonymously = true;
    try {
      await signInAnonymously(auth);
    } catch (error) {
      // Without a user there is no session, so the app cannot start: say why, rather than spin.
      console.error("Anonymous sign-in failed", error);
      publish({ status: "error", user: null, failure: describeBackendFailure(error) });
    } finally {
      signingInAnonymously = false;
    }
  }

  async function start() {
    // A backend that never answers fails nothing, so give up waiting for a session.
    setTimeout(() => {
      if (session.status === "loading") {
        publish({
          status: "error",
          user: null,
          failure: {
            kind: "network",
            code: "timeout",
            message: t`No response from the backend after ${Math.round(startupTimeoutMs / 1000)} seconds.`,
          },
        });
      }
    }, startupTimeoutMs);

    if (options.sessionPersistence) {
      try {
        await setPersistence(auth, browserSessionPersistence);
      } catch (error) {
        console.error("Could not set session persistence", error);
      }
    }

    if (isReturningUser()) {
      // Firebase restores a returning user by itself; only fall back if it never does.
      returningUserTimer = setTimeout(() => {
        const user = auth.currentUser;
        if (user) void handleUserSignedIn(user);
        else void signInAnonymouslyOnce();
      }, timeoutMs);
    }

    onAuthStateChanged(auth, (user) => {
      if (!user && !isReturningUser()) {
        void signInAnonymouslyOnce();
      } else if (!user && session.status === "signedIn") {
        publish({ status: "signedOut", user: null });
      } else if (user) {
        void handleUserSignedIn(user);
      }
    });

    // Success is delivered through the auth-state callback; this only surfaces failures.
    getRedirectResult(auth).catch((error: unknown) => {
      publish({
        redirectError: error instanceof Error ? error.message : String(error),
      });
    });
  }

  /**
   * Resolves once the session shows this user, so callers can rely on `getSession()` after
   * signing in (the auth-state callback publishes asynchronously).
   */
  function sessionReady(uid: string): Promise<void> {
    if (!started) return Promise.resolve();
    return new Promise((resolve) => {
      const check = () => {
        if (session.status === "signedIn" && session.user?.id === uid) {
          listeners.delete(check);
          resolve();
        }
      };
      listeners.add(check);
      check();
    });
  }

  function sendVerification(user: User) {
    return wrapAuthErrors(() =>
      sendEmailVerification(user, {
        url: `${origin}/`,
        handleCodeInApp: true,
      }),
    );
  }

  /**
   * Like Flutter, signing in or registering with an unverified address sends the verification
   * email. A failure here must not undo the sign-in: the verify-email page can resend.
   */
  async function sendVerificationIfNeeded(user: User) {
    if (user.emailVerified) return;
    try {
      await sendVerification(user);
    } catch (error) {
      console.error("Could not send the verification email", error);
    }
  }

  return {
    getSession: () => session,

    subscribe(listener) {
      listeners.add(listener);
      if (!started) {
        started = true;
        void start();
      }
      return () => {
        listeners.delete(listener);
      };
    },

    async signInWithEmail(email, password) {
      const credential = await wrapAuthErrors(() =>
        signInWithEmailAndPassword(auth, email, password),
      );
      await sendVerificationIfNeeded(credential.user);
      await sessionReady(credential.user.uid);
    },

    async registerWithEmail({ displayName, email, password }) {
      if (displayName.trim().length === 0) {
        throw new AuthError("display-name-required", "Your name is required.");
      }
      registrationName = displayName;
      let credential;
      try {
        credential = await wrapAuthErrors(() =>
          createUserWithEmailAndPassword(auth, email, password),
        );
      } catch (error) {
        registrationName = null;
        throw error;
      }
      await sendVerificationIfNeeded(credential.user);
      await sessionReady(credential.user.uid);
    },

    async signInWithGoogle() {
      const provider = new GoogleAuthProvider();
      provider.setCustomParameters({ prompt: "select_account" });
      await wrapAuthErrors(() => signInWithRedirect(auth, provider));
    },

    async sendPasswordReset(email) {
      if (email.trim().length === 0) {
        throw new AuthError(
          "email-missing-pw",
          "Email must be entered to reset password.",
        );
      }
      await wrapAuthErrors(() => sendPasswordResetEmail(auth, email));
    },

    async sendEmailVerification() {
      const user = auth.currentUser;
      if (user) await sendVerification(user);
    },

    async signOut() {
      setReturningUser(false);
      await signOut(auth);
      reload();
    },
  };
}

function safeLocalStorage(): Pick<Storage, "getItem" | "setItem"> {
  try {
    return window.localStorage;
  } catch {
    return { getItem: () => null, setItem: () => {} };
  }
}
