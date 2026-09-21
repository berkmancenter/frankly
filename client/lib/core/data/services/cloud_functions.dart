import 'package:cloud_functions/cloud_functions.dart';
import 'package:client/core/utils/platform_utils.dart';

/// Callables with a same-origin `/api/<name>` rewrite in firebase.json. On web
/// these are called on the app origin, avoiding the cross-origin functions host
/// (which DNS filters / privacy relays / ad-blockers can block). Names NOT in
/// this set fall back to the cross-origin host, so a missing rewrite degrades
/// safely instead of breaking. Must stay in sync with firebase.json (see test).
const sameOriginCallables = {
  'CancelStripeSubscriptionPlan',
  'CheckAdvanceMeetingGuide',
  'CheckAssignToBreakouts',
  'CheckHostlessGoToBreakouts',
  'CreateLiveStream',
  'CreateSubscriptionCheckoutSession',
  'GetBreakoutRoomAssignment',
  'GetBreakoutRoomJoinInfo',
  'GetCommunityDonationsEnabled',
  'GetCommunityPrePostEnabled',
  'GetMeetingChatSuggestionData',
  'GetMeetingJoinInfo',
  'GetMeetingPollData',
  'GetMembersData',
  'GetServerTimestamp',
  'GetStripeSubscriptionPlanInfo',
  'GetUserAdminDetails',
  'GetUserIdFromAgoraId',
  'InitiateBreakouts',
  'KickParticipant',
  'ReassignBreakoutRoom',
  'ResetParticipantAgendaItems',
  'UpdateBreakoutRoomFlagStatus',
  'UpdateCommunity',
  'UpdateStripeSubscriptionPlan',
  'VoteToKick',
  'createCommunity',
  'createDonationCheckoutSession',
  'createEvent',
  'createStripeConnectedAccount',
  'eventEnded',
  'getCommunityCalendarLink',
  'getCommunityCapabilities',
  'getStripeBillingPortalLink',
  'getStripeConnectedAccountLink',
  'joinEvent',
  'resolveJoinRequest',
  'sendAnnouncement',
  'sendEventMessage',
  'toggleLikeDislikeOnMeetingUserSuggestion',
  'unsubscribeFromCommunityNotifications',
  'updateMembership',
};

class CloudFunctions {
  static bool usingEmulator = false;

  // Retry transient/never-reached failures only; never retry client-side errors.
  static const _retryableCodes = {
    'internal',
    'unavailable',
    'deadline-exceeded',
  };
  static const _maxRetries = 2;

  Future<void> initialize() async {
    if (usingEmulator) {
      FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
    }
  }

  /// On web (no emulator), [sameOriginCallables] are called via the app origin's
  /// `/api` rewrite to skip the cross-origin functions host and CORS preflight.
  Future<Map<String, dynamic>> callFunction(
    String function,
    Map<String, dynamic> data, {
    bool isWeb = true,
  }) async {
    final isLocalhost = Uri.base.origin.contains('localhost');
    final useRedirects = !usingEmulator && isWeb && !isLocalhost;

    Future<Map<String, dynamic>> attempt() async {
      if (useRedirects) {
        final sameOriginBase = sameOriginCallables.contains(function)
            ? '${Uri.base.origin}/api'
            : null;
        final callable = getHttpsCallableWeb(function, sameOriginBase)!;
        final result = await callable.call(data);
        return result ?? {};
      } else {
        final callable = FirebaseFunctions.instance.httpsCallable(function);
        final result = await callable.call(data);
        final resultData = result.data;
        if (resultData != null &&
            resultData is String &&
            resultData.trim().isEmpty) {
          return {};
        }
        return result.data ?? {};
      }
    }

    for (var attemptNum = 0;; attemptNum++) {
      try {
        return await attempt();
      } catch (e) {
        if (attemptNum >= _maxRetries || !_isRetryable(e)) {
          rethrow;
        }
        await Future<void>.delayed(
          Duration(milliseconds: 300 * (1 << attemptNum)),
        );
      }
    }
  }

  bool _isRetryable(Object e) {
    if (e is FirebaseFunctionsException) {
      return _retryableCodes.contains(e.code);
    }
    final s = e.toString().toLowerCase();
    return s.contains('failed to fetch') ||
        s.contains('networkerror') ||
        s.contains('network error') ||
        s.contains('hostname could not be found');
  }
}
