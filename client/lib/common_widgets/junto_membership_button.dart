import 'package:flutter/material.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/common_widgets/thick_outline_button.dart';
import 'package:junto/services/firestore/firestore_utils.dart';
import 'package:junto/services/junto_user_data_service.dart';
import 'package:junto/services/services.dart';
import 'package:junto/services/user_service.dart';
import 'package:junto/utils/memoized_builder.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:junto_models/firestore/membership_request.dart';
import 'package:provider/provider.dart';

class JuntoMembershipButton extends StatefulWidget {
  final Junto junto;
  final double? height;
  final double? minWidth;
  final String? text;
  final Color? bgColor;
  final Color textColor;

  const JuntoMembershipButton(
    this.junto, {
    this.height,
    this.minWidth,
    this.text,
    this.bgColor,
    this.textColor = Colors.white,
  });

  @override
  _JuntoMembershipButtonState createState() => _JuntoMembershipButtonState();
}

class _JuntoMembershipButtonState extends State<JuntoMembershipButton> {
  bool _hovered = false;

  Future<void> _requestJuntoMembership() async {
    await guardSignedIn(() => alertOnError(context, () async {
          // Check if user is already a member of this group
          await juntoUserDataService.memberships.first;

          final juntoId = widget.junto.id;
          final isMember = juntoUserDataService.isMember(juntoId: juntoId);
          if (isMember) return;

          final request = MembershipRequest(
              userId: userService.currentUserId!,
              juntoId: widget.junto.id,
              status: MembershipRequestStatus.requested);
          await firestoreJuntoJoinRequestsService.createOrUpdateRequest(request: request);
        }));
  }

  @override
  Widget build(BuildContext context) {
    final juntoId = widget.junto.id;
    final isMember = Provider.of<JuntoUserDataService>(context).isMember(juntoId: juntoId);
    final userId = context.watch<UserService>().currentUserId!;
    final requiresApproval = widget.junto.settingsMigration.requireApprovalToJoin;

    if (isMember) {
      return JuntoInkWell(
        onHover: (hovered) => setState(() => _hovered = hovered),
        hoverColor: Colors.transparent,
        child: ThickOutlineButton(
          onPressed: () => alertOnError(
              context,
              () => juntoUserDataService.requestChangeJuntoMembership(
                    junto: widget.junto,
                    join: false,
                  )),
          text: _hovered ? 'Unfollow' : 'Followed',
          whiteBackground: false,
          minWidth: widget.minWidth,
        ),
      );
    } else if (requiresApproval) {
      return MemoizedBuilder<BehaviorSubjectWrapper<MembershipRequest?>>(
        getter: () => firestoreJuntoJoinRequestsService.getUserRequestForJuntoId(
          juntoId: juntoId,
          userId: userId,
        ),
        keys: [userId],
        builder: (context, stream) => JuntoStreamBuilder<MembershipRequest?>(
          entryFrom: '_JuntoMembershipButtonState.build',
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
                onPressed: () => _requestJuntoMembership(),
              );
            } else if ([MembershipRequestStatus.requested, MembershipRequestStatus.denied]
                .contains(request.status)) {
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
                    () => juntoUserDataService.requestChangeJuntoMembership(
                          junto: widget.junto,
                          join: true,
                        )),
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
            () => juntoUserDataService.requestChangeJuntoMembership(
                  junto: widget.junto,
                  join: true,
                )),
      );
    }
  }
}
