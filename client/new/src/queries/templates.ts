import { queryOptions, useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useApi } from '@/api/ApiProvider';
import type { Api } from '@/api/api';
import type { AgendaItem, PrePostCard, Template } from '@/api/types';
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

export function useTemplate(communityId: string, templateId: string) {
  const api = useApi();
  return useQuery({
    queryKey: qk.template(communityId, templateId),
    queryFn: () => api.templates.get(communityId, templateId),
  });
}

/** The template's public events still to come. */
export function useTemplateEvents(communityId: string, templateId: string) {
  const api = useApi();
  return useQuery({
    queryKey: qk.templateEvents(communityId, templateId),
    queryFn: () => api.events.listForTemplate(communityId, templateId),
  });
}

function useTemplateChange<V>(change: (api: Api, template: Template, variables: V) => Promise<unknown>) {
  const api = useApi();
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ template, ...variables }: { template: Template } & V) => change(api, template, variables as V),
    onSuccess: (_result, { template }) =>
      Promise.all([
        qc.invalidateQueries({ queryKey: qk.template(template.communityId, template.id) }),
        qc.invalidateQueries({ queryKey: qk.templates(template.communityId) }),
      ]),
  });
}

export const useUpdateTemplatePrePost = () =>
  useTemplateChange<{ which: 'pre' | 'post'; card: PrePostCard | null }>((api, template, { which, card }) =>
    api.templates.updatePrePost(template, which, card),
  );
export const useUpsertTemplateAgendaItem = () =>
  useTemplateChange<{ item: AgendaItem }>((api, template, { item }) => api.templates.upsertAgendaItem(template, item));
export const useDeleteTemplateAgendaItem = () =>
  useTemplateChange<{ itemId: string }>((api, template, { itemId }) =>
    api.templates.deleteAgendaItem(template, itemId),
  );
export const useReorderTemplateAgenda = () =>
  useTemplateChange<{ ids: string[] }>((api, template, { ids }) => api.templates.reorderAgenda(template, ids));
export const useClearTemplateAgenda = () =>
  useTemplateChange<object>((api, template) => api.templates.clearAgenda(template));
