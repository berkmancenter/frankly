import {
  alpha,
  createTheme,
  type SxProps,
  type Theme,
} from "@mui/material/styles";
import {
  COLOR_KEYWORDS,
  COLOR_PROPS,
  type ThemeColorPath,
} from "./colorPaths";
import { colors, fontSizes } from "./tokens";

export type { ThemeColorPath };

/**
 * A deliberately small MUI theme: the font, the two community-themable colors, and a few
 * component defaults. Everything else is styled where it is used, with `colors` and
 * `fontSizes` from `tokens.ts`. There is no Material 3 type scale and no heading aliasing:
 * pick a size and, where it matters, a semantic element (`<Typography component="h2">`).
 */
export interface ThemeColors {
  primary: string;
  secondary: string;
}

export const defaultThemeColors: ThemeColors = {
  primary: colors.primary,
  secondary: colors.secondary,
};

/** A `colors` token value (hex), a CSS keyword, or an explicit `#hex` / `rgb[a]()` literal. */
type RawColor =
  | (typeof colors)[keyof typeof colors]
  | (typeof COLOR_KEYWORDS)[number]
  | `#${string}`
  | `rgb${"a" | ""}(${string})`;

/** The plain-object form of `sx` (not the array, callback or boolean forms). */
type SxObject = Extract<SxProps<Theme>, object> extends infer S
  ? Exclude<S, readonly unknown[] | ((...args: never[]) => unknown)>
  : never;

type StrictColors = {
  [K in (typeof COLOR_PROPS)[number]]?: ThemeColorPath | RawColor;
};

/**
 * Identity helper that makes `sx` color properties closed: `sx({ color: "primary.mian" })` fails
 * to compile, whereas a bare `sx={{ color: "primary.mian" }}` is just a string to MUI. Intersecting
 * with `StrictColors` narrows those keys; every other `sx` key keeps MUI's own typing. Only
 * top-level keys are checked; nested selectors (`"&:hover"`) are not.
 */
export function sx(
  styles: SxObject & StrictColors,
): SxProps<Theme> {
  return styles;
}

const HEX6 = /^[0-9a-fA-F]{6}$/;

/** Community colors are stored as bare `RRGGBB` strings (no `#`). */
export function parseCommunityColor(
  value: string | null | undefined,
): string | null {
  if (!value) return null;
  const bare = value.replace(/^#/, "");
  return HEX6.test(bare) ? `#${bare.toUpperCase()}` : null;
}

/** Colors for a community page: `dark` is its primary, `light` its secondary (and page background). */
export function communityColors(community: {
  themeDarkColor?: string | null;
  themeLightColor?: string | null;
}): ThemeColors {
  return {
    primary:
      parseCommunityColor(community.themeDarkColor) ??
      defaultThemeColors.primary,
    secondary:
      parseCommunityColor(community.themeLightColor) ?? colors.surface,
  };
}

/** `createAppTheme` is a pure function of the two colors, so a community can nest its own. */
export function createAppTheme({
  primary,
  secondary,
}: ThemeColors = defaultThemeColors): Theme {
  return createTheme({
    palette: {
      primary: { main: primary, contrastText: colors.onPrimary },
      secondary: { main: secondary, contrastText: colors.onSecondary },
      error: { main: colors.error, contrastText: colors.onError },
      background: { default: colors.surface, paper: colors.surfaceContainerLowest },
      text: {
        primary: colors.onSurface,
        secondary: colors.onSurfaceVariant,
        disabled: alpha(colors.onSurface, 0.38),
      },
      divider: colors.outlineVariant,
    },
    shape: { borderRadius: 12 },
    typography: {
      fontFamily:
        '"Inter Variable", Inter, system-ui, -apple-system, "Segoe UI", Roboto, sans-serif',
      // `<Typography>` with no variant is body1; the app's default text is 14px.
      body1: { fontSize: fontSizes.sm, lineHeight: 1.5 },
      body2: { fontSize: fontSizes.xs, lineHeight: 1.5 },
      button: { fontSize: fontSizes.sm, fontWeight: 500, textTransform: "none" },
    },
    components: {
      MuiCssBaseline: {
        styleOverrides: {
          body: {
            fontSize: fontSizes.sm,
            lineHeight: 1.5,
            backgroundColor: colors.surface,
            color: colors.onSurface,
          },
          "img, video": { maxWidth: "100%" },
        },
      },
      MuiButton: {
        defaultProps: { disableElevation: true },
        styleOverrides: { root: { borderRadius: 20, minHeight: 40 } },
      },
      MuiPaper: {
        defaultProps: { elevation: 0 },
        styleOverrides: { root: { backgroundImage: "none" } },
      },
      MuiDialog: {
        styleOverrides: {
          paper: { borderRadius: 20, backgroundColor: colors.surface },
        },
      },
      MuiTextField: { defaultProps: { variant: "outlined" } },
      MuiTooltip: {
        styleOverrides: {
          tooltip: {
            fontSize: fontSizes.xs,
            backgroundColor: colors.inverseSurface,
            color: colors.onInverseSurface,
          },
        },
      },
    },
  });
}

export const appTheme = createAppTheme();
