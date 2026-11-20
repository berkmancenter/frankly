import {
  arrayRemove,
  arrayUnion,
  collection,
  collectionGroup,
  deleteDoc,
  deleteField,
  doc,
  getDoc,
  getDocs,
  limit,
  orderBy,
  query,
  runTransaction,
  serverTimestamp,
  setDoc,
  Timestamp,
  updateDoc,
  where,
  type DocumentData,
  type DocumentReference,
  type QueryDocumentSnapshot,
} from "firebase/firestore";
import { onAuthStateChanged } from "firebase/auth";
import { t } from "@lingui/core/macro";
import type { Api, ParticipantWithUser } from "./api";
import { ApiError } from "./api";
import type { FirebaseClient } from "./firebase";
import type {
  AgendaItem,
  AgendaItemType,
  Announcement,
  Community,
  CommunityResource,
  DiscussionThread,
  DiscussionThreadComment,
  EmotionType,
  Event,
  EventMessage,
  EventSettings,
  EventType,
  MemberDetails,
  Membership,
  MembershipStatus,
  NewEventInput,
  NotificationSettings,
  OnboardingStep,
  PrePostAttribute,
  PrePostCard,
  PrePostLink,
  Participant,
  ProfileUpdate,
  PublicUser,
  SocialLink,
  SurveyQuestion,
  Tag,
  Template,
  TemplateTag,
} from "./types";
import { DEFAULT_AGENDA_SECONDS } from "@/utils/agenda";
import {
  ALL_EVENT_SETTING_FLAGS,
  PRE_POST_ATTRIBUTES,
  SOCIAL_PLATFORMS,
} from "./types";

const membershipStatuses = new Set<MembershipStatus>([
  "owner",
  "admin",
  "moderator",
  "facilitator",
  "member",
  "banned",
  "nonmember",
  "attendee",
]);
const emotionTypes = new Set<EmotionType>([
  "thumbsUp",
  "heart",
  "hundred",
  "exclamation",
  "plusOne",
  "laughWithTears",
  "heartEyes",
]);
const onboardingSteps = new Set<OnboardingStep>([
  "brandSpace",
  "createTemplate",
  "hostEvent",
  "inviteSomeone",
]);
const memberStatuses = new Set<MembershipStatus>([
  "owner",
  "admin",
  "moderator",
  "facilitator",
  "member",
]);

function asRecord(value: unknown): Record<string, unknown> {
  if (typeof value !== "object" || value === null || Array.isArray(value)) {
    return {};
  }
  return value as Record<string, unknown>;
}

function stringValue(value: unknown): string | undefined {
  return typeof value === "string" ? value : undefined;
}

function stringArray(value: unknown): string[] {
  return Array.isArray(value)
    ? value.filter((item): item is string => typeof item === "string")
    : [];
}

function optionalBoolean(value: unknown, fallback: boolean): boolean {
  return typeof value === "boolean" ? value : fallback;
}

function optionalNumber(value: unknown, fallback: number): number {
  return typeof value === "number" && Number.isFinite(value) ? value : fallback;
}

function optionalIsoDate(value: unknown): string | undefined {
  if (value instanceof Timestamp) return value.toDate().toISOString();
  if (value instanceof Date) return value.toISOString();
  if (typeof value !== "string") return undefined;
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? undefined : date.toISOString();
}

function requiredString(value: unknown, field: string): string {
  const result = stringValue(value);
  if (!result) throw new ApiError("invalid", t`Invalid or missing ${field}`);
  return result;
}

async function requireUser(client: FirebaseClient) {
  await new Promise<void>((resolve) => {
    const unsubscribe = onAuthStateChanged(client.auth, () => {
      unsubscribe();
      resolve();
    });
  });
  const user = client.auth.currentUser;
  console.log("Current user:", user);
  if (!user)
    throw new ApiError("invalid", t`You must be signed in to continue.`);
  return user;
}

function mapPublicUser(
  userId: string,
  value: unknown,
  fallback?: PublicUser,
): PublicUser {
  const data = asRecord(value);
  return {
    id: userId,
    displayName:
      stringValue(data.displayName) ??
      fallback?.displayName ??
      // This is a fallback value, exempt it:
      // eslint-disable-next-line lingui/no-unlocalized-strings
      `User-${userId.slice(0, 4)}`,
    ...((stringValue(data.imageUrl) ?? fallback?.imageUrl)
      ? { imageUrl: stringValue(data.imageUrl) ?? fallback?.imageUrl }
      : {}),
    ...(stringValue(data.about) ? { about: stringValue(data.about) } : {}),
    ...(data.appRole === "owner" ? { isAppOwner: true } : {}),
    ...(socialLinks(data.socialMediaItems).length > 0
      ? { socialLinks: socialLinks(data.socialMediaItems) }
      : {}),
  };
}

// Social links are stored as `[{socialMediaKey, url}]`; unknown platforms and empty URLs are dropped.
function socialLinks(value: unknown): SocialLink[] {
  if (!Array.isArray(value)) return [];
  return value.flatMap((item) => {
    const { socialMediaKey, url } = asRecord(item);
    const platform = SOCIAL_PLATFORMS.find((known) => known === socialMediaKey);
    return platform && typeof url === "string" && url
      ? [{ platform, url }]
      : [];
  });
}

// An email setting is on unless it is explicitly `none`
const emailEnabled = (value: unknown) => value !== "none";
// Firestore field names, not UI text.
// eslint-disable-next-line lingui/no-unlocalized-strings
const emailType = (enabled: boolean) => (enabled ? "immediate" : "none");

const TAG_DEFINITIONS = "community-tag-definitions";
const TAGS = "community-tags";

// Tag definitions are shared across all items, so a lookup of the same id is made only once.
async function getTagDefinitions(
  client: FirebaseClient,
  ids: string[],
): Promise<Map<string, Tag>> {
  const unique = [...new Set(ids)];
  const found = await Promise.all(
    unique.map(async (id) => {
      const snapshot = await getDoc(doc(client.firestore, TAG_DEFINITIONS, id));
      const title = stringValue(snapshot.data()?.title);
      return title ? ([id, { id, title }] as const) : undefined;
    }),
  );
  return new Map(found.filter((entry) => !!entry));
}

// Firestore's "starts with" upper bound: the last character bumped by one.
const startsWithLimit = (text: string) =>
  text.slice(0, -1) +
  String.fromCodePoint((text.codePointAt(text.length - 1) ?? 0) + 1);

const normalizeSearchKey = (input: string) =>
  input.replace(/[^\w\s]+/g, "").toLowerCase();

function eventDocument(
  client: FirebaseClient,
  communityId: string,
  templateId: string,
  eventId: string,
) {
  return doc(
    client.firestore,
    "community",
    communityId,
    "templates",
    templateId,
    "events",
    eventId,
  );
}

function mapEventSettings(value: unknown): EventSettings | undefined {
  const data = asRecord(value);
  const settings: EventSettings = {};
  for (const flag of ALL_EVENT_SETTING_FLAGS) {
    if (typeof data[flag] === "boolean") settings[flag] = data[flag];
  }
  if (typeof data.autoEndGracePeriodMinutes === "number") {
    settings.autoEndGracePeriodMinutes = data.autoEndGracePeriodMinutes;
  }
  return Object.keys(settings).length > 0 ? settings : undefined;
}

// Communities that predate event settings keep them as feature flags.
function communityEventSettings(
  data: Record<string, unknown>,
  flags: string[],
): EventSettings {
  return (
    mapEventSettings(data.eventSettings) ?? {
      chat: flags.includes("chat"),
      alwaysRecord: flags.includes("alwaysRecord"),
      showChatMessagesInRealTime: true,
      talkingTimer: true,
      agendaPreview: true,
    }
  );
}

const agendaItemTypes = new Set<AgendaItemType>([
  "text",
  "video",
  "image",
  "poll",
  "wordCloud",
  "userSuggestions",
]);

function mapAgendaItems(value: unknown): AgendaItem[] {
  if (!Array.isArray(value)) return [];
  return value.flatMap((raw): AgendaItem[] => {
    const item = asRecord(raw);
    const id = stringValue(item.id);
    if (!id) return [];
    const type =
      id === "user-submitted"
        ? "userSuggestions"
        : agendaItemTypes.has(item.type as AgendaItemType)
          ? (item.type as AgendaItemType)
          : "text";
    return [
      {
        id,
        type,
        ...(stringValue(item.title) ? { title: stringValue(item.title) } : {}),
        ...(stringValue(item.content)
          ? { content: stringValue(item.content) }
          : {}),
        ...(stringValue(item.imageUrl)
          ? { imageUrl: stringValue(item.imageUrl) }
          : {}),
        ...(item.videoType === "youtube" ||
        item.videoType === "vimeo" ||
        item.videoType === "url"
          ? { videoType: item.videoType }
          : {}),
        ...(stringValue(item.videoUrl)
          ? { videoUrl: stringValue(item.videoUrl) }
          : {}),
        ...(Array.isArray(item.pollAnswers)
          ? { pollAnswers: stringArray(item.pollAnswers) }
          : {}),
        ...(typeof item.timeInSeconds === "number"
          ? { timeInSeconds: item.timeInSeconds }
          : {}),
      },
    ];
  });
}

