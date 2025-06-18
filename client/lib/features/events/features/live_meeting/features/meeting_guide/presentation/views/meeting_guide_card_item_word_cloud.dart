import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_scatter/flutter_scatter.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/data/providers/meeting_guide_card_store.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/views/agenda_item_card.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/providers/meeting_agenda_provider.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:client/core/widgets/memoized_builder.dart';
import 'package:data_models/events/live_meetings/meeting_guide.dart';
import 'package:provider/provider.dart';
import 'package:quiver/iterables.dart';
import 'package:client/core/localization/localization_helper.dart';

import 'meeting_guide_card_item_word_cloud_contract.dart';
import '../../data/models/meeting_guide_card_item_word_cloud_model.dart';
import '../meeting_guide_card_item_word_cloud_presenter.dart';

class MeetingGuideCardItemWordCloud extends StatefulWidget {
  const MeetingGuideCardItemWordCloud({Key? key}) : super(key: key);

  @override
  _MeetingGuideCardItemWordCloudState createState() =>
      _MeetingGuideCardItemWordCloudState();
}

class _MeetingGuideCardItemWordCloudState
    extends State<MeetingGuideCardItemWordCloud>
    implements MeetingGuideCardItemWordCloudView {
  final FocusNode _wordCloudResponseFocusNode = FocusNode();
  final TextEditingController _wordCloudResponseController =
      TextEditingController(text: '');

  late final MeetingGuideCardItemWordCloudModel _model;
  late final MeetingGuideCardItemWordCloudPresenter _presenter;

  @override
  void initState() {
    super.initState();

    _model = MeetingGuideCardItemWordCloudModel();
    _presenter = MeetingGuideCardItemWordCloudPresenter(context, this, _model);
  }

  @override
  void updateView() {
    setState(() {});
  }

  Future<void> _submitInputWordCloudResponse() async {
    if (_wordCloudResponseController.text.isNotEmpty) {
      await _submitWordCloudResponse(_wordCloudResponseController.text);
      setState(() => _wordCloudResponseController.text = '');
      _wordCloudResponseFocusNode.requestFocus();
    }
  }

  Future<void> _submitWordCloudResponse(String response) async {
    await alertOnError(
      context,
      () => _presenter.addWordCloudResponse(response),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<EventProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _buildWordCloudContent()),
        SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                children: [
                  Flexible(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 200),
                      child: CustomTextField(
                        padding: EdgeInsets.zero,
                        borderRadius: 10,
                        labelText: 'Enter word',
                        maxLines: 1,
                        maxLength: 30,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        onChanged: (value) => updateView(),
                        controller: _wordCloudResponseController,
                        onEditingComplete: _submitInputWordCloudResponse,
                        unfocusOnSubmit: false,
                        counterText: '',
                        hideCounter: true,
                      ),
                    ),
                  ),
                  SizedBox(width: 6),
                  ActionButton(
                    height: 55,
                    minWidth: 20,
                    color: context.theme.colorScheme.primary,
                    sendingIndicatorAlign:
                        ActionButtonSendingIndicatorAlign.none,
                    onPressed: _wordCloudResponseController.text != ''
                        ? _submitInputWordCloudResponse
                        : null,
                    child: Icon(
                      Icons.send,
                      color: context.theme.colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 6),
            _buildViewTypeButtons(),
          ],
        ),
      ],
    );
  }

  Widget _buildViewTypeButtons() {
    void changeViewType(WordCloudViewType cloudViewType) {
      if (cloudViewType != _model.wordCloudViewType) {
        _presenter.updateWordCloudView(cloudViewType);
      }
    }

    return Row(
      children: [
        CustomInkWell(
          boxShape: BoxShape.circle,
          onTap: () => changeViewType(WordCloudViewType.cloud),
          child: Tooltip(
            message: context.l10n.wordCloud,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _model.wordCloudViewType == WordCloudViewType.cloud
                    ? context.theme.colorScheme.primary
                    : Colors.transparent,
              ),
              child: Icon(
                Icons.cloud,
                size: 22,
                color: _model.wordCloudViewType == WordCloudViewType.cloud
                    ? context.theme.colorScheme.onPrimary
                    : context.theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        CustomInkWell(
          boxShape: BoxShape.circle,
          onTap: () => changeViewType(WordCloudViewType.list),
          child: Tooltip(
            message: context.l10n.wordList,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _model.wordCloudViewType == WordCloudViewType.list
                    ? context.theme.colorScheme.primary
                    : Colors.transparent,
              ),
              child: Icon(
                Icons.list,
                size: 22,
                color: _model.wordCloudViewType == WordCloudViewType.list
                    ? context.theme.colorScheme.onPrimary
                    : context.theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        SizedBox(width: 8),
        CustomInkWell(
          boxShape: BoxShape.circle,
          onTap: () => changeViewType(WordCloudViewType.mine),
          child: Tooltip(
            message: context.l10n.myResponses,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _model.wordCloudViewType == WordCloudViewType.mine
                    ? context.theme.colorScheme.primary
                    : Colors.transparent,
              ),
              child: Icon(
                Icons.person,
                size: 22,
                color: _model.wordCloudViewType == WordCloudViewType.mine
                    ? context.theme.colorScheme.onPrimary
                    : context.theme.colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWordCloudContent() {
    context.watch<AgendaProvider>();
    context.watch<UserService>();
    context.watch<EventProvider>();
    context.watch<MeetingGuideCardStore>();

    final currentUserId = _presenter.getUserId();
    final currentEvent = _presenter.getEvent();
    final inLiveMeeting = _presenter.inLiveMeeting();
    final currentAgendaItem = _presenter.getCurrentAgendaItem();
    final participantAgendaItemDetailsStream =
        _presenter.getParticipantAgendaItemDetailsStream();

    return MemoizedBuilder<Stream<List<ParticipantAgendaItemDetails>>?>(
      getter: () {
        return inLiveMeeting
            ? participantAgendaItemDetailsStream
            : Stream.value([]);
      },
      keys: [currentEvent, currentAgendaItem?.id ?? '', inLiveMeeting],
      builder: (context, stream) {
        return CustomStreamBuilder<List<ParticipantAgendaItemDetails>>(
          entryFrom: '_MeetingGuideCardState._buildWordCloudContent',
          stream: stream,
          errorMessage: 'Error loading word cloud responses',
          builder: (_, details) {
            context.watch<AgendaProvider>();

            final currentResponses = details
                    ?.firstWhereOrNull(
                      (element) => element.userId == currentUserId,
                    )
                    ?.wordCloudResponses ??
                [];
            final allResponses = groupBy<String, String>(
              (details ?? []).expand((d) => d.wordCloudResponses),
              (word) => word,
            ).map<String, int>((k, v) => MapEntry(k, v.length)).entries.sorted(
                  (a, b) => a.value == b.value
                      ? a.key.compareTo(b.key)
                      : -a.value.compareTo(b.value),
                );
            final maxValue = max(allResponses.map((e) => e.value)) ?? 0;

            if (allResponses.isEmpty) {
              return ProxiedImage(
                null,
                asset: AppAsset.kWordCloudEmptyPng,
                fit: BoxFit.cover,
              );
            }
            switch (_model.wordCloudViewType) {
              case WordCloudViewType.list:
                return _buildWordCloudList(allResponses, maxValue);
              case WordCloudViewType.cloud:
                return _buildWordCloudCloud(
                  currentResponses: currentResponses,
                  allResponses: allResponses,
                  maxValue: maxValue,
                  details: details,
                );
              case WordCloudViewType.mine:
                return _buildWordCloudMine(currentResponses);
            }
          },
        );
      },
    );
  }

  Widget _buildWordCloudList(
    List<MapEntry<String, int>> allResponses,
    int maxValue,
  ) {
    return Center(
      child: LayoutBuilder(
        builder: (_, constraints) {
          final maxLineWidth = math.min(constraints.maxWidth * .5, 200);

          return ListView.builder(
            shrinkWrap: true,
            itemCount: allResponses.length,
            itemBuilder: (context, index) {
              final response = allResponses.toList()[index];
              final lineWidth =
                  maxLineWidth * (response.value.toDouble() / maxValue);

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Tooltip(
                      message: response.value.toString(),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        child: Container(
                          height: 8,
                          width: lineWidth,
                          decoration: BoxDecoration(
                            color: context.theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: Tooltip(
                        message: response.key,
                        child: HeightConstrainedText(
                          response.key,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildWordCloudCloud({
    required List<String> currentResponses,
    required List<MapEntry<String, int>> allResponses,
    required int maxValue,
    required List<ParticipantAgendaItemDetails>? details,
  }) {
    final isMobile = _presenter.isMobile(context);

    return FittedBox(
      fit: BoxFit.contain,
      child: MemoizedBuilder<Iterable<MapEntry<String, int>>>(
        getter: () => allResponses,
        builder: (context, words) {
          return Scatter(
            fillGaps: true,
            maxChildIteration: 2000,
            delegate: ArchimedeanSpiralScatterDelegate(
              ratio: isMobile ? 2.0 : 16.0 / 9.0,
              step: .01,
              b: 2.0,
            ),
            children: words.map((e) {
              final prominence = maxValue > 1
                  ? (e.value.floorToDouble() - 1) / (maxValue - 1)
                  : .5;
              final size = 24 *
                  (1.5 + prominence) /
                  math.sqrt(math.sqrt(math.max(words.length, 6)));

              final color = context.theme.colorScheme.primary
                  .withOpacity(.5 + prominence * .5);
              if (currentResponses.contains(e.key)) {
                return HeightConstrainedText(
                  ' ${e.key} ',
                  style: TextStyle(color: color, fontSize: size),
                );
              } else {
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    child: Tooltip(
                      message: context.l10n.pressToPromote,
                      child: HeightConstrainedText(
                        ' ${e.key} ',
                        style: TextStyle(color: color, fontSize: size),
                      ),
                    ),
                    onTap: () => _submitWordCloudResponse(e.key),
                  ),
                );
              }
            }).toList(),
          );
        },
        keys: [details ?? []],
      ),
    );
  }

  Widget _buildWordCloudMine(List<String> currentResponses) {
    return SingleChildScrollView(
      child: Wrap(
        spacing: 8.0, // Gap between chips
        runSpacing: 4.0, // Gap between lines
        children: List<Widget>.generate(
          currentResponses.length,
          (index) {
            return Chip(
              label: Text(currentResponses[index]),
              deleteIcon: Icon(Icons.close),
              onDeleted: () {
                alertOnError(
                  context,
                  () => _presenter
                      .removeWordCloudResponse(currentResponses[index]),
                );
              },
              backgroundColor: Colors.grey[300],
              elevation: 2,
            );
          },
        ),
      ),
    );
  }
}
