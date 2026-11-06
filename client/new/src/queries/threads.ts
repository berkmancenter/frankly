import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useApi } from '@/api/ApiProvider';
import type { Vote } from '@/api/api';
import type { DiscussionThread, EmotionType } from '@/api/types';
import { qk } from './keys';

export function useThreads(communityId: string | undefined) {
  const api = useApi();
  return useQuery({
    queryKey: qk.threads(communityId ?? ''),
    queryFn: () => api.threads.list(communityId!),
    enabled: !!communityId,
  });
}

export function useThreadComments(threadId: string) {
  const api = useApi();
  return useQuery({
    queryKey: qk.threadComments(threadId),
    queryFn: () => api.threads.listComments(threadId),
  });
}

export function useCreateThread(communityId: string) {
  const api = useApi();
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (input: { content: string; imageUrl?: string }) =>
      api.threads.create(communityId, input),
    onSuccess: () => qc.invalidateQueries({ queryKey: qk.threads(communityId) }),
  });
}

export function useUpdateThread(communityId: string) {
  const api = useApi();
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ threadId, patch }: { threadId: string; patch: { content?: string; imageUrl?: string } }) =>
      api.threads.update(threadId, patch),
    onSuccess: (thread) => {
      qc.setQueryData(qk.thread(thread.id), thread);
      return qc.invalidateQueries({ queryKey: qk.threads(communityId) });
    },
  });
}

/**
 * Optimistic update of one thread across both caches that hold it (the list and the detail
 * page), with rollback on failure. This is the pattern for cheap, reversible reactions that
 * need no outbox because the user is looking right at the result.
 */
function useOptimisticThread(communityId: string) {
  const qc = useQueryClient();
  return {
    async apply(threadId: string, update: (t: DiscussionThread) => DiscussionThread) {
      await Promise.all([
        qc.cancelQueries({ queryKey: qk.threads(communityId) }),
        qc.cancelQueries({ queryKey: qk.thread(threadId) }),
      ]);
      const previousList = qc.getQueryData<DiscussionThread[]>(qk.threads(communityId));
      const previousOne = qc.getQueryData<DiscussionThread>(qk.thread(threadId));
      qc.setQueryData<DiscussionThread[]>(qk.threads(communityId), (list) =>
        list?.map((t) => (t.id === threadId ? update(t) : t)),
      );
      qc.setQueryData<DiscussionThread>(qk.thread(threadId), (t) => (t ? update(t) : t));
      return { previousList, previousOne };
    },
    rollback(
      threadId: string,
      ctx: { previousList?: DiscussionThread[]; previousOne?: DiscussionThread } | undefined,
    ) {
      if (ctx?.previousList) qc.setQueryData(qk.threads(communityId), ctx.previousList);
      if (ctx?.previousOne) qc.setQueryData(qk.thread(threadId), ctx.previousOne);
    },
    settle(threadId: string) {
      return Promise.all([
        qc.invalidateQueries({ queryKey: qk.threads(communityId) }),
        qc.invalidateQueries({ queryKey: qk.thread(threadId) }),
      ]);
    },
  };
}

export function useVoteThread(communityId: string, userId: string | undefined) {
  const api = useApi();
  const opt = useOptimisticThread(communityId);
  return useMutation({
    mutationFn: ({ threadId, vote }: { threadId: string; vote: Vote }) =>
      api.threads.vote(threadId, vote),
    onMutate: ({ threadId, vote }) =>
      opt.apply(threadId, (t) => {
        const likedBy = t.likedBy.filter((u) => u !== userId);
        const dislikedBy = t.dislikedBy.filter((u) => u !== userId);
        if (userId && vote === 'like') likedBy.push(userId);
        if (userId && vote === 'dislike') dislikedBy.push(userId);
        return { ...t, likedBy, dislikedBy };
      }),
    onError: (_e, { threadId }, ctx) => opt.rollback(threadId, ctx),
    onSettled: (_d, _e, { threadId }) => opt.settle(threadId),
  });
}

export function useSetThreadEmotion(communityId: string, userId: string | undefined) {
  const api = useApi();
  const opt = useOptimisticThread(communityId);
  return useMutation({
    mutationFn: ({ threadId, emotion }: { threadId: string; emotion: EmotionType | null }) =>
      api.threads.setEmotion(threadId, emotion),
    onMutate: ({ threadId, emotion }) =>
      opt.apply(threadId, (t) => {
        const emotions = t.emotions.filter((e) => e.userId !== userId);
        if (userId && emotion) emotions.push({ userId, emotion });
        return { ...t, emotions };
      }),
    onError: (_e, { threadId }, ctx) => opt.rollback(threadId, ctx),
    onSettled: (_d, _e, { threadId }) => opt.settle(threadId),
  });
}

export function useAddComment(threadId: string, communityId: string) {
  const api = useApi();
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (input: { comment: string; replyToCommentId?: string }) =>
      api.threads.addComment(threadId, input),
    onSuccess: () =>
      Promise.all([
        qc.invalidateQueries({ queryKey: qk.threadComments(threadId) }),
        qc.invalidateQueries({ queryKey: qk.thread(threadId) }),
        qc.invalidateQueries({ queryKey: qk.threads(communityId) }),
      ]),
  });
}
