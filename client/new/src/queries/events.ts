import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useApi } from '@/api/ApiProvider';
import type { NewEventInput } from '@/api/types';
import { qk } from './keys';

export function useUpcomingEvents(communityId: string | undefined) {
  const api = useApi();
  return useQuery({
    queryKey: qk.upcomingEvents(communityId ?? ''),
    queryFn: () => api.events.listUpcoming(communityId!),
    enabled: !!communityId,
  });
}

export function useAllEvents(communityId: string) {
  const api = useApi();
  return useQuery({
    queryKey: qk.allEvents(communityId),
    queryFn: () => api.events.listAll(communityId),
  });
}

export function useEventParticipants(eventId: string | undefined, enabled = true) {
  const api = useApi();
  return useQuery({
    queryKey: qk.eventParticipants(eventId ?? ''),
    queryFn: () => api.events.listParticipants(eventId!),
    enabled: !!eventId && enabled,
  });
}

export function useCreateEvent() {
  const api = useApi();
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (input: NewEventInput) => api.events.create(input),
    // A new event changes every list that can show it, and the community's onboarding progress.
    onSuccess: (event) =>
      Promise.all([
        qc.invalidateQueries({ queryKey: qk.communities() }),
        qc.invalidateQueries({ queryKey: qk.upcomingEvents(event.communityId) }),
        qc.invalidateQueries({ queryKey: qk.allEvents(event.communityId) }),
      ]),
  });
}
