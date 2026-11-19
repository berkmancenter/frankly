/**
 * Design tokens: plain, typed constants. Import them where a style needs a value:
 *
 *   sx={{ color: colors.onSurfaceVariant, fontSize: fontSizes.sm }}
 *
 * Only `primary` and `secondary` change per community; see `communityColors` in `theme.ts`.
 * Use the MUI palette paths (`'primary.main'`, `'secondary.main'`) for those two so a nested
 * community theme can override them.
 */
export const colors = {
  primary: "#313030",
  onPrimary: "#ffffff",
  primaryContainer: "#403f3f",
  onPrimaryContainer: "#d7d3d3",
  primaryFixedDim: "#c8c6c5",
  secondary: "#615e56",
  onSecondary: "#ffffff",
  secondaryContainer: "#e9e4da",
  onSecondaryContainer: "#4b4942",
  error: "#a0000b",
  onError: "#ffffff",
  errorContainer: "#ffedea",
  onErrorContainer: "#313030",
  surface: "#faf8f8",
  onSurface: "#1c1b1b",
  onSurfaceVariant: "#444748",
  surfaceContainerLowest: "#ffffff",
  surfaceContainer: "#f1edec",
  surfaceContainerHigh: "#ebe7e6",
  surfaceContainerHighest: "#e5e2e1",
  inverseSurface: "#313030",
  onInverseSurface: "#f4f0ef",
  outline: "#747878",
  outlineVariant: "#c4c7c7",
  transparent: "transparent",
} as const;

export type ColorName = keyof typeof colors;

/** Font sizes in px. Pick the one that matches the design; there are no type "roles". */
export const fontSizes = {
  xs: 12,
  sm: 14,
  md: 16,
  lg: 18,
  xl: 22,
  "2xl": 24,
  "3xl": 28,
  "4xl": 32,
} as const;

/** Port of the Flutter app's `AppSize`. */
export const appSize = {
  maxCarouselSize: 524,
  navBarHeight: 84,
  bottomNavBarHeight: 75,
  sidebarWidth: 376,
  pageContentMaxWidthDesktop: 1100,
  /** Below this width the app uses its mobile layout + bottom nav. */
  mobileBreakpoint: 1000,
} as const;
