import Box from '@mui/material/Box';
import { useState } from 'react';
import type { DiscussionThread } from '@/api/types';
import { ConstrainedBody } from '@/components/ConstrainedBody';
import { EmptyPageContent } from '@/components/EmptyPageContent';
import { ScaffoldFab } from '@/components/shell/AppScaffold';
import { ErrorState, LoadingState } from '@/components/States';
import { useIsMobile } from '@/lib/useResponsive';
import { useThreads } from '@/queries/threads';
import { useCommunityScope } from '@/scopes/CommunityScope';
import { AddCommentDialog } from './AddCommentDialog';
import { CreatePostDialog } from './CreatePostDialog';
import { PostPreviewCard } from './PostCards';

/** `/space/:displayId/posts`: a two-column masonry of posts (one column on mobile). */
export function PostsPage() {
  const { community } = useCommunityScope();
  const isMobile = useIsMobile();
  const threads = useThreads(community.id);
  const [createOpen, setCreateOpen] = useState(false);
  const [replyTo, setReplyTo] = useState<DiscussionThread | null>(null);

  const list = threads.data ?? [];
  return (
    <Box component="main">
      {threads.isPending ? (
        <LoadingState height={300} />
      ) : threads.isError ? (
        <ErrorState message="Something went wrong loading posts." />
      ) : list.length === 0 ? (
        <Box sx={{ pt: '30px', display: 'flex', justifyContent: 'center' }}>
          <EmptyPageContent type="posts" showContainer={false} onButtonPress={() => setCreateOpen(true)} />
        </Box>
      ) : isMobile ? (
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: '20px', py: '10px' }}>
          {list.map((t) => (
            <PostPreviewCard key={t.id} thread={t} onReply={setReplyTo} />
          ))}
        </Box>
      ) : (
        <ConstrainedBody>
          <Box sx={{ py: '30px', columnCount: 2, columnGap: '40px' }}>
            {list.map((t) => (
              <PostPreviewCard key={t.id} thread={t} onReply={setReplyTo} />
            ))}
          </Box>
        </ConstrainedBody>
      )}
      <Box sx={{ height: 100 }} />
      <ScaffoldFab text="Create post" onClick={() => setCreateOpen(true)} />
      {createOpen && <CreatePostDialog onClose={() => setCreateOpen(false)} />}
      {replyTo && <AddCommentDialog thread={replyTo} onClose={() => setReplyTo(null)} />}
    </Box>
  );
}
