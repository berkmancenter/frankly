/**
 * Typed URL builders — the port of `CommunityPageRoutes` / `UserSettingsLocation`.
 * Route params and search params are the source of truth for navigation state, so every
 * link in the app goes through here. Several targets (home, settings, templates, events, posts…)
 * are pages Flutter still owns: navigating to them is a hand-off (see `LegacyFallback`).
 */
export type UserSettingsSection = 'events' | 'profile' | 'notifications' | 'subscriptions';
export type AdminTab = 'profile' | 'members' | 'data' | 'settings';

const q = (params: Record<string, string | undefined>) => {
  const s = new URLSearchParams();
  for (const [k, v] of Object.entries(params)) if (v) s.set(k, v);
  const str = s.toString();
  return str ? `?${str}` : '';
};

export const paths = {
  home: '/home',
  newSpace: '/newspace',
  settings: (opts: { initialSection?: UserSettingsSection; communityId?: string } = {}) =>
    `/settings${q({ initialSection: opts.initialSection, communityId: opts.communityId })}`,

  community: (displayId: string) => {
    const base = `/space/${displayId}`;
    return {
      home: base,
      events: `${base}/discuss/upcoming`,
      templates: `${base}/discuss`,
      event: (templateId: string, eventId: string, search: Record<string, string | undefined> = {}) =>
        `${base}/discuss/${templateId}/${eventId}${q(search)}`,
      resources: `${base}/resources`,
      posts: `${base}/posts`,
      post: (threadId: string) => `${base}/post/${threadId}`,
      admin: (tab: AdminTab = 'profile') => `${base}/admin/${tab}`,
    };
  },
};
