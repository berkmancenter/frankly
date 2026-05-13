import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'

admin.initializeApp()

// ── Utilities ────────────────────────────────────────────────────────────────
import { GetServerTimestamp } from './utils/get_server_timestamp'

// ── Community ─────────────────────────────────────────────────────────────────
import { CreateCommunity } from './community/create_community'
import { CreateAnnouncement } from './community/create_announcement'
import { GetCommunityCapabilities } from './community/get_community_capabilities'
import { GetCommunityDonationsEnabled } from './community/get_community_donations_enabled'
import { GetCommunityPrePostEnabled } from './community/get_community_pre_post_enabled'
import { GetMembersData } from './community/get_members_data'
import { GetUserAdminDetails } from './community/get_user_admin_details'
import { ResolveJoinRequest } from './community/resolve_join_request'
import { TriggerEmailDigests } from './community/trigger_email_digests'
import { UnsubscribeFromCommunityNotifications } from './community/unsubscribe_from_community_notifications'
import { UpdateCommunity } from './community/update_community'
import { UpdateMembership } from './community/update_membership'
import { OnCommunity } from './community/on_community'
import { OnCommunityMembership } from './community/on_community_membership'

// ── Events ────────────────────────────────────────────────────────────────────
import { CreateEvent } from './events/create_event'
import { EventEnded } from './events/event_ended'
import { JoinEvent } from './events/join_event'
import { OnEvent } from './events/on_event'

// ── Notifications ─────────────────────────────────────────────────────────────
import { EmailEventReminder } from './events/notifications/email_event_reminder'
import { SendEventMessage } from './events/notifications/send_event_message'

// ── Calendar ──────────────────────────────────────────────────────────────────
import { CalendarFeedIcs } from './events/calendar/calendar_feed_ics'
import { CalendarFeedRss } from './events/calendar/calendar_feed_rss'
import { GetCommunityCalendarLink } from './events/calendar/get_calendar_link'

// ── Live Meetings ─────────────────────────────────────────────────────────────
import { GetMeetingJoinInfo } from './events/live_meetings/get_meeting_join_info'
import { GetMeetingPollData } from './events/live_meetings/get_meeting_poll_data'
import { GetMeetingChatSuggestionData } from './events/live_meetings/get_meeting_chat_suggestion_data'
import { KickParticipant } from './events/live_meetings/kick_participant'
import { VoteToKick } from './events/live_meetings/vote_to_kick'
import { ResetParticipantAgendaItems } from './events/live_meetings/reset_participant_agenda_items'
import { ToggleLikeDislikeOnMeetingUserSuggestion } from './events/live_meetings/toggle_like_dislike_on_meeting_user_suggestion'
import { GetUserIdFromAgoraId } from './events/live_meetings/get_user_id_from_agora_id'
import { CreateLiveStream } from './events/live_meetings/create_live_stream'
import { MuxWebhooks } from './events/live_meetings/mux_webhooks'
import { UpdateLiveStreamParticipantCount } from './events/live_meetings/update_live_stream_participant_count'
import { UpdatePresenceStatus } from './events/live_meetings/update_presence_status'

// ── Breakouts ─────────────────────────────────────────────────────────────────
import { InitiateBreakouts } from './events/live_meetings/breakouts/initiate_breakouts'
import { CheckAssignToBreakouts } from './events/live_meetings/breakouts/check_assign_to_breakouts'
import { CheckAssignToBreakoutsServer } from './events/live_meetings/breakouts/check_assign_to_breakouts_server'
import { CheckHostlessGoToBreakouts } from './events/live_meetings/breakouts/check_hostless_go_to_breakouts'
import { CheckHostlessGoToBreakoutsServer } from './events/live_meetings/breakouts/check_hostless_go_to_breakouts_server'
import { GetBreakoutRoomJoinInfo } from './events/live_meetings/breakouts/get_breakout_room_join_info'
import { GetBreakoutRoomAssignment } from './events/live_meetings/breakouts/get_breakout_room_assignment'
import { ReassignBreakoutRoom } from './events/live_meetings/breakouts/reassign_breakout_room'
import { UpdateBreakoutRoomFlagStatus } from './events/live_meetings/breakouts/update_breakout_room_flag_status'
import { CheckAdvanceMeetingGuide } from './events/live_meetings/breakouts/check_advance_meeting_guide'

