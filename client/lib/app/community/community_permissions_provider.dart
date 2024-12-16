import 'package:flutter/material.dart';
import 'package:client/app/community/community_provider.dart';
import 'package:client/app/community/utils.dart';
import 'package:client/services/services.dart';
import 'package:data_models/firestore/chat.dart';
import 'package:data_models/firestore/membership.dart';
import 'package:data_models/firestore/template.dart';
import 'package:provider/provider.dart';

/// A class that keeps track of the user's permissions in relation to the current community.
class CommunityPermissionsProvider with ChangeNotifier {
  CommunityPermissionsProvider({required this.communityProvider});

  void initialize() {
    userDataService.addListener(notifyListeners);
  }

  @override
  void dispose() {
    userDataService.removeListener(notifyListeners);
    super.dispose();
  }

  final CommunityProvider communityProvider;

  MembershipStatus get membershipStatus =>
      userDataService.getMembership(communityProvider.communityId).status ??
      MembershipStatus.nonmember;

  bool get canRequestToJoin => membershipStatus.isNotBanned;

  bool get canViewCommunityLinks => membershipStatus.isMember;

  bool get canRSVP {
    if (communityProvider.settings.requireApprovalToJoin) {
      return membershipStatus.isMember;
    } else {
      return membershipStatus.isNotBanned;
    }
  }

  bool get canParticipateInChat => membershipStatus.isMember;

  bool get canCreateEvent {
    if (!communityProvider.hasTemplates && !canCreateTemplate) {
      return false;
    } else if (communityProvider.settings.dontAllowMembersToCreateMeetings) {
      return membershipStatus.isFacilitator;
    } else if (communityProvider.settings.requireApprovalToJoin) {
      return membershipStatus.isMember;
    } else {
      return membershipStatus.isNotBanned;
    }
  }

  bool get canCreateTemplate {
    if (communityProvider.settings.allowUnofficialTemplates) {
      return membershipStatus.isMember;
    } else {
      return membershipStatus.isMod;
    }
  }

  bool get canSeeCreateTemplateButtonOnCommunityHomePage =>
      membershipStatus.isMod;

  bool get canSkipChooseTemplate => canCreateTemplate;

  bool get canModerateContent => membershipStatus.isMod;

  bool get canCreateLargeEvents => membershipStatus.isMod;

  bool get canFeatureItems => membershipStatus.isAdmin;

  bool get canEditCommunity => membershipStatus.isAdmin;

  bool get canDeleteCommunity => membershipStatus.isOwner;

  bool get isUserBillingManager =>
      communityProvider.community.creatorId != null &&
      communityProvider.community.creatorId == userService.currentUserId;

  bool canEditTemplate(Template template) {
    return (!isNullOrEmpty(template.creatorId) &&
            template.creatorId == userService.currentUserId) ||
        membershipStatus.isMod;
  }

  bool canDeleteTemplate(Template template) {
    return (!isNullOrEmpty(template.creatorId) &&
            template.creatorId == userService.currentUserId) ||
        membershipStatus.isAdmin;
  }

  bool canDeleteChatMessage(ChatMessage message) {
    return userService.currentUserId != null &&
        (userService.currentUserId == message.creatorId || canModerateContent);
  }

  static bool canEditCommunityFromId(String communityId) =>
      _membershipStatusOfCommunity(communityId).isAdmin;

  static MembershipStatus _membershipStatusOfCommunity(String communityId) =>
      userDataService.getMembership(communityId).status ??
      MembershipStatus.nonmember;

  static CommunityPermissionsProvider? read(BuildContext context) =>
      providerOrNull(
        () => Provider.of<CommunityPermissionsProvider>(context, listen: false),
      );
}
