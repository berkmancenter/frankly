/**
 * Material 3 type scale from `client/lib/styles/text_theme.dart` (Inter).
 * Each entry is fontSize / lineHeight / weight / letterSpacing.
 */
// A `type` alias (not an interface) so it is assignable to MUI's index-signature typography types.
export type TypeStyle = {
  fontSize: string;
  lineHeight: string;
  fontWeight: number;
  letterSpacing: string;
};

const role = (
  fontSize: number,
  lineHeight: number,
  fontWeight: number,
  letterSpacing: number,
): TypeStyle => ({
  fontSize: `${fontSize}px`,
  lineHeight: `${lineHeight}px`,
  fontWeight,
  letterSpacing: `${letterSpacing}px`,
});

export const m3Type = {
  displayLarge: role(57, 64, 400, -0.25),
  displayMedium: role(45, 52, 400, 0),
  displaySmall: role(36, 44, 400, 0),
  headlineLarge: role(32, 40, 400, 0),
  headlineMedium: role(28, 36, 400, 0),
  headlineSmall: role(24, 32, 400, 0),
  titleLarge: role(22, 28, 400, 0),
  titleMedium: role(16, 24, 500, 0.15),
  titleSmall: role(14, 20, 500, 0.1),
  labelLarge: role(14, 20, 500, 0.1),
  labelMedium: role(12, 16, 500, 0.5),
  labelSmall: role(11, 16, 500, 0.5),
  bodyLarge: role(16, 24, 400, 0.5),
  bodyMedium: role(14, 20, 400, 0.25),
  bodySmall: role(12, 16, 400, 0.4),
} as const;

/**
 * The Flutter app's hand-rolled `AppTextStyle` (Inter, heavier weights, tighter leading).
 * It is used for section headings, eyebrows and card copy throughout the app.
 */
const app = (fontSize: number, fontWeight: number, lineHeight: number) => ({
  fontSize: `${fontSize}px`,
  fontWeight,
  lineHeight,
});

export const appText = {
  headline1: app(40, 700, 1.1),
  headline2: app(30, 700, 1.1),
  headline2Light: app(34, 300, 1.1),
  headline3: app(24, 700, 1.1),
  headline4: app(18, 700, 1.2),
  headlineSmall: app(12, 700, 1.2),
  subhead: app(18, 500, 1.5),
  eyebrow: app(16, 400, 1.5),
  eyebrowSmall: app(14, 400, 1.5),
  body: app(16, 400, 1.5),
  bodyMedium: app(16, 600, 1.5),
  bodySmall: app(14, 400, 1),
} as const;

/** `AppSize` from app_styles.dart. */
export const appSize = {
  maxCarouselSize: 524,
  navBarHeight: 84,
  bottomNavBarHeight: 75,
  sidebarWidth: 376,
  pageContentMaxWidthDesktop: 1100,
  /** `ResponsiveLayoutService` — below this width the app uses its mobile layout + bottom nav. */
  mobileBreakpoint: 1000,
} as const;
