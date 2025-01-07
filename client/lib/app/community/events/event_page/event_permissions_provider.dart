import 'package:flutter/material.dart';
import 'package:client/app/community/community_permissions_provider.dart';
import 'package:client/app/community/events/event_page/event_provider.dart';
import 'package:client/app/community/community_provider.dart';
import 'package:client/app/community/utils.dart';
import 'package:client/services/services.dart';
import 'package:data_models/chat/chat.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/community/membership.dart';
import 'package:provider/provider.dart';

/// This class provides the user's permissions in relation to a particular event
class EventPermissionsProvider with ChangeNotifier {
  final EventProvider eventProvider;
  final CommunityProvider communityProvider;
  final CommunityPermissionsProvider communityPermissions;

  EventPermissionsProvider({
    required this.eventProvider,
    required this.communityPermissions,
    required this.communityProvider,
  });

  void initialize() => userDataService.addListener(() => notifyListeners());

  bool get avCheckEnabled =>
      communityProvider.settings.enableAVCheck &&
      eventProvider.event.eventType == EventType.hosted;

  bool get showTalkingTimeWarnings => !_isHost;

  bool get isAgendaVisibleOverride =>
      _isHost || communityPermissions.membershipStatus.isFacilitator;

  bool get canDuplicateEvent => communityPermissions.canCreateEvent;

  bool get canRefreshGuide => communityPermissions.membershipStatus.isMod;

  bool get canChat => eventProvider.isParticipant || canEditEvent;

  bool get canEditEvent {
    if (communityProvider.settings.allowUnofficialTemplates) {
      return _isHost || communityPermissions.membershipStatus.isMod;
    } else {
      return (_isHost && communityPermissions.membershipStatus.isFacilitator) ||
          communityPermissions.membershipStatus.isMod;
    }
  }

  bool get canDownloadRegistrationData =>
      communityPermissions.membershipStatus.isAdmin;

  bool get canModerateSuggestions =>
      _isHost || communityPermissions.membershipStatus.isMod;

  bool get canCancelEvent =>
      _isHost || communityPermissions.membershipStatus.isMod;

  bool get canAccessAdminTabInEvent {
    return _isHost || communityPermissions.membershipStatus.isFacilitator;
  }

  bool get canEditEventTitle {
    return canEditEvent &&
            (communityProvider.settings.allowUnofficialTemplates) ||
        communityPermissions.membershipStatus.isMod;
  }

  bool get canStartEvent =>
      _isHost || communityPermissions.membershipStatus.isMod;

  bool get canCancelParticipation {
    return !_isHost && eventProvider.isParticipant;
  }

  bool get canJoinEvent {
    if (eventProvider.event.isLocked) {
      return false;
    } else if (communityProvider.settings.requireApprovalToJoin) {
      return communityPermissions.membershipStatus.isMember;
    } else {
      return communityPermissions.membershipStatus.isNotBanned;
    }
  }

  bool get _isHost {
    return eventProvider.event.creatorId == userService.currentUserId;
  }

  bool get canBroadcastChat =>
      (_isHost || communityPermissions.membershipStatus.isMod) &&
      eventProvider.isLiveStream;

  bool get canPinItemInParticipantWidget => _isHost;

  bool canMuteParticipantInParticipantWidget(String userId) =>
      userId != userService.currentUserId && _isHost;

  bool canKickParticipantInParticipantWidget(String userId) =>
      userId != userService.currentUserId &&
      eventProvider.event.eventType == EventType.hostless;

  bool get canParticipate => eventProvider.isParticipant;

  bool canDeleteEventMessage(ChatMessage message) =>
      userService.currentUserId != null &&
      (userService.currentUserId == message.creatorId ||
          communityPermissions.canModerateContent);

  bool canDeleteSuggestedItem(SuggestedAgendaItem item) =>
      (item.creatorId == userService.currentUserId) ||
      _isHost ||
      communityPermissions.canModerateContent;

  bool canRemoveParticipant(Participant participant) {
    final participantIsHostOfEvent =
        participant.id == eventProvider.event.creatorId;
    final participantIsUser = participant.id == userService.currentUserId;

    return !participantIsHostOfEvent &&
        (_isHost ||
            participantIsUser ||
            communityPermissions.canModerateContent);
  }

  static EventPermissionsProvider? watch(BuildContext context) =>
      providerOrNull(() => Provider.of<EventPermissionsProvider>(context));

  static EventPermissionsProvider? read(BuildContext context) => providerOrNull(
        () => Provider.of<EventPermissionsProvider>(context, listen: false),
      );
}
