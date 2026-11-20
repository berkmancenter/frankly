import { describe, expect, it } from "vitest";
import {
  PRESET_COLOR_THEMES,
  contrastRatio,
  isAccentDarkEnough,
  isBackgroundLightEnough,
  isColorComboValid,
  isColorValid,
  luminance,
} from "@/utils/communityTheme";

describe("community theme colors", () => {
  it("accepts only six hex digits", () => {
    expect(isColorValid("0aF9c1")).toBe(true);
    for (const bad of ["", "fff", "12345g", "1234567", undefined, null]) {
      expect(isColorValid(bad)).toBe(false);
    }
  });

  it("measures luminance and contrast like WCAG", () => {
    expect(luminance("FFFFFF")).toBeCloseTo(1);
    expect(luminance("000000")).toBeCloseTo(0);
    expect(contrastRatio("FFFFFF", "000000")).toBeCloseTo(21);
    expect(contrastRatio("000000", "FFFFFF")).toBeCloseTo(21);
  });

  it("wants a dark enough accent and a light enough background", () => {
    expect(isAccentDarkEnough("203EA0")).toBe(true);
    expect(isAccentDarkEnough("FFFF00")).toBe(false);
    expect(isBackgroundLightEnough("DEF8FF")).toBe(true);
    expect(isBackgroundLightEnough("333333")).toBe(false);
  });

  it("needs a lighter background than accent, with contrast", () => {
    expect(isColorComboValid("DEF8FF", "203EA0")).toBe(true);
    expect(isColorComboValid("203EA0", "DEF8FF")).toBe(false);
    expect(isColorComboValid("DEF8FF", "DEF8FE")).toBe(false);
    expect(isColorComboValid("DEF8FF", "nope")).toBe(false);
    expect(isColorComboValid(undefined, "203EA0")).toBe(false);
  });

  it("offers presets that are all valid combinations", () => {
    for (const { light, dark } of PRESET_COLOR_THEMES) {
      expect(isColorValid(light) && isColorValid(dark)).toBe(true);
    }
    // The app's own colors plus nine more.
    expect(PRESET_COLOR_THEMES).toHaveLength(10);
  });
});
