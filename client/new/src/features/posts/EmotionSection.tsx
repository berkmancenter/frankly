import Box from '@mui/material/Box';
import ButtonBase from '@mui/material/ButtonBase';
import Popover from '@mui/material/Popover';
import Typography from '@mui/material/Typography';
import { useState } from 'react';
import type { EmotionType, EmotionVote } from '@/api/types';
import { colors } from "@/theme/tokens";

export const EMOTIONS: { id: EmotionType; src: string; label: string }[] = [
  { id: 'thumbsUp', src: 'emoji-thumbs-up.png', label: 'Thumbs up' },
  { id: 'heart', src: 'emoji-heart.png', label: 'Heart' },
  { id: 'hundred', src: 'emoji-hundred.png', label: '100' },
  { id: 'exclamation', src: 'emoji-exclamation.png', label: 'Exclamation' },
  { id: 'plusOne', src: 'emoji-plus-one.png', label: 'Plus one' },
  { id: 'laughWithTears', src: 'emoji-laugh-tears.png', label: 'Laughing' },
  { id: 'heartEyes', src: 'emoji-heart-eyes.png', label: 'Heart eyes' },
];

const asset = (id: EmotionType) => EMOTIONS.find((e) => e.id === id)!.src;

/**
 * Reactions on a post or comment: a "smiley +" button that opens a pill of seven emoji, and —
 * once there are reactions — a strip of the distinct emoji used plus the total count.
 */
export function EmotionSection({
  emotions,
  myUserId,
  onSelect,
}: {
  emotions: EmotionVote[];
  myUserId: string | undefined;
  onSelect: (emotion: EmotionType | null) => void;
}) {
  const [anchor, setAnchor] = useState<HTMLElement | null>(null);
  const mine = emotions.find((e) => e.userId === myUserId)?.emotion ?? null;
  const distinct = [...new Set(emotions.map((e) => e.emotion))];

  return (
    <Box sx={{ display: 'flex', alignItems: 'center', gap: '2px' }}>
      {distinct.length > 0 && (
        <Box sx={{ display: 'flex', alignItems: 'center', maxWidth: 100, height: 36, py: '4px', px: '2px', overflow: 'hidden' }}>
          {distinct.map((id) => (
            <img key={id} src={`/media/${asset(id)}`} alt="" width={20} height={20} />
          ))}
        </Box>
      )}
      <ButtonBase aria-label="Add reaction" onClick={(e) => setAnchor(e.currentTarget)} sx={{ borderRadius: '50%', p: '2px' }}>
        <img src="/media/smiley-with-plus.png" alt="" width={20} height={20} />
      </ButtonBase>
      {emotions.length > 0 && (
        <Typography sx={{ ml: '10px', color: colors.onPrimaryContainer }}>
          {emotions.length}
        </Typography>
      )}
      <Popover
        open={!!anchor}
        anchorEl={anchor}
        onClose={() => setAnchor(null)}
        anchorOrigin={{ vertical: 'top', horizontal: 'center' }}
        transformOrigin={{ vertical: 'bottom', horizontal: 'center' }}
        slotProps={{ paper: { sx: { borderRadius: '45px', pl: '12px', pr: '4px', py: '2px', display: 'flex', boxShadow: 2 } } }}
      >
        {EMOTIONS.map((e) => (
          <ButtonBase
            key={e.id}
            aria-label={e.label}
            aria-pressed={mine === e.id}
            onClick={() => {
              onSelect(mine === e.id ? null : e.id);
              setAnchor(null);
            }}
            sx={{ p: '8px', borderRadius: '10px', bgcolor: mine === e.id ? colors.surface : 'transparent' }}
          >
            <img src={`/media/${e.src}`} alt="" width={20} height={20} />
          </ButtonBase>
        ))}
      </Popover>
    </Box>
  );
}
