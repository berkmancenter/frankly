/**
 * Typed URL builders — the port of `CommunityPageRoutes` / `user pages`.
 * Route params and search params are the source of truth for navigation state, so every
 * link in the app goes through here. Several targets (home, settings, templates, events, posts…)
 * are pages Flutter still owns: navigating to them is a hand-off (see `LegacyFallback`).
 */
export type ProfileSection = "events" | "profile" | "notifications";
export const PROFILE_SECTIONS: readonly ProfileSection[] = ["events", "profile", "notifications"];
export type AdminTab = "profile" | "members" | "data" | "settings";
export const ADMIN_TABS: readonly AdminTab[] = ["profile", "members", "data", "settings"];

const q = (params: Record<string, string | undefined>) => {
  const s = new URLSearchParams();
  for (const [k, v] of Object.entries(params)) if (v) s.set(k, v);
  const str = s.toString();
  return str ? `?${str}` : "";
};

export const paths = {
  root: "/",
  // The signed-in user's page: their events, profile and email notifications.
  profile: (
    opts: { section?: ProfileSection; communityId?: string } = {},
  ) => `/profile${q({ section: opts.section, communityId: opts.communityId })}`,

  community: (displayId: string) => {
    const base = `/space/${displayId}`;
    return {
      home: base,
      events: `${base}/discuss/upcoming`,
      templates: `${base}/discuss`,
      template: (templateId: string) => `${base}/discuss/${templateId}`,
      event: (
        templateId: string,
        eventId: string,
        search: Record<string, string | undefined> = {},
      ) => `${base}/discuss/${templateId}/${eventId}${q(search)}`,
      resources: `${base}/resources`,
      posts: `${base}/posts`,
      post: (threadId: string) => `${base}/post/${threadId}`,
      admin: (tab: AdminTab = "profile") => `${base}/admin/${tab}`,
    };
  },
};
