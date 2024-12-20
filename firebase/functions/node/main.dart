import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart'
    hide CloudFunction;
import 'package:get_it/get_it.dart';
import 'package:functions/firestore_event_function.dart';
import 'package:functions/cloud_function.dart';
import 'package:functions/admin/payments/cancel_stripe_subscription_plan.dart';
import 'package:functions/events/live_meetings/breakouts/check_advance_meeting_guide.dart';
import 'package:functions/events/live_meetings/breakouts/check_assign_to_breakouts.dart';
import 'package:functions/events/live_meetings/breakouts/check_hostless_go_to_breakouts.dart';
import 'package:functions/community/create_announcement.dart';
import 'package:functions/events/create_event.dart';
import 'package:functions/admin/payments/create_donation_checkout_session.dart';
import 'package:functions/community/create_community.dart';
import 'package:functions/events/live_meetings/create_live_stream.dart';
import 'package:functions/admin/payments/create_stripe_connected_account.dart';
import 'package:functions/admin/payments/create_subscription_checkout_session.dart';
import 'package:functions/events/event_ended.dart';
import 'package:functions/events/live_meetings/breakouts/get_breakout_room_assignment.dart';
import 'package:functions/events/live_meetings/breakouts/get_breakout_room_join_info.dart';
import 'package:functions/events/calendar/get_calendar_link.dart';
import 'package:functions/community/get_community_capabilities.dart';
import 'package:functions/community/get_community_donations_enabled.dart';
import 'package:functions/community/get_community_pre_post_enabled.dart';
import 'package:functions/events/live_meetings/get_meeting_chat_suggestion_data.dart';
import 'package:functions/events/live_meetings/get_meeting_join_info.dart';
import 'package:functions/community/get_members_data.dart';
import 'package:functions/utils/get_server_timestamp.dart';
import 'package:functions/admin/payments/get_stripe_billing_portal_link.dart';
import 'package:functions/admin/payments/get_stripe_connected_account_link.dart';
import 'package:functions/admin/payments/get_stripe_subscription_plan_info.dart';
import 'package:functions/community/get_user_admin_details.dart';
import 'package:functions/events/live_meetings/get_user_id_from_agora_id.dart';
import 'package:functions/events/live_meetings/breakouts/initiate_breakouts.dart';
import 'package:functions/events/join_event.dart';
import 'package:functions/events/live_meetings/breakouts/reassign_breakout_room.dart';
import 'package:functions/events/live_meetings/reset_participant_agenda_items.dart';
import 'package:functions/community/resolve_join_request.dart';
import 'package:functions/events/notifications/send_event_message.dart';
import 'package:functions/utils/server_timestamp.dart';
import 'package:functions/events/live_meetings/toggle_like_dislike_on_meeting_user_suggestion.dart';
import 'package:functions/events/live_meetings/kick_participant.dart';
import 'package:functions/community/unsubscribe_from_community_notifications.dart';
import 'package:functions/events/live_meetings/breakouts/update_breakout_room_flag_status.dart';
import 'package:functions/community/update_community.dart';
import 'package:functions/community/update_membership.dart';
import 'package:functions/admin/payments/update_stripe_subscription_plan.dart';
import 'package:functions/events/live_meetings/vote_to_kick.dart';
import 'package:functions/events/live_meetings/update_presence_status.dart';
import 'package:functions/events/on_event.dart';
import 'package:functions/discussion_threads/on_discussion_thread.dart';
import 'package:functions/discussion_threads/on_discussion_thread_comment.dart';
import 'package:functions/community/on_community.dart';
import 'package:functions/community/on_community_membership.dart';
import 'package:functions/admin/partner_agreements/on_partner_agreements.dart';
import 'package:functions/templates/on_template.dart';
import 'package:functions/events/calendar/calendar_feed_ics.dart';
import 'package:functions/events/calendar/calendar_feed_rss.dart';
import 'package:functions/events/live_meetings/breakouts/check_assign_to_breakouts_server.dart';
import 'package:functions/events/live_meetings/breakouts/check_hostless_go_to_breakouts_server.dart';
import 'package:functions/events/notifications/email_event_reminder.dart';
import 'package:functions/utils/extend_cloud_task_scheduler.dart';
import 'package:functions/events/live_meetings/mux_webhooks.dart';
import 'package:functions/utils/share_link.dart';
import 'package:functions/admin/payments/stripe_connected_account_webhooks.dart';
import 'package:functions/admin/payments/stripe_webhooks.dart';
import 'package:functions/community/trigger_email_digests.dart';
import 'package:functions/events/live_meetings/update_live_stream_participant_count.dart';
import 'package:functions/utils/firestore_utils.dart';
import 'package:node_interop/node.dart';
import 'package:uuid/uuid.dart';

