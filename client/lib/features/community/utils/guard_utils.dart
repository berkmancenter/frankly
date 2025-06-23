import 'package:client/core/widgets/confirm_dialog.dart';
import 'package:client/features/auth/utils/auth_utils.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/community/membership.dart';
import 'package:flutter/material.dart';
import 'package:client/services.dart';
import 'package:client/core/localization/localization_helper.dart';

Future<T?> guardCommunityMember<T>(
  BuildContext context,
  Community community,
  Future<T> Function() action,
) {
  final communityId = community.id;

  return guardSignedIn<T?>(() async {
    await userDataService.memberships.first;
    if (!userDataService.getMembership(communityId).isMember) {
      final joinCommunity = await ConfirmDialog(
        title: context.l10n.joinCommunity(community.name ?? ''),
        mainText:
            'You must be a member of this space to participate. Would you like to join?',
        confirmText: 'Yes, Join!',
        cancelText: context.l10n.cancel,
      ).show();

      if (!joinCommunity) return null;
    }

    await userDataService.changeCommunityMembership(
      userId: userService.currentUserId!,
      communityId: communityId,
      newStatus: MembershipStatus.member,
      allowMemberDowngrade: false,
    );
    return action();
  });
}
