/**
 * Material 3 color roles, ported 1:1 from `client/lib/styles/material_theme.dart`
 * (`MaterialTheme.lightScheme()`). The Flutter app ships a single light theme, so
 * that is all we carry over.
 *
 * MUI's palette only knows primary/secondary/error/... so the full M3 role set lives
 * under `theme.palette.m3` (see `augment.d.ts`). Because MUI's `sx` resolves color
 * strings against the palette, you can write `sx={{ bgcolor: 'm3.surfaceContainerLowest' }}`.
 */
export interface M3Scheme {
  primary: string;
  surfaceTint: string;
  onPrimary: string;
  primaryContainer: string;
  onPrimaryContainer: string;
  primaryFixed: string;
  onPrimaryFixed: string;
  primaryFixedDim: string;
  onPrimaryFixedVariant: string;
  secondary: string;
  onSecondary: string;
  secondaryContainer: string;
  onSecondaryContainer: string;
  secondaryFixed: string;
  onSecondaryFixed: string;
  secondaryFixedDim: string;
  onSecondaryFixedVariant: string;
  tertiary: string;
  onTertiary: string;
  tertiaryContainer: string;
  onTertiaryContainer: string;
  tertiaryFixed: string;
  onTertiaryFixed: string;
  tertiaryFixedDim: string;
  onTertiaryFixedVariant: string;
  error: string;
  onError: string;
  errorContainer: string;
  onErrorContainer: string;
  surface: string;
  onSurface: string;
  surfaceDim: string;
  surfaceBright: string;
  onSurfaceVariant: string;
  surfaceContainerLowest: string;
  surfaceContainerLow: string;
  surfaceContainer: string;
  surfaceContainerHigh: string;
  surfaceContainerHighest: string;
  inverseSurface: string;
  onInverseSurface: string;
  inversePrimary: string;
  outline: string;
  outlineVariant: string;
  shadow: string;
  scrim: string;
}

export const lightScheme: M3Scheme = {
  primary: '#313030',
  surfaceTint: '#5f5e5e',
  onPrimary: '#ffffff',
  primaryContainer: '#403f3f',
  onPrimaryContainer: '#d7d3d3',
  primaryFixed: '#e5e2e1',
  onPrimaryFixed: '#1c1b1b',
  primaryFixedDim: '#c8c6c5',
  onPrimaryFixedVariant: '#474646',
  secondary: '#615e56',
  onSecondary: '#ffffff',
  secondaryContainer: '#e9e4da',
  onSecondaryContainer: '#4b4942',
  secondaryFixed: '#e7e2d8',
  onSecondaryFixed: '#1d1c16',
  secondaryFixedDim: '#cbc6bc',
  onSecondaryFixedVariant: '#49473f',
  tertiary: '#595f60',
  onTertiary: '#ffffff',
  tertiaryContainer: '#c3c9c9',
  onTertiaryContainer: '#323839',
  tertiaryFixed: '#dee4e3',
  onTertiaryFixed: '#171d1d',
  tertiaryFixedDim: '#c2c8c8',
  onTertiaryFixedVariant: '#424848',
  error: '#a0000b',
  onError: '#ffffff',
  errorContainer: '#ffedea',
  onErrorContainer: '#313030',
  surface: '#faf8f8',
  onSurface: '#1c1b1b',
  surfaceDim: '#ddd9d8',
  surfaceBright: '#fdf8f8',
  onSurfaceVariant: '#444748',
  surfaceContainerLowest: '#ffffff',
  surfaceContainerLow: '#f7f3f2',
  surfaceContainer: '#f1edec',
  surfaceContainerHigh: '#ebe7e6',
  surfaceContainerHighest: '#e5e2e1',
  inverseSurface: '#313030',
  onInverseSurface: '#f4f0ef',
  inversePrimary: '#c8c6c5',
  outline: '#747878',
  outlineVariant: '#c4c7c7',
  shadow: '#000000',
  scrim: '#000000',
};

const HEX6 = /^[0-9a-fA-F]{6}$/;

/** Community colors are stored as bare `RRGGBB` strings (no `#`). */
export function parseCommunityColor(value: string | null | undefined): string | null {
  if (!value) return null;
  const bare = value.replace(/^#/, '');
  return HEX6.test(bare) ? `#${bare.toUpperCase()}` : null;
}

/**
 * Derive the scheme used *inside* a community page. Mirrors `CommunityPageState.build`:
 * only `primary` and `secondary` are swapped; every other role stays at the base value.
 */
export function communityScheme(
  base: M3Scheme,
  colors: { dark?: string | null; light?: string | null } | null,
): M3Scheme {
  if (!colors) return base;
  const dark = parseCommunityColor(colors.dark) ?? base.primary;
  const light = parseCommunityColor(colors.light) ?? base.surface;
  return { ...base, primary: dark, secondary: light };
}

/** Page background for a community page (`lightThemeColor`). */
export function communityBackground(
  base: M3Scheme,
  colors: { light?: string | null } | null,
): string {
  return parseCommunityColor(colors?.light) ?? base.surface;
}
