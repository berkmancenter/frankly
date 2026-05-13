/**
 * TypeScript type definitions corresponding to the Dart data_models package.
 * These mirror the Dart Freezed models used throughout the Firebase functions.
 */

// ─── Enums ───────────────────────────────────────────────────────────────────

export enum MembershipStatus {
    owner = 'owner',
    admin = 'admin',
    moderator = 'moderator',
    facilitator = 'facilitator',
    member = 'member',
    banned = 'banned',
    nonmember = 'nonmember',
    attendee = 'attendee',
}

export function membershipIsOwner(s: MembershipStatus): boolean {
    return s === MembershipStatus.owner
}
export function membershipIsAdmin(s: MembershipStatus): boolean {
    return membershipIsOwner(s) || s === MembershipStatus.admin
}
export function membershipIsMod(s: MembershipStatus): boolean {
    return membershipIsAdmin(s) || s === MembershipStatus.moderator
}
export function membershipIsFacilitator(s: MembershipStatus): boolean {
    return membershipIsMod(s) || s === MembershipStatus.facilitator
}
export function membershipIsMember(s: MembershipStatus): boolean {
    return membershipIsFacilitator(s) || s === MembershipStatus.member
}
export function membershipIsAttendee(s: MembershipStatus): boolean {
    return membershipIsMember(s) || s === MembershipStatus.attendee
}

export enum EventStatus {
    active = 'active',
    canceled = 'canceled',
}

export enum EventType {
    hosted = 'hosted',
    hostless = 'hostless',
    livestream = 'livestream',
}

export enum EventEmailType {
    initialSignUp = 'initialSignUp',
    oneDayReminder = 'oneDayReminder',
    oneHourReminder = 'oneHourReminder',
    updated = 'updated',
    canceled = 'canceled',
    ended = 'ended',
}

export enum ParticipantStatus {
    active = 'active',
    inactive = 'inactive',
    banned = 'banned',
}

export enum OnboardingStep {
    brandSpace = 'brandSpace',
    createTemplate = 'createTemplate',
    hostEvent = 'hostEvent',
    inviteSomeone = 'inviteSomeone',
    createStripeAccount = 'createStripeAccount',
}

export enum BreakoutRoomStatus {
    pending = 'pending',
    active = 'active',
    inactive = 'inactive',
    processingAssignments = 'processingAssignments',
}

export enum BreakoutAssignmentMethod {
    targetPerRoom = 'targetPerRoom',
    smartMatch = 'smartMatch',
    category = 'category',
}

export enum BreakoutRoomFlagStatus {
    needsHelp = 'needsHelp',
    none = 'none',
}

export enum RecordingSessionStatus {
    starting = 'starting',
    recording = 'recording',
    stopped = 'stopped',
    failed = 'failed',
}

export enum RecordingRoomType {
    main = 'main',
    breakout = 'breakout',
}

export enum MembershipRequestStatus {
    requested = 'requested',
    approved = 'approved',
    denied = 'denied',
}

export enum NotificationEmailType {
    immediate = 'immediate',
    none = 'none',
}

export enum PlanType {
    unrestricted = 'unrestricted',
    pro = 'pro',
    club = 'club',
    individual = 'individual',
}

export enum PaymentType {
    oneTimeDonation = 'oneTimeDonation',
}

export enum AgendaItemType {
    talkingPoints = 'talkingPoints',
    poll = 'poll',
    iceBreaker = 'iceBreaker',
}

export enum LiveMeetingEventType {
    finishMeeting = 'finishMeeting',
    advanceAgendaItem = 'advanceAgendaItem',
    agendaItemStarted = 'agendaItemStarted',
}

export enum EventProposalType {
    kick = 'kick',
}

export enum EventProposalStatus {
    open = 'open',
    accepted = 'accepted',
    rejected = 'rejected',
}

// ─── Community ───────────────────────────────────────────────────────────────

export interface CommunitySettings {
    allowDonations?: boolean
    allowUnofficialTemplates?: boolean
    enableHostless?: boolean
    disableEmailDigests?: boolean
    dontAllowMembersToCreateMeetings?: boolean
    enableDiscussionThreads?: boolean
    multiplePeopleOnStage?: boolean
    multipleVideoTypes?: boolean
    requireApprovalToJoin?: boolean
    chat?: boolean
}

