import { describe, expect, it } from "vitest";
import { isEmailValid, isPasswordValid } from "@/features/auth/validation";

describe("isEmailValid", () => {
  it("accepts ordinary addresses", () => {
    expect(isEmailValid("ada@example.com")).toBe(true);
    expect(isEmailValid("ada.lovelace+news@example.org")).toBe(true);
  });

  it("rejects text without an @ or a domain", () => {
    expect(isEmailValid("ada")).toBe(false);
    expect(isEmailValid("ada@")).toBe(false);
    expect(isEmailValid("ada@example")).toBe(false);
    expect(isEmailValid("")).toBe(false);
  });
});

describe("isPasswordValid", () => {
  it("needs 12 characters with a lowercase and an uppercase letter", () => {
    expect(isPasswordValid("Abcdefghijkl")).toBe(true);
    expect(isPasswordValid("Abcdefghijk")).toBe(false);
    expect(isPasswordValid("abcdefghijklm")).toBe(false);
    expect(isPasswordValid("ABCDEFGHIJKLM")).toBe(false);
  });
});
