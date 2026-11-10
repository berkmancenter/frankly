import CloseIcon from "@mui/icons-material/Close";
import Dialog from "@mui/material/Dialog";
import IconButton from "@mui/material/IconButton";
import type { ReactNode } from "react";
import { useIsMobile } from "@/utils/useResponsive";
import { colors } from "@/theme/tokens";

interface AppDialogProps {
  open: boolean;
  onClose: () => void;
  children: ReactNode;
  maxWidth?: number;
  /** On mobile the dialog takes the whole screen (no radius, no outer gutter). */
  fullscreenOnMobile?: boolean;
  /** Inner padding in px. */
  padding?: number;
  /** Hide the close button (e.g. while a request is in flight). */
  hideClose?: boolean;
  /** Paper background token (default: white). */
  background?: string;
  closeLabel?: string;
  ariaLabel?: string;
}

/**
 * `CreateDialogUiMigration`: the shell used by most forms — radius-20 white card, 30px gutter
 * to the viewport, close button 20px in from the top-right corner, scrolls when tall.
 */
export function AppDialog({
  open,
  onClose,
  children,
  maxWidth = 700,
  fullscreenOnMobile = false,
  padding = 50,
  hideClose,
  background = colors.surfaceContainerLowest,
  closeLabel = "Close",
  ariaLabel,
}: AppDialogProps) {
  const isMobile = useIsMobile();
  const full = fullscreenOnMobile && isMobile;
  return (
    <Dialog
      open={open}
      onClose={onClose}
      fullScreen={full}
      maxWidth={false}
      slotProps={{
        paper: {
          "aria-label": ariaLabel,
          sx: {
            width: "100%",
            maxWidth: full ? "none" : maxWidth,
            m: full ? 0 : "30px",
            maxHeight: full ? "100%" : "calc(100% - 60px)",
            borderRadius: full ? 0 : "20px",
            bgcolor: background,
            p: `${padding}px`,
            position: "relative",
          },
        },
        backdrop: { sx: { bgcolor: "rgba(0,0,0,0.54)" } },
      }}
    >
      {!hideClose && (
        <IconButton
          aria-label={closeLabel}
          onClick={onClose}
          sx={{
            position: "absolute",
            top: 12,
            right: 12,

            zIndex: 1,
            color: colors.onSurface,
          }}
        >
          <CloseIcon />
        </IconButton>
      )}
      {children}
    </Dialog>
  );
}