// ── Admin Payments ─────────────────────────────────────────────────────────────
import { StripeWebhooks } from './admin/payments/stripe_webhooks'
import { StripeConnectedAccountWebhooks } from './admin/payments/stripe_connected_account_webhooks'
import { CreateDonationCheckoutSession } from './admin/payments/create_donation_checkout_session'
import { CreateSubscriptionCheckoutSession } from './admin/payments/create_subscription_checkout_session'
import { CreateStripeConnectedAccount } from './admin/payments/create_stripe_connected_account'
import { GetStripeBillingPortalLink } from './admin/payments/get_stripe_billing_portal_link'
import { GetStripeConnectedAccountLink } from './admin/payments/get_stripe_connected_account_link'
import { GetStripeSubscriptionPlanInfo } from './admin/payments/get_stripe_subscription_plan_info'
import { UpdateStripeSubscriptionPlan } from './admin/payments/update_stripe_subscription_plan'
import { CancelStripeSubscriptionPlan } from './admin/payments/cancel_stripe_subscription_plan'

// ── Admin Partner Agreements ───────────────────────────────────────────────────
import { OnPartnerAgreements } from './admin/partner_agreements/on_partner_agreements'

// ── Discussion Threads ────────────────────────────────────────────────────────
import { OnDiscussionThread } from './discussion_threads/on_discussion_thread'
import { OnDiscussionThreadComment } from './discussion_threads/on_discussion_thread_comment'

// ── Templates ─────────────────────────────────────────────────────────────────
import { OnTemplate } from './templates/on_template'
import { OnRequestMethod } from './on_request_method'

// ═══════════════════════════════════════════════════════════════════════════════
// Register OnCall / OnRequest functions (single export)
// ═══════════════════════════════════════════════════════════════════════════════

exports.GetServerTimestamp = new GetServerTimestamp().register()

// Community
exports.CreateCommunity = new CreateCommunity().register()
exports.CreateAnnouncement = new CreateAnnouncement().register()
exports.GetCommunityCapabilities = new GetCommunityCapabilities().register()
exports.GetCommunityDonationsEnabled = new GetCommunityDonationsEnabled().register()
exports.GetCommunityPrePostEnabled = new GetCommunityPrePostEnabled().register()
exports.GetMembersData = new GetMembersData().register()
exports.GetUserAdminDetails = new GetUserAdminDetails().register()
exports.ResolveJoinRequest = new ResolveJoinRequest().register()
exports.TriggerEmailDigests = new TriggerEmailDigests().register()
exports.UnsubscribeFromCommunityNotifications =
    new UnsubscribeFromCommunityNotifications().register()
exports.UpdateCommunity = new UpdateCommunity().register()
exports.UpdateMembership = new UpdateMembership().register()

// Events
exports.CreateEvent = new CreateEvent().register()
exports.EventEnded = new EventEnded().register()
exports.JoinEvent = new JoinEvent().register()

// Notifications
exports.EmailEventReminder = new EmailEventReminder().register()
exports.SendEventMessage = new SendEventMessage().register()

// Calendar
exports.GetCommunityCalendarLink = new GetCommunityCalendarLink().register()

// Live Meetings
exports.GetMeetingJoinInfo = new GetMeetingJoinInfo().register()
exports.GetMeetingPollData = new GetMeetingPollData().register()
exports.GetMeetingChatSuggestionData = new GetMeetingChatSuggestionData().register()
exports.KickParticipant = new KickParticipant().register()
exports.VoteToKick = new VoteToKick().register()
exports.ResetParticipantAgendaItems = new ResetParticipantAgendaItems().register()
exports.ToggleLikeDislikeOnMeetingUserSuggestion =
    new ToggleLikeDislikeOnMeetingUserSuggestion().register()
