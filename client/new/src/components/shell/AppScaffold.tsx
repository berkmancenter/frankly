import Box from "@mui/material/Box";
import Drawer from "@mui/material/Drawer";
import { ThemeProvider, useTheme, type Theme } from "@mui/material/styles";
import { createContext, useContext, useState, type ReactNode } from "react";
import { createPortal } from "react-dom";
import ButtonBase from "@mui/material/ButtonBase";
import AddIcon from "@mui/icons-material/Add";
import Typography from "@mui/material/Typography";
import { useIsMobile } from "@/utils/useResponsive";
import { appSize, appText } from "@/theme/typography";
import { NavBar } from "./NavBar";
import { SideBar } from "./SideBar";

const FabHostContext = createContext<HTMLElement | null>(null);

interface AppScaffoldProps {
  children: ReactNode;
  /** Page background (community pages use the community's light color). */
  bgColor?: string;
  /** Theme for the content area only; the nav bar and drawer keep the app theme. */
  childTheme?: Theme;
  bottomNav?: ReactNode;
}

/**
 * Port of `CustomScaffold`: nav bar + content + optional bottom nav + end drawer + floating
 * action button slot. Owns two bits of purely local UI state: sidebar open and the FAB host element.
 */
export function AppScaffold({
  children,
  bgColor,
  childTheme,
  bottomNav,
}: AppScaffoldProps) {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [fabHost, setFabHost] = useState<HTMLElement | null>(null);
  const parentTheme = useTheme();
  const isMobile = useIsMobile();

  const content = (
    <>
      {children}
      <Box
        ref={setFabHost}
        sx={{
          position: "fixed",
          right: "10px",
          bottom: isMobile ? appSize.bottomNavBarHeight : "10px",
          zIndex: 1050,
        }}
      />
    </>
  );

  return (
    <FabHostContext.Provider value={fabHost}>
      <Box
        sx={{
          height: "100dvh",
          display: "flex",
          flexDirection: "column",
          bgcolor: bgColor ?? "background.default",
        }}
      >
        <Box sx={{ flex: 1, minHeight: 0, overflowY: "auto" }}>
          <NavBar onMenuClick={() => setSidebarOpen(true)} />
          <ThemeProvider theme={childTheme ?? parentTheme}>
            {content}
          </ThemeProvider>
        </Box>
        {bottomNav}
      </Box>
      <Drawer
        anchor="right"
        open={sidebarOpen}
        onClose={() => setSidebarOpen(false)}
        slotProps={{
          paper: { sx: { width: appSize.sidebarWidth, maxWidth: "100vw" } },
          backdrop: { sx: { bgcolor: "rgba(0,0,0,0.54)" } },
        }}
      >
        <SideBar onClose={() => setSidebarOpen(false)} />
      </Drawer>
    </FabHostContext.Provider>
  );
}

/**
 * A page-declared floating action button: rendered into the scaffold's fixed slot via a portal,
 * so it follows the *content* theme (community colors) while living at the screen corner.
 * Mobile shows just the icon, like `CommunityPageFloatingActionButton`.
 */
export function ScaffoldFab({
  text,
  onClick,
}: {
  text: string;
  onClick: () => void;
}) {
  const host = useContext(FabHostContext);
  const isMobile = useIsMobile();
  if (!host) return null;
  return createPortal(
    <ButtonBase
      onClick={onClick}
      aria-label={text}
      sx={{
        height: 87,
        minWidth: 87,
        borderRadius: "45px",
        bgcolor: "primary.main",
        color: "primary.contrastText",
        px: "23px",
        py: "10px",
        boxShadow: "0 3px 8px rgba(0,0,0,.3)",
        gap: "20px",
      }}
    >
      <AddIcon sx={{ fontSize: 41 }} />
      {!isMobile && (
        <Typography sx={{ ...appText.subhead, color: "inherit", pr: "3px" }}>
          {text}
        </Typography>
      )}
    </ButtonBase>,
    host,
  );
}
