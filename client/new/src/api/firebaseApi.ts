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
  Announcement,
  Community,
  CommunityResource,
  DiscussionThread,
  DiscussionThreadComment,
  EmotionType,
  Event,
  EventType,
  MemberDetails,
  Membership,
  MembershipStatus,
  NewEventInput,
  OnboardingStep,
  Participant,
  PublicUser,
  Template,
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
      `User-${userId.slice(0, 4)}`,
    ...((stringValue(data.imageUrl) ?? fallback?.imageUrl)
      ? { imageUrl: stringValue(data.imageUrl) ?? fallback?.imageUrl }
      : {}),
    ...(stringValue(data.about) ? { about: stringValue(data.about) } : {}),
    ...(data.appRole === "owner" ? { isAppOwner: true } : {}),
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
    },
    onboardingSteps: stringArray(data.onboardingSteps).filter(
      (step): step is OnboardingStep =>
        onboardingSteps.has(step as OnboardingStep),
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
  if (!snapshot.exists()) throw new ApiError("notFound", t`Community not found`);
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
    },

    templates: {
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
        const eventData: DocumentData = {
          id: eventRef.id,
          collectionPath: eventCollection.path,
          communityId: input.communityId,
          templateId: input.templateId,
          creatorId: user.uid,
          status: "active",
          eventType: input.eventType,
          title:
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
        await client.functions.call("createEvent", {
          eventPath: eventRef.path,
        });
        const savedEvent = await getDoc(eventRef);
        if (!savedEvent.exists()) {
          throw new ApiError("notFound", t`Created event was not found`);
        }
        return mapEvent(savedEvent.id, savedEvent.data(), community.displayId);
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
