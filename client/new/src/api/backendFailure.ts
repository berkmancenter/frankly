/**
 * Failures to reach, or to use, the backend at all, as opposed to the backend answering "no":
 * a project or API key that does not exist, a network that is down, a service that is returning
 * errors. They are told apart from ordinary failures (permission denied, document missing) by
 * the Firebase error `code` and message, read structurally so this file does not depend on Firebase.
 */
export type BackendFailureKind =
  /** The app's Firebase settings are wrong (project, API key, a disabled API). */
  | "config"
  /** The request never got an answer: offline, DNS, the emulators not running, a timeout. */
  | "network"
  /** The backend answered with an internal error. */
  | "service"
  /** Something else stopped the app from loading; not known to be the backend's fault. */
  | "unknown";

export interface BackendFailure {
  kind: BackendFailureKind;
  /** Firebase error code without its `auth/`, `functions/` prefix, or `unknown`. */
  code: string;
  /** The technical message, for the details line. */
  message: string;
}

const CONFIG_CODES = new Set([
  "api-key-not-valid",
  "invalid-api-key",
  "configuration-not-found",
  "project-not-found",
  "app-not-authorized",
  "invalid-app-id",
  "operation-not-allowed",
  "admin-restricted-operation",
  "unauthorized-domain",
]);

const NETWORK_CODES = new Set([
  "network-request-failed",
  "timeout",
  "unavailable",
  "deadline-exceeded",
]);

/** Code reported when a failure carries none. */
const UNKNOWN = "unknown";

const SERVICE_CODES = new Set(["internal-error", "service-unavailable"]);

/** Messages that mean "wrong project" even when the code is a generic `permission-denied` or `not-found`. */
const CONFIG_MESSAGE =
  /api key not valid|has not been used in project|project[_ -]?not[_ -]?found|database .* does not exist|api has not been enabled|is disabled/i;

const NETWORK_MESSAGE = /failed to fetch|networkerror|load failed|network request failed|client is offline/i;

function codeOf(error: unknown): string {
  const raw = (error as { code?: unknown } | null)?.code;
  if (typeof raw !== "string") return "";
  return raw.toLowerCase().replace(/^(auth|functions|firestore)\//, "").replaceAll("_", "-");
}

function messageOf(error: unknown): string {
  if (error instanceof Error) return error.message;
  return typeof error === "string" ? error : "";
}

/** The failure if `error` means the backend is misconfigured, unreachable or erroring; otherwise `null`. */
export function classifyBackendFailure(error: unknown): BackendFailure | null {
  const code = codeOf(error);
  const message = messageOf(error);
  const failure = (kind: BackendFailureKind): BackendFailure => ({
    kind,
    code: code || UNKNOWN,
    message,
  });
  if (CONFIG_CODES.has(code) || CONFIG_MESSAGE.test(message)) {
    return failure("config");
  }
  if (NETWORK_CODES.has(code) || NETWORK_MESSAGE.test(message)) {
    return failure("network");
  }
  if (SERVICE_CODES.has(code)) return failure("service");
  return null;
}

/** Like `classifyBackendFailure`, but any error becomes a failure (`unknown` when it is not a known kind). */
export function describeBackendFailure(error: unknown): BackendFailure {
  return (
    classifyBackendFailure(error) ?? {
      kind: "unknown",
      code: codeOf(error) || UNKNOWN,
      message: messageOf(error),
    }
  );
}

/** Retrying cannot fix a misconfigured backend, so queries skip their retry for it. */
export const isConfigFailure = (error: unknown): boolean =>
  classifyBackendFailure(error)?.kind === "config";
