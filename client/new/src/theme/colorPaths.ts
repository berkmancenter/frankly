/**
 * The closed set of `sx` color values, kept free of imports so tooling (the ESLint config) can
 * read it at runtime. `theme.ts` derives its types from these lists and the lint rule derives
 * its pattern from them, so adding a palette path here updates both.
 */

/** Every palette path as `sx` resolves it (`color: "primary.main"`). */
export const THEME_COLOR_PATHS = [
  "primary.main",
  "primary.contrastText",
  "secondary.main",
  "secondary.contrastText",
  "error.main",
  "error.contrastText",
  "background.default",
  "background.paper",
  "text.primary",
  "text.secondary",
  "text.disabled",
  "action.active",
  "action.hover",
  "action.selected",
  "action.disabled",
  "action.disabledBackground",
  "action.focus",
  "divider",
] as const;

export type ThemeColorPath = (typeof THEME_COLOR_PATHS)[number];

/** CSS color keywords that are fine to write inline. */
export const COLOR_KEYWORDS = ["inherit", "transparent", "currentColor"] as const;

/** The `sx` properties whose values are restricted to theme colors. */
export const COLOR_PROPS = [
  "color",
  "bgcolor",
  "backgroundColor",
  "borderColor",
] as const;
