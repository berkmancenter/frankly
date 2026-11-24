import { FirebaseError, getApp, type FirebaseApp } from "firebase/app";
import {
  connectFunctionsEmulator,
  getFunctions,
  httpsCallable,
  type Functions,
  type HttpsCallableOptions,
} from "firebase/functions";
import { getAuth, type Auth } from "firebase/auth";
import { isDev } from "@/utils/dev";

export interface CloudFunctionsOptions {
  region?: string;
  /** Where the plain HTTP functions live (no trailing slash), for `post`. */
  httpBaseUrl?: string;
  sameOrigin?: boolean;
  emulator?: {
    host: string;
    port: number;
  };
}

const emulatorConnections = new WeakSet<Functions>();
// These callable names have same-origin hosting rewrites in firebase.json.
const sameOriginCallables = new Set([
  "GetCommunityDonationsEnabled",
  "GetMembersData",
  "CreateLiveStream",
  "GetCommunityPrePostEnabled",
  "sendEventMessage",
  "getCommunityCalendarLink",
  "GetUserAdminDetails",
  "createCommunity",
  "createEvent",
  "sendAnnouncement",
  "updateMembership",
  "UpdateCommunity",
  "resolveJoinRequest",
]);

class CallableRequestError extends Error {
  constructor(
    readonly code: string,
    message: string,
  ) {
    super(message);
    this.name = "CallableRequestError";
  }
}

/** Calls deployed Firebase functions, or an explicitly configured emulator. */
export class CloudFunctions {
  private functions?: Functions;

  constructor(
    private readonly options: CloudFunctionsOptions = {},
    private readonly app?: FirebaseApp,
    private readonly auth?: Auth,
  ) {}

  private getClient(): Functions {
    if (this.functions) return this.functions;

    // Resolve the app lazily so this module can be imported before Firebase setup.
    const functions = getFunctions(this.app ?? getApp(), this.options.region);
    const { emulator } = this.options;

    if (emulator && !emulatorConnections.has(functions)) {
      connectFunctionsEmulator(functions, emulator.host, emulator.port);
      emulatorConnections.add(functions);
    }

    this.functions = functions;
    return functions;
  }

  async call<Request = unknown, Response = unknown>(
    name: string,
    data: Request,
    options?: HttpsCallableOptions,
  ): Promise<Response> {
    for (let attempt = 0; ; attempt += 1) {
      try {
        if (this.shouldUseSameOrigin(name)) {
          return await this.callSameOrigin<Request, Response>(name, data);
        }

        const callable = httpsCallable<Request, Response>(
          this.getClient(),
          name,
          options,
        );
        const result = await callable(data);
        if (isDev) console.log(`Callable result for ${name}:`, result.data);
        return result.data;
      } catch (error) {
        if (attempt >= 2 || !this.isRetryable(error)) throw error;
        await new Promise((resolve) => setTimeout(resolve, 300 * 2 ** attempt));
      }
    }
  }

  /**
   * Calls a plain HTTP function (not a callable) with the signed-in user's token, and returns its
   * JSON body. Rejects on any status but 200.
   */
  async post<Response = unknown>(name: string, body: unknown): Promise<Response> {
    const auth = this.auth ?? getAuth(this.app ?? getApp());
    const idToken = await auth.currentUser?.getIdToken();
    if (!idToken) throw new Error("Not authenticated");
    const response = await fetch(`${this.options.httpBaseUrl ?? ""}/${name}`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${idToken}`,
      },
      body: JSON.stringify(body),
    });
    if (response.status !== 200) {
      throw new Error(`Function ${name} failed with status ${response.status}`);
    }
    return (await response.json()) as Response;
  }

  private shouldUseSameOrigin(name: string): boolean {
    if (
      !this.options.sameOrigin ||
      this.options.emulator ||
      !sameOriginCallables.has(name) ||
      typeof window === "undefined"
    ) {
      return false;
    }

    return !["localhost", "127.0.0.1", "::1"].includes(
      window.location.hostname,
    );
  }

  private async callSameOrigin<Request, Response>(
    name: string,
    data: Request,
  ): Promise<Response> {
    const auth = this.auth ?? getAuth(this.app ?? getApp());
    const idToken = await auth.currentUser?.getIdToken();
    const response = await fetch(`${window.location.origin}/api/${name}`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        ...(idToken ? { Authorization: `Bearer ${idToken}` } : {}),
      },
      body: JSON.stringify({ data }),
    });
    const body: unknown = await response.json();
    const envelope = this.asRecord(body);
    const error = this.asRecord(envelope.error);

    if (!response.ok || envelope.error) {
      throw new CallableRequestError(
        this.stringValue(error.status) ?? "internal",
        this.stringValue(error.message) ?? `Function ${name} failed`,
      );
    }
    if (!Object.prototype.hasOwnProperty.call(envelope, "result")) {
      throw new Error(`Function ${name} returned an invalid callable response`);
    }
    return envelope.result as Response;
  }

  private asRecord(value: unknown): Record<string, unknown> {
    if (typeof value !== "object" || value === null || Array.isArray(value)) {
      return {};
    }
    return value as Record<string, unknown>;
  }

  private stringValue(value: unknown): string | undefined {
    return typeof value === "string" ? value : undefined;
  }

  private isRetryable(error: unknown): boolean {
    if (error instanceof FirebaseError) {
      return error.code.endsWith("/unavailable");
    }
    if (error instanceof CallableRequestError) {
      return error.code.toLowerCase() === "unavailable";
    }
    const message = error instanceof Error ? error.message.toLowerCase() : "";
    return (
      message.includes("failed to fetch") ||
      message.includes("networkerror") ||
      message.includes("network error") ||
      message.includes("hostname could not be found")
    );
  }
}

export const cloudFunctions = new CloudFunctions();
