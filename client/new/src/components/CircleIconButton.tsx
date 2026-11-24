import ButtonBase from '@mui/material/ButtonBase';
import Tooltip from '@mui/material/Tooltip';
import type { ReactNode } from 'react';

interface CircleIconButtonProps {
  icon: ReactNode;
  tooltip: string;
  onClick?: (e: React.MouseEvent<HTMLElement>) => void;
  /** Background; defaults to primary. */
  color?: string;
  iconColor?: string;
  size?: number;
  href?: string;
}

/** `CircleIconButton`: a 44px filled circle (10px padding + 24px icon) with a tooltip. */
export function CircleIconButton({
  icon,
  tooltip,
  onClick,
  color = 'primary.main',
  iconColor = 'primary.contrastText',
  size = 44,
  href,
}: CircleIconButtonProps) {
  return (
    <Tooltip title={tooltip}>
      <ButtonBase
        onClick={onClick}
        {...(href ? { href } : {})}
        aria-label={tooltip}
        sx={{
          width: size,
          height: size,
          borderRadius: '50%',
          bgcolor: color,
          color: iconColor,
          flexShrink: 0,
          '& svg': { fontSize: 24 },
          '&:hover': { opacity: 0.88 },
        }}
      >
        {icon}
      </ButtonBase>
    </Tooltip>
  );
}
