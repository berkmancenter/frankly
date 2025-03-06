import 'package:client/features/auth/utils/auth_utils.dart';
import 'package:flutter/material.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/core/widgets/buttons/thick_outline_button.dart';
import 'package:client/core/utils/firestore_utils.dart';
import 'package:client/features/user/data/services/user_data_service.dart';
import 'package:client/services.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:client/core/widgets/memoized_builder.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/community/membership_request.dart';
import 'package:provider/provider.dart';

class CommunityMembershipButton extends StatefulWidget {
  final Community community;
  final double? height;
  final double? minWidth;
  final String? text;
  final Color? bgColor;
  final Color textColor;

  const CommunityMembershipButton(
    this.community, {
    this.height,
    this.minWidth,
    this.text,
    this.bgColor,
    this.textColor = Colors.white,
  });

  @override
  _CommunityMembershipButtonState createState() =>
      _CommunityMembershipButtonState();
}

class _CommunityMembershipButtonState extends State<CommunityMembershipButton> {
  bool _hovered = false;

  Future<void> _requestCommunityMembership() async {
    await guardSignedIn(
      () => alertOnError(context, () async {
        // Check if user is already a member of this group
        await userDataService.memberships.first;

        final communityId = widget.community.id;
        final isMember = userDataService.isMember(communityId: communityId);
        if (isMember) return;

        final request = MembershipRequest(
          userId: userService.currentUserId!,
          communityId: widget.community.id,
          status: MembershipRequestStatus.requested,
        );
        await firestoreCommunityJoinRequestsService.createOrUpdateRequest(
          request: request,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final communityId = widget.community.id;
    final isMember = Provider.of<UserDataService>(context)
        .isMember(communityId: communityId);
    final userId = context.watch<UserService>().currentUserId!;
    final requiresApproval =
        widget.community.settingsMigration.requireApprovalToJoin;

    if (isMember) {
      return CustomInkWell(
        onHover: (hovered) => setState(() => _hovered = hovered),
        hoverColor: Colors.transparent,
        child: ThickOutlineButton(
          onPressed: () => alertOnError(
            context,
            () => userDataService.requestChangeCommunityMembership(
              community: widget.community,
              join: false,
            ),
          ),
          text: _hovered ? 'Unfollow' : 'Followed',
          backgroundColor: Colors.white,
          minWidth: widget.minWidth,
        ),
      );
    } else if (requiresApproval) {
      return MemoizedBuilder<BehaviorSubjectWrapper<MembershipRequest?>>(
        getter: () =>
            firestoreCommunityJoinRequestsService.getUserRequestForCommunityId(
          communityId: communityId,
          userId: userId,
        ),
        keys: [userId],
        builder: (context, stream) => CustomStreamBuilder<MembershipRequest?>(
          entryFrom: '_CommunityMembershipButtonState.build',
          stream: stream,
          height: 42,
          width: 42,
          builder: (_, request) {
            if (request == null) {
              return ActionButton(
                text: 'Request To Follow',
                textColor: widget.textColor,
                height: widget.height,
                minWidth: widget.minWidth,
                color: widget.bgColor,
                sendingIndicatorAlign: ActionButtonSendingIndicatorAlign.none,
                onPressed: () => _requestCommunityMembership(),
              );
            } else if ([
              MembershipRequestStatus.requested,
              MembershipRequestStatus.denied,
            ].contains(request.status)) {
              return ActionButton(
                text: 'Follow Request Sent',
                textColor: widget.textColor,
                height: widget.height,
                minWidth: widget.minWidth,
                color: widget.bgColor,
                sendingIndicatorAlign: ActionButtonSendingIndicatorAlign.none,
                onPressed: null,
              );
            } else {
              return ActionButton(
                text: widget.text ?? 'Follow',
                textColor: widget.textColor,
                height: widget.height,
                minWidth: widget.minWidth,
                color: widget.bgColor,
                sendingIndicatorAlign: ActionButtonSendingIndicatorAlign.none,
                onPressed: () => alertOnError(
                  context,
                  () => userDataService.requestChangeCommunityMembership(
                    community: widget.community,
                    join: true,
                  ),
                ),
              );
            }
          },
        ),
      );
    } else {
      return ActionButton(
        text: 'Follow',
        textColor: widget.textColor,
        minWidth: widget.minWidth,
        height: widget.height,
        color: widget.bgColor,
        sendingIndicatorAlign: ActionButtonSendingIndicatorAlign.none,
        onPressed: () => alertOnError(
          context,
          () => userDataService.requestChangeCommunityMembership(
            community: widget.community,
            join: true,
          ),
        ),
      );
    }
  }
}
