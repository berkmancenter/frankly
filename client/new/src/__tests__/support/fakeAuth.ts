import { vi, type Mock } from "vitest";
import type { AuthService, AuthSession, AuthUser } from "@/api/auth";

export const authUser = (overrides: Partial<AuthUser> = {}): AuthUser => ({
  id: "user-1",
  email: "ada@example.com",
  emailVerified: true,
  isAnonymous: false,
  displayName: "Ada Lovelace",
  photoUrl: null,
  ...overrides,
});

/** The session of a visitor who has not signed in (Firebase gives them an anonymous user). */
export const anonymousSession = (): AuthSession => ({
  status: "signedIn",
  user: authUser({ isAnonymous: true, email: null, displayName: null }),
  redirectError: null,
});

export type FakeAuth = {
  [K in keyof AuthService]: AuthService[K] extends (...args: infer A) => infer R
    ? Mock<(...args: A) => R>
    : AuthService[K];
} & {
  /** Replace the session and notify subscribers, like a Firebase auth-state change. */
  setSession(next: Partial<AuthSession>): void;
};

/**
 * An `AuthService` for tests: signed in as a registered user unless told otherwise, every
 * method a resolving `vi.fn`, and `setSession` to simulate auth-state changes.
 */
export function createFakeAuth(initial: Partial<AuthSession> = {}): FakeAuth {
  let session: AuthSession = {
    status: "signedIn",
    user: authUser(),
    redirectError: null,
    ...initial,
  };
  const listeners = new Set<() => void>();
  return {
    getSession: vi.fn(() => session),
    subscribe: vi.fn((listener: () => void) => {
      listeners.add(listener);
      return () => {
        listeners.delete(listener);
      };
    }),
    signInWithEmail: vi.fn(async () => {}),
    registerWithEmail: vi.fn(async () => {}),
    signInWithGoogle: vi.fn(async () => {}),
    sendPasswordReset: vi.fn(async () => {}),
    sendEmailVerification: vi.fn(async () => {}),
    signOut: vi.fn(async () => {}),
    setSession(next) {
      session = { ...session, ...next };
      listeners.forEach((listener) => listener());
    },
  };
}
