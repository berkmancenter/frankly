import CloseIcon from "@mui/icons-material/Close";
import Box from "@mui/material/Box";
import Dialog from "@mui/material/Dialog";
import IconButton from "@mui/material/IconButton";
import Typography from "@mui/material/Typography";
import { t } from "@lingui/core/macro";
import { useCallback, useRef, useState, type ReactNode } from "react";
import { useIsMobile } from "@/utils/useResponsive";
import { ActionButton } from "./ActionButton";
import { fontSizes } from "@/theme/tokens";

export interface ConfirmOptions {
  title?: string;
  mainText?: string;
  subText?: string;
  confirmText?: string;
  /** Only rendered when provided (the Flutter dialog shows just "Yes" otherwise). */
  cancelText?: string;
  /** Color the confirm button as destructive. */
  destructive?: boolean;
  textAlign?: "center" | "left";
}

interface ConfirmDialogViewProps extends ConfirmOptions {
  open: boolean;
  onResolve: (confirmed: boolean) => void | Promise<void>;
  /** The ✕ / backdrop / Escape. Defaults to `onResolve(false)`; pass it to tell "No" from "dismissed". */
  onDismiss?: () => void;
  /** Extra content between the text and the buttons. */
  children?: ReactNode;
}

/**
 * `ConfirmDialog`: radius-20 `surface` card, 40px padding, 600px max, ✕ top-right, centered
 * title (headlineSmall / headlineMedium on mobile), cancel on the left, confirm on the right.
 */
export function ConfirmDialogView({
  open,
  onResolve,
  onDismiss,
  title,
  mainText,
  subText,
  confirmText = t`Yes`,
  cancelText,
  destructive,
  textAlign = "center",
  children,
}: ConfirmDialogViewProps) {
  const isMobile = useIsMobile();
  return (
    <Dialog
      open={open}
      onClose={() => (onDismiss ? onDismiss() : onResolve(false))}
      maxWidth={false}
      slotProps={{
        paper: {
          sx: {
            width: "100%",
            maxWidth: 600,
            m: 2,
            p: "40px",
            borderRadius: "20px",
          },
        },
        backdrop: { sx: { bgcolor: "rgba(0,0,0,0.54)" } },
      }}
    >
      <Box
        sx={{
          display: "flex",
          justifyContent: "flex-end",
          mt: "-16px",
          mr: "-16px",
          mb: "4px",
        }}
      >
        <IconButton
          aria-label={t`Close`}
          size="small"
          onClick={() => (onDismiss ? onDismiss() : onResolve(false))}
        >
          <CloseIcon />
        </IconButton>
      </Box>
      {title && (
        <Typography
          component="h2"
          sx={{ fontSize: isMobile ? fontSizes["3xl"] : fontSizes["2xl"], textAlign, mb: "10px" }}
        >
          {title}
        </Typography>
      )}
      {mainText && (
        <Typography sx={{ fontSize: fontSizes.md, textAlign, mb: "10px" }}>
          {mainText}
        </Typography>
      )}
      {subText && (
        <Typography
          sx={{ textAlign: "center", mb: "10px" }}
        >
          {subText}
        </Typography>
      )}
      {children}
      <Box
        sx={{
          mt: "12px",
          display: "flex",
          justifyContent: cancelText ? "space-between" : "flex-end",
          gap: 2,
        }}
      >
        {cancelText && (
          <ActionButton
            type="text"
            height={55}
            minWidth={100}
            onPress={() => onResolve(false)}
          >
            {cancelText}
          </ActionButton>
        )}
        <ActionButton
          height={55}
          color={destructive ? "error.main" : undefined}
          textColor={destructive ? "error.contrastText" : undefined}
          sx={{ px: "18px" }}
          onPress={() => onResolve(true)}
        >
          {confirmText}
        </ActionButton>
      </Box>
    </Dialog>
  );
}

/**
 * Imperative confirm without a global dialog store. The *caller* owns the dialog's state:
 *
 *   const { confirm, dialog } = useConfirm();
 *   if (await confirm({ title: 'Delete post', ... })) ...
 *   return <>{dialog} ...</>
 *
 * The state lives in (and dies with) the component that asked.
 */
export function useConfirm() {
  const [options, setOptions] = useState<ConfirmOptions | null>(null);
  const resolver = useRef<((confirmed: boolean) => void) | null>(null);

  const confirm = useCallback(
    (opts: ConfirmOptions) =>
      new Promise<boolean>((resolve) => {
        resolver.current?.(false);
        resolver.current = resolve;
        setOptions(opts);
      }),
    [],
  );

  const resolve = useCallback((confirmed: boolean) => {
    resolver.current?.(confirmed);
    resolver.current = null;
    setOptions(null);
  }, []);

  const dialog = options ? (
    <ConfirmDialogView open {...options} onResolve={resolve} />
  ) : null;
  return { confirm, dialog };
}
