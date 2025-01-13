import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/data/providers/meeting_guide_card_store.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/providers/meeting_agenda_provider.dart';
import 'package:client/features/events/features/event_page/presentation/widgets/survey_answer_tile.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/action_button.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/core/data/services/logging_service.dart';
import 'package:client/services.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/events/live_meetings/meeting_guide.dart';
import 'package:provider/provider.dart';

import 'meeting_guide_card_item_poll_contract.dart';
import '../../data/models/meeting_guide_card_item_poll_model.dart';
import '../meeting_guide_card_item_poll_presenter.dart';

class MeetingGuideCardItemPoll extends StatefulWidget {
  @override
  State<MeetingGuideCardItemPoll> createState() =>
      _MeetingGuideCardItemPollState();
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
    context.watch<EventProvider>();
    context.watch<MeetingGuideCardStore>();

    final userId = _presenter.getUserId();
    final liveMeetingPath = _presenter.getLiveMeetingPath();
    final agendaItem = _presenter.getCurrentAgendaItem();
    final pollAnswers = agendaItem?.pollAnswers ?? [];
    final participantAgendaItemDetailsStream =
        _presenter.getParticipantAgendaItemDetailsStream();
    final currentCardAgendaItemId = agendaItem?.id ?? '';

    // Should never happen
    if (agendaItem == null) {
      loggingService.log(
        '_MeetingGuideCardItemPollState.build: AgendaItem is null',
        logType: LogType.error,
      );
      return SizedBox.shrink();
    }

    return CustomStreamBuilder<List<ParticipantAgendaItemDetails>>(
      entryFrom: '_MeetingGuideCardItemPollState.build',
      stream: participantAgendaItemDetailsStream,
      height: 100,
      builder: (context, participantAgendaItemDetailsList) {
        if (_model.isShowingQuestions) {
          final currentVote =
              _presenter.getCurrentVote(participantAgendaItemDetailsList);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final answer in pollAnswers)
                _buildQuestions(
                  liveMeetingPath,
                  answer,
                  currentVote,
                  userId,
                  agendaItem.id,
                ),
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
            nonNullVotes,
            (item) => item.pollResponse!,
          );
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
                HeightConstrainedText('Awaiting responses…')
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
                  onPressed: () =>
                      _presenter.showQuestions(currentCardAgendaItemId),
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
                  () => _presenter.voteOnPoll(
                    agendaItemId,
                    userId,
                    liveMeetingPath,
                    newVote!,
                  ),
                );
              }
            },
          ),
          Expanded(
            child: HeightConstrainedText(
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
