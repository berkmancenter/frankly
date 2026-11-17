import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useApi } from '@/api/ApiProvider';
import type { Api } from '@/api/api';
import type { AgendaItem, BreakoutAssignmentMethod, Event, EventSettings, EventUpdate, NewEventInput, PrePostCard, SurveyAnswer, SurveyQuestion } from '@/api/types';
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

// How often an open event page re-reads who is going and who is in the room.
export const EVENT_REFRESH_MS = 15_000;

export function useEventParticipants(eventId: string | undefined, enabled = true, refetchInterval?: number) {
  const api = useApi();
  return useQuery({
    queryKey: qk.eventParticipants(eventId ?? ''),
    queryFn: () => api.events.listParticipants(eventId!),
    enabled: !!eventId && enabled,
    refetchInterval,
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

export function useEvent(communityId: string, templateId: string, eventId: string) {
  const api = useApi();
  return useQuery({
    queryKey: qk.event(eventId),
    queryFn: () => api.events.get(communityId, templateId, eventId),
    refetchInterval: EVENT_REFRESH_MS,
  });
}

export function useEventMessages(event: Event | undefined) {
  const api = useApi();
  return useQuery({
    queryKey: qk.eventMessages(event?.id ?? ''),
    queryFn: () => api.events.listMessages(event!),
    enabled: !!event,
  });
}

export function useCalendarLinks(event: Event, enabled: boolean) {
  const api = useApi();
  return useQuery({
    queryKey: qk.calendarLinks(event.id),
    queryFn: () => api.events.calendarLinks(event),
    enabled,
    staleTime: Infinity,
  });
}

export function useSendEventMessage() {
  const api = useApi();
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ event, message }: { event: Event; message: string }) => api.events.sendMessage(event, message),
    onSuccess: (_result, { event }) => qc.invalidateQueries({ queryKey: qk.eventMessages(event.id) }),
  });
}

export function useRemoveEventMessage() {
  const api = useApi();
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ event, messageId }: { event: Event; messageId: string }) =>
      api.events.removeMessage(event, messageId),
    onSuccess: (_result, { event }) => qc.invalidateQueries({ queryKey: qk.eventMessages(event.id) }),
  });
}

/** RSVP, withdraw and cancel all change who is going, and what the event lists show. */
function useEventChange<V>(change: (api: Api, event: Event, variables: V) => Promise<unknown>) {
  const api = useApi();
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ event, ...variables }: { event: Event } & V) => change(api, event, variables as V),
    onSuccess: (_result, { event }) =>
      Promise.all([
        qc.invalidateQueries({ queryKey: qk.event(event.id) }),
        qc.invalidateQueries({ queryKey: qk.eventParticipants(event.id) }),
        qc.invalidateQueries({ queryKey: qk.upcomingEvents(event.communityId) }),
        qc.invalidateQueries({ queryKey: qk.allEvents(event.communityId) }),
        qc.invalidateQueries({ queryKey: qk.myEvents() }),
        qc.invalidateQueries({ queryKey: qk.me() }),
      ]),
  });
}

export const useUpdateEvent = () =>
  useEventChange<{ patch: EventUpdate }>((api, event, { patch }) => api.events.update(event, patch));
export const useUpdatePrePost = () =>
  useEventChange<{ which: 'pre' | 'post'; card: PrePostCard | null }>((api, event, { which, card }) =>
    api.events.updatePrePost(event, which, card),
  );
export const useUpsertAgendaItem = () =>
  useEventChange<{ item: AgendaItem }>((api, event, { item }) => api.events.upsertAgendaItem(event, item));
export const useDeleteAgendaItem = () =>
  useEventChange<{ itemId: string }>((api, event, { itemId }) => api.events.deleteAgendaItem(event, itemId));
export const useReorderAgenda = () =>
  useEventChange<{ ids: string[] }>((api, event, { ids }) => api.events.reorderAgenda(event, ids));
export const useSaveSurveyQuestions = () =>
  useEventChange<{ questions: SurveyQuestion[] }>((api, event, { questions }) =>
    api.events.saveSurveyQuestions(event, questions),
  );
export const useUpdateBreakoutSettings = () =>
  useEventChange<{ patch: { assignmentMethod?: BreakoutAssignmentMethod; targetParticipants?: number } }>(
    (api, event, { patch }) => api.events.updateBreakoutSettings(event, patch),
  );
export const useClearAgenda = () => useEventChange<object>((api, event) => api.events.clearAgenda(event));
export const useRefreshEventFromTemplate = () =>
  useEventChange<object>((api, event) => api.events.refreshFromTemplate(event));
export const useUpdateEventSettings = () =>
  useEventChange<{ settings: EventSettings }>((api, event, { settings }) => api.events.updateSettings(event, settings));

export const useJoinEvent = () =>
  useEventChange<{ joinCommunity?: boolean; survey?: SurveyAnswer[] }>((api, event, { joinCommunity, survey }) =>
    api.events.join(event, { joinCommunity, survey }),
  );
export const useLeaveEvent = () =>
  useEventChange<{ participantId?: string }>((api, event, { participantId }) =>
    api.events.leave(event, participantId),
  );
export const useCancelEvent = () => useEventChange<object>((api, event) => api.events.cancel(event));