export interface EventSettings {
    alwaysRecord?: boolean
    allowPredefineBreakoutsOnHosted?: boolean
    defaultStageView?: boolean
    showSmartMatchingForBreakouts?: boolean
    enableBreakoutsByCategory?: boolean
    enablePrerequisites?: boolean
    reminderEmails?: boolean
    talkingTimer?: boolean
    chat?: boolean
    showChatMessagesInRealTime?: boolean
    allowMultiplePeopleOnStage?: boolean
    agendaPreview?: boolean
}

export interface Community {
    id: string
    displayIds: string[]
    name?: string
    contactEmail?: string
    creatorId?: string
    profileImageUrl?: string
    bannerImageUrl?: string
    createdDate?: Date
    isPublic?: boolean
    description?: string
    websiteUrl?: string
    facebookUrl?: string
    linkedinUrl?: string
    twitterUrl?: string
    blueskyUrl?: string
    youtubeUrl?: string
    instagramUrl?: string
    tagLine?: string
    communitySettings?: CommunitySettings
    eventSettings?: EventSettings
    donationDialogText?: string
    ratingSurveyUrl?: string
    themeLightColor?: string
    themeDarkColor?: string
    onboardingSteps?: string[]
    enabledFeatureFlags?: string[]
}

export function getCommunitySettings(community: Community): CommunitySettings {
    if (community.communitySettings) return community.communitySettings
    const flags = community.enabledFeatureFlags ?? []
    return {
        allowDonations: flags.includes('allowDonations'),
        allowUnofficialTemplates: flags.includes('allowUnofficialTemplates'),
        enableHostless: flags.includes('enableHostless'),
        disableEmailDigests: flags.includes('disableEmailDigests'),
        dontAllowMembersToCreateMeetings: flags.includes('dontAllowMembersToCreateMeetings'),
        enableDiscussionThreads: flags.includes('enableDiscussionThreads'),
        multiplePeopleOnStage: flags.includes('multiplePeopleOnStage'),
        multipleVideoTypes: flags.includes('multipleVideoTypes'),
        requireApprovalToJoin: flags.includes('requireApprovalToJoin'),
    }
}

export function getEventSettings(community: Community): EventSettings {
    if (community.eventSettings) return community.eventSettings
    const flags = community.enabledFeatureFlags ?? []
    return {
        alwaysRecord: flags.includes('alwaysRecord'),
        allowPredefineBreakoutsOnHosted: flags.includes('allowPredefineBreakoutsOnHosted'),
        chat: flags.includes('chat'),
        defaultStageView: flags.includes('defaultStageView'),
        enableBreakoutsByCategory: flags.includes('enableBreakoutsByCategory'),
        showSmartMatchingForBreakouts: flags.includes('showSmartMatchingForBreakouts'),
        reminderEmails: !flags.includes('suppressJoinEventEmails'),
    }
}

export function getCommunityDisplayId(community: Community): string {
    return community.displayIds?.[0] ?? community.id
}

// ─── Membership ──────────────────────────────────────────────────────────────

export interface Membership {
    userId: string
    communityId: string
    status?: MembershipStatus
    firstJoined?: Date
    invisible?: boolean
}

export function membershipIsAdminOf(m: Membership): boolean {
    return m.status ? membershipIsAdmin(m.status) : false
}
export function membershipIsModOf(m: Membership): boolean {
    return m.status ? membershipIsMod(m.status) : false
}
export function membershipIsMemberOf(m: Membership): boolean {
    return m.status ? membershipIsMember(m.status) : false
}
export function membershipIsFacilitatorOf(m: Membership): boolean {
    return m.status ? membershipIsFacilitator(m.status) : false
}
export function membershipIsAttendeeOf(m: Membership): boolean {
    return m.status ? membershipIsAttendee(m.status) : false
}

export interface MembershipRequest {
    userId: string
    communityId?: string
    status?: MembershipRequestStatus
}

// ─── Events ──────────────────────────────────────────────────────────────────

export interface WaitingRoomInfo {
    durationSeconds?: number
    waitingMediaBufferSeconds?: number
}

export interface BreakoutRoomSurveyQuestion {
    answerOptionId: string
    answers: Array<{ options: Array<{ id: string }> }>
}

export interface Participant {
    id: string
    status?: ParticipantStatus
    membershipStatus?: MembershipStatus
    isPresent?: boolean
    lastUpdatedTime?: Date
    currentBreakoutRoomId?: string
    joinParameters?: Record<string, string>
    breakoutRoomSurveyQuestions?: BreakoutRoomSurveyQuestion[]
}

export interface AgendaItem {
    id: string
    type?: AgendaItemType
    content?: string
}

export interface LiveStreamInfo {
    muxId?: string
    muxStatus?: string
    latestAssetPlaybackId?: string
}

