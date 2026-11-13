// @vitest-environment jsdom
import { FirebaseError } from "firebase/app";
import type { Auth, User } from "firebase/auth";
import type { Firestore } from "firebase/firestore";
import { afterEach, beforeEach, describe, expect, it, vi, type Mock } from "vitest";
import { AuthError, type AuthService } from "@/api/auth";
import { createFirebaseAuthService } from "@/api/firebaseAuthService";

const fb = vi.hoisted(() => ({
  onAuthStateChanged: vi.fn(),
  signInAnonymously: vi.fn(),
  signInWithEmailAndPassword: vi.fn(),
  createUserWithEmailAndPassword: vi.fn(),
  signInWithRedirect: vi.fn(),
  getRedirectResult: vi.fn(),
  sendPasswordResetEmail: vi.fn(),
  sendEmailVerification: vi.fn(),
  signOut: vi.fn(),
  setPersistence: vi.fn(),
  runTransaction: vi.fn(),
  setCustomParameters: vi.fn(),
}));

vi.mock("firebase/auth", () => ({
  GoogleAuthProvider: class {
    setCustomParameters = fb.setCustomParameters;
  },
  browserSessionPersistence: "session",
  onAuthStateChanged: fb.onAuthStateChanged,
  signInAnonymously: fb.signInAnonymously,
  signInWithEmailAndPassword: fb.signInWithEmailAndPassword,
  createUserWithEmailAndPassword: fb.createUserWithEmailAndPassword,
  signInWithRedirect: fb.signInWithRedirect,
  getRedirectResult: fb.getRedirectResult,
  sendPasswordResetEmail: fb.sendPasswordResetEmail,
  sendEmailVerification: fb.sendEmailVerification,
  signOut: fb.signOut,
  setPersistence: fb.setPersistence,
}));
vi.mock("firebase/firestore", () => ({
  doc: (_db: unknown, ...path: string[]) => ({ path: path.join("/") }),
  runTransaction: fb.runTransaction,
}));

const KEY = "flutter.is-returning-user";

const firebaseUser = (overrides: Partial<User> = {}) =>
  ({
    uid: "abcdef123",
    email: "ada@example.com",
    emailVerified: true,
    isAnonymous: false,
    displayName: null,
    photoURL: null,
    reload: vi.fn(async () => {}),
    ...overrides,
  }) as unknown as User;

class MemoryStorage {
  private items = new Map<string, string>();
  getItem = (key: string) => this.items.get(key) ?? null;
  setItem = (key: string, value: string) => void this.items.set(key, value);
}

let emitAuthState: (user: User | null) => void;
let tx: { get: ReturnType<typeof vi.fn>; set: ReturnType<typeof vi.fn> };
let storage: MemoryStorage;
let reload: Mock<() => void>;
const auth = { currentUser: null } as unknown as Auth;

function create(options: Parameters<typeof createFirebaseAuthService>[1] = {}): AuthService {
  return createFirebaseAuthService(
    { auth, firestore: {} as Firestore },
    { storage, reload, origin: "https://app.test", ...options },
  );
}

/** Subscribes (which starts the service) and lets the start-up promises settle. */
async function started(options?: Parameters<typeof createFirebaseAuthService>[1]) {
  const service = create(options);
  const listener = vi.fn();
  service.subscribe(listener);
  await vi.advanceTimersByTimeAsync(0);
  return { service, listener };
}

const settle = () => vi.advanceTimersByTimeAsync(0);

