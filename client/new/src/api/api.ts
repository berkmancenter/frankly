import type {
  BreakoutAssignmentMethod,
  AgendaItem,
  Announcement,
  Community,
  CommunityResource,
  DiscussionThread,
  DiscussionThreadComment,
  EmotionType,
  CalendarLinks,
  Event,
  EventMessage,
  EventSettings,
  EventUpdate,
  PrePostCard,
  SurveyAnswer,
  SurveyQuestion,
  MemberDetails,
  Me,
  Membership,
  NewEventInput,
  Participant,
  NotificationSettings,
  ProfileUpdate,
  PublicUser,
  Tag,
  Template,
  TemplateTag,
} from "./types";

export type ApiErrorCode = "notFound" | "invalid";

export class ApiError extends Error {
  readonly code: ApiErrorCode;
  constructor(code: ApiErrorCode, message: string) {
    super(message);
    this.name = "ApiError";
    this.code = code;
  }
}

export interface NewCommunityInput {
  name: string;
  /** URL slug: `/space/:displayId`. */
  displayId: string;
  isPublic: boolean;
}

export interface ParticipantWithUser {
  participant: Participant;
  user: PublicUser;
}

export type Vote = "like" | "dislike" | "neutral";

/** The client-facing data surface, independent of its Firebase implementation. */
export interface Api {
  me: {
    get(): Promise<Me>;
  };

  users: {
    get(userId: string): Promise<PublicUser>;
    /** Saves the signed-in user's own profile and returns it as stored. */
    updateMe(patch: ProfileUpdate): Promise<PublicUser>;
    /**
     * A user's email, which only they and the admins of `communityId` may see. Undefined when
     * it is not available.
     */
    email(userId: string, communityId?: string): Promise<string | undefined>;
  };

  tags: {
    /** Every tag on the community's templates. */
    listForTemplates(communityId: string): Promise<TemplateTag[]>;
    listForUser(userId: string): Promise<Tag[]>;
    /** Existing tags whose title starts with `input`. */
    suggest(input: string): Promise<Tag[]>;
    /** Tags the signed-in user's profile, creating the shared definition when it is new. */
    addToMyProfile(title: string): Promise<Tag>;
    removeFromMyProfile(tagId: string): Promise<void>;
  };

  notifications: {
    /** The user's email settings for a community (both on until they say otherwise). */
    get(communityId: string): Promise<NotificationSettings>;
    update(communityId: string, patch: Partial<NotificationSettings>): Promise<NotificationSettings>;
  };

  communities: {
    listMine(): Promise<Community[]>;
    getByDisplayId(displayId: string): Promise<Community>;
    follow(communityId: string): Promise<Membership>;
    unfollow(communityId: string): Promise<void>;
    listMembers(communityId: string): Promise<MemberDetails[]>;
    donationsEnabled(communityId: string): Promise<boolean>;
    /** Whether this community shows pre- and post-event cards. */
    prePostEnabled(communityId: string): Promise<boolean>;
    /**
     * Creates a community owned by the current user. Rejects with `ApiError("invalid")` (and a
     * readable message) when the server refuses it, e.g. the URL is already taken.
     */
    create(
      input: NewCommunityInput,
    ): Promise<{ communityId: string; displayId: string }>;
  };

  templates: {
    list(communityId: string): Promise<Template[]>;
    get(communityId: string, templateId: string): Promise<Template>;
    /** Saves the card shown after sign-up (`pre`) or after the event (`post`); `null` removes it. */
    updatePrePost(template: Template, which: 'pre' | 'post', card: PrePostCard | null): Promise<void>;
    clearAgenda(template: Template): Promise<void>;
    upsertAgendaItem(template: Template, item: AgendaItem): Promise<void>;
    deleteAgendaItem(template: Template, itemId: string): Promise<void>;
    reorderAgenda(template: Template, ids: string[]): Promise<void>;
  };

