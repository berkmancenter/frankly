import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import type { Event } from '@/api/types';
import { Avatar } from '@/components/Avatar';
import { useEventParticipants } from '@/queries/events';
import { useCurrentUserId } from '@/queries/me';
import { colors } from "@/theme/tokens";
import { plural } from '@lingui/core/macro';
import { useLingui } from '@lingui/react/macro';

interface ParticipantsRowProps {
  event: Pick<Event, 'id' | 'creatorId'> & Partial<Pick<Event, 'eventType' | 'registrationCount'>>;
  // While the meeting is live only the people in it count.
  presentOnly?: boolean;
  /** Avatar diameter. */
  iconSize?: number;
  /** Max avatars drawn. */
  maxAvatars?: number;
}

/**
 * Overlapping avatar stack + count. The signed-in user and the event creator are drawn on top;
 * the text reads "You", "You + N", "+N", "N People" or the single participant's name.
 */
export function ParticipantsRow({ event, presentOnly = false, iconSize = 30, maxAvatars = 6 }: ParticipantsRowProps) {
  const { t } = useLingui();
  const participants = useEventParticipants(event.id).data;
  const meId = useCurrentUserId();
  // Withdrawn and removed people are not part of the headcount.
  const data = participants?.filter(
    ({ participant }) => participant.status === 'active' && (!presentOnly || participant.isPresent),
  );
  // Hostless and livestream events keep a head count on the event and show stand-in faces.
  const estimated = !!event.eventType && event.eventType !== 'hosted';
  if (estimated) return <EstimatedRow event={event} people={data ?? []} iconSize={iconSize} maxAvatars={maxAvatars} />;
  if (!data || data.length === 0) return null;

  const total = data.length;
  const isParticipant = data.some((p) => p.user.id === meId);

  // Important people last == painted on top.
  const rank = (id: string) => (id === meId ? 2 : id === event.creatorId ? 1 : 0);
  const shown = [...data].sort((a, b) => rank(a.user.id) - rank(b.user.id)).slice(-maxAvatars);
  const overlap = Math.round(iconSize * 0.48);

  const text = isParticipant
    ? total > 1
      ? t`You + ${total - 1}`
      : t`You`
    : total > shown.length
      ? t`+${total - shown.length}`
      : total > 1
        ? t`${total} People`
        : (data[0]?.user.displayName ?? t`1 person`);

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

function EstimatedRow({
  event,
  people,
  iconSize,
  maxAvatars,
}: {
  event: NonNullable<ParticipantsRowProps['event']>;
  people: NonNullable<ReturnType<typeof useEventParticipants>['data']>;
  iconSize: number;
  maxAvatars: number;
}) {
  const meId = useCurrentUserId();
  const registered = event.registrationCount ?? 0;
  if (registered <= 0) return null;
  // Me and the host are real faces; the rest of the row is filled with stand-ins.
  const real = [
    ...people.filter((p) => p.user.id === meId),
    ...people.filter((p) => p.user.id === event.creatorId && p.user.id !== meId),
  ];
  const standIns = Math.max(maxAvatars - real.length, 0);
  const overlap = Math.round(iconSize * 0.48);
  return (
    <Box sx={{ display: 'flex', alignItems: 'center', minHeight: iconSize, minWidth: 0 }}>
      <Box sx={{ display: 'flex', alignItems: 'center', pl: `${overlap}px`, flexShrink: 0 }}>
        {Array.from({ length: standIns }, (_, i) => (
          <Box key={`stand-in-${i}`} sx={{ ml: `-${overlap}px`, display: 'flex' }}>
            <Avatar size={iconSize} />
          </Box>
        ))}
        {real.map((p) => (
          <Box key={p.user.id} sx={{ ml: `-${overlap}px`, display: 'flex' }}>
            <Avatar name={p.user.displayName} imageUrl={p.user.imageUrl} size={iconSize} />
          </Box>
        ))}
      </Box>
      <Typography noWrap sx={{ ml: '5px', color: colors.onSurface, minWidth: 0 }}>
        {plural(registered, { one: '# Registration', other: '# Registrations' })}
      </Typography>
    </Box>
  );
}
