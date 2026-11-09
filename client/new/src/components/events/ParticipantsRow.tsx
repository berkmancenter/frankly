import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import type { Event } from '@/api/types';
import { Avatar } from '@/components/Avatar';
import { useEventParticipants } from '@/queries/events';
import { useCurrentUserId } from '@/queries/me';
import { colors } from "@/theme/tokens";

interface ParticipantsRowProps {
  event: Pick<Event, 'id' | 'creatorId'>;
  /** Avatar diameter. */
  iconSize?: number;
  /** Max avatars drawn. */
  maxAvatars?: number;
}

/**
 * Overlapping avatar stack + count. The signed-in user and the event creator are drawn on top;
 * the text reads "You", "You + N", "+N", "N People" or the single participant's name.
 */
export function ParticipantsRow({ event, iconSize = 30, maxAvatars = 6 }: ParticipantsRowProps) {
  const { data } = useEventParticipants(event.id);
  const meId = useCurrentUserId();
  if (!data || data.length === 0) return null;

  const total = data.length;
  const isParticipant = data.some((p) => p.user.id === meId);

  // Important people last == painted on top.
  const rank = (id: string) => (id === meId ? 2 : id === event.creatorId ? 1 : 0);
  const shown = [...data].sort((a, b) => rank(a.user.id) - rank(b.user.id)).slice(-maxAvatars);
  const overlap = Math.round(iconSize * 0.48);

  const text = isParticipant
    ? total > 1
      ? `You + ${total - 1}`
      : 'You'
    : total > shown.length
      ? `+${total - shown.length}`
      : total > 1
        ? `${total} People`
        : (data[0]?.user.displayName ?? '1 person');

  return (
    <Box sx={{ display: 'flex', alignItems: 'center', minHeight: iconSize, minWidth: 0 }}>
      <Box sx={{ display: 'flex', alignItems: 'center', pl: `${overlap}px`, flexShrink: 0 }}>
        {shown.map((p) => (
          <Box key={p.user.id} sx={{ ml: `-${overlap}px`, display: 'flex' }}>
            <Avatar name={p.user.displayName} imageUrl={p.user.imageUrl} size={iconSize} />
          </Box>
        ))}
      </Box>
      <Typography noWrap sx={{ ml: '5px', color: colors.onSurface, minWidth: 0 }}>
        {text}
      </Typography>
    </Box>
  );
}
