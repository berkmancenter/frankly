import Box from '@mui/material/Box';
import ButtonBase from '@mui/material/ButtonBase';
import Typography from '@mui/material/Typography';
import { t } from '@lingui/core/macro';
import { useState } from 'react';
import { ProfileDrawer } from '@/features/profile/ProfileDrawer';
import { useCurrentUserId, useUser } from '@/queries/me';
import { Avatar } from './Avatar';

interface ProfileChipProps {
  userId: string | undefined;
  size?: number;
  showName?: boolean;
  /** Replace the name with "You" for the signed-in user. */
  showIsYou?: boolean;
  enableOnTap?: boolean;
  nameWeight?: number;
  nameColor?: string;
  /** Append "(you)" to the signed-in user's name (suggestion cards). */
  youSuffix?: boolean;
}

/** `ProfileChip`: circular avatar (2px ring) + name; tapping opens the profile drawer. */
export function ProfileChip({
  userId,
  size = 42,
  showName = true,
  showIsYou = false,
  enableOnTap = true,
  nameWeight = 400,
  nameColor,
  youSuffix = false,
}: ProfileChipProps) {
  const { data: user } = useUser(userId);
  const meId = useCurrentUserId();
  const [open, setOpen] = useState(false);

  const isMe = !!userId && userId === meId;
  const name =
    showIsYou && isMe
      ? t({ id: 'profileChip.you', message: 'You' })
      : (user?.displayName ?? t({ id: 'profileChip.anonymous', message: 'Anonymous' }));

  const content = (
    <Box sx={{ display: 'inline-flex', alignItems: 'center', minWidth: 0 }}>
      <Avatar name={user?.displayName} imageUrl={user?.imageUrl} size={size} />
      {showName && (
        <Typography
          sx={{
            px: '8px',
            fontWeight: nameWeight,
            color: nameColor,
            display: '-webkit-box',
            WebkitLineClamp: 2,
            WebkitBoxOrient: 'vertical',
            overflow: 'hidden',
          }}
        >
          {name}
          {youSuffix && isMe ? t({ id: 'profileChip.youSuffix', message: ' (you)' }) : ''}
        </Typography>
      )}
    </Box>
  );

  if (!enableOnTap) return content;
  return (
    <>
      <ButtonBase
        onClick={() => setOpen(true)}
        aria-label={showName ? undefined : t({ id: 'profileChip.ariaLabel', message: `Profile of ${name}` })}
        sx={{ borderRadius: `${size / 2}px`, textAlign: 'left', maxWidth: '100%' }}
      >
        {content}
      </ButtonBase>
      {open && userId && <ProfileDrawer userId={userId} onClose={() => setOpen(false)} />}
    </>
  );
}
