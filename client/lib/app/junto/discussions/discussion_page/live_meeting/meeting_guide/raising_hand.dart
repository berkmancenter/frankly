import 'package:flutter/material.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/meeting_guide/meeting_guide_card_store.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/meeting_agenda_provider.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/junto_image.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_asset.dart';
import 'package:junto/styles/app_styles.dart';

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
      message: 'Raise your hand to join the speaker queue',
      child: ActionButton(
        type: ActionButtonType.flat,
        sendingIndicatorAlign: ActionButtonSendingIndicatorAlign.none,
        minWidth: 0,
        height: 0,
        onPressed: () => firestoreMeetingGuideService.toggleHandRaise(
          agendaItemId: MeetingGuideCardStore.read(context)?.meetingGuideCardAgendaItem?.id ?? '',
          userId: userService.currentUserId ?? '',
          liveMeetingPath: AgendaProvider.read(context).liveMeetingPath,
          isHandRaised: !isHandRaised,
        ),
        color: isHandRaised ? AppColor.darkBlue : AppColor.white,
        padding:
            isCardMinimized ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: isCardMinimized
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              )
            : RoundedRectangleBorder(
                side: BorderSide(width: 2.0, color: AppColor.darkBlue),
                borderRadius: BorderRadius.circular(30),
              ),
        child: JuntoImage(
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
