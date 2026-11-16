import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { useApi } from "@/api/ApiProvider";
import { qk } from "./keys";

/** Every tag on the community's templates, for the filter on the templates page. */
export function useTemplateTags(communityId: string | undefined) {
  const api = useApi();
  return useQuery({
    queryKey: qk.templateTags(communityId ?? ""),
    queryFn: () => api.tags.listForTemplates(communityId!),
    enabled: !!communityId,
  });
}

export function useUserTags(userId: string | undefined) {
  const api = useApi();
  return useQuery({
    queryKey: qk.userTags(userId ?? ""),
    queryFn: () => api.tags.listForUser(userId!),
    enabled: !!userId,
  });
}

export function useTagSuggestions(input: string) {
  const api = useApi();
  const text = input.trim();
  return useQuery({
    queryKey: qk.tagSuggestions(text),
    queryFn: () => api.tags.suggest(text),
    enabled: !!text,
  });
}

/** Adds and removes tags on the signed-in user's own profile. */
export function useProfileTagMutations(userId: string) {
  const api = useApi();
  const qc = useQueryClient();
  const refresh = () => qc.invalidateQueries({ queryKey: qk.userTags(userId) });
  return {
    add: useMutation({ mutationFn: (title: string) => api.tags.addToMyProfile(title), onSuccess: refresh }),
    remove: useMutation({ mutationFn: (tagId: string) => api.tags.removeFromMyProfile(tagId), onSuccess: refresh }),
  };
}

/** The user's email, for themselves and community admins only (`enabled` says whether to ask). */
export function useUserEmail(userId: string, communityId: string | undefined, enabled: boolean) {
  const api = useApi();
  return useQuery({
    queryKey: qk.userEmail(userId, communityId ?? ""),
    queryFn: () => api.users.email(userId, communityId),
    enabled,
  });
}
