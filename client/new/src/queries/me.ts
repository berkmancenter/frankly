import { queryOptions, useQuery } from '@tanstack/react-query';
import { useApi } from '@/api/ApiProvider';
import type { Api } from '@/api/api';
import type { Me, Membership, PublicUser } from '@/api/types';
import { qk } from './keys';

export const meQuery = (api: Api) =>
  queryOptions({
    queryKey: qk.me(),
    queryFn: () => api.me.get(),
    staleTime: 60_000,
  });

export const userQuery = (api: Api, userId: string) =>
  queryOptions({
    queryKey: qk.user(userId),
    queryFn: () => api.users.get(userId),
    staleTime: 5 * 60_000,
  });

/** The signed-in user plus all of their memberships. */
export function useMe() {
  const api = useApi();
  return useQuery(meQuery(api));
}

export function useCurrentUser(): PublicUser | undefined {
  return useMe().data?.user;
}

export function useCurrentUserId(): string | undefined {
  return useMe().data?.user.id;
}

/** The current user's membership in a community (or `undefined` if they never interacted). */
export function useMembership(communityId: string | undefined): Membership | undefined {
  const api = useApi();
  const { data } = useQuery({
    ...meQuery(api),
    select: (me: Me) => me.memberships.find((m) => m.communityId === communityId),
  });
  return data;
}

export function useUser(userId: string | undefined) {
  const api = useApi();
  return useQuery({ ...userQuery(api, userId ?? ''), enabled: !!userId });
}
