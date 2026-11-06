import type { CSSProperties } from 'react';
import type { M3Scheme } from './m3';

declare module '@mui/material/styles' {
  interface Palette {
    /** Full Material 3 color role set. Resolvable in `sx` as e.g. `'m3.onSurfaceVariant'`. */
    m3: M3Scheme;
  }
  interface PaletteOptions {
    m3?: M3Scheme;
  }

  interface TypographyVariants {
    displayLarge: CSSProperties;
    displayMedium: CSSProperties;
    displaySmall: CSSProperties;
    headlineLarge: CSSProperties;
    headlineMedium: CSSProperties;
    headlineSmall: CSSProperties;
    titleLarge: CSSProperties;
    titleMedium: CSSProperties;
    titleSmall: CSSProperties;
    labelLarge: CSSProperties;
    labelMedium: CSSProperties;
    labelSmall: CSSProperties;
    bodyLarge: CSSProperties;
    bodyMedium: CSSProperties;
    bodySmall: CSSProperties;
  }
  interface TypographyVariantsOptions {
    displayLarge?: CSSProperties;
    displayMedium?: CSSProperties;
    displaySmall?: CSSProperties;
    headlineLarge?: CSSProperties;
    headlineMedium?: CSSProperties;
    headlineSmall?: CSSProperties;
    titleLarge?: CSSProperties;
    titleMedium?: CSSProperties;
    titleSmall?: CSSProperties;
    labelLarge?: CSSProperties;
    labelMedium?: CSSProperties;
    labelSmall?: CSSProperties;
    bodyLarge?: CSSProperties;
    bodyMedium?: CSSProperties;
    bodySmall?: CSSProperties;
  }
}

declare module '@mui/material/Typography' {
  interface TypographyPropsVariantOverrides {
    displayLarge: true;
    displayMedium: true;
    displaySmall: true;
    headlineLarge: true;
    headlineMedium: true;
    headlineSmall: true;
    titleLarge: true;
    titleMedium: true;
    titleSmall: true;
    labelLarge: true;
    labelMedium: true;
    labelSmall: true;
    bodyLarge: true;
    bodyMedium: true;
    bodySmall: true;
  }
}
