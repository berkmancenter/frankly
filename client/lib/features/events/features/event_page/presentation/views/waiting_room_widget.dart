import 'package:client/core/utils/toast_utils.dart';
import 'package:client/styles/styles.dart';
import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:client/features/events/features/event_page/presentation/views/waiting_room_widget_contract.dart';
import 'package:client/features/events/features/event_page/data/models/waiting_room_widget_model.dart';
import 'package:client/features/events/features/event_page/presentation/waiting_room_widget_presenter.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/features/events/features/event_page/presentation/widgets/media_item_section.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/widgets/time_input_form.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/events/event.dart';
import 'package:client/core/localization/localization_helper.dart';

class WaitingRoomWidget extends StatefulWidget {
  final Event event;

  const WaitingRoomWidget({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  State<WaitingRoomWidget> createState() => _WaitingRoomWidgetState();
}

class _WaitingRoomWidgetState extends State<WaitingRoomWidget>
    implements WaitingRoomWidgetView {
  late final WaitingRoomWidgetModel _model;
  late final WaitingRoomWidgetPresenter _presenter;

  @override
  void initState() {
    super.initState();

    _model = WaitingRoomWidgetModel(widget.event);
    _presenter = WaitingRoomWidgetPresenter(this, _model);
    _presenter.init();
  }

  @override
  Widget build(BuildContext context) {
    final introLengthDuration =
        Duration(seconds: _model.waitingRoomInfo.durationSeconds);
    final waitingBufferDuration =
        Duration(seconds: _model.waitingRoomInfo.waitingMediaBufferSeconds);
    final waitingMediaItem = _model.waitingRoomInfo.waitingMediaItem;
    final introMediaItem = _model.waitingRoomInfo.introMediaItem;

    final waitingBufferDurationDescription =
        prettyDuration(waitingBufferDuration)
            .replaceAll('minute', 'min')
            .replaceAll('second', 'sec');
    final introLengthDurationDescription = prettyDuration(introLengthDuration)
        .replaceAll('minute', 'min')
        .replaceAll('second', 'sec');

    final introStartTime = DateFormat.jms()
        .format(_model.event.scheduledTime!.add(waitingBufferDuration));
    final breakoutsInitiationTime = DateFormat.jms().format(
      _model.event.scheduledTime!
          .add(waitingBufferDuration)
          .add(introLengthDuration),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeightConstrainedText(
            'Intro Text',
            style: AppTextStyle.subhead
                .copyWith(color: context.theme.colorScheme.secondary),
          ),
          CustomTextField(
            minLines: 3,
            keyboardType: TextInputType.multiline,
            borderType: BorderType.outline,
            borderRadius: 10,
            initialValue: _model.waitingRoomInfo.content,
            onChanged: (value) => _presenter.updateWaitingText(value),
            hintText: context.l10n.enterWaitingRoomText,
            textStyle: AppTextStyle.body
                .copyWith(color: context.theme.colorScheme.secondary),
          ),
          SizedBox(height: 20),
          Text(
            'Waiting Room Image/Video',
            style: AppTextStyle.subhead
                .copyWith(color: context.theme.colorScheme.primary),
          ),
          SizedBox(height: 10),
          MediaItemSection(
            mediaItem: waitingMediaItem,
            onDelete: () => _presenter.deleteWaitingMedia(),
            onUpdate: (mediaItem) => _presenter.updateWaitingMedia(mediaItem),
            onVideoDurationDetected: (durationInSeconds) {
              if (!mounted) return;
              _presenter.updateWaitingBufferDuration(
                Duration(seconds: durationInSeconds),
              );
              showRegularToast(
                context,
                'Buffer time updated to ${ prettyDuration(Duration(seconds: durationInSeconds)).replaceAll('minute', 'min').replaceAll('second', 'sec')} to match video length.',
                toastType: ToastType.neutral,
              );
            },
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Checkbox(
                activeColor: context.theme.colorScheme.primary,
                checkColor: context.theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                  side: BorderSide(color: context.theme.colorScheme.primary),
                ),
                side: BorderSide(color: context.theme.colorScheme.primary),
                value: _model.waitingRoomInfo.loopWaitingVideo,
                onChanged: (bool? value) =>
                    _presenter.updateLoopWaitingVideo(value ?? false),
              ),
              HeightConstrainedText(context.l10n.loopVideo),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TimeInputForm(
                duration: waitingBufferDuration,
                onUpdate: (d) => _presenter.updateWaitingBufferDuration(d),
              ),
              SizedBox(width: 20),
              Expanded(
                child: HeightConstrainedText(
                  context.l10n.bufferTimeDescription(
                    waitingBufferDurationDescription,
                  ),
                  style: context.theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          if (_presenter.enableIntroVideo) ...[
            Text(
              'Intro Image/Video',
              style: AppTextStyle.subhead
                  .copyWith(color: context.theme.colorScheme.primary),
            ),
            Text(
              context.l10n.playsAt(introStartTime),
              style: context.theme.textTheme.bodyMedium,
            ),
            SizedBox(height: 20),
            MediaItemSection(
              mediaItem: introMediaItem,
              onDelete: () => _presenter.deleteIntroMedia(),
              onUpdate: (mediaItem) => _presenter.updateIntroMedia(mediaItem),
              onVideoDurationDetected: (durationInSeconds) {
                if (!mounted) return;
                _presenter.updateDuration(Duration(seconds: durationInSeconds));
                showRegularToast(
                  context,
                  'Intro Length updated to ${prettyDuration(Duration(seconds: durationInSeconds)).replaceAll('minute', 'min').replaceAll('second', 'sec')} to match video length.',
                  toastType: ToastType.neutral,
                );
              },
            ),
            SizedBox(height: 10),
            HeightConstrainedText(
              'Intro Length',
              style: AppTextStyle.subhead,
            ),
            SizedBox(height: 10),
            Row(
              children: [
                TimeInputForm(
                  duration: introLengthDuration,
                  onUpdate: (d) => _presenter.updateDuration(d),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: HeightConstrainedText(
                    context.l10n
                        .introBeforeBreakouts(introLengthDurationDescription),
                    style: context.theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 18),
          HeightConstrainedText(
            'Participants will be sent into rooms at $breakoutsInitiationTime.\n${context.l10n.bufferAndIntroTime(
              waitingBufferDurationDescription,
              introLengthDurationDescription,
            )}.',
            style: context.theme.textTheme.titleMedium,
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ActionButton(
                loadingHeight: 10.0,
                color: context.theme.colorScheme.primary,
                textColor: context.theme.colorScheme.onPrimary,
                text: 'Save',
                onPressed: () => alertOnError(
                  context,
                  () async {
                    await _presenter.save();
                    if (!mounted) return;
                    showRegularToast(
                      this.context,
                      'Waiting Room Changes Saved',
                      toastType: ToastType.success,
                    );
                  },
                ),
              ),
            ],
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