function mapBreakout(value: unknown): Event["breakout"] {
  if (typeof value !== "object" || value === null) return undefined;
  const data = asRecord(value);
  return {
    assignmentMethod:
      data.assignmentMethod === "smartMatch" ? "smartMatch" : "targetPerRoom",
    targetParticipants: optionalNumber(data.targetParticipants, 8),
  };
}

function mapSurveyQuestions(value: unknown): SurveyQuestion[] | undefined {
  const questions = asRecord(value).breakoutQuestions;
  if (!Array.isArray(questions) || questions.length === 0) return undefined;
  return questions.flatMap((raw): SurveyQuestion[] => {
    const question = asRecord(raw);
    const id = stringValue(question.id);
    const title = stringValue(question.title);
    if (!id || !title) return [];
    const structured = (
      Array.isArray(question.answers) ? question.answers : []
    ).flatMap((raw) => {
      const answer = asRecord(raw);
      const answerId = stringValue(answer.id);
      if (!answerId || !Array.isArray(answer.options)) return [];
      const options = answer.options.flatMap((option) => {
        const { id: optionId, title: optionTitle } = asRecord(option);
        return stringValue(optionId)
          ? [
              {
                id: stringValue(optionId)!,
                title: stringValue(optionTitle) ?? "",
              },
            ]
          : [];
      });
      return [{ id: answerId, options }];
    });
    return [
      {
        id,
        title,
        type: question.type === "freeText" ? "freeText" : "multipleChoice",
        options: structured.flatMap((answer) => answer.options),
        answers: structured,
      },
    ];
  });
}

function mapPrePostCard(value: unknown): PrePostCard | undefined {
  const data = asRecord(value);
  if (Object.keys(data).length === 0) return undefined;
  const urls = Array.isArray(data.prePostUrls) ? data.prePostUrls : [];
  return {
    headline: stringValue(data.headline) ?? "",
    message: stringValue(data.message) ?? "",
    links: urls.map((raw): PrePostLink => {
      const link = asRecord(raw);
      const attributes = Array.isArray(link.attributes) ? link.attributes : [];
      return {
        ...(stringValue(link.buttonText)
          ? { buttonText: stringValue(link.buttonText) }
          : {}),
        ...(stringValue(link.surveyUrl)
          ? { url: stringValue(link.surveyUrl) }
          : {}),
        attributes: attributes.flatMap((attribute) => {
          const { type, queryParam } = asRecord(attribute);
          return PRE_POST_ATTRIBUTES.includes(type as PrePostAttribute)
            ? [
                {
                  type: type as PrePostAttribute,
                  queryParam: stringValue(queryParam) ?? "",
                },
              ]
            : [];
        }),
      };
    }),
  };
}

function storedCard(card: PrePostCard, type: "preEvent" | "postEvent") {
  return {
    headline: card.headline,
    message: card.message,
    type,
    prePostUrls: card.links.map((link) => ({
      buttonText: link.buttonText ?? null,
      surveyUrl: link.url ?? null,
      attributes: link.attributes,
    })),
  };
}

// Stored field names and values, not UI text.
/* eslint-disable lingui/no-unlocalized-strings */
function storedAgendaItem(
  item: AgendaItem,
  previous?: Record<string, unknown>,
) {
  return {
    ...previous,
    id: item.id,
    type: item.type,
    title: item.title ?? "",
    content: item.content ?? "",
    videoType: item.videoType ?? "url",
    videoUrl: item.videoUrl ?? "",
    imageUrl: item.imageUrl ?? "",
    pollAnswers: item.pollAnswers ?? [],
    timeInSeconds: item.timeInSeconds ?? DEFAULT_AGENDA_SECONDS,
    suggestionsButtonText: "",
  };
}

/* eslint-enable lingui/no-unlocalized-strings */

// Reads the stored agenda, lets `edit` change it, and writes it back in one transaction. Steps `edit` leaves
// alone are written back exactly as stored, so fields this app does not show are never lost.
async function editAgenda(
  client: FirebaseClient,
  reference: DocumentReference,
  edit: (items: Record<string, unknown>[]) => Record<string, unknown>[],
) {
  await runTransaction(client.firestore, async (transaction) => {
    const snapshot = await transaction.get(reference);
    const stored = snapshot.data()?.agendaItems;
    const items = Array.isArray(stored) ? stored.map(asRecord) : [];
    transaction.update(reference, { agendaItems: edit(items) });
  });
}

const upsertStep = (item: AgendaItem) => (items: Record<string, unknown>[]) => {
  const index = items.findIndex((existing) => existing.id === item.id);
  return index < 0
    ? [...items, storedAgendaItem(item)]
    : items.map((existing, i) =>
        i === index ? storedAgendaItem(item, existing) : existing,
      );
};

const deleteStep = (itemId: string) => (items: Record<string, unknown>[]) =>
  items.filter((existing) => existing.id !== itemId);

const reorderSteps = (ids: string[]) => (items: Record<string, unknown>[]) => {
  const byId = new Map(
    items.map((existing) => [existing.id as string, existing]),
  );
  if (ids.length !== items.length || !ids.every((id) => byId.has(id))) {
    throw new ApiError(
      "invalid",
      t`Error in updating agenda ordering. Please refresh.`,
    );
  }
  return ids.map((id) => byId.get(id)!);
};

// Sets up the streaming service for a livestream event: the public ids go on the event, and the stream's address and
// key go in a private document that only the host can read.
async function provisionLiveStream(
  client: FirebaseClient,
  communityId: string,
) {
  const response = asRecord(
    await client.functions.call("CreateLiveStream", { communityId }),
  );
  const muxId = stringValue(response.muxId);
  const muxPlaybackId = stringValue(response.muxPlaybackId);
  if (!muxId || !muxPlaybackId) {
    throw new ApiError("invalid", t`The live stream could not be set up.`);
  }
  return {
    liveStreamInfo: { muxId, muxPlaybackId },
    privateInfo: {
      streamServerUrl: stringValue(response.streamServerUrl) ?? "",
      streamKey: stringValue(response.streamKey) ?? "",
    },
  };
}

const savePrivateLiveStreamInfo = (
  reference: DocumentReference,
  info: { streamServerUrl: string; streamKey: string },
) => setDoc(doc(reference, "private-live-stream-info", reference.id), info);

// Changes some fields of the event's breakout definition, in one transaction. With no definition yet, the defaults
// are stored along with the change; otherwise only the given fields are touched.
async function editBreakouts(
  client: FirebaseClient,
  event: Event,
  fields: Record<string, unknown>,
) {
  const user = await requireUser(client);
  const reference = eventDocument(
    client,
    event.communityId,
    event.templateId,
    event.id,
  );
  await runTransaction(client.firestore, async (transaction) => {
    const snapshot = await transaction.get(reference);
    const definition = snapshot.data()?.breakoutRoomDefinition;
    if (definition && typeof definition === "object") {
      transaction.update(
        reference,
        Object.fromEntries(
          // Firestore field paths, not UI text.
          /* eslint-disable lingui/no-unlocalized-strings */
          Object.entries(fields).map(([key, value]) => [
            `breakoutRoomDefinition.${key}`,
            /* eslint-enable lingui/no-unlocalized-strings */
            value,
          ]),
        ),
      );
    } else {
      transaction.update(reference, {
        breakoutRoomDefinition: {
          creatorId: user.uid,
          targetParticipants: 8,
          breakoutQuestions: [],
          categories: [],
          // Stored value, not UI text.

          assignmentMethod: "targetPerRoom",
          ...fields,
        },
      });
    }
  });
}

function templateDocument(
  client: FirebaseClient,
  communityId: string,
  templateId: string,
) {
  return doc(
    client.firestore,
    "community",
    communityId,
    "templates",
    templateId,
  );
}

function mapNotificationSettings(value: unknown): NotificationSettings {
  const data = asRecord(value);
  return {
    notifyAnnouncements: emailEnabled(data.notifyAnnouncements),
    notifyEvents: emailEnabled(data.notifyEvents),
  };
}

