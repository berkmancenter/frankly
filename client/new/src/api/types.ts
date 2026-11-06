/**
 * Domain model. A trimmed, JSON-friendly port of `data_models/lib` (the Dart/Freezed
 * package shared by the Flutter client and functions). Firestore dates are normalized to
 * ISO-8601 strings at the API boundary.
 */

/* ----------------------------------------------------------------------------
 * Users & membership
 * ------------------------------------------------------------------------- */

export interface PublicUser {
  id: string;
  displayName: string;
  imageUrl?: string;
  about?: string;
  /** `AppRole.owner` — may create new communities ("Start a community"). */
  isAppOwner?: boolean;
}

export type MembershipStatus =
  | 'owner'
  | 'admin'
  | 'moderator'
  | 'facilitator'
  | 'member'
  | 'banned'
  | 'nonmember'
  | 'attendee';

export interface Membership {
  userId: string;
  communityId: string;
  status: MembershipStatus;
  /** Set when the community requires approval: `Follow` becomes a request. */
  requestStatus?: 'pending' | 'approved' | 'denied';
}

/** The signed-in user and all of their community memberships. */
export interface Me {
  user: PublicUser;
  memberships: Membership[];
}

/* ----------------------------------------------------------------------------
 * Communities
 * ------------------------------------------------------------------------- */

export type OnboardingStep =
  | 'brandSpace'
  | 'createTemplate'
  | 'hostEvent'
  | 'inviteSomeone';

export interface CommunitySettings {
  allowDonations: boolean;
  allowUnofficialTemplates: boolean;
  /** When true only facilitators and above can create events. */
  dontAllowMembersToCreateMeetings: boolean;
  enableDiscussionThreads: boolean;
  requireApprovalToJoin: boolean;
}

export interface Community {
  id: string;
  /** URL slug: `/space/:displayId`. */
  displayId: string;
  name: string;
  tagLine?: string;
  description?: string;
  contactEmail?: string;
  profileImageUrl?: string;
  isPublic: boolean;
  /** `RRGGBB` (no `#`) — page background inside community pages. */
  themeLightColor?: string;
  /** `RRGGBB` (no `#`) — primary color inside community pages. */
  themeDarkColor?: string;
  creatorId: string;
  createdDate?: string;
  settings: CommunitySettings;
  onboardingSteps: OnboardingStep[];
  isOnboardingOverviewEnabled: boolean;
}

export interface MemberDetails {
  user: PublicUser;
  membership: Membership;
}

/* ----------------------------------------------------------------------------
 * Templates, events
 * ------------------------------------------------------------------------- */

export interface Template {
  id: string;
  communityId: string;
  title: string;
  description?: string;
  category?: string;
  image?: string;
  status: 'active' | 'removed';
  creatorId: string;
  prerequisiteTemplateId?: string;
  orderingPriority: number;
  createdDate?: string;
}

export type EventType = 'hosted' | 'hostless' | 'livestream';
export type EventStatus = 'active' | 'canceled';

export interface Event {
  id: string;
  communityId: string;
  /** Denormalized by the server so event cards can link without loading the community. */
  communityDisplayId: string;
  templateId: string;
  creatorId: string;
  status: EventStatus;
  eventType: EventType;
  title?: string;
  description?: string;
  image?: string;
  scheduledTime?: string;
  endedAt?: string;
  durationInMinutes: number;
  isPublic: boolean;
  prerequisiteTemplateId?: string;
  createdDate?: string;
}

export type ParticipantStatus = 'active' | 'canceled' | 'banned';

export interface Participant {
  userId: string;
  eventId: string;
  status: ParticipantStatus;
  isPresent: boolean;
  createdDate?: string;
}

export interface EventMessage {
  id: string;
  creatorId: string;
  createdAt: string;
  message: string;
}

export interface NewEventInput {
  communityId: string;
  templateId: string;
  title?: string;
  scheduledTime: string;
  durationInMinutes: number;
  eventType: EventType;
  isPublic: boolean;
}

/* ----------------------------------------------------------------------------
 * Reactions and realtime payloads
 *
 * The live meeting is not migrated, but `api/realtime.ts` (the contract of the connection
 * state machine) is written in terms of these payloads, so they stay until it is revisited.
 * ------------------------------------------------------------------------- */

/** The seven emotions of the Flutter `EmotionType` (chat reactions + post/comment reactions). */
export type EmotionType =
  | 'thumbsUp'
  | 'heart'
  | 'hundred'
  | 'exclamation'
  | 'plusOne'
  | 'laughWithTears'
  | 'heartEyes';

export interface EmotionVote {
  userId: string;
  emotion: EmotionType;
}

export interface ChatMessage {
  id: string;
  /** Client-generated idempotency key; lets the UI reconcile optimistic outbox items. */
  clientId: string;
  roomId: string;
  creatorId: string;
  message?: string;
  emotion?: EmotionType;
  createdAt: string;
  removed?: boolean;
}

export interface PresenceEntry {
  userId: string;
  /** Agora uid of this participant, when they publish media in the RTC channel. */
  rtcUid?: number;
  displayName: string;
  imageUrl?: string;
  audioOn: boolean;
  videoOn: boolean;
  speaking: boolean;
  joinedAt: string;
}

export interface Suggestion {
  id: string;
  userId: string;
  text: string;
  likedBy: string[];
  dislikedBy: string[];
  createdAt: string;
}

export interface LiveMeetingState {
  eventId: string;
  phase: 'notStarted' | 'running' | 'finished';
  /** `-1` until the meeting starts. */
  currentItemIndex: number;
  itemStartedAt?: string;
  startedAt?: string;
  endedAt?: string;
  /** Ordered queue of users with their hand up; first entry is "up next". */
  raisedHands: string[];
  /** Hostless meetings: users who have clicked "I'm ready to move on" for the current item. */
  readyToAdvance: string[];
  /** Hostless: ISO time the server will auto-advance at (majority reached). */
  pendingAdvanceAt?: string;
  pollVotes: Record<string, Record<string, string>>;
  wordCloud: Record<string, { userId: string; word: string }[]>;
  suggestions: Record<string, Suggestion[]>;
}

/* ----------------------------------------------------------------------------
 * Posts, resources, announcements
 * ------------------------------------------------------------------------- */

export interface DiscussionThread {
  id: string;
  communityId: string;
  creatorId: string;
  createdAt?: string;
  title?: string;
  content: string;
  imageUrl?: string;
  likedBy: string[];
  dislikedBy: string[];
  emotions: EmotionVote[];
  commentCount: number;
}

export interface DiscussionThreadComment {
  id: string;
  threadId: string;
  creatorId: string;
  createdAt?: string;
  comment: string;
  replyToCommentId?: string;
  deleted?: boolean;
  emotions: EmotionVote[];
}

export interface CommunityResource {
  id: string;
  communityId: string;
  title: string;
  url: string;
  image?: string;
  createdDate?: string;
}

export interface Announcement {
  id: string;
  communityId: string;
  title?: string;
  message: string;
  creatorId: string;
  createdDate?: string;
}