  events: {
    listUpcoming(communityId: string): Promise<Event[]>;
    listAll(communityId: string): Promise<Event[]>;
    /** The template's public events that have not happened yet, soonest first. */
    listForTemplate(communityId: string, templateId: string): Promise<Event[]>;
    /** Active events the signed-in user is registered for, across every community. */
    listMine(): Promise<Event[]>;
    create(input: NewEventInput): Promise<Event>;
    get(communityId: string, templateId: string, eventId: string): Promise<Event>;
    listParticipants(eventId: string): Promise<ParticipantWithUser[]>;
    /** RSVPs the signed-in user; with `joinCommunity` they also follow the community. */
    join(event: Event, options?: { joinCommunity?: boolean; survey?: SurveyAnswer[] }): Promise<void>;
    /** Withdraws an RSVP: the signed-in user's, or `participantId`'s when the host or a moderator removes them. */
    leave(event: Event, participantId?: string): Promise<void>;
    cancel(event: Event): Promise<void>;
    /** Announcements to the event's participants, newest first. */
    listMessages(event: Event): Promise<EventMessage[]>;
    calendarLinks(event: Event): Promise<CalendarLinks>;
    /** Posts an announcement to the event's participants (the server also emails them). */
    sendMessage(event: Event, message: string): Promise<void>;
    removeMessage(event: Event, messageId: string): Promise<void>;
    update(event: Event, patch: EventUpdate): Promise<Event>;
    /** Resets the event's agenda to the template's current one; who is going is untouched. */
    refreshFromTemplate(event: Event): Promise<void>;
    clearAgenda(event: Event): Promise<void>;
    /** Adds the step, or replaces the one with the same id. */
    upsertAgendaItem(event: Event, item: AgendaItem): Promise<void>;
    deleteAgendaItem(event: Event, itemId: string): Promise<void>;
    /** Puts the steps in this order; rejects when the ids no longer match the agenda. */
    reorderAgenda(event: Event, ids: string[]): Promise<void>;
    /** Saves the sign-up questions used to match people into breakout rooms. */
    saveSurveyQuestions(event: Event, questions: SurveyQuestion[]): Promise<void>;
    /** Changes how people are split into breakout rooms (defining breakouts if they were not yet). */
    updateBreakoutSettings(
      event: Event,
      patch: { assignmentMethod?: BreakoutAssignmentMethod; targetParticipants?: number },
    ): Promise<void>;
    /** Saves the card shown after sign-up (`pre`) or after the event (`post`); `null` removes it. */
    updatePrePost(event: Event, which: 'pre' | 'post', card: PrePostCard | null): Promise<void>;
    updateSettings(event: Event, settings: EventSettings): Promise<Event>;
    hasAttendedTemplate(templateId: string): Promise<boolean>;
  };

  threads: {
    list(communityId: string): Promise<DiscussionThread[]>;
    create(
      communityId: string,
      input: { title?: string; content: string; imageUrl?: string },
    ): Promise<DiscussionThread>;
    update(
      threadId: string,
      patch: { content?: string; imageUrl?: string },
    ): Promise<DiscussionThread>;
    vote(threadId: string, vote: Vote): Promise<DiscussionThread>;
    setEmotion(
      threadId: string,
      emotion: EmotionType | null,
    ): Promise<DiscussionThread>;
    listComments(threadId: string): Promise<DiscussionThreadComment[]>;
    addComment(
      threadId: string,
      input: { comment: string; replyToCommentId?: string },
    ): Promise<DiscussionThreadComment>;
  };

  resources: {
    /** Link preview lookup (title + image) for the "paste a URL" step. */
    preview(url: string): Promise<{ title: string; image?: string }>;
    list(communityId: string): Promise<CommunityResource[]>;
    create(
      communityId: string,
      input: { title: string; url: string; image?: string },
    ): Promise<CommunityResource>;
    update(
      communityId: string,
      resourceId: string,
      patch: Partial<Pick<CommunityResource, "title" | "url" | "image">>,
    ): Promise<CommunityResource>;
    remove(communityId: string, resourceId: string): Promise<void>;
  };

  announcements: {
    list(communityId: string): Promise<Announcement[]>;
    create(
      communityId: string,
      input: { title?: string; message: string },
    ): Promise<void>;
    remove(communityId: string, announcementId: string): Promise<void>;
  };
}
