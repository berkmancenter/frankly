import type {
  Announcement,
  Community,
  CommunityResource,
  DiscussionThread,
  DiscussionThreadComment,
  EmotionType,
  Event,
  MemberDetails,
  Me,
  Membership,
  NewEventInput,
  Participant,
  PublicUser,
  Template,
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
  };

  communities: {
    listMine(): Promise<Community[]>;
    getByDisplayId(displayId: string): Promise<Community>;
    follow(communityId: string): Promise<Membership>;
    unfollow(communityId: string): Promise<void>;
    listMembers(communityId: string): Promise<MemberDetails[]>;
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
  };

  events: {
    listUpcoming(communityId: string): Promise<Event[]>;
    listAll(communityId: string): Promise<Event[]>;
    create(input: NewEventInput): Promise<Event>;
    listParticipants(eventId: string): Promise<ParticipantWithUser[]>;
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
