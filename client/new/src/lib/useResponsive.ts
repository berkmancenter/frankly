import useMediaQuery from '@mui/material/useMediaQuery';
import { appSize } from '@/theme/typography';

/**
 * `ResponsiveLayoutService`: the Flutter app has a single breakpoint at 1000px. Below it the
 * layout is "mobile" and a bottom nav bar replaces the top-nav links.
 */
export function useIsMobile(): boolean {
  return useMediaQuery(`(max-width:${appSize.mobileBreakpoint - 0.02}px)`, { noSsr: true });
}

/** Same threshold today, kept separate because the Flutter service exposes both. */
export function useShowBottomNav(): boolean {
  return useIsMobile();
}
