import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart'
    hide CloudFunction;
import 'package:get_it/get_it.dart';
import 'package:functions/functions/firestore_event_function.dart';
import 'package:functions/functions/cloud_function.dart';
import 'package:functions/functions/on_call/cancel_stripe_subscription_plan.dart';
import 'package:functions/functions/on_call/check_advance_meeting_guide.dart';
import 'package:functions/functions/on_call/check_assign_to_breakouts.dart';
import 'package:functions/functions/on_call/check_hostless_go_to_breakouts.dart';
import 'package:functions/functions/on_call/create_announcement.dart';
import 'package:functions/functions/on_call/create_event.dart';
import 'package:functions/functions/on_call/create_donation_checkout_session.dart';
import 'package:functions/functions/on_call/create_community.dart';
import 'package:functions/functions/on_call/create_live_stream.dart';
import 'package:functions/functions/on_call/create_stripe_connected_account.dart';
import 'package:functions/functions/on_call/create_subscription_checkout_session.dart';
import 'package:functions/functions/on_call/event_ended.dart';
import 'package:functions/functions/on_call/get_breakout_room_assignment.dart';
import 'package:functions/functions/on_call/get_breakout_room_join_info.dart';
import 'package:functions/functions/on_call/get_calendar_link.dart';
import 'package:functions/functions/on_call/get_community_capabilities.dart';
import 'package:functions/functions/on_call/get_community_donations_enabled.dart';
import 'package:functions/functions/on_call/get_community_pre_post_enabled.dart';
import 'package:functions/functions/on_call/get_meeting_chat_suggestion_data.dart';
import 'package:functions/functions/on_call/get_meeting_join_info.dart';
import 'package:functions/functions/on_call/get_members_data.dart';
import 'package:functions/functions/on_call/get_server_timestamp.dart';
import 'package:functions/functions/on_call/get_stripe_billing_portal_link.dart';
import 'package:functions/functions/on_call/get_stripe_connected_account_link.dart';
import 'package:functions/functions/on_call/get_stripe_subscription_plan_info.dart';
import 'package:functions/functions/on_call/get_user_admin_details.dart';
import 'package:functions/functions/on_call/get_user_id_from_agora_id.dart';
import 'package:functions/functions/on_call/initiate_breakouts.dart';
import 'package:functions/functions/on_call/join_event.dart';
import 'package:functions/functions/on_call/reassign_breakout_room.dart';
import 'package:functions/functions/on_call/reset_participant_agenda_items.dart';
import 'package:functions/functions/on_call/resolve_join_request.dart';
import 'package:functions/functions/on_call/send_event_message.dart';
import 'package:functions/functions/on_call/server_timestamp.dart';
import 'package:functions/functions/on_call/toggle_like_dislike_on_meeting_user_suggestion.dart';
import 'package:functions/functions/on_call/kick_participant.dart';
import 'package:functions/functions/on_call/unsubscribe_from_community_notifications.dart';
import 'package:functions/functions/on_call/update_breakout_room_flag_status.dart';
import 'package:functions/functions/on_call/update_community.dart';
import 'package:functions/functions/on_call/update_membership.dart';
import 'package:functions/functions/on_call/update_stripe_subscription_plan.dart';
import 'package:functions/functions/on_call/vote_to_kick.dart';
import 'package:functions/functions/on_database/update_presence_status.dart';
import 'package:functions/functions/on_firestore/on_event.dart';
import 'package:functions/functions/on_firestore/on_discussion_thread.dart';
import 'package:functions/functions/on_firestore/on_discussion_thread_comment.dart';
import 'package:functions/functions/on_firestore/on_community.dart';
import 'package:functions/functions/on_firestore/on_community_membership.dart';
import 'package:functions/functions/on_firestore/on_partner_agreements.dart';
import 'package:functions/functions/on_firestore/on_template.dart';
import 'package:functions/functions/on_request/calendar_feed_ics.dart';
import 'package:functions/functions/on_request/calendar_feed_rss.dart';
import 'package:functions/functions/on_request/check_assign_to_breakouts_server.dart';
import 'package:functions/functions/on_request/check_hostless_go_to_breakouts_server.dart';
import 'package:functions/functions/on_request/email_event_reminder.dart';
import 'package:functions/functions/on_request/extend_cloud_task_scheduler.dart';
import 'package:functions/functions/on_request/mux_webhooks.dart';
import 'package:functions/functions/on_request/share_link.dart';
import 'package:functions/functions/on_request/stripe_connected_account_webhooks.dart';
import 'package:functions/functions/on_request/stripe_webhooks.dart';
import 'package:functions/functions/on_scheduled/trigger_email_digests.dart';
import 'package:functions/functions/on_scheduled/update_live_stream_participant_count.dart';
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
