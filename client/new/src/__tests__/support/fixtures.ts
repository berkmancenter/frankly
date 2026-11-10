import type {
  Announcement,
  Community,
  CommunityResource,
  DiscussionThread,
  DiscussionThreadComment,
  Event,
  Me,
  Membership,
  PublicUser,
  Template,
} from "@/api/types";

/** Small builders with sensible defaults; override only what the test cares about. */

export const user = (over: Partial<PublicUser> = {}): PublicUser => ({
  id: "u1",
  displayName: "Ada Lovelace",
  ...over,
});

export const community = (over: Partial<Community> = {}): Community => ({
  id: "c1",
  displayId: "civic-lab",
  name: "Civic Lab",
  tagLine: "Talk it through",
  description: "A place to talk.",
  isPublic: true,
  creatorId: "u1",
  settings: {
    allowDonations: false,
    allowUnofficialTemplates: false,
    dontAllowMembersToCreateMeetings: false,
    enableDiscussionThreads: true,
    requireApprovalToJoin: false,
  },
  onboardingSteps: [],
  isOnboardingOverviewEnabled: false,
  ...over,
});

export const membership = (over: Partial<Membership> = {}): Membership => ({
  userId: "u1",
  communityId: "c1",
  status: "member",
  ...over,
});

export const me = (over: Partial<Me> = {}): Me => ({
  user: user(),
  memberships: [],
  ...over,
});

export const template = (over: Partial<Template> = {}): Template => ({
  id: "t1",
  communityId: "c1",
  title: "Check-in",
  status: "active",
  creatorId: "u1",
  orderingPriority: 0,
  ...over,
});

export const event = (over: Partial<Event> = {}): Event => ({
  id: "e1",
  communityId: "c1",
  communityDisplayId: "civic-lab",
  templateId: "t1",
  creatorId: "u1",
  status: "active",
  eventType: "hosted",
  title: "Weekly chat",
  scheduledTime: "2030-01-01T18:00:00.000Z",
  durationInMinutes: 60,
  isPublic: true,
  ...over,
});

export const thread = (over: Partial<DiscussionThread> = {}): DiscussionThread => ({
  id: "th1",
  communityId: "c1",
  creatorId: "u1",
  content: "Hello everyone",
  likedBy: [],
  dislikedBy: [],
  emotions: [],
  commentCount: 0,
  ...over,
});

export const comment = (
  over: Partial<DiscussionThreadComment> = {},
): DiscussionThreadComment => ({
  id: "cm1",
  threadId: "th1",
  creatorId: "u1",
  comment: "Nice point",
  emotions: [],
  ...over,
});

export const resource = (over: Partial<CommunityResource> = {}): CommunityResource => ({
  id: "r1",
  communityId: "c1",
  title: "Handbook",
  url: "https://example.com",
  ...over,
});

export const announcement = (over: Partial<Announcement> = {}): Announcement => ({
  id: "a1",
  communityId: "c1",
  message: "Welcome!",
  creatorId: "u1",
  ...over,
});
