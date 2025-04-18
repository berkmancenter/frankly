import 'package:flutter/material.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/views/agenda_item_poll_contract.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_poll_data.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_poll_model.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/agenda_item_poll_presenter.dart';
import 'package:client/features/events/features/event_page/presentation/widgets/survey_answer_tile.dart';
import 'package:client/core/widgets/custom_text_field.dart';

class AgendaItemPoll extends StatefulWidget {
  final bool isEditMode;
  final AgendaItemPollData agendaItemPollData;
  final void Function(AgendaItemPollData) onChanged;

  const AgendaItemPoll({
    Key? key,
    required this.isEditMode,
    required this.agendaItemPollData,
    required this.onChanged,
  }) : super(key: key);

  @override
  _AgendaItemPollState createState() => _AgendaItemPollState();
}

class _AgendaItemPollState extends State<AgendaItemPoll>
    implements AgendaItemPollView {
  late AgendaItemPollModel _model;
  late AgendaItemPollPresenter _presenter;

  void _init() {
    _model = AgendaItemPollModel(
      widget.isEditMode,
      widget.agendaItemPollData,
      widget.onChanged,
    );
    _presenter = AgendaItemPollPresenter(this, _model);
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didUpdateWidget(AgendaItemPoll oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isEditMode != widget.isEditMode) {
      _init();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_model.isEditMode) {
      return Column(
        key: Key('poll-${_model.pollStateKey}'),
        children: [
          CustomTextField(
            initialValue: _model.agendaItemPollData.question,
            labelText: 'Poll Question',
            hintText: 'Question goes here',
            maxLines: null,
            onChanged: (value) => _presenter.updatePollQuestion(value),
          ),
          SizedBox(height: 16),
          ..._buildAnswersEdit(),
        ],
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        shrinkWrap: true,
        itemCount: _model.agendaItemPollData.answers.length,
        itemBuilder: (context, index) {
          final String answer = _model.agendaItemPollData.answers[index];

          return SurveyAnswerTile(answer: answer);
        },
      );
    }
  }

  Iterable<Widget> _buildAnswersEdit() {
    final List<String> answers = _model.agendaItemPollData.answers;

    return [
      ...answers.asMap().entries.map((entry) {
        final index = entry.key;
        final answer = entry.value;

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(Icons.radio_button_off),
              SizedBox(width: 15),
              Expanded(
                child: CustomTextField(
                  initialValue: answer,
                  maxLines: 1,
                  onChanged: (value) => _presenter.updateAnswer(value, index),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_forever),
                splashRadius: 20,
                tooltip: 'Delete option',
                hoverColor: Colors.black26,
                padding: const EdgeInsets.all(14),
                onPressed: () => _presenter.removeAnswer(index),
              ),
            ],
          ),
        );
      }),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(Icons.radio_button_off),
            SizedBox(width: 15),
            Expanded(
              child: CustomTextField(
                hintText: 'Add option',
                maxLines: 1,
                onChanged: (value) => _presenter.addAnswer(value),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  @override
  void updateView() {
    setState(() {});
  }
}
