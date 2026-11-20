import { colors } from "@/theme/tokens";

// Community themes are two colors, stored as bare `RRGGBB` strings: a light background and a dark accent.

export interface PresetColorTheme {
  light: string;
  dark: string;
}

/** The first preset is the app's own look. */
export const PRESET_COLOR_THEMES: readonly PresetColorTheme[] = [
  {
    light: colors.surface.slice(1).toUpperCase(),
    dark: colors.primary.slice(1).toUpperCase(),
  },
  { light: "DEF8FF", dark: "203EA0" },
  { light: "E1F4EE", dark: "006442" },
  { light: "76F1A4", dark: "0F200F" },
  { light: "F9EB0F", dark: "000000" },
  { light: "FFA800", dark: "320243" },
  { light: "FF6258", dark: "001D58" },
  { light: "EAF3FD", dark: "900E2D" },
  { light: "FBE5D6", dark: "660D6B" },
  { light: "EFEFEF", dark: "222222" },
];

const HEX6 = /^[0-9a-fA-F]{6}$/;

export const isColorValid = (
  color: string | null | undefined,
): color is string => !!color && HEX6.test(color);

// Relative luminance, per https://www.w3.org/TR/2008/REC-WCAG20-20081211/#relativeluminancedef
export function luminance(color: string): number {
  const [r, g, b] = [0, 2, 4].map((at) => {
    const channel = parseInt(color.slice(at, at + 2), 16) / 255;
    return channel <= 0.03928
      ? channel / 12.92
      : ((channel + 0.055) / 1.055) ** 2.4;
  }) as [number, number, number];
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

export function contrastRatio(first: string, second: string): number {
  const a = luminance(first);
  const b = luminance(second);
  return (Math.max(a, b) + 0.05) / (Math.min(a, b) + 0.05);
}

const hasEnoughContrast = (first: string, second: string) =>
  contrastRatio(first, second) > 4.5;

const SURFACE = colors.surface.slice(1);
const PRIMARY = colors.primary.slice(1);

/** The accent has to read against the app's light surface, so text in it stays legible. */
export const isAccentDarkEnough = (dark: string) =>
  hasEnoughContrast(dark, SURFACE);

/** The background has to carry the app's dark text. */
export const isBackgroundLightEnough = (light: string) =>
  hasEnoughContrast(light, PRIMARY);

export function isColorComboValid(
  light: string | null | undefined,
  dark: string | null | undefined,
): boolean {
  if (!isColorValid(light) || !isColorValid(dark)) return false;
  return (
    hasEnoughContrast(light, dark) &&
    luminance(light) > luminance(dark) &&
    isAccentDarkEnough(dark) &&
    isBackgroundLightEnough(light)
  );
}
