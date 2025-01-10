import 'package:client/core/utils/toast_utils.dart';
import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:client/features/events/features/event_page/presentation/views/waiting_room_widget_contract.dart';
import 'package:client/features/events/features/event_page/data/models/waiting_room_widget_model.dart';
import 'package:client/features/events/features/event_page/presentation/waiting_room_widget_presenter.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/action_button.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/core/widgets/ui_migration.dart';
import 'package:client/features/events/features/event_page/presentation/widgets/media_item_section.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/events/event.dart';

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
    final minutesInString = introLengthDuration.inMinutes.toString();
    final secondsInString =
        (introLengthDuration.inSeconds % 60).toString().padLeft(2, '0');

    final waitingBufferMinutesInString =
        waitingBufferDuration.inMinutes.toString();
    final waitingBufferSecondsInString =
        (waitingBufferDuration.inSeconds % 60).toString().padLeft(2, '0');

    // Hide the ability to toggle chat on and off for now
    const showChatOption = false;

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

    return UIMigration(
      whiteBackground: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeightConstrainedText(
              'Intro Text',
              style: AppTextStyle.subhead.copyWith(color: AppColor.gray1),
            ),
            CustomTextField(
              minLines: 3,
              borderType: BorderType.outline,
              borderRadius: 10,
              initialValue: _model.waitingRoomInfo.content,
              onChanged: (value) => _presenter.updateWaitingText(value),
              hintText: 'Enter waiting room text (optional)',
              textStyle: AppTextStyle.body.copyWith(color: AppColor.gray1),
            ),
            SizedBox(height: 20),
            Text(
              'Waiting Room Image/Video',
              style: AppTextStyle.subhead.copyWith(color: AppColor.darkBlue),
            ),
            SizedBox(height: 10),
            MediaItemSection(
              mediaItem: waitingMediaItem,
              onDelete: () => _presenter.deleteWaitingMedia(),
              onUpdate: (mediaItem) => _presenter.updateWaitingMedia(mediaItem),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  activeColor: AppColor.darkBlue,
                  checkColor: AppColor.brightGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                    side: BorderSide(color: AppColor.darkBlue),
                  ),
                  side: BorderSide(color: AppColor.darkBlue),
                  value: _model.waitingRoomInfo.loopWaitingVideo,
                  onChanged: (bool? value) =>
                      _presenter.updateLoopWaitingVideo(value ?? false),
                ),
                HeightConstrainedText('Loop Video'),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 50,
                  child: CustomTextField(
                    padding: EdgeInsets.zero,
                    maxLines: 1,
                    initialValue: waitingBufferMinutesInString,
                    onChanged: (value) =>
                        _presenter.updateWaitingBufferMinutesInString(value),
                    isOnlyDigits: true,
                    useDarkMode: false,
                    numberThreshold: 60,
                  ),
                ),
                SizedBox(width: 4),
                HeightConstrainedText(
                  ':',
                  style: AppTextStyle.bodyMedium
                      .copyWith(color: AppColor.darkBlue),
                ),
                SizedBox(width: 4),
                SizedBox(
                  width: 50,
                  child: CustomTextField(
                    padding: EdgeInsets.zero,
                    maxLines: 1,
                    initialValue: waitingBufferSecondsInString,
                    onChanged: (value) =>
                        _presenter.updateWaitingBufferSecondsInString(value),
                    isOnlyDigits: true,
                    useDarkMode: false,
                    numberThreshold: 59,
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: HeightConstrainedText(
                    'Buffer: Allow $waitingBufferDurationDescription for people to filter in',
                    style: AppTextStyle.body,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            if (_presenter.enableIntroVideo) ...[
              RichText(
                text: TextSpan(
                  text: 'Intro Image/Video',
                  style:
                      AppTextStyle.subhead.copyWith(color: AppColor.darkBlue),
                  children: [
                    TextSpan(
                      text: ' (Plays at $introStartTime)',
                      style: AppTextStyle.bodyMedium,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              MediaItemSection(
                mediaItem: introMediaItem,
                onDelete: () => _presenter.deleteIntroMedia(),
                onUpdate: (mediaItem) => _presenter.updateIntroMedia(mediaItem),
              ),
              SizedBox(height: 10),
              HeightConstrainedText(
                'Intro Length',
                style: AppTextStyle.subhead,
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: CustomTextField(
                      padding: EdgeInsets.zero,
                      maxLines: 1,
                      initialValue: minutesInString,
                      onChanged: (value) =>
                          _presenter.updateMinutesInString(value),
                      isOnlyDigits: true,
                      useDarkMode: false,
                      numberThreshold: 60,
                    ),
                  ),
                  SizedBox(width: 4),
                  HeightConstrainedText(
                    ':',
                    style: AppTextStyle.bodyMedium
                        .copyWith(color: AppColor.darkBlue),
                  ),
                  SizedBox(width: 4),
                  SizedBox(
                    width: 50,
                    child: CustomTextField(
                      padding: EdgeInsets.zero,
                      maxLines: 1,
                      initialValue: secondsInString,
                      onChanged: (value) =>
                          _presenter.updateSecondsInString(value),
                      isOnlyDigits: true,
                      useDarkMode: false,
                      numberThreshold: 59,
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: HeightConstrainedText(
                      '$introLengthDurationDescription intro before participants are sent to breakouts',
                      style: AppTextStyle.body,
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: 18),
            HeightConstrainedText(
              'Participants will be sent into rooms at $breakoutsInitiationTime '
              '($waitingBufferDurationDescription buffer + $introLengthDurationDescription intro)',
              style: AppTextStyle.subhead,
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (showChatOption) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: _model.waitingRoomInfo.enableChat,
                        activeColor: Theme.of(context).colorScheme.secondary,
                        activeTrackColor: Theme.of(context).primaryColor,
                        onChanged: _presenter.enableChat,
                      ),
                      SizedBox(width: 10),
                      HeightConstrainedText(
                        'Enable Chat',
                        style: AppTextStyle.bodyMedium,
                      ),
                    ],
                  ),
                ] else
                  SizedBox.shrink(),
                ActionButton(
                  loadingHeight: 10.0,
                  color: AppColor.darkBlue,
                  textColor: AppColor.brightGreen,
                  text: 'Save',
                  onPressed: () => alertOnError(
                    context,
                    () async {
                      await _presenter.save();
                      showRegularToast(
                        context,
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
      ),
    );
  }

  @override
  void updateView() {
    setState(() {});
  }
}