final _onCallFunctions = <CloudFunction>[
  CancelStripeSubscriptionPlan(),
  CheckAdvanceMeetingGuide(),
  CheckAssignToBreakouts(),
  CheckHostlessGoToBreakouts(),
  CreateAnnouncement(),
  CreateDonationCheckoutSession(),
  CreateEvent(),
  CreateCommunity(),
  CreateLiveStream(),
  CreateStripeConnectedAccount(),
  CreateSubscriptionCheckoutSession(),
  GetBreakoutRoomAssignment(),
  GetBreakoutRoomJoinInfo(),
  GetCommunityCapabilities(),
  GetCommunityDonationsEnabled(),
  GetCommunityPrePostEnabled(),
  GetMeetingChatSuggestionData(),
  GetMeetingJoinInfo(),
  GetMembersData(),
  GetServerTimestamp(),
  GetStripeBillingPortalLink(),
  GetStripeConnectedAccountLink(),
  GetStripeSubscriptionPlanInfo(),
  GetUserAdminDetails(),
  GetUserIdFromAgoraId(),
  GetCommunityCalendarLink(),
  InitiateBreakouts(),
  JoinEvent(),
  ReassignBreakoutRoom(),
  ResetParticipantAgendaItems(),
  ResolveJoinRequest(),
  SendEventMessage(),
  ServerTimestamp(),
  ToggleLikeDislikeOnMeetingUserSuggestion(),
  KickParticipant(),
  UnsubscribeFromCommunityNotifications(),
  UpdateBreakoutRoomFlagStatus(),
  UpdateCommunity(),
  UpdateMembership(),
  UpdateStripeSubscriptionPlan(),
  VoteToKick(),
  EventEnded(),
];

final _onRequestFunctions = <CloudFunction>[
  CalendarFeedIcs(),
  CalendarFeedRss(),
  CheckAssignToBreakoutsServer(),
  CheckHostlessGoToBreakoutsServer(),
  EmailEventReminder(),
  ExtendCloudTaskScheduler(),
  MuxWebhooks(),
  ShareLink(),
  StripeConnectedAccountWebhooks(),
  StripeWebhooks(),
];

final _cloudFunctions = <CloudFunction>[
  ..._onCallFunctions,
  ..._onRequestFunctions,

  // On database functions
  UpdatePresenceStatus(),

  // On PubSub functions
  TriggerEmailDigests(),
  UpdateLiveStreamParticipantCount(),
];

final _eventFunctions = <FirestoreEventFunction>[
  OnEvent(),
  OnDiscussionThread(),
  OnDiscussionThreadComment(),
  OnCommunity(),
  OnCommunityMembership(),
  OnPartnerAgreements(),
  OnTemplate(),
];

void _registerServices() {
  setFirebaseAppFactory(() => FirebaseAdmin.instance.initializeApp()!);
  // reference firebaseApp to call initializeApp() and set singleton prior to
  // javascript function registration
  firebaseApp.firestore();
  GetIt.instance.registerSingleton(const Uuid());
}

void _registerJsFunctions() {
  functions['downloadRecording'] = require('../js/download-recordings.js');
  functions['imageProxy'] = require('../js/image-proxy.js');
}

void main() {
  _registerServices();

  for (var function in _cloudFunctions) {
    function.register(functions);
  }

  for (var function in _eventFunctions) {
    function.register(functions);
  }

  _registerJsFunctions();
}
