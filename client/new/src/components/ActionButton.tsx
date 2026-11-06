import Button from '@mui/material/Button';
import CircularProgress from '@mui/material/CircularProgress';
import Tooltip from '@mui/material/Tooltip';
import type { SxProps, Theme } from '@mui/material/styles';
import { useEffect, useRef, useState, type MouseEvent, type ReactNode } from 'react';

export type ActionButtonType = 'filled' | 'outline' | 'text';

export interface ActionButtonProps {
  type?: ActionButtonType;
  text?: string;
  children?: ReactNode;
  /** Leading icon (any node). */
  icon?: ReactNode;
  /** Fill color (filled) or border color (outline). Any CSS color or palette path. */
  color?: string;
  textColor?: string;
  /** May return a promise: while it is pending the button shows a spinner and ignores clicks. */
  onPress?: (event: MouseEvent<HTMLElement>) => unknown;
  disabled?: boolean;
  /** Fill the available width. */
  expand?: boolean;
  height?: number;
  minWidth?: number;
  radius?: number;
  maxTextWidth?: number;
  maxLines?: number;
  contentAlign?: 'start' | 'center' | 'end';
  tooltip?: string;
  /** Label for tests / assistive tech when the content is not text. */
  ariaLabel?: string;
  hideLoadingIndicator?: boolean;
  sx?: SxProps<Theme>;
  borderColor?: string;
}

/**
 * Port of Flutter's `ActionButton`: three looks (filled / outline / text), 10px radius,
 * 96x50 minimum, and — the part that matters — an async-aware `onPress`: return a promise
 * and the button shows a spinner and swallows double clicks until it settles.
 */
export function ActionButton({
  type = 'filled',
  text,
  children,
  icon,
  color,
  textColor,
  onPress,
  disabled,
  expand,
  height = 50,
  minWidth = 96,
  radius = 10,
  maxTextWidth,
  maxLines,
  contentAlign = 'center',
  tooltip,
  ariaLabel,
  hideLoadingIndicator,
  sx,
  borderColor,
}: ActionButtonProps) {
  const [waiting, setWaiting] = useState(false);
  const mounted = useRef(true);
  useEffect(() => {
    mounted.current = true;
    return () => {
      mounted.current = false;
    };
  }, []);

  const handleClick = async (event: MouseEvent<HTMLElement>) => {
    if (waiting || !onPress) return;
    setWaiting(true);
    try {
      // Errors are the caller's to handle (toast / dialog); the button only guards re-entry.
      await onPress(event);
    } catch {
      /* swallowed on purpose: see above */
    } finally {
      if (mounted.current) setWaiting(false);
    }
  };

  const variant = type === 'filled' ? 'contained' : type === 'outline' ? 'outlined' : 'text';
  const isDisabled = disabled || (!onPress && !waiting);

  const colorSx =
    type === 'filled'
      ? { bgcolor: color ?? 'primary.main', color: textColor ?? 'primary.contrastText' }
      : type === 'outline'
        ? {
            color: textColor ?? 'primary.main',
            borderColor: borderColor ?? color ?? 'primary.main',
            '&:hover': { borderColor: borderColor ?? color ?? 'primary.main' },
          }
        : { color: textColor ?? 'primary.main' };

  const button = (
    <Button
      variant={variant}
      disabled={isDisabled || waiting}
      onClick={handleClick}
      aria-label={ariaLabel ?? text}
      sx={[
        {
          minHeight: height,
          minWidth,
          borderRadius: `${radius}px`,
          justifyContent:
            contentAlign === 'start' ? 'flex-start' : contentAlign === 'end' ? 'flex-end' : 'center',
          width: expand ? '100%' : undefined,
          textAlign: contentAlign === 'start' ? 'left' : 'center',
          '&.Mui-disabled': waiting ? { opacity: 1 } : undefined,
          ...(colorSx as object),
          ...(waiting && type === 'filled' && !isDisabled
            ? { bgcolor: color ?? 'primary.main', color: textColor ?? 'primary.contrastText' }
            : {}),
        },
        ...(Array.isArray(sx) ? sx : [sx]),
      ]}
    >
      {waiting && !hideLoadingIndicator && (
        <CircularProgress
          size={24}
          color="inherit"
          sx={{ mr: text || children ? '14px' : 0, flexShrink: 0 }}
        />
      )}
      {!waiting && icon && (
        <span style={{ display: 'inline-flex', marginRight: text || children ? 6 : 0 }}>{icon}</span>
      )}
      {text !== undefined ? (
        <span
          style={{
            maxWidth: maxTextWidth,
            display: maxLines ? '-webkit-box' : undefined,
            WebkitLineClamp: maxLines,
            WebkitBoxOrient: 'vertical',
            overflow: maxLines || maxTextWidth ? 'hidden' : undefined,
            textOverflow: 'ellipsis',
          }}
        >
          {text}
        </span>
      ) : (
        children
      )}
    </Button>
  );

  const wrapped = tooltip ? (
    <Tooltip title={tooltip}>
      <span style={{ display: expand ? 'block' : 'inline-flex' }}>{button}</span>
    </Tooltip>
  ) : (
    button
  );
  return expand ? <div style={{ width: '100%' }}>{wrapped}</div> : wrapped;
}
