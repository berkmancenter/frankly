import 'package:flutter/material.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/firestore/chat.dart';
import 'package:junto_models/firestore/membership.dart';
import 'package:junto_models/firestore/topic.dart';
import 'package:provider/provider.dart';

/// A class that keeps track of the user's permissions in relation to the current community.
class CommunityPermissionsProvider with ChangeNotifier {
  CommunityPermissionsProvider({required this.juntoProvider});

  void initialize() {
    juntoUserDataService.addListener(notifyListeners);
  }

  @override
  void dispose() {
    juntoUserDataService.removeListener(notifyListeners);
    super.dispose();
  }

  final JuntoProvider juntoProvider;

  MembershipStatus get membershipStatus =>
      juntoUserDataService.getMembership(juntoProvider.juntoId).status ??
      MembershipStatus.nonmember;

  bool get canRequestToJoin => membershipStatus.isNotBanned;

  bool get canViewCommunityLinks => membershipStatus.isMember;

  bool get canRSVP {
    if (juntoProvider.settings.requireApprovalToJoin) {
      return membershipStatus.isMember;
    } else {
      return membershipStatus.isNotBanned;
    }
  }

  bool get canParticipateInChat => membershipStatus.isMember;

  bool get canCreateEvent {
    if (!juntoProvider.hasTopics && !canCreateTopic) {
      return false;
    } else if (juntoProvider.settings.dontAllowMembersToCreateMeetings) {
      return membershipStatus.isFacilitator;
    } else if (juntoProvider.settings.requireApprovalToJoin) {
      return membershipStatus.isMember;
    } else {
      return membershipStatus.isNotBanned;
    }
  }

  bool get canCreateTopic {
    if (juntoProvider.settings.allowUnofficialTopics) {
      return membershipStatus.isMember;
    } else {
      return membershipStatus.isMod;
    }
  }

  bool get canSeeCreateTopicButtonOnCommunityHomePage => membershipStatus.isMod;

  bool get canSkipChooseTemplate => canCreateTopic;

  bool get canModerateContent => membershipStatus.isMod;

  bool get canCreateLargeEvents => membershipStatus.isMod;

  bool get canFeatureItems => membershipStatus.isAdmin;

  bool get canEditCommunity => membershipStatus.isAdmin;

  bool get canDeleteCommunity => membershipStatus.isOwner;

  bool get isUserBillingManager =>
      juntoProvider.junto.creatorId != null &&
      juntoProvider.junto.creatorId == userService.currentUserId;

  bool canEditTopic(Topic topic) {
    return (!isNullOrEmpty(topic.creatorId) && topic.creatorId == userService.currentUserId) ||
        membershipStatus.isMod;
  }

  bool canDeleteTopic(Topic topic) {
    return (!isNullOrEmpty(topic.creatorId) && topic.creatorId == userService.currentUserId) ||
        membershipStatus.isAdmin;
  }

  bool canDeleteChatMessage(ChatMessage message) {
    return userService.currentUserId != null &&
        (userService.currentUserId == message.creatorId || canModerateContent);
  }

  static bool canEditCommunityFromId(String juntoId) => _membershipStatusOfJunto(juntoId).isAdmin;

  static MembershipStatus _membershipStatusOfJunto(String juntoId) =>
      juntoUserDataService.getMembership(juntoId).status ?? MembershipStatus.nonmember;

  static CommunityPermissionsProvider? read(BuildContext context) =>
      providerOrNull(() => Provider.of<CommunityPermissionsProvider>(context, listen: false));
}
