/**
 * The authentication surface, independent of Firebase.
 *
 * Every visitor is signed in: first-time and returning visitors who have no account get an
 * anonymous Firebase user, and "signing in" replaces it with a registered one. `isAnonymous`
 * is what separates the two.
 */

import type { BackendFailure } from "./backendFailure";

export interface AuthUser {
  id: string;
  email: string | null;
  emailVerified: boolean;
  isAnonymous: boolean;
  displayName: string | null;
  photoUrl: string | null;
}

/** `error`: no session could be established because the backend is misconfigured or unreachable. */
export type AuthStatus = "loading" | "signedIn" | "signedOut" | "error";

/** An immutable snapshot; the service returns the same object until something changes. */
export interface AuthSession {
  status: AuthStatus;
  user: AuthUser | null;
  /** Set when a Google redirect sign-in came back with an error. */
  redirectError: string | null;
  /** Why there is no session; set only while `status` is `error`. */
  failure?: BackendFailure;
}

/** A user who has an account (not the anonymous placeholder). */
export const isRegistered = (session: AuthSession): boolean =>
  !!session.user && !session.user.isAnonymous;

/**
 * Failure of an auth call. `code` is the Firebase auth code without its `auth/` prefix
 * (`invalid-credential`, `email-already-in-use`, …) or one of ours (`email-missing-pw`,
 * `display-name-required`); `AccountErrorMessage` maps it to copy.
 */
export class AuthError extends Error {
  readonly code: string;
  constructor(code: string, message?: string) {
    super(message ?? code);
    this.name = "AuthError";
    this.code = code;
  }
}

export interface AuthService {
  /** Current session. Stable between changes, so it works as a `useSyncExternalStore` snapshot. */
  getSession(): AuthSession;
  /** Starts the service on first use (anonymous sign-in, redirect result). */
  subscribe(listener: () => void): () => void;

  signInWithEmail(email: string, password: string): Promise<void>;
  /** Creates the account; `displayName` becomes the public profile name. */
  registerWithEmail(input: {
    displayName: string;
    email: string;
    password: string;
  }): Promise<void>;
  /** Redirects away to Google; the result is picked up on return. */
  signInWithGoogle(): Promise<void>;
  sendPasswordReset(email: string): Promise<void>;
  sendEmailVerification(): Promise<void>;
  /** Signs out and reloads the page, like Flutter. */
  signOut(): Promise<void>;
}
