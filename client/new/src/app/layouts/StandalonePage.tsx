import type { ReactNode } from "react";
import { AppScaffold } from "@/components/layout/AppScaffold";
import { HomeBottomNavBar } from "@/components/layout/BottomNavBar";
import { useShowBottomNav } from "@/utils/useResponsive";

/** Scaffold for pages outside a community (not found, and later home, settings, new space): home bottom bar on mobile. */
export function StandalonePage({ children }: { children: ReactNode }) {
  const showBottomNav = useShowBottomNav();
  return (
    <AppScaffold bottomNav={showBottomNav ? <HomeBottomNavBar /> : undefined}>
      {children}
    </AppScaffold>
  );
}
