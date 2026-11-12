import { describe, expect, it } from "vitest";
import { defaultDisplayName, firstAndLastInitial, uidToInt } from "@/utils/users";

describe("firstAndLastInitial", () => {
  it("keeps the first name and abbreviates the last", () => {
    expect(firstAndLastInitial("Ada Lovelace")).toBe("Ada L");
    expect(firstAndLastInitial("Ada Augusta King Lovelace")).toBe("Ada L");
  });

  it("leaves a single word alone", () => {
    expect(firstAndLastInitial("Ada")).toBe("Ada");
  });

  it("is null for nothing", () => {
    expect(firstAndLastInitial(null)).toBeNull();
    expect(firstAndLastInitial(undefined)).toBeNull();
    expect(firstAndLastInitial("")).toBeNull();
  });
});

describe("uidToInt", () => {
  // Reference values computed with the Dart implementation in data_models/lib/utils/utils.dart.
  it("matches the Dart hash", () => {
    expect(uidToInt("")).toBe(0);
    expect(uidToInt("a")).toBe(97);
    expect(uidToInt("ab")).toBe(97 * 257 + 98);
  });

  it("stays within 30 bits for long uids", () => {
    const value = uidToInt("x".repeat(200));
    expect(value).toBeGreaterThanOrEqual(0);
    expect(value).toBeLessThan(1 << 30);
  });
});

describe("defaultDisplayName", () => {
  const uid = "abcdef123";

  it("prefers the name typed at sign-up, then the profile name, then the email", () => {
    expect(defaultDisplayName({ uid, registrationName: "Ada Lovelace", profileName: "Other Name", email: "x@y.z" })).toBe("Ada L");
    expect(defaultDisplayName({ uid, profileName: "Grace Hopper", email: "x@y.z" })).toBe("Grace H");
    expect(defaultDisplayName({ uid, email: "grace@example.com" })).toBe("grace@example.com");
  });

  it("falls back to the start of the uid", () => {
    expect(defaultDisplayName({ uid })).toBe("User-abcd");
  });
});