exports.GetUserIdFromAgoraId = new GetUserIdFromAgoraId().register()
exports.CreateLiveStream = new CreateLiveStream().register()
exports.MuxWebhooks = new MuxWebhooks().register()

// Breakouts
exports.InitiateBreakouts = new InitiateBreakouts().register()
exports.CheckAssignToBreakouts = new CheckAssignToBreakouts().register()
exports.CheckAssignToBreakoutsServer = new CheckAssignToBreakoutsServer().register()
exports.CheckHostlessGoToBreakouts = new CheckHostlessGoToBreakouts().register()
exports.CheckHostlessGoToBreakoutsServer = new CheckHostlessGoToBreakoutsServer().register()
exports.GetBreakoutRoomJoinInfo = new GetBreakoutRoomJoinInfo().register()
exports.GetBreakoutRoomAssignment = new GetBreakoutRoomAssignment().register()
exports.ReassignBreakoutRoom = new ReassignBreakoutRoom().register()
exports.UpdateBreakoutRoomFlagStatus = new UpdateBreakoutRoomFlagStatus().register()
exports.CheckAdvanceMeetingGuide = new CheckAdvanceMeetingGuide().register()

// Admin Payments
exports.StripeWebhooks = new StripeWebhooks().register()
exports.StripeConnectedAccountWebhooks = new StripeConnectedAccountWebhooks().register()
exports.CreateDonationCheckoutSession = new CreateDonationCheckoutSession().register()
exports.CreateSubscriptionCheckoutSession = new CreateSubscriptionCheckoutSession().register()
exports.CreateStripeConnectedAccount = new CreateStripeConnectedAccount().register()
exports.GetStripeBillingPortalLink = new GetStripeBillingPortalLink().register()
exports.GetStripeConnectedAccountLink = new GetStripeConnectedAccountLink().register()
exports.GetStripeSubscriptionPlanInfo = new GetStripeSubscriptionPlanInfo().register()
exports.UpdateStripeSubscriptionPlan = new UpdateStripeSubscriptionPlan().register()
exports.CancelStripeSubscriptionPlan = new CancelStripeSubscriptionPlan().register()

// ═══════════════════════════════════════════════════════════════════════════════
// Register CloudFunction implementations (register takes `functions` param)
// ═══════════════════════════════════════════════════════════════════════════════

exports.UpdatePresenceStatus = new UpdatePresenceStatus().register(functions)
exports.UpdateLiveStreamParticipantCount = new UpdateLiveStreamParticipantCount().register(
    functions
)
exports.CalendarFeedIcs = new CalendarFeedIcs().register(functions)
exports.CalendarFeedRss = new CalendarFeedRss().register(functions)

// ═══════════════════════════════════════════════════════════════════════════════
// Register OnFirestoreFunction implementations (register returns Record)
// ═══════════════════════════════════════════════════════════════════════════════

function registerFirestoreFunctions(
    record: Record<string, functions.CloudFunction<unknown>>
): void {
    for (const [name, fn] of Object.entries(record)) {
        exports[name] = fn
    }
}

registerFirestoreFunctions(
    new OnCommunity().register() as Record<string, functions.CloudFunction<unknown>>
)
registerFirestoreFunctions(
    new OnCommunityMembership().register() as Record<string, functions.CloudFunction<unknown>>
)
registerFirestoreFunctions(
    new OnEvent().register() as Record<string, functions.CloudFunction<unknown>>
)
registerFirestoreFunctions(
    new OnPartnerAgreements().register() as Record<string, functions.CloudFunction<unknown>>
)
registerFirestoreFunctions(
    new OnDiscussionThread().register() as Record<string, functions.CloudFunction<unknown>>
)
registerFirestoreFunctions(
    new OnDiscussionThreadComment().register() as Record<string, functions.CloudFunction<unknown>>
)
registerFirestoreFunctions(
    new OnTemplate().register() as Record<string, functions.CloudFunction<unknown>>
)
