import useMediaQuery from "@mui/material/useMediaQuery";
import { appSize } from "@/theme/tokens";

/**
 * `ResponsiveLayoutService`: a single breakpoint at 1000px. Below it, the layout is considered "mobile".
 */
export function useIsMobile(): boolean {
  return useMediaQuery(`(max-width:${appSize.mobileBreakpoint - 0.02}px)`, {
    noSsr: true,
  });
}

/** Same threshold today, kept separate because the Flutter service exposes both. */
// TODO: Consider if the bottom nav should be shown based on other criteria in the future.
export function useShowBottomNav(): boolean {
  return useIsMobile();
}
