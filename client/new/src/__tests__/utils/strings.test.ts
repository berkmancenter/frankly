import { describe, expect, it } from "vitest";
import { isBlank } from "@/utils/strings";

describe("isBlank", () => {
  it("is true for missing and whitespace-only strings", () => {
    expect(isBlank(undefined)).toBe(true);
    expect(isBlank(null)).toBe(true);
    expect(isBlank("")).toBe(true);
    expect(isBlank(" \n\t ")).toBe(true);
  });

  it("is false when there is any visible character", () => {
    expect(isBlank("a")).toBe(false);
    expect(isBlank("  a  ")).toBe(false);
  });
});
