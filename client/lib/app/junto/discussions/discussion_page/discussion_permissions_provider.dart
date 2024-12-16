import 'package:flutter/material.dart';
import 'package:junto/app/junto/community_permissions_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_provider.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/firestore/chat.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/membership.dart';
import 'package:provider/provider.dart';

/// This class provides the user's permissions in relation to a particular discussion
class DiscussionPermissionsProvider with ChangeNotifier {
  final DiscussionProvider discussionProvider;
  final JuntoProvider juntoProvider;
  final CommunityPermissionsProvider communityPermissions;

  DiscussionPermissionsProvider({
    required this.discussionProvider,
    required this.communityPermissions,
    required this.juntoProvider,
  });

  void initialize() => juntoUserDataService.addListener(() => notifyListeners());

  bool get avCheckEnabled =>
      juntoProvider.settings.enableAVCheck &&
      discussionProvider.discussion.discussionType == DiscussionType.hosted;

  bool get showTalkingTimeWarnings => !_isHost;

  bool get isAgendaVisibleOverride =>
      _isHost || communityPermissions.membershipStatus.isFacilitator;

  bool get canDuplicateEvent => communityPermissions.canCreateEvent;

  bool get canRefreshGuide => communityPermissions.membershipStatus.isMod;

  bool get canChat => discussionProvider.isParticipant || canEditDiscussion;

  bool get canEditDiscussion {
    if (juntoProvider.settings.allowUnofficialTopics) {
      return _isHost || communityPermissions.membershipStatus.isMod;
    } else {
      return (_isHost && communityPermissions.membershipStatus.isFacilitator) ||
          communityPermissions.membershipStatus.isMod;
    }
  }

  bool get canDownloadRegistrationData => communityPermissions.membershipStatus.isAdmin;

  bool get canModerateSuggestions => _isHost || communityPermissions.membershipStatus.isMod;

  bool get canCancelDiscussion => _isHost || communityPermissions.membershipStatus.isMod;

  bool get canAccessAdminTabInDiscussion {
    return _isHost || communityPermissions.membershipStatus.isFacilitator;
  }

  bool get canEditDiscussionTitle {
    return canEditDiscussion && (juntoProvider.settings.allowUnofficialTopics) ||
        communityPermissions.membershipStatus.isMod;
  }

  bool get canStartDiscussion => _isHost || communityPermissions.membershipStatus.isMod;

  bool get canCancelParticipation {
    return !_isHost && discussionProvider.isParticipant;
  }

  bool get canJoinEvent {
    if (discussionProvider.discussion.isLocked) {
      return false;
    } else if (juntoProvider.settings.requireApprovalToJoin) {
      return communityPermissions.membershipStatus.isMember;
    } else {
      return communityPermissions.membershipStatus.isNotBanned;
    }
  }

  bool get _isHost {
    return discussionProvider.discussion.creatorId == userService.currentUserId;
  }

  bool get canBroadcastChat =>
      (_isHost || communityPermissions.membershipStatus.isMod) && discussionProvider.isLiveStream;

  bool get canPinItemInParticipantWidget => _isHost;

  bool canMuteParticipantInParticipantWidget(String userId) =>
      userId != userService.currentUserId && _isHost;

  bool canKickParticipantInParticipantWidget(String userId) =>
      userId != userService.currentUserId &&
      discussionProvider.discussion.discussionType == DiscussionType.hostless;

  bool get canParticipate => discussionProvider.isParticipant;

  bool canDeleteDiscussionMessage(ChatMessage message) =>
      userService.currentUserId != null &&
      (userService.currentUserId == message.creatorId || communityPermissions.canModerateContent);

  bool canDeleteSuggestedItem(SuggestedAgendaItem item) =>
      (item.creatorId == userService.currentUserId) ||
      _isHost ||
      communityPermissions.canModerateContent;

  bool canRemoveParticipant(Participant participant) {
    final participantIsHostOfDiscussion = participant.id == discussionProvider.discussion.creatorId;
    final participantIsUser = participant.id == userService.currentUserId;

    return !participantIsHostOfDiscussion &&
        (_isHost || participantIsUser || communityPermissions.canModerateContent);
  }

  static DiscussionPermissionsProvider? watch(BuildContext context) =>
      providerOrNull(() => Provider.of<DiscussionPermissionsProvider>(context));

  static DiscussionPermissionsProvider? read(BuildContext context) =>
      providerOrNull(() => Provider.of<DiscussionPermissionsProvider>(context, listen: false));
}