/**
 * The server turned the request down, as opposed to failing. The SDK reports `functions/failed-precondition`;
 * the same-origin path reports the HTTP status name, `FAILED_PRECONDITION`.
 */
function isCallableRefusal(error: unknown): error is Error {
  const code = (error as { code?: unknown } | null)?.code;
  return (
    error instanceof Error &&
    typeof code === "string" &&
    /(^|\/)(failed-precondition|invalid-argument)$/.test(
      code.toLowerCase().replaceAll("_", "-"),
    )
  );
}

async function getPublicUser(
  client: FirebaseClient,
  userId: string,
  fallback?: PublicUser,
): Promise<PublicUser> {
  const snapshot = await getDoc(doc(client.firestore, "publicUser", userId));
  return mapPublicUser(userId, snapshot.data(), fallback);
}

function mapMembership(
  userId: string,
  communityId: string,
  value: unknown,
): Membership {
  const data = asRecord(value);
  const rawStatus = stringValue(data.status);
  const status =
    rawStatus && membershipStatuses.has(rawStatus as MembershipStatus)
      ? (rawStatus as MembershipStatus)
      : "nonmember";
  const requestStatus = stringValue(data.requestStatus);
  return {
    userId: stringValue(data.userId) ?? userId,
    communityId: stringValue(data.communityId) ?? communityId,
    status,
    ...(requestStatus === "pending" ||
    requestStatus === "approved" ||
    requestStatus === "denied"
      ? { requestStatus }
      : {}),
  };
}

function mapCommunity(id: string, value: unknown): Community {
  const data = asRecord(value);
  const flags = stringArray(data.enabledFeatureFlags);
  const rawSettings = asRecord(data.communitySettings);
  const boolSetting = (key: string, defaultValue: boolean) =>
    optionalBoolean(rawSettings[key], flags.includes(key) || defaultValue);
  const displayIds = stringArray(data.displayIds);

  return {
    id,
    displayId: displayIds[0] ?? id,
    name: requiredString(data.name, "community name"),
    ...(stringValue(data.tagLine)
      ? { tagLine: stringValue(data.tagLine) }
      : {}),
    ...(stringValue(data.description)
      ? { description: stringValue(data.description) }
      : {}),
    ...(stringValue(data.contactEmail)
      ? { contactEmail: stringValue(data.contactEmail) }
      : {}),
    ...(stringValue(data.profileImageUrl)
      ? { profileImageUrl: stringValue(data.profileImageUrl) }
      : {}),
    isPublic: optionalBoolean(data.isPublic, false),
    ...(stringValue(data.themeLightColor)
      ? { themeLightColor: stringValue(data.themeLightColor) }
      : {}),
    ...(stringValue(data.themeDarkColor)
      ? { themeDarkColor: stringValue(data.themeDarkColor) }
      : {}),
    creatorId: requiredString(data.creatorId, "community creator ID"),
    ...(optionalIsoDate(data.createdDate)
      ? { createdDate: optionalIsoDate(data.createdDate) }
      : {}),
    settings: {
      allowDonations: boolSetting("allowDonations", true),
      allowUnofficialTemplates: boolSetting("allowUnofficialTemplates", false),
      dontAllowMembersToCreateMeetings: boolSetting(
        "dontAllowMembersToCreateMeetings",
        true,
      ),
      enableDiscussionThreads: boolSetting("enableDiscussionThreads", true),
      requireApprovalToJoin: boolSetting("requireApprovalToJoin", false),
      enableHostless: boolSetting("enableHostless", true),
    },
    eventSettings: communityEventSettings(data, flags),
    onboardingSteps: stringArray(data.onboardingSteps).filter(
      (step): step is OnboardingStep =>
        onboardingSteps.has(step as OnboardingStep),
    ),
    allowAdditionalRegistrationField: stringArray(data.internalFlags).includes(
      "allowAdditionalRegistrationField",
    ),
    isOnboardingOverviewEnabled: optionalBoolean(
      data.isOnboardingOverviewEnabled,
      false,
    ),
  };
}

function mapTemplate(
  id: string,
  communityId: string,
  value: unknown,
): Template {
  const data = asRecord(value);
  return {
    id,
    communityId,
    title: requiredString(data.title, "template title"),
    ...(stringValue(data.description)
      ? { description: stringValue(data.description) }
      : {}),
    ...(stringValue(data.category)
      ? { category: stringValue(data.category) }
      : {}),
    ...(stringValue(data.image) ? { image: stringValue(data.image) } : {}),
    status: data.status === "removed" ? "removed" : "active",
    creatorId: stringValue(data.creatorId) ?? "",
    ...(stringValue(data.prerequisiteTemplateId)
      ? { prerequisiteTemplateId: stringValue(data.prerequisiteTemplateId) }
      : {}),
    orderingPriority: optionalNumber(data.orderingPriority, 0),
    agendaItems: mapAgendaItems(data.agendaItems),
    ...(mapPrePostCard(data.preEventCardData)
      ? { preEventCard: mapPrePostCard(data.preEventCardData) }
      : {}),
    ...(mapPrePostCard(data.postEventCardData)
      ? { postEventCard: mapPrePostCard(data.postEventCardData) }
      : {}),
    ...(mapEventSettings(data.eventSettings)
      ? { eventSettings: mapEventSettings(data.eventSettings) }
      : {}),
    ...(optionalIsoDate(data.createdDate)
      ? { createdDate: optionalIsoDate(data.createdDate) }
      : {}),
  };
}

function mapEvent(
  id: string,
  value: unknown,
  communityDisplayId: string,
): Event {
  const data = asRecord(value);
  const eventType = stringValue(data.eventType);
  const validEventType: EventType =
    eventType === "hostless" || eventType === "livestream"
      ? eventType
      : data.liveStreamInfo != null
        ? "livestream"
        : "hosted";
  return {
    id,
    communityId: requiredString(data.communityId, "event community ID"),
    communityDisplayId,
    templateId: requiredString(data.templateId, "event template ID"),
    creatorId: requiredString(data.creatorId, "event creator ID"),
    status: data.status === "canceled" ? "canceled" : "active",
    eventType: validEventType,
    ...(stringValue(data.title) ? { title: stringValue(data.title) } : {}),
    ...(stringValue(data.description)
      ? { description: stringValue(data.description) }
      : {}),
    ...(stringValue(data.image) ? { image: stringValue(data.image) } : {}),
    ...(optionalIsoDate(data.scheduledTime)
      ? { scheduledTime: optionalIsoDate(data.scheduledTime) }
      : {}),
    ...(optionalIsoDate(data.endedAt)
      ? { endedAt: optionalIsoDate(data.endedAt) }
      : {}),
    durationInMinutes: optionalNumber(data.durationInMinutes, 60),
    isPublic: optionalBoolean(data.isPublic, false),
    ...(stringValue(data.prerequisiteTemplateId)
      ? { prerequisiteTemplateId: stringValue(data.prerequisiteTemplateId) }
      : {}),
    isLocked: optionalBoolean(data.isLocked, false),
    agendaItems: mapAgendaItems(data.agendaItems),
    hasLiveStream:
      typeof data.liveStreamInfo === "object" && data.liveStreamInfo !== null,
    ...(mapBreakout(data.breakoutRoomDefinition)
      ? { breakout: mapBreakout(data.breakoutRoomDefinition) }
      : {}),
    ...(mapSurveyQuestions(data.breakoutRoomDefinition)
      ? { surveyQuestions: mapSurveyQuestions(data.breakoutRoomDefinition) }
      : {}),
    ...(mapPrePostCard(data.preEventCardData)
      ? { preEventCard: mapPrePostCard(data.preEventCardData) }
      : {}),
    ...(mapPrePostCard(data.postEventCardData)
      ? { postEventCard: mapPrePostCard(data.postEventCardData) }
      : {}),
    ...(mapEventSettings(data.eventSettings)
      ? { eventSettings: mapEventSettings(data.eventSettings) }
      : {}),
    ...(typeof data.maxParticipants === "number"
      ? { maxParticipants: data.maxParticipants }
      : {}),
    ...(typeof data.participantCountEstimate === "number"
      ? { participantCountEstimate: data.participantCountEstimate }
      : {}),
    ...(typeof data.registrationCount === "number"
      ? { registrationCount: data.registrationCount }
      : {}),
    ...(typeof data.presentParticipantCountEstimate === "number"
      ? {
          presentParticipantCountEstimate: data.presentParticipantCountEstimate,
        }
      : {}),
    ...(optionalIsoDate(data.createdDate)
      ? { createdDate: optionalIsoDate(data.createdDate) }
      : {}),
  };
}

