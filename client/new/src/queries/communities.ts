import { queryOptions, useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useApi } from '@/api/ApiProvider';
import type { Api, NewCommunityInput } from '@/api/api';
import { qk } from './keys';

export const communityByDisplayIdQuery = (api: Api, displayId: string) =>
  queryOptions({
    queryKey: qk.communityByDisplayId(displayId),
    queryFn: () => api.communities.getByDisplayId(displayId),
    staleTime: 30_000,
  });

export const myCommunitiesQuery = (api: Api) =>
  queryOptions({
    queryKey: qk.myCommunities(),
    queryFn: () => api.communities.listMine(),
    staleTime: 30_000,
  });

export function useCommunity(displayId: string) {
  const api = useApi();
  return useQuery(communityByDisplayIdQuery(api, displayId));
}

export function useMyCommunities() {
  const api = useApi();
  return useQuery(myCommunitiesQuery(api));
}

/** Membership state changed: refresh `me`, the "my communities" list and anything permission-gated. */
function useInvalidateMembership() {
  const qc = useQueryClient();
  return () =>
    Promise.all([
      qc.invalidateQueries({ queryKey: qk.me() }),
      qc.invalidateQueries({ queryKey: qk.myCommunities() }),
    ]);
}

export function useCreateCommunity() {
  const api = useApi();
  const invalidate = useInvalidateMembership();
  return useMutation({
    mutationFn: (input: NewCommunityInput) => api.communities.create(input),
    onSuccess: invalidate,
  });
}

export function useFollowCommunity() {
  const api = useApi();
  const invalidate = useInvalidateMembership();
  return useMutation({
    mutationFn: (communityId: string) => api.communities.follow(communityId),
    onSuccess: invalidate,
  });
}

export function useUnfollowCommunity() {
  const api = useApi();
  const invalidate = useInvalidateMembership();
  return useMutation({
    mutationFn: (communityId: string) => api.communities.unfollow(communityId),
    onSuccess: invalidate,
  });
}

export function useMembers(communityId: string) {
  const api = useApi();
  return useQuery({
    queryKey: qk.members(communityId),
    queryFn: () => api.communities.listMembers(communityId),
  });
}
