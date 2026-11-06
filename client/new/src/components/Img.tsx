import BrokenImageIcon from '@mui/icons-material/BrokenImage';
import Box from '@mui/material/Box';
import type { SxProps, Theme } from '@mui/material/styles';
import { useState } from 'react';

interface ImgProps {
  src?: string | null;
  alt?: string;
  width?: number | string;
  height?: number | string;
  radius?: number | string;
  fit?: 'cover' | 'contain' | 'fill';
  sx?: SxProps<Theme>;
}

/** `ProxiedImage`: cover-fit image on an `onPrimaryContainer` placeholder that shows an icon on error. */
export function Img({ src, alt = '', width, height, radius, fit = 'cover', sx }: ImgProps) {
  const [failed, setFailed] = useState(false);
  const showImage = !!src && !failed;
  return (
    <Box
      sx={[
        {
          width,
          height,
          borderRadius: radius,
          bgcolor: 'm3.onPrimaryContainer',
          overflow: 'hidden',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          flexShrink: 0,
          color: 'm3.onSurfaceVariant',
        },
        ...(Array.isArray(sx) ? sx : [sx]),
      ]}
    >
      {showImage ? (
        <img
          src={src}
          alt={alt}
          onError={() => setFailed(true)}
          style={{ width: '100%', height: '100%', objectFit: fit, display: 'block' }}
        />
      ) : (
        !src ? null : <BrokenImageIcon sx={{ fontSize: 30 }} />
      )}
    </Box>
  );
}