describe("createFirebaseAuthService", () => {
  beforeEach(() => {
    vi.useFakeTimers();
    vi.spyOn(console, "error").mockImplementation(() => {});
    Object.values(fb).forEach((mock) => mock.mockReset());
    fb.onAuthStateChanged.mockImplementation((_auth: Auth, callback: (user: User | null) => void) => {
      emitAuthState = callback;
      return () => {};
    });
    fb.getRedirectResult.mockResolvedValue(null);
    fb.signInAnonymously.mockResolvedValue({});
    fb.setPersistence.mockResolvedValue(undefined);
    tx = { get: vi.fn(async () => ({ exists: () => false, data: () => ({}) })), set: vi.fn() };
    fb.runTransaction.mockImplementation(async (_db: unknown, run: (t: typeof tx) => unknown) => run(tx));
    storage = new MemoryStorage();
    reload = vi.fn();
    (auth as { currentUser: User | null }).currentUser = null;
  });

  afterEach(() => {
    vi.useRealTimers();
    vi.restoreAllMocks();
  });

  describe("session", () => {
    it("is loading and does nothing until someone subscribes", () => {
      const service = create();
      expect(service.getSession()).toEqual({ status: "loading", user: null, redirectError: null });
      expect(fb.onAuthStateChanged).not.toHaveBeenCalled();
    });

    it("starts once, however many subscribe", async () => {
      const { service } = await started();
      service.subscribe(() => {});
      await settle();
      expect(fb.onAuthStateChanged).toHaveBeenCalledTimes(1);
    });

    it("publishes the signed-in user and remembers the visitor as returning", async () => {
      const { service, listener } = await started();
      emitAuthState(firebaseUser());
      await settle();
      expect(service.getSession()).toMatchObject({
        status: "signedIn",
        user: { id: "abcdef123", email: "ada@example.com", isAnonymous: false, emailVerified: true },
      });
      expect(listener).toHaveBeenCalled();
      expect(storage.getItem(KEY)).toBe("true");
    });

    it("returns the same snapshot until something changes", async () => {
      const { service } = await started();
      emitAuthState(firebaseUser());
      await settle();
      const before = service.getSession();
      emitAuthState(firebaseUser());
      await settle();
      expect(service.getSession()).toBe(before);
    });

    it("becomes signed out when the user goes away", async () => {
      const { service } = await started();
      emitAuthState(firebaseUser());
      await settle();
      storage.setItem(KEY, "true");
      emitAuthState(null);
      await settle();
      expect(service.getSession()).toMatchObject({ status: "signedOut", user: null });
    });

    it("reloads an unverified user so a verification done elsewhere is noticed", async () => {
      const user = firebaseUser({ emailVerified: false });
      vi.mocked(user.reload).mockImplementation(async () => {
        (user as { emailVerified: boolean }).emailVerified = true;
      });
      const { service } = await started();
      emitAuthState(user);
      await settle();
      expect(user.reload).toHaveBeenCalled();
      expect(service.getSession().user?.emailVerified).toBe(true);
    });

    it("surfaces a failed Google redirect", async () => {
      fb.getRedirectResult.mockRejectedValue(new Error("popup closed"));
      const { service } = await started();
      expect(service.getSession().redirectError).toBe("popup closed");
    });

    it("keeps the session in sessionStorage when asked (emulator)", async () => {
      await started({ sessionPersistence: true });
      expect(fb.setPersistence).toHaveBeenCalledWith(auth, "session");
    });
  });

  describe("when the backend cannot be used", () => {
    it("reports why a new visitor could not be signed in, instead of staying on loading", async () => {
      fb.signInAnonymously.mockRejectedValue(new FirebaseError("auth/network-request-failed", "offline"));
      const { service, listener } = await started();
      emitAuthState(null);
      await settle();
      expect(service.getSession()).toMatchObject({
        status: "error",
        user: null,
        failure: { kind: "network", code: "network-request-failed", message: "offline" },
      });
      expect(listener).toHaveBeenCalled();
    });

    it("tells a wrong API key from a network problem", async () => {
      fb.signInAnonymously.mockRejectedValue(new FirebaseError("auth/invalid-api-key", "bad key"));
      const { service } = await started();
      emitAuthState(null);
      await settle();
      expect(service.getSession().failure?.kind).toBe("config");
    });

    it("still reports a failure it does not recognize", async () => {
      fb.signInAnonymously.mockRejectedValue(new Error("who knows"));
      const { service } = await started();
      emitAuthState(null);
      await settle();
      expect(service.getSession()).toMatchObject({ status: "error", failure: { kind: "unknown" } });
    });

    it("reports a returning visitor whose anonymous fallback fails", async () => {
      storage.setItem(KEY, "true");
      fb.signInAnonymously.mockRejectedValue(new FirebaseError("auth/network-request-failed", "offline"));
      const { service } = await started({ returningUserTimeoutMs: 8000 });
      emitAuthState(null);
      await vi.advanceTimersByTimeAsync(8000);
      expect(service.getSession().status).toBe("error");
    });

    it("gives up waiting for a backend that never answers", async () => {
      fb.signInAnonymously.mockReturnValue(new Promise(() => {}));
      const { service } = await started({ startupTimeoutMs: 15_000 });
      emitAuthState(null);
      await vi.advanceTimersByTimeAsync(14_999);
      expect(service.getSession().status).toBe("loading");
      await vi.advanceTimersByTimeAsync(1);
      expect(service.getSession()).toMatchObject({ status: "error", failure: { kind: "network", code: "timeout" } });
    });

    it("does not time out a session that arrived in time", async () => {
      const { service } = await started({ startupTimeoutMs: 15_000 });
      emitAuthState(firebaseUser());
      await vi.advanceTimersByTimeAsync(30_000);
      expect(service.getSession().status).toBe("signedIn");
    });

    it("recovers when a user turns up after the failure", async () => {
      fb.signInAnonymously.mockRejectedValue(new FirebaseError("auth/network-request-failed", "offline"));
      const { service } = await started();
      emitAuthState(null);
      await settle();
      emitAuthState(firebaseUser());
      await settle();
      expect(service.getSession().status).toBe("signedIn");
      expect(service.getSession().failure).toBeUndefined();
    });
  });

  describe("anonymous visitors", () => {
    it("signs a new visitor in anonymously", async () => {
      await started();
      emitAuthState(null);
      await settle();
      expect(fb.signInAnonymously).toHaveBeenCalledTimes(1);
    });

    it("does not start a second anonymous sign-in while one is running", async () => {
      fb.signInAnonymously.mockReturnValue(new Promise(() => {}));
      await started();
      emitAuthState(null);
      emitAuthState(null);
      await settle();
      expect(fb.signInAnonymously).toHaveBeenCalledTimes(1);
    });

    it("gives a returning visitor time to be restored before signing in anonymously", async () => {
      storage.setItem(KEY, "true");
      await started({ returningUserTimeoutMs: 8000 });
      emitAuthState(null);
      await vi.advanceTimersByTimeAsync(7999);
      expect(fb.signInAnonymously).not.toHaveBeenCalled();
      await vi.advanceTimersByTimeAsync(1);
      expect(fb.signInAnonymously).toHaveBeenCalledTimes(1);
    });

    it("does not sign a restored returning visitor in anonymously", async () => {
      storage.setItem(KEY, "true");
      await started({ returningUserTimeoutMs: 8000 });
      emitAuthState(firebaseUser({ isAnonymous: true, email: null }));
      await vi.advanceTimersByTimeAsync(10_000);
      expect(fb.signInAnonymously).not.toHaveBeenCalled();
    });

    it("does not create a public profile for an anonymous user", async () => {
      await started();
      emitAuthState(firebaseUser({ isAnonymous: true, email: null }));
      await settle();
      expect(fb.runTransaction).not.toHaveBeenCalled();
    });
  });

  describe("public profile", () => {
    it("creates it for a new account, named from the registration form", async () => {
      fb.createUserWithEmailAndPassword.mockImplementation(async () => {
        const user = firebaseUser({ emailVerified: false });
        emitAuthState(user);
        return { user };
      });
      const { service } = await started();
      await service.registerWithEmail({ displayName: "Ada Lovelace", email: "ada@example.com", password: "pw" });
      await settle();
      expect(tx.set).toHaveBeenCalledWith(
        { path: "publicUser/abcdef123" },
        {
          id: "abcdef123",
          agoraId: expect.any(Number),
          displayName: "Ada L",
          imageUrl: "https://picsum.photos/seed/abcdef123/80",
        },
      );
    });

    it("uses the account photo and name from the provider when there is no form (Google)", async () => {
      const { service } = await started();
      emitAuthState(firebaseUser({ displayName: "Grace Hopper", photoURL: "https://img/g.png" }));
      await settle();
      expect(service.getSession().user?.id).toBe("abcdef123");
      expect(tx.set).toHaveBeenCalledWith(
        { path: "publicUser/abcdef123" },
        expect.objectContaining({ displayName: "Grace H", imageUrl: "https://img/g.png" }),
      );
    });

    it("leaves an existing profile alone", async () => {
      const { uidToInt } = await import("@/utils/users");
      tx.get.mockResolvedValue({ exists: () => true, data: () => ({ agoraId: uidToInt("abcdef123") }) });
      await started();
      emitAuthState(firebaseUser());
      await settle();
      expect(tx.set).not.toHaveBeenCalled();
    });

    it("backfills agoraId on an older profile", async () => {
      tx.get.mockResolvedValue({ exists: () => true, data: () => ({ displayName: "Old" }) });
      await started();
      emitAuthState(firebaseUser());
      await settle();
      expect(tx.set).toHaveBeenCalledWith(
        { path: "publicUser/abcdef123" },
        { agoraId: expect.any(Number) },
        { merge: true },
      );
    });

    it("does not hold up the session when the profile write fails", async () => {
      fb.runTransaction.mockRejectedValue(new Error("blocked"));
      const { service } = await started();
      emitAuthState(firebaseUser());
      await settle();
      expect(service.getSession().status).toBe("signedIn");
    });
  });

  describe("signInWithEmail", () => {
    it("signs in, and resolves once the session shows the user", async () => {
      const user = firebaseUser();
      fb.signInWithEmailAndPassword.mockImplementation(async () => {
        emitAuthState(user);
        return { user };
      });
      const { service } = await started();
      await service.signInWithEmail("ada@example.com", "pw");
      expect(fb.signInWithEmailAndPassword).toHaveBeenCalledWith(auth, "ada@example.com", "pw");
      expect(service.getSession().user?.id).toBe("abcdef123");
      expect(fb.sendEmailVerification).not.toHaveBeenCalled();
    });

    it("sends the verification email to an unverified address", async () => {
      const user = firebaseUser({ emailVerified: false });
      fb.signInWithEmailAndPassword.mockImplementation(async () => {
        emitAuthState(user);
        return { user };
      });
      const { service } = await started();
      await service.signInWithEmail("ada@example.com", "pw");
      expect(fb.sendEmailVerification).toHaveBeenCalledWith(user, {
        url: "https://app.test/",
        handleCodeInApp: true,
      });
    });

    it("still signs in when the verification email cannot be sent", async () => {
      const user = firebaseUser({ emailVerified: false });
      fb.sendEmailVerification.mockRejectedValue(new Error("offline"));
      fb.signInWithEmailAndPassword.mockImplementation(async () => {
        emitAuthState(user);
        return { user };
      });
      const { service } = await started();
      await expect(service.signInWithEmail("ada@example.com", "pw")).resolves.toBeUndefined();
    });

    it("turns Firebase failures into AuthErrors without the auth/ prefix", async () => {
      fb.signInWithEmailAndPassword.mockRejectedValue(new FirebaseError("auth/invalid-credential", "bad"));
      const { service } = await started();
      await expect(service.signInWithEmail("a@b.co", "x")).rejects.toEqual(
        expect.objectContaining({ name: "AuthError", code: "invalid-credential" }),
      );
    });

    it("lets other errors through untouched", async () => {
      const boom = new Error("boom");
      fb.signInWithEmailAndPassword.mockRejectedValue(boom);
      const { service } = await started();
      await expect(service.signInWithEmail("a@b.co", "x")).rejects.toBe(boom);
    });
  });

  describe("registerWithEmail", () => {
    it("needs a name", async () => {
      const { service } = await started();
      await expect(
        service.registerWithEmail({ displayName: "  ", email: "a@b.co", password: "pw" }),
      ).rejects.toEqual(expect.objectContaining({ code: "display-name-required" }));
      expect(fb.createUserWithEmailAndPassword).not.toHaveBeenCalled();
    });

    it("does not leak a failed attempt's name into the next account", async () => {
      fb.createUserWithEmailAndPassword.mockRejectedValueOnce(new FirebaseError("auth/email-already-in-use", "x"));
      const { service } = await started();
      await expect(
        service.registerWithEmail({ displayName: "Wrong Name", email: "a@b.co", password: "pw" }),
      ).rejects.toBeInstanceOf(AuthError);
      emitAuthState(firebaseUser({ email: "grace@example.com" }));
      await settle();
      expect(tx.set).toHaveBeenCalledWith(
        { path: "publicUser/abcdef123" },
        expect.objectContaining({ displayName: "grace@example.com" }),
      );
    });
  });

  describe("other calls", () => {
    it("redirects to Google, asking which account", async () => {
      const { service } = await started();
      await service.signInWithGoogle();
      expect(fb.setCustomParameters).toHaveBeenCalledWith({ prompt: "select_account" });
      expect(fb.signInWithRedirect).toHaveBeenCalledWith(auth, expect.anything());
    });

    it("sends a password reset, but not without an email", async () => {
      const { service } = await started();
      await service.sendPasswordReset("ada@example.com");
      expect(fb.sendPasswordResetEmail).toHaveBeenCalledWith(auth, "ada@example.com");
      await expect(service.sendPasswordReset("  ")).rejects.toEqual(
        expect.objectContaining({ code: "email-missing-pw" }),
      );
    });

    it("sends the verification email to the current user", async () => {
      const user = firebaseUser({ emailVerified: false });
      (auth as { currentUser: User | null }).currentUser = user;
      const { service } = await started();
      await service.sendEmailVerification();
      expect(fb.sendEmailVerification).toHaveBeenCalledWith(user, expect.objectContaining({ handleCodeInApp: true }));
    });

    it("signs out, forgets the returning visitor, and reloads", async () => {
      storage.setItem(KEY, "true");
      const { service } = await started();
      await service.signOut();
      expect(fb.signOut).toHaveBeenCalledWith(auth);
      expect(storage.getItem(KEY)).toBe("false");
      expect(reload).toHaveBeenCalledTimes(1);
    });
  });
});
