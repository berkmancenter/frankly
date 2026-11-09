import Box from '@mui/material/Box';
import IconButton from '@mui/material/IconButton';
import type { ReactNode } from 'react';
import { colors } from "@/theme/tokens";

/** Nav icon with a 24x2 `primary` indicator under it while selected. */
export function SelectableNavigationIcon({
  icon,
  selected,
  onClick,
  label,
}: {
  icon: ReactNode;
  selected: boolean;
  onClick?: () => void;
  label: string;
}) {
  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
      <IconButton
        aria-label={label}
        onClick={onClick}
        sx={{ color: selected ? colors.onSurface : colors.onSurfaceVariant }}
      >
        {icon}
      </IconButton>
      {selected && <Box sx={{ height: 2, width: 24, bgcolor: 'primary.main' }} />}
    </Box>
  );
}
