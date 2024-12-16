import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:get_it/get_it.dart';
import 'package:junto_functions/functions/firestore_event_function.dart';
import 'package:junto_functions/functions/junto_cloud_function.dart';
import 'package:junto_functions/functions/on_call/cancel_stripe_subscription_plan.dart';
import 'package:junto_functions/functions/on_call/check_advance_meeting_guide.dart';
import 'package:junto_functions/functions/on_call/check_assign_to_breakouts.dart';
import 'package:junto_functions/functions/on_call/check_hostless_go_to_breakouts.dart';
import 'package:junto_functions/functions/on_call/create_announcement.dart';
import 'package:junto_functions/functions/on_call/create_discussion.dart';
import 'package:junto_functions/functions/on_call/create_donation_checkout_session.dart';
import 'package:junto_functions/functions/on_call/create_junto.dart';
import 'package:junto_functions/functions/on_call/create_live_stream.dart';
import 'package:junto_functions/functions/on_call/create_stripe_connected_account.dart';
import 'package:junto_functions/functions/on_call/create_subscription_checkout_session.dart';
import 'package:junto_functions/functions/on_call/discussion_ended.dart';
import 'package:junto_functions/functions/on_call/get_breakout_room_assignment.dart';
import 'package:junto_functions/functions/on_call/get_breakout_room_join_info.dart';
import 'package:junto_functions/functions/on_call/get_calendar_link.dart';
import 'package:junto_functions/functions/on_call/get_junto_capabilities.dart';
import 'package:junto_functions/functions/on_call/get_junto_donations_enabled.dart';
import 'package:junto_functions/functions/on_call/get_junto_pre_post_enabled.dart';
import 'package:junto_functions/functions/on_call/get_meeting_chat_suggestion_data.dart';
import 'package:junto_functions/functions/on_call/get_meeting_join_info.dart';
import 'package:junto_functions/functions/on_call/get_members_data.dart';
import 'package:junto_functions/functions/on_call/get_server_timestamp.dart';
import 'package:junto_functions/functions/on_call/get_stripe_billing_portal_link.dart';
import 'package:junto_functions/functions/on_call/get_stripe_connected_account_link.dart';
import 'package:junto_functions/functions/on_call/get_stripe_subscription_plan_info.dart';
import 'package:junto_functions/functions/on_call/get_user_admin_details.dart';
import 'package:junto_functions/functions/on_call/get_user_id_from_agora_id.dart';
import 'package:junto_functions/functions/on_call/helper_functions.dart';
import 'package:junto_functions/functions/on_call/initiate_breakouts.dart';
import 'package:junto_functions/functions/on_call/join_discussion.dart';
import 'package:junto_functions/functions/on_call/reassign_breakout_room.dart';
import 'package:junto_functions/functions/on_call/reset_participant_agenda_items.dart';
import 'package:junto_functions/functions/on_call/resolve_join_request.dart';
import 'package:junto_functions/functions/on_call/send_discussion_message.dart';
import 'package:junto_functions/functions/on_call/server_timestamp.dart';
import 'package:junto_functions/functions/on_call/toggle_like_dislike_on_meeting_user_suggestion.dart';
import 'package:junto_functions/functions/on_call/kick_participant.dart';
import 'package:junto_functions/functions/on_call/unsubscribe_from_junto_notifications.dart';
import 'package:junto_functions/functions/on_call/update_breakout_room_flag_status.dart';
import 'package:junto_functions/functions/on_call/update_junto.dart';
import 'package:junto_functions/functions/on_call/update_membership.dart';
import 'package:junto_functions/functions/on_call/update_stripe_subscription_plan.dart';
import 'package:junto_functions/functions/on_call/vote_to_kick.dart';
import 'package:junto_functions/functions/on_database/update_presence_status.dart';
import 'package:junto_functions/functions/on_firestore/on_discussion.dart';
import 'package:junto_functions/functions/on_firestore/on_discussion_thread.dart';
import 'package:junto_functions/functions/on_firestore/on_discussion_thread_comment.dart';
import 'package:junto_functions/functions/on_firestore/on_junto.dart';
import 'package:junto_functions/functions/on_firestore/on_junto_membership.dart';
import 'package:junto_functions/functions/on_firestore/on_partner_agreements.dart';
import 'package:junto_functions/functions/on_firestore/on_topic.dart';
import 'package:junto_functions/functions/on_request/calendar_feed_ics.dart';
import 'package:junto_functions/functions/on_request/calendar_feed_rss.dart';
import 'package:junto_functions/functions/on_request/check_assign_to_breakouts_server.dart';
import 'package:junto_functions/functions/on_request/check_hostless_go_to_breakouts_server.dart';
import 'package:junto_functions/functions/on_request/email_discussion_reminder.dart';
import 'package:junto_functions/functions/on_request/extend_cloud_task_scheduler.dart';
import 'package:junto_functions/functions/on_request/mux_webhooks.dart';
import 'package:junto_functions/functions/on_request/share_link.dart';
import 'package:junto_functions/functions/on_request/stripe_connected_account_webhooks.dart';
import 'package:junto_functions/functions/on_request/stripe_webhooks.dart';
import 'package:junto_functions/functions/on_scheduled/trigger_email_digests.dart';
import 'package:junto_functions/functions/on_scheduled/update_live_stream_participant_count.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:node_interop/node.dart';
import 'package:uuid/uuid.dart';

