import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { useApi } from "@/api/ApiProvider";
import type { NotificationSettings, ProfileUpdate } from "@/api/types";
import { qk } from "./keys";

/** Active events the signed-in user is registered for, across all communities. */
export function useMyEvents() {
  const api = useApi();
  return useQuery({ queryKey: qk.myEvents(), queryFn: () => api.events.listMine() });
}

/** Saves the user's own profile, then refreshes everything that shows it (the nav avatar, profile cards). */
export function useUpdateProfile() {
  const api = useApi();
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (patch: ProfileUpdate) => api.users.updateMe(patch),
    onSuccess: (user) => {
      qc.setQueryData(qk.user(user.id), user);
      return qc.invalidateQueries({ queryKey: qk.me() });
    },
  });
}

export function useNotificationSettings(communityId: string | undefined) {
  const api = useApi();
  return useQuery({
    queryKey: qk.notificationSettings(communityId ?? ""),
    queryFn: () => api.notifications.get(communityId!),
    enabled: !!communityId,
  });
}

export function useUpdateNotificationSettings(communityId: string) {
  const api = useApi();
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (patch: Partial<NotificationSettings>) => api.notifications.update(communityId, patch),
    onSuccess: (settings) => qc.setQueryData(qk.notificationSettings(communityId), settings),
  });
}
