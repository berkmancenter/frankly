import { FirebaseError } from "firebase/app";
import { describe, expect, it } from "vitest";
import { classifyBackendFailure, describeBackendFailure, isConfigFailure } from "@/api/backendFailure";

const firebase = (code: string, message = "") => new FirebaseError(code, message);

describe("classifyBackendFailure", () => {
  it.each([
    "auth/invalid-api-key",
    "auth/configuration-not-found",
    "auth/operation-not-allowed",
    "auth/app-not-authorized",
  ])("calls %s a configuration problem", (code) => {
    expect(classifyBackendFailure(firebase(code))?.kind).toBe("config");
  });

  it("recognizes a rejected API key from the message", () => {
    expect(
      classifyBackendFailure(firebase("auth/internal-error", "API key not valid. Please pass a valid API key."))?.kind,
    ).toBe("config");
  });

  it("recognizes a wrong project from the message, whatever the code", () => {
    expect(
      classifyBackendFailure(
        firebase("permission-denied", "Cloud Firestore API has not been used in project nope before or it is disabled."),
      )?.kind,
    ).toBe("config");
    expect(
      classifyBackendFailure(firebase("not-found", "The database (default) does not exist for project nope"))?.kind,
    ).toBe("config");
  });

  it.each(["auth/network-request-failed", "unavailable", "functions/unavailable", "deadline-exceeded", "auth/timeout"])(
    "calls %s a network problem",
    (code) => {
      expect(classifyBackendFailure(firebase(code))?.kind).toBe("network");
    },
  );

  it("recognizes a fetch that never connected", () => {
    expect(classifyBackendFailure(new TypeError("Failed to fetch"))?.kind).toBe("network");
    expect(classifyBackendFailure(new Error("Failed to get document because the client is offline."))?.kind).toBe(
      "network",
    );
  });

  it("calls an internal error from the service a service problem", () => {
    expect(classifyBackendFailure(firebase("auth/internal-error"))?.kind).toBe("service");
  });

  it("strips the prefix from the code it reports", () => {
    expect(classifyBackendFailure(firebase("auth/network-request-failed", "boom"))).toEqual({
      kind: "network",
      code: "network-request-failed",
      message: "boom",
    });
  });

  it("leaves ordinary failures alone", () => {
    expect(classifyBackendFailure(firebase("permission-denied", "Missing or insufficient permissions."))).toBeNull();
    expect(classifyBackendFailure(firebase("auth/wrong-password"))).toBeNull();
    expect(classifyBackendFailure(new Error("unauthenticated"))).toBeNull();
    expect(classifyBackendFailure(undefined)).toBeNull();
  });
});

describe("describeBackendFailure", () => {
  it("falls back to an unknown failure that keeps the message", () => {
    expect(describeBackendFailure(new Error("unauthenticated"))).toEqual({
      kind: "unknown",
      code: "unknown",
      message: "unauthenticated",
    });
  });

  it("copes with something that is not an error", () => {
    expect(describeBackendFailure("nope")).toMatchObject({ kind: "unknown", message: "nope" });
    expect(describeBackendFailure(null)).toMatchObject({ kind: "unknown", message: "" });
  });
});

describe("isConfigFailure", () => {
  it("is true only for a misconfigured backend", () => {
    expect(isConfigFailure(firebase("auth/invalid-api-key"))).toBe(true);
    expect(isConfigFailure(firebase("unavailable"))).toBe(false);
    expect(isConfigFailure(new Error("x"))).toBe(false);
  });
});
