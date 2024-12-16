import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/meeting_guide/meeting_guide_card_store.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/meeting_agenda_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/survey_answer_tile.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/services/logging_service.dart';
import 'package:junto/services/services.dart';
import 'package:junto/services/user_service.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto_models/firestore/meeting_guide.dart';
import 'package:provider/provider.dart';

import 'meeting_guide_card_item_poll_contract.dart';
import 'meeting_guide_card_item_poll_model.dart';
import 'meeting_guide_card_item_poll_presenter.dart';

class MeetingGuideCardItemPoll extends StatefulWidget {
  @override
  State<MeetingGuideCardItemPoll> createState() => _MeetingGuideCardItemPollState();
}

class _MeetingGuideCardItemPollState extends State<MeetingGuideCardItemPoll>
    implements MeetingGuideCardItemPollView {
  late final MeetingGuideCardItemPollModel _model;
  late final MeetingGuideCardItemPollPresenter _presenter;

  @override
  void initState() {
    super.initState();

    _model = MeetingGuideCardItemPollModel();
    _presenter = MeetingGuideCardItemPollPresenter(context, this, _model);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AgendaProvider>();
    context.watch<UserService>();
    context.watch<DiscussionProvider>();
    context.watch<MeetingGuideCardStore>();

    final userId = _presenter.getUserId();
    final liveMeetingPath = _presenter.getLiveMeetingPath();
    final agendaItem = _presenter.getCurrentAgendaItem();
    final pollAnswers = agendaItem?.pollAnswers ?? [];
    final participantAgendaItemDetailsStream = _presenter.getParticipantAgendaItemDetailsStream();
    final currentCardAgendaItemId = agendaItem?.id ?? '';

    // Should never happen
    if (agendaItem == null) {
      loggingService.log(
        '_MeetingGuideCardItemPollState.build: AgendaItem is null',
        logType: LogType.error,
      );
      return SizedBox.shrink();
    }

    return JuntoStreamBuilder<List<ParticipantAgendaItemDetails>>(
      entryFrom: '_MeetingGuideCardItemPollState.build',
      stream: participantAgendaItemDetailsStream,
      height: 100,
      builder: (context, participantAgendaItemDetailsList) {
        if (_model.isShowingQuestions) {
          final currentVote = _presenter.getCurrentVote(participantAgendaItemDetailsList);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final answer in pollAnswers)
                _buildQuestions(liveMeetingPath, answer, currentVote, userId, agendaItem.id),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: ActionButton(
                  text: 'Show Results',
                  color: AppColor.darkBlue,
                  textColor: AppColor.brightGreen,
                  onPressed: currentVote != null
                      ? () => _presenter.showResults(currentCardAgendaItemId)
                      : null,
                ),
              ),
            ],
          );
        } else {
          final nonNullVotes = (participantAgendaItemDetailsList ?? []).where(
            (p) => p.pollResponse != null,
          );
          final responseMap = groupBy<ParticipantAgendaItemDetails, String>(
              nonNullVotes, (item) => item.pollResponse!);
          final voteTotal = responseMap.values.expand((votes) => votes).length;
          final answers = responseMap.entries
              .where((e) => pollAnswers.contains(e.key))
              .sortedBy<num>((e) => e.value.length)
              .reversed
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (answers.isEmpty)
                JuntoText('Awaiting responses…')
              else ...[
                for (final answer in answers)
                  SurveyAnswerTile(
                    answer: answer.key,
                    totalParticipants: voteTotal,
                    answeredParticipants: answer.value.length,
                  ),
              ],
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: ActionButton(
                  type: ActionButtonType.outline,
                  text: 'Show Questions',
                  color: Colors.transparent,
                  onPressed: () => _presenter.showQuestions(currentCardAgendaItemId),
                  borderSide: BorderSide(color: AppColor.darkBlue),
                  textColor: AppColor.darkBlue,
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildQuestions(
    String liveMeetingPath,
    String value,
    String? vote,
    String userId,
    String agendaItemId,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Radio<String>(
              activeColor: AppColor.darkBlue,
              value: value,
              groupValue: vote,
              onChanged: (newVote) async {
                if (newVote != vote) {
                  await alertOnError(
                    context,
                    () => _presenter.voteOnPoll(agendaItemId, userId, liveMeetingPath, newVote!),
                  );
                }
              }),
          Expanded(
            child: JuntoText(
              value,
              style: AppTextStyle.body.copyWith(color: AppColor.darkBlue),
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
