import 'package:flutter/material.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/data/providers/meeting_guide_card_store.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/providers/meeting_agenda_provider.dart';
import 'package:client/core/widgets/action_button.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/services.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/localization/localization_helper.dart';

class RaisingHandToggle extends StatelessWidget {
  const RaisingHandToggle({
    Key? key,
    required this.isHandRaised,
    required this.isCardMinimized,
  }) : super(key: key);

  final bool isHandRaised;
  final bool isCardMinimized;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: context.l10n.raiseHandToJoinSpeakerQueue,
      child: ActionButton(
        type: ActionButtonType.flat,
        sendingIndicatorAlign: ActionButtonSendingIndicatorAlign.none,
        minWidth: 0,
        height: 0,
        onPressed: () => firestoreMeetingGuideService.toggleHandRaise(
          agendaItemId: MeetingGuideCardStore.read(context)
                  ?.meetingGuideCardAgendaItem
                  ?.id ??
              '',
          userId: userService.currentUserId ?? '',
          liveMeetingPath: AgendaProvider.read(context).liveMeetingPath,
          isHandRaised: !isHandRaised,
        ),
        color: isHandRaised ? AppColor.darkBlue : AppColor.white,
        padding: isCardMinimized
            ? EdgeInsets.zero
            : EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: isCardMinimized
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              )
            : RoundedRectangleBorder(
                side: BorderSide(width: 2.0, color: AppColor.darkBlue),
                borderRadius: BorderRadius.circular(30),
              ),
        child: ProxiedImage(
          null,
          asset: AppAsset.raisedHand(),
          height: 22,
          width: 22,
          loadingColor: Colors.transparent,
        ),
      ),
    );
  }
}
