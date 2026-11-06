/**
 * Query keys are the *parameterization* of server state: every key is a pure function of the
 * ids it depends on, hierarchical so a whole subtree can be invalidated with one prefix
 * (`qk.community(id)`), and never built by hand at a call site.
 *
 * Unobserved queries are garbage-collected by TanStack Query (`gcTime`), which is the
 * "auto-disposed" half of the state-management model.
 */
export const qk = {
  me: () => ['me'] as const,
  user: (userId: string) => ['users', userId] as const,

  communities: () => ['communities'] as const,
  myCommunities: () => ['communities', 'mine'] as const,
  communityByDisplayId: (displayId: string) => ['communities', 'by-display-id', displayId] as const,
  /** Prefix for everything that belongs to one community. */
  community: (communityId: string) => ['community', communityId] as const,
  members: (communityId: string) => ['community', communityId, 'members'] as const,
  templates: (communityId: string) => ['community', communityId, 'templates'] as const,
  upcomingEvents: (communityId: string) => ['community', communityId, 'events', 'upcoming'] as const,
  allEvents: (communityId: string) => ['community', communityId, 'events', 'all'] as const,
  threads: (communityId: string) => ['community', communityId, 'threads'] as const,
  resources: (communityId: string) => ['community', communityId, 'resources'] as const,
  announcements: (communityId: string) => ['community', communityId, 'announcements'] as const,

  attendedTemplate: (templateId: string) => ['templates', templateId, 'attended'] as const,

  eventParticipants: (eventId: string) => ['events', eventId, 'participants'] as const,

  thread: (threadId: string) => ['threads', threadId] as const,
  threadComments: (threadId: string) => ['threads', threadId, 'comments'] as const,
};