function mapEmotions(value: unknown): DiscussionThread["emotions"] {
  if (!Array.isArray(value)) return [];
  return value.flatMap((item) => {
    const data = asRecord(item);
    const userId = stringValue(data.creatorId) ?? stringValue(data.userId);
    const emotion = stringValue(data.emotionType) ?? stringValue(data.emotion);
    return userId && emotion && emotionTypes.has(emotion as EmotionType)
      ? [{ userId, emotion: emotion as EmotionType }]
      : [];
  });
}

function mapThread(
  id: string,
  communityId: string,
  value: unknown,
): DiscussionThread {
  const data = asRecord(value);
  return {
    id,
    communityId,
    creatorId: requiredString(data.creatorId, "post creator ID"),
    ...(optionalIsoDate(data.createdAt)
      ? { createdAt: optionalIsoDate(data.createdAt) }
      : {}),
    ...(stringValue(data.title) ? { title: stringValue(data.title) } : {}),
    content: requiredString(data.content, "post content"),
    ...(stringValue(data.imageUrl)
      ? { imageUrl: stringValue(data.imageUrl) }
      : {}),
    likedBy: stringArray(data.likedByIds ?? data.likedBy),
    dislikedBy: stringArray(data.dislikedByIds ?? data.dislikedBy),
    emotions: mapEmotions(data.emotions),
    commentCount: optionalNumber(data.commentCount, 0),
  };
}

function mapComment(
  id: string,
  threadId: string,
  value: unknown,
): DiscussionThreadComment {
  const data = asRecord(value);
  return {
    id,
    threadId,
    creatorId: requiredString(data.creatorId, "comment creator ID"),
    ...(optionalIsoDate(data.createdAt)
      ? { createdAt: optionalIsoDate(data.createdAt) }
      : {}),
    comment: requiredString(data.comment, "comment"),
    ...(stringValue(data.replyToCommentId)
      ? { replyToCommentId: stringValue(data.replyToCommentId) }
      : {}),
    ...(optionalBoolean(data.isDeleted ?? data.deleted, false)
      ? { deleted: true }
      : {}),
    emotions: mapEmotions(data.emotions),
  };
}

function mapResource(
  id: string,
  communityId: string,
  value: unknown,
): CommunityResource {
  const data = asRecord(value);
  return {
    id,
    communityId,
    title: requiredString(data.title, "resource title"),
    url: requiredString(data.url, "resource URL"),
    ...(stringValue(data.image) ? { image: stringValue(data.image) } : {}),
    ...(optionalIsoDate(data.createdDate)
      ? { createdDate: optionalIsoDate(data.createdDate) }
      : {}),
  };
}

function mapAnnouncement(
  id: string,
  communityId: string,
  value: unknown,
): Announcement {
  const data = asRecord(value);
  return {
    id,
    communityId,
    ...(stringValue(data.title) ? { title: stringValue(data.title) } : {}),
    message: requiredString(data.message, "announcement message"),
    creatorId: requiredString(data.creatorId, "announcement creator ID"),
    ...(optionalIsoDate(data.createdDate)
      ? { createdDate: optionalIsoDate(data.createdDate) }
      : {}),
  };
}

function requiredReference(
  snapshot: QueryDocumentSnapshot<DocumentData> | undefined,
  entity: string,
): DocumentReference<DocumentData> {
  if (!snapshot) throw new ApiError("notFound", t`${entity} not found`);
  return snapshot.ref;
}

async function findCollectionGroupDocument(
  client: FirebaseClient,
  collectionName: string,
  id: string,
): Promise<DocumentReference<DocumentData>> {
  const matches = await getDocs(
    query(
      collectionGroup(client.firestore, collectionName),
      where("id", "==", id),
      limit(1),
    ),
  );
  return requiredReference(matches.docs[0], collectionName);
}

async function getThreadReference(
  client: FirebaseClient,
  threadId: string,
): Promise<DocumentReference<DocumentData>> {
  return findCollectionGroupDocument(client, "discussion-threads", threadId);
}

async function getCommunity(
  client: FirebaseClient,
  communityId: string,
): Promise<Community> {
  const snapshot = await getDoc(
    doc(client.firestore, "community", communityId),
  );
  if (!snapshot.exists())
    throw new ApiError("notFound", t`Community not found`);
  return mapCommunity(snapshot.id, snapshot.data());
}

function mapParticipant(
  snapshot: QueryDocumentSnapshot<DocumentData>,
  eventId: string,
): Participant {
  const data = snapshot.data();
  const status = stringValue(data.status);
  return {
    userId: stringValue(data.id) ?? snapshot.id,
    eventId,
    status: status === "canceled" || status === "banned" ? status : "active",
    isPresent: optionalBoolean(data.isPresent, false),
    ...(optionalIsoDate(data.createdDate)
      ? { createdDate: optionalIsoDate(data.createdDate) }
      : {}),
  };
}