export interface BreakoutRoomDefinition {
    assignmentMethod?: BreakoutAssignmentMethod
    targetParticipants?: number
    breakoutQuestions?: Array<{ id: string }>
}

export interface Event {
    id: string
    status: EventStatus
    nullableEventType?: EventType
    collectionPath: string
    communityId: string
    templateId: string
    creatorId: string
    scheduledTime?: Date
    scheduledTimeZone?: string
    title?: string
    description?: string
    image?: string
    isPublic?: boolean
    minParticipants?: number
    maxParticipants?: number
    agendaItems?: AgendaItem[]
    waitingRoomInfo?: WaitingRoomInfo
    breakoutRoomDefinition?: BreakoutRoomDefinition
    isLocked?: boolean
    liveStreamInfo?: LiveStreamInfo
    preEventCardData?: PrePostCard
    postEventCardData?: PrePostCard
    eventSettings?: EventSettings
    durationInMinutes?: number
    participantCountEstimate?: number
    presentParticipantCountEstimate?: number
    breakoutMatchIdsToRecord?: string[]
}

export function getEventType(event: Event): EventType {
    if (event.nullableEventType) return event.nullableEventType
    if (event.liveStreamInfo) return EventType.livestream
    return EventType.hosted
}

export function getEventFullPath(event: Event): string {
    return `${event.collectionPath}/${event.id}`
}

export function timeUntilScheduledStart(event: Event, now: Date): number {
    const bufferMs = (event.waitingRoomInfo?.waitingMediaBufferSeconds ?? 0) * 1000
    const scheduled = event.scheduledTime ? event.scheduledTime.getTime() + bufferMs : now.getTime()
    return scheduled - now.getTime()
}

export function timeUntilWaitingRoomFinished(event: Event, now: Date): number {
    let ms = timeUntilScheduledStart(event, now)
    if (event.waitingRoomInfo?.durationSeconds) {
        ms += event.waitingRoomInfo.durationSeconds * 1000
    }
    return ms
}

export interface EventEmailLog {
    userId?: string
    eventEmailType?: EventEmailType
    sendId?: string
}

export interface EventMessage {
    createdAtMillis?: number
    [key: string]: unknown
}

export interface PrePostCard {
    headline: string
    message: string
    hasData?: boolean
    prePostUrls?: Array<{
        surveyUrl?: string
        buttonText?: string
    }>
    getFinalisedUrl?: (opts: {
        userId: string
        event: Event
        email?: string
        urlInfo: { surveyUrl?: string }
    }) => string
}

// ─── Templates ───────────────────────────────────────────────────────────────

export interface Template {
    id: string
    creatorId?: string
    collectionPath?: string
    title?: string
    image?: string
    [key: string]: unknown
}

// ─── Live Meetings ────────────────────────────────────────────────────────────

export interface BreakoutRoomSession {
    breakoutRoomSessionId?: string
    breakoutRoomStatus?: BreakoutRoomStatus
    assignmentMethod?: BreakoutAssignmentMethod
    targetParticipantsPerRoom?: number
    hasWaitingRoom?: boolean
    scheduledTime?: Date
    processingId?: string
    statusUpdatedTime?: Date
    maxRoomNumber?: number
}

export interface LiveMeetingParticipant {
    communityId?: string
}

export interface LiveMeetingEvent {
    event?: LiveMeetingEventType
    agendaItem?: string
    hostless?: boolean
    timestamp?: Date
}

export interface LiveMeeting {
    meetingId?: string
    currentBreakoutSession?: BreakoutRoomSession
    record?: boolean
    recordingSessionId?: string
    participants?: LiveMeetingParticipant[]
    events?: LiveMeetingEvent[]
}

export interface BreakoutRoom {
    roomId: string
    creatorId?: string
    roomName?: string
    orderingPriority?: number
    participantIds: string[]
    originalParticipantIdsAssignment?: string[]
    record?: boolean
    recordingSessionId?: string
    flagStatus?: BreakoutRoomFlagStatus
}

export interface ParticipantAgendaItemDetails {
    userId?: string
    agendaItemId?: string
    meetingId?: string
    readyToAdvance?: boolean
    pollResponse?: unknown
}

// ─── Recording ───────────────────────────────────────────────────────────────

export interface RecordingSession {
    sessionId: string
    communityId: string
    eventId: string
    roomId: string
    roomType: RecordingRoomType
    status: RecordingSessionStatus
    gcsPrefix?: string
    chatPath?: string
    participantIds?: string[]
    breakoutSessionId?: string
    agoraResourceId?: string
    agoraSid?: string
    errorMessage?: string
    stoppedAt?: unknown
}

