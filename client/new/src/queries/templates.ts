import { queryOptions, useQuery } from '@tanstack/react-query';
import { useApi } from '@/api/ApiProvider';
import type { Api } from '@/api/api';
import { qk } from './keys';

export const templatesQuery = (api: Api, communityId: string) =>
  queryOptions({
    queryKey: qk.templates(communityId),
    queryFn: () => api.templates.list(communityId),
  });

export function useTemplates(communityId: string | undefined) {
  const api = useApi();
  return useQuery({ ...templatesQuery(api, communityId ?? ''), enabled: !!communityId });
}

/** Whether the current user already attended an event of `templateId` (prerequisite check). */
export function useHasAttendedTemplate(templateId: string | undefined) {
  const api = useApi();
  return useQuery({
    queryKey: qk.attendedTemplate(templateId ?? ''),
    queryFn: () => api.events.hasAttendedTemplate(templateId!),
    enabled: !!templateId,
  });
}
