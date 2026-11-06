import AttachFileRoundedIcon from '@mui/icons-material/AttachFileRounded';
import Box from '@mui/material/Box';
import ButtonBase from '@mui/material/ButtonBase';
import Dialog from '@mui/material/Dialog';
import Divider from '@mui/material/Divider';
import IconButton from '@mui/material/IconButton';
import Typography from '@mui/material/Typography';
import { useRef, useState } from 'react';
import type { DiscussionThread } from '@/api/types';
import { ActionButton } from '@/components/ActionButton';
import { Avatar } from '@/components/Avatar';
import { useToast } from '@/components/Toast';
import { isBlank } from '@/lib/strings';
import { useIsMobile } from '@/lib/useResponsive';
import { useCreateThread, useUpdateThread } from '@/queries/threads';
import { useCurrentUser } from '@/queries/me';
import { useCommunityScope } from '@/scopes/CommunityScope';
import { EMOTIONS } from './EmotionSection';

const EMOJI_CHARS = ['👍', '❤️', '💯', '❗', '➕', '😂', '😍'];

/** Create / edit post: avatar + ✕, a growing text area, an image attachment, emoji shortcuts and "Post". */
export function CreatePostDialog({ thread, onClose }: { thread?: DiscussionThread; onClose: () => void }) {
  const { community } = useCommunityScope();
  const me = useCurrentUser();
  const isMobile = useIsMobile();
  const toast = useToast();
  const create = useCreateThread(community.id);
  const update = useUpdateThread(community.id);
  const [text, setText] = useState(thread?.content ?? '');
  const [imageUrl, setImageUrl] = useState<string | undefined>(thread?.imageUrl);
  const fileRef = useRef<HTMLInputElement>(null);
  const editing = !!thread;

  const pickImage = (file: File | undefined) => {
    if (!file) return;
    const reader = new FileReader();
    reader.onload = () => setImageUrl(String(reader.result));
    reader.readAsDataURL(file);
  };

  const submit = async () => {
    try {
      if (thread) await update.mutateAsync({ threadId: thread.id, patch: { content: text.trim(), imageUrl } });
      else await create.mutateAsync({ content: text.trim(), imageUrl });
      toast.success(editing ? 'Post has been updated' : 'Post has been created');
      onClose();
    } catch {
      toast.error('Something went wrong. Please try again.');
    }
  };

  return (
    <Dialog
      open
      onClose={onClose}
      fullScreen={isMobile}
      slotProps={{ paper: { sx: { width: '100%', maxWidth: 640, borderRadius: isMobile ? 0 : '10px', bgcolor: 'm3.surfaceContainerLowest', m: isMobile ? 0 : 2 } } }}
    >
      <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', px: '20px', pt: '20px' }}>
        <Avatar name={me?.displayName} imageUrl={me?.imageUrl} size={42} />
        <IconButton aria-label="Close" onClick={onClose}>
          <img src="/media/x.png" alt="" width={30} height={30} />
        </IconButton>
      </Box>
      <Box sx={{ pt: '20px', overflowY: 'auto', flex: 1 }}>
        {imageUrl && (
          <Box sx={{ mb: '20px', position: 'relative' }}>
            <img src={imageUrl} alt="Attached" style={{ width: '100%', maxHeight: 400, objectFit: 'cover', display: 'block' }} />
            <ButtonBase
              aria-label="Remove image"
              onClick={() => setImageUrl(undefined)}
              sx={{ position: 'absolute', top: 8, right: 8, bgcolor: 'rgba(0,0,0,.5)', borderRadius: '50%', p: '6px' }}
            >
              <img src="/media/x.png" alt="" width={18} height={18} style={{ filter: 'invert(1)' }} />
            </ButtonBase>
          </Box>
        )}
        <Box
          component="textarea"
          autoFocus
          aria-label="Post text"
          placeholder="Type something"
          value={text}
          rows={4}
          onChange={(e: React.ChangeEvent<HTMLTextAreaElement>) => setText(e.target.value)}
          sx={{
            display: 'block',
            width: 'calc(100% - 32px)',
            mx: '16px',
            border: 0,
            outline: 0,
            resize: 'none',
            minHeight: 96,
            maxHeight: 240,
            fontFamily: 'inherit',
            fontSize: 16,
            lineHeight: 1.5,
            color: 'm3.onSurface',
            bgcolor: 'transparent',
          }}
        />
        <Box sx={{ px: '16px', pt: '10px', pb: '10px' }}>
          <ButtonBase onClick={() => fileRef.current?.click()} sx={{ gap: '10px', borderRadius: 1, color: 'primary.main' }}>
            <AttachFileRoundedIcon />
            <Typography variant="bodyMedium" sx={{ color: 'primary.main' }}>
              Image
            </Typography>
          </ButtonBase>
          <input
            ref={fileRef}
            type="file"
            accept="image/*"
            hidden
            aria-label="Attach image"
            onChange={(e) => pickImage(e.target.files?.[0])}
          />
        </Box>
      </Box>
      <Divider />
      <Box sx={{ px: '20px', py: '10px', display: 'flex', alignItems: 'center', gap: '10px' }}>
        <Box sx={{ flex: 1, display: 'flex', overflowX: 'auto', height: 40, alignItems: 'center' }}>
          {EMOTIONS.map((e, i) => (
            <ButtonBase
              key={e.id}
              aria-label={`Insert ${e.label}`}
              onClick={() => setText((t) => `${t}${EMOJI_CHARS[i]}`)}
              sx={{ p: '6px', borderRadius: '8px', flexShrink: 0 }}
            >
              <img src={`/media/${e.src}`} alt="" width={24} height={24} />
            </ButtonBase>
          ))}
        </Box>
        <ActionButton text={editing ? 'Update' : 'Post'} disabled={isBlank(text)} onPress={submit} />
      </Box>
    </Dialog>
  );
}
