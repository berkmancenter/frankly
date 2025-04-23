import 'package:client/core/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:client/features/events/features/live_meeting/data/providers/live_meeting_provider.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/data/providers/meeting_guide_card_store.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/presentation/widgets/raising_hand.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/providers/meeting_agenda_provider.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/features/user/data/services/user_data_service.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/app_styles.dart';
import 'package:data_models/events/live_meetings/meeting_guide.dart';
import 'package:provider/provider.dart';

import 'meeting_guide_minimized_card_contract.dart';
import '../../data/models/meeting_guide_minimized_card_model.dart';
import '../meeting_guide_minimized_card_presenter.dart';

class MeetingGuideMinimizedCard extends StatefulWidget {
  final void Function() onExpandCard;

  const MeetingGuideMinimizedCard({Key? key, required this.onExpandCard})
      : super(key: key);

  @override
  State<MeetingGuideMinimizedCard> createState() =>
      _MeetingGuideMinimizedCardState();
}

class _MeetingGuideMinimizedCardState extends State<MeetingGuideMinimizedCard>
    implements MeetingGuideMinimizedCardView {
  late final MeetingGuideMinimizedCardModel _model;
  late final MeetingGuideMinimizedCardPresenter _presenter;

  @override
  void initState() {
    super.initState();

    _model = MeetingGuideMinimizedCardModel();
    _presenter = MeetingGuideMinimizedCardPresenter(context, this, _model);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<MeetingGuideCardStore>();
    context.watch<LiveMeetingProvider>();
    context.watch<UserDataService>();
    context.watch<CommunityProvider>();
    context.watch<AgendaProvider>();

    const spacerPadding = EdgeInsets.symmetric(horizontal: 10.0);

    final participantAgendaItemDetailsStream =
        _presenter.getParticipantAgendaItemDetailsStream();
    final agendaItem = _presenter.getCurrentItem();
    final currentItemId = _presenter.getCurrentAgendaModelItemId();
    final isHandRaised = _presenter.isHandRaised();
    final isMeetingFinished = _presenter.isMeetingFinished();

    final showNextButton =
        !_presenter.isHosted() || _presenter.canUserControlMeeting();

    return Container(
      margin: const EdgeInsets.only(top: 2, right: 5),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (agendaItem != null)
            Padding(
              padding: spacerPadding,
              child: RaisingHandToggle(
                isHandRaised: isHandRaised,
                isCardMinimized: true,
              ),
            ),
          if (currentItemId != null && showNextButton)
            CustomStreamBuilder<List<ParticipantAgendaItemDetails>>(
              entryFrom: '_MeetingGuideMinimizedCardState.build',
              stream: participantAgendaItemDetailsStream,
              showLoading: false,
              builder: (context, itemDetails) {
                final isReadyToAdvance = _presenter.readyToAdvance(itemDetails);

                return Padding(
                  padding: spacerPadding,
                  child: isMeetingFinished || isReadyToAdvance
                      ? Icon(
                          Icons.check_circle_outline_rounded,
                          color: AppColor.brightGreen,
                        )
                      : _ForwardButton(currentAgendaItemId: currentItemId),
                );
              },
            ),
          Padding(
            padding: spacerPadding,
            child: ActionButton(
              tooltipText: 'Show Agenda Item',
              type: ActionButtonType.flat,
              sendingIndicatorAlign: ActionButtonSendingIndicatorAlign.none,
              minWidth: 40,
              onPressed: widget.onExpandCard,
              color: AppColor.white,
              padding: EdgeInsets.zero,
              child: ProxiedImage(
                null,
                asset: AppAsset.kMaximizePng,
                height: 23,
                width: 22,
                loadingColor: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void updateView() {
    setState(() {});
  }
}

class _ForwardButton extends HookWidget {
  final String currentAgendaItemId;

  const _ForwardButton({
    Key? key,
    required this.currentAgendaItemId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final agendaProvider = AgendaProvider.watch(context);

    return ActionButton(
      type: ActionButtonType.flat,
      sendingIndicatorAlign: ActionButtonSendingIndicatorAlign.none,
      minWidth: 40,
      onPressed: () => alertOnError(context, () async {
        await agendaProvider.moveForward(
          currentAgendaItemId: currentAgendaItemId,
        );
        showRegularToast(
          context,
          "You're ready to move on",
          toastType: ToastType.success,
        );
      }),
      color: AppColor.white,
      padding: EdgeInsets.zero,
      child: ProxiedImage(
        null,
        asset: AppAsset.kMoveForwardPng,
        height: 22,
        width: 22,
        loadingColor: Colors.transparent,
      ),
    );
  }
}