// ─── Admin ────────────────────────────────────────────────────────────────────

export interface PlanCapabilityList {
    type?: string
    userHours?: number
    adminCount?: number
    facilitatorCount?: number
    takeRate?: number
    hasSmartMatching?: boolean
    hasLivestreams?: boolean
    hasCustomUrls?: boolean
    hasAdvancedBranding?: boolean
    hasBasicAnalytics?: boolean
    hasCustomAnalytics?: boolean
    hasIntegrations?: boolean
    hasPrePost?: boolean
}

export interface PartnerAgreement {
    id?: string
    communityId?: string
    allowPayments?: boolean
    planOverride?: string
    stripeConnectedAccountId?: string
    stripeConnectedAccountActive?: boolean
}

export interface BillingSubscription {
    id?: string
    appliedCommunityId?: string
    type?: string
    activeUntil?: Date
    canceled?: boolean
}

export interface PaymentRecord {
    id: string
    authUid: string
    communityId: string
    amountInCents: number
    createdDate?: Date
    type?: PaymentType
}

// ─── User ─────────────────────────────────────────────────────────────────────

export interface PublicUserInfo {
    displayName?: string
    photoUrl?: string
}

export interface CommunityUserSettings {
    userId?: string
    communityId?: string
    notifyAnnouncements?: NotificationEmailType | null
    notifyEvents?: NotificationEmailType | null
}

export interface MemberDetails {
    id: string
    email?: string
    displayName?: string
    membership?: Membership
    memberEvent?: MemberEventData
}

export interface MemberEventData {
    eventId?: string
    templateId?: string
    participant?: Participant
}

export interface UserAdminDetails {
    userId?: string
    email?: string
}

// ─── Announcements ────────────────────────────────────────────────────────────

export interface Announcement {
    title?: string
    [key: string]: unknown
}

// ─── Discussion Threads ──────────────────────────────────────────────────────

export interface DiscussionThread {
    id: string
    [key: string]: unknown
}

// ─── Proposals ───────────────────────────────────────────────────────────────

export interface EventProposalVote {
    voterUserId?: string
    inFavor?: boolean
    reason?: string
}

export interface EventProposal {
    id: string
    initiatingUserId?: string
    targetUserId?: string
    type?: EventProposalType
    status?: EventProposalStatus
    votes?: EventProposalVote[]
    closedAt?: Date
}

// ─── Email ───────────────────────────────────────────────────────────────────

export interface SendGridEmailMessage {
    subject: string
    html: string
    attachments?: EmailAttachment[]
}

export interface EmailAttachment {
    filename: string
    content: string
    contentType: string
}

export interface SendGridEmail {
    to: string[]
    from: string
    message: SendGridEmailMessage
}

// ─── Cloud Function Requests / Responses ─────────────────────────────────────

export interface CreateEventRequest {
    eventPath: string
}

export interface CreateAnnouncementRequest {
    communityId: string
    announcement?: Announcement
}

export interface SendEventMessageRequest {
    communityId: string
    templateId: string
    eventId: string
    eventMessage: EventMessage
}

export interface CreateCommunityRequest {
    community?: Community
    agreementId?: string
}

export interface CreateCommunityResponse {
    communityId: string
}

export interface UpdateCommunityRequest {
    community: Community
    keys: string[]
}

export interface UpdateMembershipRequest {
    communityId: string
    userId: string
    status?: MembershipStatus
}

export interface GetCommunityCapabilitiesRequest {
    communityId: string
}

export interface GetCommunityDonationsEnabledRequest {
    communityId: string
}

export interface GetCommunityPrePostEnabledRequest {
    communityId: string
}

export interface GetMembersDataRequest {
    communityId: string
    userIds: string[]
    eventPath?: string
}

export interface GetMembersDataResponse {
    membersDetailsList: MemberDetails[]
}

export interface GetUserAdminDetailsRequest {
    userIds: string[]
    communityId?: string
    eventPath?: string
}

export interface GetUserAdminDetailsResponse {
    userAdminDetails: UserAdminDetails[]
}

export interface ResolveJoinRequestRequest {
    communityId: string
    userId: string
    approve?: boolean
}

export interface UnsubscribeFromCommunityNotificationsRequest {
    data: string
}

export interface EmailEventReminderRequest {
    communityId: string
    templateId: string
    eventId: string
    eventEmailType?: EventEmailType
}

