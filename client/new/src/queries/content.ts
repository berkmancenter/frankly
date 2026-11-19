import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useApi } from '@/api/ApiProvider';
import type { CommunityResource } from '@/api/types';
import { qk } from './keys';

/* ----------------------------------------------------------------- resources */

export function useResources(communityId: string | undefined) {
  const api = useApi();
  return useQuery({
    queryKey: qk.resources(communityId ?? ''),
    queryFn: () => api.resources.list(communityId!),
    enabled: !!communityId,
  });
}

export function useCreateResource(communityId: string) {
  const api = useApi();
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (input: { title: string; url: string; image?: string }) =>
      api.resources.create(communityId, input),
    onSuccess: () => qc.invalidateQueries({ queryKey: qk.resources(communityId) }),
  });
}

export function useUpdateResource(communityId: string) {
  const api = useApi();
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({
      resourceId,
      patch,
    }: {
      resourceId: string;
      patch: Partial<Pick<CommunityResource, 'title' | 'url' | 'image'>>;
    }) => api.resources.update(communityId, resourceId, patch),
    onSuccess: () => qc.invalidateQueries({ queryKey: qk.resources(communityId) }),
  });
}

export function useRemoveResource(communityId: string) {
  const api = useApi();
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (resourceId: string) => api.resources.remove(communityId, resourceId),
    onSuccess: () => qc.invalidateQueries({ queryKey: qk.resources(communityId) }),
  });
}

/* ------------------------------------------------------------- announcements */

export function useAnnouncements(communityId: string | undefined, enabled = true) {
  const api = useApi();
  return useQuery({
    queryKey: qk.announcements(communityId ?? ''),
    queryFn: () => api.announcements.list(communityId!),
    enabled: !!communityId && enabled,
  });
}

export function useCreateAnnouncement(communityId: string) {
  const api = useApi();
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (input: { title?: string; message: string }) =>
      api.announcements.create(communityId, input),
    onSuccess: () => qc.invalidateQueries({ queryKey: qk.announcements(communityId) }),
  });
}

export function useRemoveAnnouncement(communityId: string) {
  const api = useApi();
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (announcementId: string) => api.announcements.remove(communityId, announcementId),
    onSuccess: () => qc.invalidateQueries({ queryKey: qk.announcements(communityId) }),
  });
}
