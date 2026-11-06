import CircularProgress from '@mui/material/CircularProgress';
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import type { ReactNode } from 'react';

/** Centered spinner; `height` reserves space so pages don't jump when data arrives. */
export function LoadingState({ height = 300, message }: { height?: number | string; message?: string }) {
  return (
    <Box
      sx={{
        height,
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        gap: 2,
      }}
    >
      <CircularProgress color="primary" />
      {message && <Typography variant="bodyMedium">{message}</Typography>}
    </Box>
  );
}

export function ErrorState({
  message = 'Something went wrong. Please refresh.',
  action,
  height = 200,
}: {
  message?: string;
  action?: ReactNode;
  height?: number | string;
}) {
  return (
    <Box
      role="alert"
      sx={{
        minHeight: height,
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        gap: 2,
        textAlign: 'center',
        p: 2,
      }}
    >
      <Typography variant="bodyLarge" sx={{ color: 'm3.onSurfaceVariant' }}>
        {message}
      </Typography>
      {action}
    </Box>
  );
}