export interface ExtendCloudTaskSchedulerRequest {
    scheduledTime: Date
    functionName: string
    payload: string
}

export interface GetMeetingJoinInfoRequest {
    eventPath: string
}

export interface GetMeetingJoinInfoResponse {
    identity: string
    meetingToken: string
    meetingId: string
}

export interface GetBreakoutRoomJoinInfoRequest {
    eventPath: string
    eventId: string
    breakoutRoomId: string
}

export interface GetBreakoutRoomAssignmentRequest {
    eventPath: string
    eventId: string
}

export interface GetBreakoutRoomAssignmentResponse {
    roomId?: string
}

export interface InitiateBreakoutsRequest {
    eventPath: string
    breakoutSessionId?: string
    assignmentMethod?: BreakoutAssignmentMethod
    targetParticipantsPerRoom: number
    includeWaitingRoom?: boolean
}

export interface CheckAssignToBreakoutsRequest {
    eventPath: string
    breakoutSessionId?: string
}

export interface CheckHostlessGoToBreakoutsRequest {
    eventPath: string
}

export interface ReassignBreakoutRoomRequest {
    eventPath: string
    breakoutRoomSessionId: string
    userId: string
    newRoomNumber: string
}

export interface UpdateBreakoutRoomFlagStatusRequest {
    eventPath: string
    breakoutSessionId: string
    roomId: string
    flagStatus?: BreakoutRoomFlagStatus
}

export interface CheckAdvanceMeetingGuideRequest {
    eventPath: string
    breakoutSessionId?: string
    breakoutRoomId?: string
    userReadyAgendaId?: string
    presentIds: string[]
}

export interface KickParticipantRequest {
    eventPath: string
    userToKickId: string
    breakoutRoomId?: string
}

export interface VoteToKickRequest {
    eventPath: string
    liveMeetingPath: string
    targetUserId: string
    inFavor?: boolean
    reason?: string
}

export interface EventEndedRequest {
    eventPath: string
}

export interface GetMeetingPollDataRequest {
    eventPath: string
}

export interface GetMeetingPollDataResponse {
    polls: PollData[]
}

export interface PollData {
    userId?: string
    userName?: string
    userEmail?: string
    agendaItemId?: string
    pollQuestion?: string
    pollResponse?: unknown
    roomId?: string
    answeredDate?: Date
}

export interface GetMeetingChatSuggestionDataRequest {
    eventPath: string
}

export interface ResetParticipantAgendaItemsRequest {
    eventPath: string
    agendaItemId?: string
}

export interface ToggleLikeDislikeOnMeetingUserSuggestionRequest {
    eventPath: string
    suggestionId: string
    like?: boolean
}

export interface UpdateLiveStreamParticipantCountRequest {
    eventPath: string
    count: number
}

export interface GetUserIdFromAgoraIdRequest {
    agoraId: number
}

export interface CreateLiveStreamRequest {
    eventPath: string
}

export interface CreateDonationCheckoutSessionRequest {
    communityId: string
    amountInCents: number
}

export interface CreateDonationCheckoutSessionResponse {
    sessionId: string
}

export interface CreateSubscriptionCheckoutSessionRequest {
    type: PlanType
    appliedCommunityId: string
    returnRedirectPath: string
}

export interface CreateSubscriptionCheckoutSessionResponse {
    sessionId: string
}

export interface CreateStripeConnectedAccountRequest {
    agreementId: string
}

export interface GetStripeBillingPortalLinkRequest {
    returnRedirectPath: string
}

export interface GetStripeBillingPortalLinkResponse {
    url: string
}

export interface GetStripeConnectedAccountLinkRequest {
    agreementId: string
    returnRedirectPath: string
}

export interface GetStripeConnectedAccountLinkResponse {
    url: string
}

export interface GetStripeSubscriptionPlanInfoRequest {
    communityId: string
}

export interface UpdateStripeSubscriptionPlanRequest {
    subscriptionId: string
    type: PlanType
}

export interface CancelStripeSubscriptionPlanRequest {
    subscriptionId: string
}

export interface GetCommunityCalendarLinkRequest {
    eventPath: string
}

export interface GetCommunityCalendarLinkResponse {
    googleCalendarLink: string
    office365CalendarLink: string
    outlookCalendarLink: string
    icsLink: string
}

export interface GetServerTimestampRequest {
    [key: string]: unknown
}

export interface GetServerTimestampResponse {
    serverTimestamp: string
}

export const breakoutsWaitingRoomId = 'waiting-room'
export const reassignNewRoomId = 'new-room'
export const startMeetingAgendaItemId = 'start'
