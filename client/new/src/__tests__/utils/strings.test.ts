import { describe, expect, it } from "vitest";
import { humanizeKey, isBlank } from "@/utils/strings";

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

describe("humanizeKey", () => {
  it("spaces and capitalizes camelCase keys", () => {
    expect(humanizeKey("allowUnofficialTemplates")).toBe("Allow Unofficial Templates");
    expect(humanizeKey("chat")).toBe("Chat");
  });

  it("writes A V as A/V", () => {
    expect(humanizeKey("enableAVCheck")).toBe("Enable A/V Check");
  });
});
