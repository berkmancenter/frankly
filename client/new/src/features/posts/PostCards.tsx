import Box from '@mui/material/Box';
import ButtonBase from '@mui/material/ButtonBase';
import Typography from '@mui/material/Typography';
import { useNavigate } from 'react-router';
import type { DiscussionThread } from '@/api/types';
import { paths } from '@/app/paths';
import { Avatar } from '@/components/Avatar';
import { ProfileChip } from '@/components/ProfileChip';
import { compactNumber, pluralize } from '@/lib/format';
import { useIsMobile } from '@/lib/useResponsive';
import { useSetThreadEmotion, useThreadComments, useVoteThread } from '@/queries/threads';
import { useCurrentUser, useCurrentUserId } from '@/queries/me';
import { useCommunityScope } from '@/scopes/CommunityScope';
import { appText } from '@/theme/typography';
import { EmotionSection } from './EmotionSection';

/** Like / dislike cluster: compact count, thumbs-up, thumbs-down. */
export function VoteCluster({ thread, gap = '10px' }: { thread: DiscussionThread; gap?: string }) {
  const { community } = useCommunityScope();
  const me = useCurrentUserId();
  const vote = useVoteThread(community.id, me);
  const liked = !!me && thread.likedBy.includes(me);
  const disliked = !!me && thread.dislikedBy.includes(me);
  const count = thread.likedBy.length - thread.dislikedBy.length;
  return (
    <Box sx={{ display: 'flex', alignItems: 'center' }}>
      <Typography variant="bodyMedium" sx={{ color: 'm3.onSurfaceVariant', mr: gap }}>
        {compactNumber(count)}
      </Typography>
      <ButtonBase
        aria-label="Like"
        aria-pressed={liked}
        onClick={(e) => {
          e.stopPropagation();
          vote.mutate({ threadId: thread.id, vote: liked ? 'neutral' : 'like' });
        }}
        sx={{ borderRadius: 1 }}
      >
        <img src={`/media/${liked ? 'like-selected' : 'like'}.png`} alt="" width={20} height={20} />
      </ButtonBase>
      <ButtonBase
        aria-label="Dislike"
        aria-pressed={disliked}
        onClick={(e) => {
          e.stopPropagation();
          vote.mutate({ threadId: thread.id, vote: disliked ? 'neutral' : 'dislike' });
        }}
        sx={{ borderRadius: 1, ml: '5px' }}
      >
        <img src={`/media/${disliked ? 'dislike-selected' : 'dislike'}.png`} alt="" width={20} height={20} />
      </ButtonBase>
    </Box>
  );
}

/** A post in the list: author + votes, picture, body, comment count + reactions, latest comment, reply box. */
export function PostPreviewCard({ thread, onReply }: { thread: DiscussionThread; onReply: (thread: DiscussionThread) => void }) {
  const { community } = useCommunityScope();
  const isMobile = useIsMobile();
  const navigate = useNavigate();
  const me = useCurrentUser();
  const comments = useThreadComments(thread.id);
  const emotion = useSetThreadEmotion(community.id, me?.id);
  const latest = comments.data?.find((c) => !c.deleted);
  const open = () => navigate(paths.community(community.displayId).post(thread.id));

  return (
    <Box
      component="article"
      onClick={open}
      sx={{
        bgcolor: 'm3.surfaceContainerLowest',
        cursor: 'pointer',
        breakInside: 'avoid',
        mb: isMobile ? 0 : '40px',
        display: 'flex',
        flexDirection: 'column',
        gap: '20px',
        pb: '20px',
        '&:hover': { boxShadow: '0 2px 8px rgba(0,0,0,0.12)' },
      }}
    >
      <Box sx={{ px: '20px', pt: '20px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }} onClick={(e) => e.stopPropagation()}>
        <ProfileChip userId={thread.creatorId} nameColor="inherit" nameWeight={600} />
        <VoteCluster thread={thread} />
      </Box>
      {thread.imageUrl && (
        <img src={thread.imageUrl} alt="" style={{ width: '100%', height: isMobile ? 300 : 'auto', objectFit: 'cover', display: 'block' }} />
      )}
      <Typography
        sx={{
          ...appText.body,
          color: 'm3.onSurfaceVariant',
          px: '20px',
          display: '-webkit-box',
          WebkitLineClamp: 5,
          WebkitBoxOrient: 'vertical',
          overflow: 'hidden',
          whiteSpace: 'pre-wrap',
        }}
      >
        {thread.content}
      </Typography>
      <Box sx={{ px: '20px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <Typography variant="bodyMedium" sx={{ color: 'm3.onSurfaceVariant' }}>
          {thread.commentCount === 0 ? 'No Comments' : pluralize(thread.commentCount, 'Comment')}
        </Typography>
        <Box onClick={(e) => e.stopPropagation()}>
          <EmotionSection
            emotions={thread.emotions}
            myUserId={me?.id}
            onSelect={(e) => emotion.mutate({ threadId: thread.id, emotion: e })}
          />
        </Box>
      </Box>
      {latest && (
        <Box sx={{ px: '20px' }}>
          <Box sx={{ borderLeft: '1px solid', borderColor: 'm3.outline', pl: '10px' }}>
            <Typography
              sx={{ ...appText.body, display: '-webkit-box', WebkitLineClamp: 3, WebkitBoxOrient: 'vertical', overflow: 'hidden' }}
            >
              {latest.comment}
            </Typography>
            <Typography variant="bodyMedium" sx={{ textDecoration: 'underline', mt: '4px' }}>
              See more
            </Typography>
          </Box>
        </Box>
      )}
      <Box sx={{ px: '20px' }} onClick={(e) => e.stopPropagation()}>
        <ButtonBase
          onClick={() => onReply(thread)}
          sx={{
            width: '100%',
            justifyContent: 'flex-start',
            gap: '10px',
            p: '10px',
            borderRadius: '10px',
            border: '1px solid',
            borderColor: 'm3.outline',
          }}
        >
          <Avatar name={me?.displayName} imageUrl={me?.imageUrl} size={42} />
          <Typography variant="bodyMedium" sx={{ color: 'm3.onSurfaceVariant' }}>
            Reply
          </Typography>
        </ButtonBase>
      </Box>
    </Box>
  );
}
