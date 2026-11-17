/**
 * Domain model. A trimmed, JSON-friendly port of `data_models/lib` (the Dart/Freezed
 * package shared by the Flutter client and functions). Firestore dates are normalized to
 * ISO-8601 strings at the API boundary.
 */

/* ----------------------------------------------------------------------------
 * Users & membership
 * ------------------------------------------------------------------------- */

// Identifiers stored in Firestore, not UI text.
// eslint-disable-next-line lingui/no-unlocalized-strings
export const SOCIAL_PLATFORMS = ['instagram', 'twitter', 'facebook', 'linkedin'] as const;
export type SocialPlatform = (typeof SOCIAL_PLATFORMS)[number];

export interface SocialLink {
  platform: SocialPlatform;
  url: string;
}

// What a user changes about their own profile; absent fields are left alone.
export interface ProfileUpdate {
  displayName?: string;
  about?: string;
  imageUrl?: string;
  // The full list: platforms left out are removed.
  socialLinks?: SocialLink[];
}

// A tag's shared definition: `#title`.
export interface Tag {
  id: string;
  title: string;
}

// One tag on one template.
export interface TemplateTag {
  templateId: string;
  tag: Tag;
}

// Which emails a member gets from one community.
export interface NotificationSettings {
  notifyAnnouncements: boolean;
  notifyEvents: boolean;
}

export interface PublicUser {
  id: string;
  displayName: string;
  imageUrl?: string;
  about?: string;
  socialLinks?: SocialLink[];
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
  /** Whether hosts may create events with no host. */
  enableHostless: boolean;
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
  /** What events default to in this community. */
  eventSettings: EventSettings;
  onboardingSteps: OnboardingStep[];
  isOnboardingOverviewEnabled: boolean;
  /** Lets hosts add free-text questions to the sign-up questions (set by the platform team only). */
  allowAdditionalRegistrationField: boolean;
}

export interface MemberDetails {
  user: PublicUser;
  membership: Membership;
}

/* ----------------------------------------------------------------------------
 * Templates, events
 * ------------------------------------------------------------------------- */

// The switches a host can set on a template or event; whatever is unset falls back to the template, then the community.
// Firestore field names, not UI text.
/* eslint-disable lingui/no-unlocalized-strings */
export const EVENT_SETTING_FLAGS = [
  'chat',
  'showChatMessagesInRealTime',
  'alwaysRecord',
  'alwaysTranscribe',
  'autoEndMeeting',
  'talkingTimer',
  'agendaPreview',
] as const;
// Switches only developers touch, shown outside production.
export const DEV_EVENT_SETTING_FLAGS = [
  'reminderEmails',
  'allowMultiplePeopleOnStage',
  'showSmartMatchingForBreakouts',
  'defaultStageView',
  'enableBreakoutsByCategory',
  'enablePrerequisites',
] as const;
export const ALL_EVENT_SETTING_FLAGS = [...EVENT_SETTING_FLAGS, ...DEV_EVENT_SETTING_FLAGS] as const;
/* eslint-enable lingui/no-unlocalized-strings */
export type EventSettingFlag = (typeof EVENT_SETTING_FLAGS)[number];
export type AnyEventSettingFlag = (typeof ALL_EVENT_SETTING_FLAGS)[number];

export type EventSettings = { [K in AnyEventSettingFlag]?: boolean } & {
  /** 0-120; only matters while `autoEndMeeting` is on. */
  autoEndGracePeriodMinutes?: number;
};

// Firestore values, not UI text.
// eslint-disable-next-line lingui/no-unlocalized-strings
export const PRE_POST_ATTRIBUTES = ['userId', 'eventId', 'email'] as const;
export type PrePostAttribute = (typeof PRE_POST_ATTRIBUTES)[number];

// A link on a pre- or post-event card; the chosen attributes are added to it as query parameters.
export interface PrePostLink {
  buttonText?: string;
  url?: string;
  attributes: { type: PrePostAttribute; queryParam: string }[];
}

// What a host shows participants right after they sign up (`preEvent`) or once the event is over (`postEvent`).
export interface PrePostCard {
  headline: string;
  message: string;
  links: PrePostLink[];
}

// A question the host asks while people sign up, used to match them into breakout rooms.
export interface SurveyQuestion {
  id: string;
  title: string;
  type: 'multipleChoice' | 'freeText';
  /** The choices of a multiple-choice question, flattened from `answers`. */
  options: { id: string; title: string }[];
  /** The stored choice groups; a question with no free text has at least two. */
  answers: { id: string; options: { id: string; title: string }[] }[];
}

export interface SurveyAnswer {
  questionId: string;
  answerOptionId?: string;
  freeText?: string;
}

export type AgendaItemType = 'text' | 'video' | 'image' | 'poll' | 'wordCloud' | 'userSuggestions';

// One step of an event's agenda, as the host planned it.
export type VideoType = 'youtube' | 'vimeo' | 'url';

export type BreakoutAssignmentMethod = 'targetPerRoom' | 'smartMatch';

export interface AgendaItem {
  id: string;
  type: AgendaItemType;
  title?: string;
  content?: string;
  imageUrl?: string;
  videoType?: VideoType;
  videoUrl?: string;
  pollAnswers?: string[];
  timeInSeconds?: number;
}

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
  agendaItems: AgendaItem[];
  preEventCard?: PrePostCard;
  postEventCard?: PrePostCard;
  eventSettings?: EventSettings;
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
  isLocked: boolean;
  agendaItems: AgendaItem[];
  /** How people are split into breakout rooms; absent until the host defines breakouts. */
  breakout?: { assignmentMethod: BreakoutAssignmentMethod; targetParticipants: number };
  /** Whether a live stream has been set up for the event (only livestream events have one). */
  hasLiveStream: boolean;
  surveyQuestions?: SurveyQuestion[];
  preEventCard?: PrePostCard;
  postEventCard?: PrePostCard;
  eventSettings?: EventSettings;
  maxParticipants?: number;
  /** Server-kept head count for events that do not list their participants (hostless, livestream). */
  participantCountEstimate?: number;
  registrationCount?: number;
  presentParticipantCountEstimate?: number;
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

/** What the edit drawer changes; absent fields are left alone. */
export interface EventUpdate {
  eventType?: EventType;
  title?: string;
  description?: string;
  image?: string;
  isPublic?: boolean;
  /** ISO time. */
  scheduledTime?: string;
  maxParticipants?: number;
  durationInMinutes?: number;
}

export interface CalendarLinks {
  google: string;
  outlook: string;
  office365: string;
  /** The text of an .ics file. */
  ics: string;
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