final _onCallHelperFunctions = <JuntoCloudFunction>[
  AddNewField(),
  RemoveExistingField(),
];

final _onCallFunctions = <JuntoCloudFunction>[
  CancelStripeSubscriptionPlan(),
  CheckAdvanceMeetingGuide(),
  CheckAssignToBreakouts(),
  CheckHostlessGoToBreakouts(),
  CreateAnnouncement(),
  CreateDonationCheckoutSession(),
  CreateDiscussion(),
  CreateJunto(),
  CreateLiveStream(),
  CreateStripeConnectedAccount(),
  CreateSubscriptionCheckoutSession(),
  GetBreakoutRoomAssignment(),
  GetBreakoutRoomJoinInfo(),
  GetJuntoCapabilities(),
  GetJuntoDonationsEnabled(),
  GetJuntoPrePostEnabled(),
  GetMeetingChatSuggestionData(),
  GetMeetingJoinInfo(),
  GetMembersData(),
  GetServerTimestamp(),
  GetStripeBillingPortalLink(),
  GetStripeConnectedAccountLink(),
  GetStripeSubscriptionPlanInfo(),
  GetUserAdminDetails(),
  GetUserIdFromAgoraId(),
  GetJuntoCalendarLink(),
  InitiateBreakouts(),
  JoinDiscussion(),
  ReassignBreakoutRoom(),
  ResetParticipantAgendaItems(),
  ResolveJoinRequest(),
  SendDiscussionMessage(),
  ServerTimestamp(),
  ToggleLikeDislikeOnMeetingUserSuggestion(),
  KickParticipant(),
  UnsubscribeFromJuntoNotifications(),
  UpdateBreakoutRoomFlagStatus(),
  UpdateJunto(),
  UpdateMembership(),
  UpdateStripeSubscriptionPlan(),
  VoteToKick(),
  DiscussionEnded(),
];

final _onRequestFunctions = <JuntoCloudFunction>[
  CalendarFeedIcs(),
  CalendarFeedRss(),
  CheckAssignToBreakoutsServer(),
  CheckHostlessGoToBreakoutsServer(),
  EmailDiscussionReminder(),
  ExtendCloudTaskScheduler(),
  MuxWebhooks(),
  ShareLink(),
  StripeConnectedAccountWebhooks(),
  StripeWebhooks(),
];

final _cloudFunctions = <JuntoCloudFunction>[
  ..._onCallHelperFunctions,
  ..._onCallFunctions,
  ..._onRequestFunctions,

  // On database functions
  UpdatePresenceStatus(),

  // On PubSub functions
  TriggerEmailDigests(),
  UpdateLiveStreamParticipantCount(),
];

final _eventFunctions = <FirestoreEventFunction>[
  OnDiscussion(),
  OnDiscussionThread(),
  OnDiscussionThreadComment(),
  OnJunto(),
  OnJuntoMembership(),
  OnPartnerAgreements(),
  OnTopic(),
];

void _registerServices() {
  setFirebaseAppFactory(() => FirebaseAdmin.instance.initializeApp()!);

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