export function createFirebaseApi(client: FirebaseClient): Api {
  const api: Api = {
    me: {
      async get() {
        const user = await requireUser(client);
        const membershipSnapshot = await getDocs(
          collection(
            client.firestore,
            "memberships",
            user.uid,
            "community-membership",
          ),
        );
        const userFallback: PublicUser = {
          id: user.uid,
          // This is a fallback value, exempt it:
          // eslint-disable-next-line lingui/no-unlocalized-strings
          displayName: user.displayName ?? `User-${user.uid.slice(0, 4)}`,
          ...(user.photoURL ? { imageUrl: user.photoURL } : {}),
        };
        const [publicUser, memberships] = await Promise.all([
          getPublicUser(client, user.uid, userFallback),
          membershipSnapshot.docs.map((membership) =>
            mapMembership(user.uid, membership.id, membership.data()),
          ),
        ]);
        return { user: publicUser, memberships };
      },
    },

    users: {
      async get(userId) {
        await requireUser(client);
        const snapshot = await getDoc(
          doc(client.firestore, "publicUser", userId),
        );
        if (!snapshot.exists()) {
          return mapPublicUser(userId, undefined);
        }
        return mapPublicUser(userId, snapshot.data());
      },

      async email(userId, communityId) {
        const user = await requireUser(client);
        if (user.uid === userId) return user.email ?? undefined;
        const response = asRecord(
          await client.functions.call("GetUserAdminDetails", {
            userIds: [userId],
            ...(communityId ? { communityId } : {}),
          }),
        );
        const details = Array.isArray(response.userAdminDetails)
          ? response.userAdminDetails
          : [];
        const match =
          details.map(asRecord).find((detail) => detail.userId === userId) ??
          asRecord(details[0]);
        return stringValue(match.email);
      },

      async updateMe(patch: ProfileUpdate) {
        const user = await requireUser(client);
        const reference = doc(client.firestore, "publicUser", user.uid);
        const changes: DocumentData = {
          ...(patch.displayName !== undefined
            ? { displayName: patch.displayName }
            : {}),
          ...(patch.about !== undefined ? { about: patch.about } : {}),
          ...(patch.imageUrl !== undefined ? { imageUrl: patch.imageUrl } : {}),
          ...(patch.socialLinks !== undefined
            ? {
                socialMediaItems: patch.socialLinks.map(
                  ({ platform, url }) => ({
                    socialMediaKey: platform,
                    url,
                  }),
                ),
              }
            : {}),
        };
        // `merge` creates the document when the user never had one.
        await setDoc(reference, changes, { merge: true });
        return mapPublicUser(user.uid, (await getDoc(reference)).data());
      },
    },

    tags: {
      async listForTemplates(communityId) {
        await requireUser(client);
        const snapshots = await getDocs(
          query(
            collectionGroup(client.firestore, TAGS),
            where("communityId", "==", communityId),
            where("taggedItemType", "==", "template"),
          ),
        );
        const assignments = snapshots.docs.flatMap((snapshot) => {
          const data = snapshot.data();
          const templateId = stringValue(data.taggedItemId);
          const definitionId = stringValue(data.definitionId);
          return templateId && definitionId
            ? [{ templateId, definitionId }]
            : [];
        });
        const definitions = await getTagDefinitions(
          client,
          assignments.map((assignment) => assignment.definitionId),
        );
        return assignments.flatMap(
          ({ templateId, definitionId }): TemplateTag[] => {
            const tag = definitions.get(definitionId);
            return tag ? [{ templateId, tag }] : [];
          },
        );
      },

      async listForUser(userId) {
        await requireUser(client);
        const snapshots = await getDocs(
          collection(client.firestore, "publicUser", userId, TAGS),
        );
        const ids = snapshots.docs.flatMap(
          (snapshot) => stringValue(snapshot.data().definitionId) ?? [],
        );
        const definitions = await getTagDefinitions(client, ids);
        return ids.flatMap((id) => definitions.get(id) ?? []);
      },

      async suggest(input) {
        await requireUser(client);
        const key = normalizeSearchKey(input);
        if (!key) return [];
        const snapshots = await getDocs(
          query(
            collection(client.firestore, TAG_DEFINITIONS),
            where("searchKey", ">=", key),
            where("searchKey", "<", startsWithLimit(key)),
            limit(20),
          ),
        );
        return snapshots.docs.flatMap((snapshot) => {
          const title = stringValue(snapshot.data().title);
          return title ? [{ id: snapshot.id, title }] : [];
        });
      },

      async addToMyProfile(title) {
        const user = await requireUser(client);
        const clean = title.trim();
        const existing = await getDocs(
          query(
            collection(client.firestore, TAG_DEFINITIONS),
            where("title", "==", clean),
            limit(1),
          ),
        );
        let id = existing.docs[0]?.id;
        if (!id) {
          const reference = doc(collection(client.firestore, TAG_DEFINITIONS));
          await setDoc(reference, {
            id: reference.id,
            title: clean,
            searchKey: normalizeSearchKey(clean),
          });
          id = reference.id;
        }
        await setDoc(doc(client.firestore, "publicUser", user.uid, TAGS, id), {
          // eslint-disable-next-line lingui/no-unlocalized-strings -- Firestore enum value, not UI text
          taggedItemType: "profile",
          taggedItemId: user.uid,
          definitionId: id,
        });
        return { id, title: clean };
      },

      async removeFromMyProfile(tagId) {
        const user = await requireUser(client);
        await deleteDoc(
          doc(client.firestore, "publicUser", user.uid, TAGS, tagId),
        );
      },
    },

    notifications: {
      async get(communityId) {
        const user = await requireUser(client);
        const snapshot = await getDoc(
          doc(
            client.firestore,
            "privateUserData",
            user.uid,
            "communityUserSettings",
            communityId,
          ),
        );
        return mapNotificationSettings(snapshot.data());
      },

      async update(communityId, patch) {
        const user = await requireUser(client);
        const reference = doc(
          client.firestore,
          "privateUserData",
          user.uid,
          "communityUserSettings",
          communityId,
        );
        await setDoc(
          reference,
          {
            userId: user.uid,
            communityId,
            ...(patch.notifyAnnouncements !== undefined
              ? { notifyAnnouncements: emailType(patch.notifyAnnouncements) }
              : {}),
            ...(patch.notifyEvents !== undefined
              ? { notifyEvents: emailType(patch.notifyEvents) }
              : {}),
          },
          { merge: true },
        );
        return mapNotificationSettings((await getDoc(reference)).data());
      },
    },

    communities: {
      async listMine() {
        const user = await requireUser(client);
        const memberships = await getDocs(
          collection(
            client.firestore,
            "memberships",
            user.uid,
            "community-membership",
          ),
        );
        const memberIds = memberships.docs
          .map((membership) =>
            mapMembership(user.uid, membership.id, membership.data()),
          )
          .filter((membership) => memberStatuses.has(membership.status))
          .map((membership) => membership.communityId);
        const communities = await Promise.all(
          memberIds.map(async (communityId) => {
            const snapshot = await getDoc(
              doc(client.firestore, "community", communityId),
            );
            return snapshot.exists()
              ? mapCommunity(snapshot.id, snapshot.data())
              : undefined;
          }),
        );
        return communities.filter(
          (community): community is Community => !!community,
        );
      },

      async getByDisplayId(displayId) {
        await requireUser(client);
        const matches = await getDocs(
          query(
            collection(client.firestore, "community"),
            where("displayIds", "array-contains", displayId),
            limit(1),
          ),
        );
        if (matches.docs[0]) {
          return mapCommunity(matches.docs[0].id, matches.docs[0].data());
        }
        const byId = await getDoc(
          doc(client.firestore, "community", displayId),
        );
        if (!byId.exists())
          throw new ApiError("notFound", t`Community not found`);
        return mapCommunity(byId.id, byId.data());
      },

      async follow(communityId) {
        const user = await requireUser(client);
        await client.functions.call("updateMembership", {
          communityId,
          userId: user.uid,
          status: "member",
          invisible: null,
        });
        const snapshot = await getDoc(
          doc(
            client.firestore,
            "memberships",
            user.uid,
            "community-membership",
            communityId,
          ),
        );
        if (!snapshot.exists()) {
          throw new ApiError("invalid", t`Membership update was not saved`);
        }
        return mapMembership(user.uid, communityId, snapshot.data());
      },

      async unfollow(communityId) {
        const user = await requireUser(client);
        await client.functions.call("updateMembership", {
          communityId,
          userId: user.uid,
          status: "nonmember",
          invisible: null,
        });
        await deleteDoc(
          doc(
            client.firestore,
            "community",
            communityId,
            "join-requests",
            user.uid,
          ),
        );
      },

      async create({ name, displayId, isPublic }) {
        await requireUser(client);
        // The server assigns the real id; the client sends one only because the model requires it.
        const draftId = doc(collection(client.firestore, "community")).id;
        try {
          const response = await client.functions.call<
            { community: Record<string, unknown> },
            { communityId: string }
          >("createCommunity", {
            community: {
              id: draftId,
              name: name.trim(),
              displayIds: displayId ? [displayId] : [],
              isPublic,
              isOnboardingOverviewEnabled: true,
            },
          });
          return {
            communityId: response.communityId,
            displayId: displayId || response.communityId,
          };
        } catch (error) {
          if (isCallableRefusal(error)) {
            throw new ApiError("invalid", error.message);
          }
          throw error;
        }
      },

      async listMembers(communityId) {
        await requireUser(client);
        const membershipDocs = await getDocs(
          query(
            collectionGroup(client.firestore, "community-membership"),
            where("communityId", "==", communityId),
          ),
        );
        const userIds = membershipDocs.docs.map((membership) => {
          const value = asRecord(membership.data());
          const pathUserId = membership.ref.path.split("/")[1];
          return stringValue(value.userId) ?? pathUserId;
        });
        if (userIds.some((userId) => !userId)) {
          throw new ApiError(
            "invalid",
            "A community membership has no user ID",
          );
        }
        const response = asRecord(
          await client.functions.call("GetMembersData", {
            communityId,
            userIds,
          }),
        );
        if (!Array.isArray(response.membersDetailsList)) {
          throw new ApiError(
            "invalid",
            "GetMembersData returned an invalid response",
          );
        }
        const details = response.membersDetailsList;
        return Promise.all(
          details.map(async (value): Promise<MemberDetails> => {
            const detail = asRecord(value);
            const userId = requiredString(detail.id, "member user ID");
            const membership = mapMembership(
              userId,
              communityId,
              detail.membership,
            );
            return {
              user: await getPublicUser(client, userId),
              membership,
            };
          }),
        );
      },

      async prePostEnabled(communityId) {
        const response = asRecord(
          await client.functions.call("GetCommunityPrePostEnabled", {
            communityId,
          }),
        );
        return response.prePostEnabled === true;
      },

      async donationsEnabled(communityId) {
        const response = asRecord(
          await client.functions.call("GetCommunityDonationsEnabled", {
            communityId,
          }),
        );
        if (typeof response.donationsEnabled !== "boolean") {
          throw new ApiError(
            "invalid",
            "GetCommunityDonationsEnabled returned an invalid response",
          );
        }
        return response.donationsEnabled;
      },
    },

    templates: {
      async get(communityId, templateId) {
        await requireUser(client);
        const snapshot = await getDoc(
          templateDocument(client, communityId, templateId),
        );
        if (!snapshot.exists())
          throw new ApiError("notFound", t`This template was not found.`);
        return mapTemplate(snapshot.id, communityId, snapshot.data());
      },

      async updatePrePost(template, which, card) {
        await requireUser(client);
        await updateDoc(
          templateDocument(client, template.communityId, template.id),
          {
            // Firestore field names, not UI text.

            [which === "pre" ? "preEventCardData" : "postEventCardData"]: card
              ? storedCard(card, which === "pre" ? "preEvent" : "postEvent")
              : deleteField(),
          },
        );
      },

      async upsertAgendaItem(template, item) {
        await requireUser(client);
        await editAgenda(
          client,
          templateDocument(client, template.communityId, template.id),
          upsertStep(item),
        );
      },

      async deleteAgendaItem(template, itemId) {
        await requireUser(client);
        await editAgenda(
          client,
          templateDocument(client, template.communityId, template.id),
          deleteStep(itemId),
        );
      },

      async reorderAgenda(template, ids) {
        await requireUser(client);
        await editAgenda(
          client,
          templateDocument(client, template.communityId, template.id),
          reorderSteps(ids),
        );
      },

      async clearAgenda(template) {
        await requireUser(client);
        await updateDoc(
          templateDocument(client, template.communityId, template.id),
          { agendaItems: [] },
        );
      },

      async list(communityId) {
        await requireUser(client);
        const snapshots = await getDocs(
          collection(client.firestore, "community", communityId, "templates"),
        );
        return snapshots.docs
          .map((snapshot) =>
            mapTemplate(snapshot.id, communityId, snapshot.data()),
          )
          .filter((template) => template.status !== "removed")
          .sort(
            (left, right) => left.orderingPriority - right.orderingPriority,
          );
      },
    },

    events: {
      async listUpcoming(communityId) {
        const events = await api.events.listAll(communityId);
        const now = Date.now() - 15 * 60_000;
        return events.filter(
          (event) =>
            event.status === "active" &&
            event.isPublic &&
            !event.endedAt &&
            event.scheduledTime &&
            Date.parse(event.scheduledTime) >= now,
        );
      },

      async listAll(communityId) {
        await requireUser(client);
        const [snapshots, community] = await Promise.all([
          getDocs(
            query(
              collectionGroup(client.firestore, "events"),
              where("communityId", "==", communityId),
            ),
          ),
          getCommunity(client, communityId),
        ]);
        return snapshots.docs
          .map((snapshot) =>
            mapEvent(snapshot.id, snapshot.data(), community.displayId),
          )
          .filter((event) => event.status === "active")
          .sort(
            (left, right) =>
              Date.parse(right.scheduledTime ?? "") -
              Date.parse(left.scheduledTime ?? ""),
          );
      },

      async listForTemplate(communityId, templateId) {
        await requireUser(client);
        const [snapshots, community] = await Promise.all([
          getDocs(
            query(
              collection(
                client.firestore,
                "community",
                communityId,
                "templates",
                templateId,
                "events",
              ),
              where("isPublic", "==", true),
              where(
                "scheduledTime",
                ">",
                Timestamp.fromMillis(Date.now() - 15 * 60_000),
              ),
              orderBy("scheduledTime"),
            ),
          ),
          getCommunity(client, communityId),
        ]);
        return snapshots.docs
          .map((snapshot) =>
            mapEvent(snapshot.id, snapshot.data(), community.displayId),
          )
          .filter((event) => event.status === "active");
      },

      async listMine() {
        const user = await requireUser(client);
        const participants = await getDocs(
          query(
            collectionGroup(client.firestore, "event-participants"),
            where("id", "==", user.uid),
            where("status", "==", "active"),
          ),
        );
        // A participant document lives under its event: .../events/{eventId}/event-participants/{id}.
        const eventSnapshots = await Promise.all(
          participants.docs.flatMap((participant) => {
            const event = participant.ref.parent.parent;
            return event ? [getDoc(event)] : [];
          }),
        );
        const displayIds = new Map<string, string>();
        const events: Event[] = [];
        for (const snapshot of eventSnapshots) {
          if (!snapshot.exists()) continue;
          const communityId = stringValue(snapshot.data().communityId);
          if (!communityId) continue;
          if (!displayIds.has(communityId)) {
            displayIds.set(
              communityId,
              (await getCommunity(client, communityId)).displayId,
            );
          }
          events.push(
            mapEvent(
              snapshot.id,
              snapshot.data(),
              displayIds.get(communityId)!,
            ),
          );
        }
        return events.filter((event) => event.status === "active");
      },

      async create(input: NewEventInput) {
        const user = await requireUser(client);
        const [community, templateSnapshot] = await Promise.all([
          getCommunity(client, input.communityId),
          getDoc(
            doc(
              client.firestore,
              "community",
              input.communityId,
              "templates",
              input.templateId,
            ),
          ),
        ]);
        const template = asRecord(templateSnapshot.data());
        const eventCollection = collection(
          client.firestore,
          "community",
          input.communityId,
          "templates",
          input.templateId,
          "events",
        );
        const eventRef = doc(eventCollection);
        const scheduledTime = new Date(input.scheduledTime);
        if (Number.isNaN(scheduledTime.getTime())) {
          throw new ApiError("invalid", t`Invalid event schedule`);
        }
        const stream =
          input.eventType === "livestream"
            ? await provisionLiveStream(client, input.communityId)
            : undefined;
        const eventData: DocumentData = {
          ...(stream ? { liveStreamInfo: stream.liveStreamInfo } : {}),
          id: eventRef.id,
          collectionPath: eventCollection.path,
          communityId: input.communityId,
          templateId: input.templateId,
          creatorId: user.uid,
          status: "active",
          eventType: input.eventType,
          title:
            // This is a fallback value, exempt it:
            // eslint-disable-next-line lingui/no-unlocalized-strings
            input.title ?? stringValue(template.title) ?? "My custom event",
          description: stringValue(template.description) ?? "",
          image: stringValue(template.image) ?? "",
          createdDate: serverTimestamp(),
          scheduledTime: Timestamp.fromDate(scheduledTime),
          durationInMinutes: input.durationInMinutes,
          isPublic: input.isPublic,
          minParticipants: 0,
          isLocked: false,
          agendaItems: [],
        };
        const existingMembership = await getDoc(
          doc(
            client.firestore,
            "memberships",
            user.uid,
            "community-membership",
            input.communityId,
          ),
        );
        const membership = mapMembership(
          user.uid,
          input.communityId,
          existingMembership.data(),
        );
        if (!memberStatuses.has(membership.status)) {
          await client.functions.call("updateMembership", {
            communityId: input.communityId,
            userId: user.uid,
            status: "attendee",
            invisible: null,
          });
        }
        await setDoc(eventRef, eventData);
        if (stream)
          await savePrivateLiveStreamInfo(eventRef, stream.privateInfo);
        await client.functions.call("createEvent", {
          eventPath: eventRef.path,
        });
        const savedEvent = await getDoc(eventRef);
        if (!savedEvent.exists()) {
          throw new ApiError("notFound", t`Created event was not found`);
        }
        return mapEvent(savedEvent.id, savedEvent.data(), community.displayId);
      },

      async get(communityId, templateId, eventId) {
        await requireUser(client);
        const [snapshot, community] = await Promise.all([
          getDoc(eventDocument(client, communityId, templateId, eventId)),
          getCommunity(client, communityId),
        ]);
        if (!snapshot.exists()) {
          throw new ApiError("notFound", t`This event was not found.`);
        }
        return mapEvent(snapshot.id, snapshot.data(), community.displayId);
      },

      async join(event, options) {
        const user = await requireUser(client);
        const reference = eventDocument(
          client,
          event.communityId,
          event.templateId,
          event.id,
        );
        // Read it fresh: it may have been canceled since the page loaded.
        const current = await getDoc(reference);
        if (current.data()?.status === "canceled") {
          throw new ApiError(
            "invalid",
            t`Sorry, this event was canceled, so you cannot join it.`,
          );
        }
        const membership = await getDoc(
          doc(
            client.firestore,
            "memberships",
            user.uid,
            "community-membership",
            event.communityId,
          ),
        );
        const status = stringValue(membership.data()?.status);
        // Anyone who RSVPs becomes at least an attendee of the community; members keep their rank.
        if (!status || status === "nonmember") {
          await client.functions.call("updateMembership", {
            communityId: event.communityId,
            userId: user.uid,
            status: "attendee",
            invisible: null,
          });
        }
        await setDoc(
          doc(reference, "event-participants", user.uid),
          {
            id: user.uid,
            communityId: event.communityId,
            templateId: event.templateId,
            status: "active",
            ...(event.surveyQuestions?.length
              ? {
                  breakoutRoomSurveyQuestions: event.surveyQuestions.map(
                    (question) => {
                      const answer = options?.survey?.find(
                        (candidate) => candidate.questionId === question.id,
                      );
                      return {
                        id: question.id,
                        title: question.title,
                        type: question.type,
                        answerOptionId: answer?.answerOptionId ?? "",
                        answers: question.answers,
                        ...(answer?.freeText !== undefined
                          ? { freeTextAnswer: answer.freeText }
                          : {}),
                      };
                    },
                  ),
                }
              : {}),
            ...(event.scheduledTime
              ? {
                  scheduledTime: Timestamp.fromDate(
                    new Date(event.scheduledTime),
                  ),
                }
              : {}),
            ...(user.email ? { email: user.email } : {}),
            ...(user.displayName ? { name: user.displayName } : {}),
            createdDate: serverTimestamp(),
          },
          { merge: true },
        );
        if (options?.joinCommunity)
          await api.communities.follow(event.communityId);
        // The server sends the confirmation email; the RSVP itself already succeeded without it.
        void client.functions
          .call("joinEvent", { ...current.data(), id: event.id })
          .catch(() => undefined);
      },

      async leave(event, participantId) {
        const user = await requireUser(client);
        const id = participantId ?? user.uid;
        await setDoc(
          doc(
            eventDocument(
              client,
              event.communityId,
              event.templateId,
              event.id,
            ),
            "event-participants",
            id,
          ),
          { id, status: "canceled", lastUpdatedTime: serverTimestamp() },
          { merge: true },
        );
      },

      async cancel(event) {
        await requireUser(client);
        await updateDoc(
          eventDocument(client, event.communityId, event.templateId, event.id),
          { status: "canceled" },
        );
      },

      async listMessages(event) {
        await requireUser(client);
        const snapshots = await getDocs(
          query(
            collection(
              eventDocument(
                client,
                event.communityId,
                event.templateId,
                event.id,
              ),
              "event-messages",
            ),
            orderBy("createdAt", "desc"),
          ),
        );
        return snapshots.docs.flatMap((snapshot): EventMessage[] => {
          const data = snapshot.data();
          const message = stringValue(data.message);
          const creatorId = stringValue(data.creatorId);
          return message && creatorId
            ? [
                {
                  id: snapshot.id,
                  creatorId,
                  message,
                  createdAt: optionalIsoDate(data.createdAt) ?? "",
                },
              ]
            : [];
        });
      },

      async sendMessage(event, message) {
        const user = await requireUser(client);
        await client.functions.call("sendEventMessage", {
          communityId: event.communityId,
          templateId: event.templateId,
          eventId: event.id,
          eventMessage: { creatorId: user.uid, message },
        });
      },

      async removeMessage(event, messageId) {
        await requireUser(client);
        await deleteDoc(
          doc(
            eventDocument(
              client,
              event.communityId,
              event.templateId,
              event.id,
            ),
            "event-messages",
            messageId,
          ),
        );
      },

      async update(event, patch) {
        await requireUser(client);
        const reference = eventDocument(
          client,
          event.communityId,
          event.templateId,
          event.id,
        );
        // Becoming a livestream needs a stream set up, once.
        const stream =
          patch.eventType === "livestream" && !event.hasLiveStream
            ? await provisionLiveStream(client, event.communityId)
            : undefined;
        await updateDoc(reference, {
          ...(stream ? { liveStreamInfo: stream.liveStreamInfo } : {}),
          ...(patch.eventType !== undefined
            ? { eventType: patch.eventType }
            : {}),
          ...(patch.title !== undefined ? { title: patch.title } : {}),
          ...(patch.description !== undefined
            ? { description: patch.description }
            : {}),
          ...(patch.image !== undefined ? { image: patch.image } : {}),
          ...(patch.isPublic !== undefined ? { isPublic: patch.isPublic } : {}),
          ...(patch.scheduledTime !== undefined
            ? {
                scheduledTime: Timestamp.fromDate(
                  new Date(patch.scheduledTime),
                ),
              }
            : {}),
          ...(patch.maxParticipants !== undefined
            ? { maxParticipants: patch.maxParticipants }
            : {}),
          ...(patch.durationInMinutes !== undefined
            ? { durationInMinutes: patch.durationInMinutes }
            : {}),
        });
        if (stream)
          await savePrivateLiveStreamInfo(reference, stream.privateInfo);
        const community = await getCommunity(client, event.communityId);
        return mapEvent(
          event.id,
          (await getDoc(reference)).data(),
          community.displayId,
        );
      },

      async updatePrePost(event, which, card) {
        await requireUser(client);
        const type = which === "pre" ? "preEvent" : "postEvent";
        await updateDoc(
          eventDocument(client, event.communityId, event.templateId, event.id),
          {
            // Firestore field names, not UI text.

            [which === "pre" ? "preEventCardData" : "postEventCardData"]: card
              ? storedCard(card, type)
              : deleteField(),
          },
        );
      },

      async upsertAgendaItem(event, item) {
        await requireUser(client);
        await editAgenda(
          client,
          eventDocument(client, event.communityId, event.templateId, event.id),
          upsertStep(item),
        );
      },

      async deleteAgendaItem(event, itemId) {
        await requireUser(client);
        await editAgenda(
          client,
          eventDocument(client, event.communityId, event.templateId, event.id),
          deleteStep(itemId),
        );
      },

      async reorderAgenda(event, ids) {
        await requireUser(client);
        await editAgenda(
          client,
          eventDocument(client, event.communityId, event.templateId, event.id),
          reorderSteps(ids),
        );
      },

      async saveSurveyQuestions(event, questions) {
        await editBreakouts(client, event, {
          breakoutQuestions: questions.map((question) => ({
            id: question.id,
            title: question.title,
            type: question.type,
            answerOptionId: "",
            answers: question.type === "freeText" ? [] : question.answers,
          })),
        });
      },

      async updateBreakoutSettings(event, patch) {
        await editBreakouts(client, event, {
          ...(patch.assignmentMethod !== undefined
            ? { assignmentMethod: patch.assignmentMethod }
            : {}),
          ...(patch.targetParticipants !== undefined
            ? { targetParticipants: patch.targetParticipants }
            : {}),
        });
      },

      async clearAgenda(event) {
        await requireUser(client);
        await updateDoc(
          eventDocument(client, event.communityId, event.templateId, event.id),
          { agendaItems: [] },
        );
      },

      async refreshFromTemplate(event) {
        await requireUser(client);
        const template = await getDoc(
          doc(
            client.firestore,
            "community",
            event.communityId,
            "templates",
            event.templateId,
          ),
        );
        // The agenda is copied as stored; this app does not need to read what is in it.
        const agendaItems = Array.isArray(template.data()?.agendaItems)
          ? template.data()?.agendaItems
          : [];
        await updateDoc(
          eventDocument(client, event.communityId, event.templateId, event.id),
          { agendaItems },
        );
      },

      async updateSettings(event, settings) {
        await requireUser(client);
        const reference = eventDocument(
          client,
          event.communityId,
          event.templateId,
          event.id,
        );
        // One field at a time, so settings this app does not show are left as they were.
        await updateDoc(
          reference,
          Object.fromEntries(
            // Firestore field paths, not UI text.
            /* eslint-disable lingui/no-unlocalized-strings */
            Object.entries(settings).flatMap(([key, value]) =>
              value === undefined ? [] : [[`eventSettings.${key}`, value]],
            ),
            /* eslint-enable lingui/no-unlocalized-strings */
          ),
        );
        const community = await getCommunity(client, event.communityId);
        return mapEvent(
          event.id,
          (await getDoc(reference)).data(),
          community.displayId,
        );
      },

      async calendarLinks(event) {
        const response = asRecord(
          await client.functions.call("getCommunityCalendarLink", {
            eventPath: `community/${event.communityId}/templates/${event.templateId}/events/${event.id}`,
          }),
        );
        return {
          google: stringValue(response.googleCalendarLink) ?? "",
          outlook: stringValue(response.outlookCalendarLink) ?? "",
          office365: stringValue(response.office365CalendarLink) ?? "",
          ics: stringValue(response.icsLink) ?? "",
        };
      },

      async listParticipants(eventId): Promise<ParticipantWithUser[]> {
        await requireUser(client);
        const eventRef = await findCollectionGroupDocument(
          client,
          "events",
          eventId,
        );
        const participants = await getDocs(
          collection(client.firestore, eventRef.path, "event-participants"),
        );
        return Promise.all(
          participants.docs.map(async (snapshot) => {
            const participant = mapParticipant(snapshot, eventId);
            return {
              participant,
              user: await getPublicUser(client, participant.userId),
            };
          }),
        );
      },

      async hasAttendedTemplate(templateId) {
        const user = await requireUser(client);
        const participants = await getDocs(
          query(
            collectionGroup(client.firestore, "event-participants"),
            where("id", "==", user.uid),
            where("templateId", "==", templateId),
            where("status", "==", "active"),
            where("scheduledTime", "<", Timestamp.now()),
          ),
        );
        return participants.docs.length > 0;
      },
    },

    threads: {
      async list(communityId) {
        await requireUser(client);
        const snapshots = await getDocs(
          query(
            collection(
              client.firestore,
              "community",
              communityId,
              "discussion-threads",
            ),
            where("isDeleted", "==", false),
            orderBy("createdAt", "desc"),
          ),
        );
        return snapshots.docs.map((snapshot) =>
          mapThread(snapshot.id, communityId, snapshot.data()),
        );
      },

      async create(communityId, input) {
        const user = await requireUser(client);
        const threadRef = doc(
          collection(
            client.firestore,
            "community",
            communityId,
            "discussion-threads",
          ),
        );
        const createdAt = new Date().toISOString();
        await setDoc(threadRef, {
          id: threadRef.id,
          communityId,
          creatorId: user.uid,
          createdAt: serverTimestamp(),
          title: input.title ?? null,
          content: input.content,
          imageUrl: input.imageUrl ?? null,
          likedByIds: [],
          dislikedByIds: [],
          emotions: [],
          commentCount: 0,
          isDeleted: false,
        });
        return mapThread(threadRef.id, communityId, {
          id: threadRef.id,
          communityId,
          creatorId: user.uid,
          createdAt,
          title: input.title,
          content: input.content,
          imageUrl: input.imageUrl,
          likedByIds: [],
          dislikedByIds: [],
          emotions: [],
          commentCount: 0,
        });
      },

      async update(threadId, patch) {
        await requireUser(client);
        const threadRef = await getThreadReference(client, threadId);
        const changes: Record<string, unknown> = {};
        if ("content" in patch && patch.content !== undefined) {
          changes.content = patch.content;
        }
        if ("imageUrl" in patch) {
          changes.imageUrl = patch.imageUrl ?? deleteField();
        }
        if (Object.keys(changes).length > 0)
          await updateDoc(threadRef, changes);
        const snapshot = await getDoc(threadRef);
        const communityId = threadRef.path.split("/")[1];
        return mapThread(threadId, communityId, snapshot.data());
      },

      async vote(threadId, vote) {
        const user = await requireUser(client);
        const threadRef = await getThreadReference(client, threadId);
        const changes = {
          likedByIds:
            vote === "like" ? arrayUnion(user.uid) : arrayRemove(user.uid),
          dislikedByIds:
            vote === "dislike" ? arrayUnion(user.uid) : arrayRemove(user.uid),
        };
        await updateDoc(threadRef, changes);
        const snapshot = await getDoc(threadRef);
        return mapThread(
          threadId,
          threadRef.path.split("/")[1],
          snapshot.data(),
        );
      },

      async setEmotion(threadId, emotion) {
        const user = await requireUser(client);
        const threadRef = await getThreadReference(client, threadId);
        await runTransaction(client.firestore, async (transaction) => {
          const snapshot = await transaction.get(threadRef);
          if (!snapshot.exists()) {
            throw new ApiError("notFound", t`Post not found`);
          }
          const emotions = mapEmotions(snapshot.data().emotions).filter(
            (item) => item.userId !== user.uid,
          );
          if (emotion) {
            emotions.push({ userId: user.uid, emotion });
          }
          transaction.update(threadRef, {
            emotions: emotions.map((item) => ({
              creatorId: item.userId,
              emotionType: item.emotion,
            })),
          });
        });
        const snapshot = await getDoc(threadRef);
        return mapThread(
          threadId,
          threadRef.path.split("/")[1],
          snapshot.data(),
        );
      },

      async listComments(threadId) {
        await requireUser(client);
        const threadRef = await getThreadReference(client, threadId);
        const snapshots = await getDocs(
          query(
            collection(
              client.firestore,
              threadRef.path,
              "discussion-thread-comments",
            ),
            orderBy("createdAt", "desc"),
          ),
        );
        return snapshots.docs.map((snapshot) =>
          mapComment(snapshot.id, threadId, snapshot.data()),
        );
      },

      async addComment(threadId, input) {
        const user = await requireUser(client);
        const threadRef = await getThreadReference(client, threadId);
        const commentRef = doc(
          collection(
            client.firestore,
            threadRef.path,
            "discussion-thread-comments",
          ),
        );
        const createdAt = new Date().toISOString();
        await setDoc(commentRef, {
          id: commentRef.id,
          creatorId: user.uid,
          createdAt: serverTimestamp(),
          comment: input.comment,
          ...(input.replyToCommentId
            ? { replyToCommentId: input.replyToCommentId }
            : {}),
          isDeleted: false,
          emotions: [],
        });
        const comment = mapComment(commentRef.id, threadId, {
          id: commentRef.id,
          creatorId: user.uid,
          createdAt,
          comment: input.comment,
          replyToCommentId: input.replyToCommentId,
          isDeleted: false,
          emotions: [],
        });
        return comment;
      },
    },

    resources: {
      async preview(url) {
        const key = import.meta.env.VITE_LINK_PREVIEW_API_KEY;
        if (!key) {
          // i18n: shown to the site admin configuring link previews, not a typical end user
          throw new ApiError(
            "invalid",
            t`Link preview is not configured. Set VITE_LINK_PREVIEW_API_KEY.`,
          );
        }
        const parsedUrl = new URL(url);
        if (parsedUrl.protocol !== "http:" && parsedUrl.protocol !== "https:") {
          throw new ApiError(
            "invalid",
            t`Only HTTP and HTTPS links can be previewed.`,
          );
        }
        const response = await fetch(
          `https://api.linkpreview.net/?key=${encodeURIComponent(key)}&q=${encodeURIComponent(url)}`,
        );
        if (!response.ok) {
          throw new Error(t`Link preview request failed (${response.status})`);
        }
        const preview = asRecord(await response.json());
        return {
          title: requiredString(preview.title, "link preview title"),
          ...(stringValue(preview.image)
            ? { image: stringValue(preview.image) }
            : {}),
        };
      },

      async list(communityId) {
        await requireUser(client);
        const snapshots = await getDocs(
          collection(
            client.firestore,
            "community",
            communityId,
            "community-resources",
          ),
        );
        return snapshots.docs.map((snapshot) =>
          mapResource(snapshot.id, communityId, snapshot.data()),
        );
      },

      async create(communityId, input) {
        const user = await requireUser(client);
        const resourceRef = doc(
          collection(
            client.firestore,
            "community",
            communityId,
            "community-resources",
          ),
        );
        const createdDate = new Date().toISOString();
        await setDoc(resourceRef, {
          id: resourceRef.id,
          communityId,
          creatorId: user.uid,
          title: input.title,
          url: input.url,
          image: input.image ?? null,
          createdDate: serverTimestamp(),
        });
        return mapResource(resourceRef.id, communityId, {
          id: resourceRef.id,
          communityId,
          title: input.title,
          url: input.url,
          image: input.image,
          createdDate,
        });
      },

      async update(communityId, resourceId, patch) {
        await requireUser(client);
        const resourceRef = doc(
          client.firestore,
          "community",
          communityId,
          "community-resources",
          resourceId,
        );
        const changes: Record<string, unknown> = {};
        // eslint-disable-next-line lingui/no-unlocalized-strings -- link-preview field names
        for (const key of ["title", "url", "image"] as const) {
          if (key in patch) changes[key] = patch[key] ?? deleteField();
        }
        if (Object.keys(changes).length > 0)
          await updateDoc(resourceRef, changes);
        const snapshot = await getDoc(resourceRef);
        if (!snapshot.exists())
          throw new ApiError("notFound", t`Resource not found`);
        return mapResource(resourceId, communityId, snapshot.data());
      },

      async remove(communityId, resourceId) {
        await requireUser(client);
        await deleteDoc(
          doc(
            client.firestore,
            "community",
            communityId,
            "community-resources",
            resourceId,
          ),
        );
      },
    },

    announcements: {
      async list(communityId) {
        await requireUser(client);
        const snapshots = await getDocs(
          query(
            collection(
              client.firestore,
              "community",
              communityId,
              "announcements",
            ),
            orderBy("createdDate", "desc"),
          ),
        );
        return snapshots.docs
          .filter(
            (snapshot) => snapshot.data().announcementStatus !== "removed",
          )
          .map((snapshot) =>
            mapAnnouncement(snapshot.id, communityId, snapshot.data()),
          );
      },

      async create(communityId, input) {
        const user = await requireUser(client);
        await client.functions.call("sendAnnouncement", {
          communityId,
          announcement: {
            announcementStatus: "active",
            creatorId: user.uid,
            createdDate: new Date().toISOString(),
            title: input.title ?? null,
            message: input.message,
          },
        });
      },

      async remove(communityId, announcementId) {
        await requireUser(client);
        await updateDoc(
          doc(
            client.firestore,
            "community",
            communityId,
            "announcements",
            announcementId,
          ),
          { announcementStatus: "removed" },
        );
      },
    },
  };
  return api;
}
