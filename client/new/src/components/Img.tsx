import BrokenImageIcon from '@mui/icons-material/BrokenImage';
import Box from '@mui/material/Box';
import type { SxProps, Theme } from '@mui/material/styles';
import { useState } from 'react';
import { colors } from "@/theme/tokens";

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
  // Remember *which* URL failed, so a new `src` gets a fresh attempt.
  const [failedSrc, setFailedSrc] = useState<string | null>(null);
  const showImage = !!src && failedSrc !== src;
  return (
    <Box
      sx={[
        {
          width,
          height,
          borderRadius: radius,
          bgcolor: colors.onPrimaryContainer,
          overflow: 'hidden',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          flexShrink: 0,
          color: colors.onSurfaceVariant,
        },
        ...(Array.isArray(sx) ? sx : [sx]),
      ]}
    >
      {showImage ? (
        <img
          src={src}
          alt={alt}
          onError={() => setFailedSrc(src)}
          style={{ width: '100%', height: '100%', objectFit: fit, display: 'block' }}
        />
      ) : (
        !src ? null : <BrokenImageIcon sx={{ fontSize: 30 }} />
      )}
    </Box>
  );
}
