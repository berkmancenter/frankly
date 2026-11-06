import Box, { type BoxProps } from '@mui/material/Box';
import type { ReactNode } from 'react';
import { appSize } from '@/theme/typography';

interface ConstrainedBodyProps extends Omit<BoxProps, 'children'> {
  children: ReactNode;
  /** Max width of the content column (default: the 1100px desktop column). */
  maxWidth?: number;
  /** Horizontal padding in px. The Flutter default is 20 on both sides. */
  paddingLeft?: number;
  paddingRight?: number;
}

/** `ConstrainedBody`: a centered column with 20px side gutters. */
export function ConstrainedBody({
  children,
  maxWidth = appSize.pageContentMaxWidthDesktop,
  paddingLeft = 20,
  paddingRight = 20,
  sx,
  ...rest
}: ConstrainedBodyProps) {
  return (
    <Box
      {...rest}
      sx={[
        { display: 'flex', justifyContent: 'center', pl: `${paddingLeft}px`, pr: `${paddingRight}px` },
        ...(Array.isArray(sx) ? sx : [sx]),
      ]}
    >
      <Box sx={{ width: '100%', maxWidth }}>{children}</Box>
    </Box>
  );
}
