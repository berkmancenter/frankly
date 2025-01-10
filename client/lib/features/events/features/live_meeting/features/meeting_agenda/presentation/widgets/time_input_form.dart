import 'package:flutter/material.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';

class TimeInputForm extends StatefulWidget {
  final bool isWhiteBackground;
  final Duration duration;
  final void Function(Duration) onUpdate;
  final bool isClockShowing;

  const TimeInputForm({
    Key? key,
    required this.isWhiteBackground,
    required this.duration,
    required this.onUpdate,
    this.isClockShowing = false,
  }) : super(key: key);

  @override
  State<TimeInputForm> createState() => _TimeInputFormState();
}

class _TimeInputFormState extends State<TimeInputForm> {
  late final TextEditingController _minutesTextEditingController;
  late final TextEditingController _secondsTextEditingController;

  @override
  void initState() {
    super.initState();

    _minutesTextEditingController =
        TextEditingController(text: _getMinutesInString());
    _secondsTextEditingController =
        TextEditingController(text: _getSecondsInString());
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildNumberInput(
          _minutesTextEditingController,
          (value) => _getDurationFromMinutes(value),
        ),
        SizedBox(width: 4),
        HeightConstrainedText(
          ':',
          style: AppTextStyle.bodyMedium.copyWith(
            color:
                widget.isWhiteBackground ? AppColor.darkBlue : AppColor.white,
          ),
        ),
        SizedBox(width: 4),
        _buildNumberInput(
          _secondsTextEditingController,
          (value) => _getDurationFromSeconds(value),
        ),
        if (widget.isClockShowing) ...[
          SizedBox(width: 8),
          ProxiedImage(null, asset: AppAsset.clock(), width: 20, height: 20),
        ],
      ],
    );
  }

  Widget _buildNumberInput(
    TextEditingController textEditingController,
    Duration Function(String) getDurationFromString,
  ) {
    return SizedBox(
      width: 50,
      child: CustomTextField(
        controller: textEditingController,
        maxLines: 1,
        onChanged: (value) {
          final duration = getDurationFromString(value);
          widget.onUpdate(duration);
        },
        isOnlyDigits: true,
        numberThreshold: 59,
        useDarkMode: !widget.isWhiteBackground,
      ),
    );
  }

  String _getMinutesInString() {
    return widget.duration.inMinutes.toString();
  }

  String _getSecondsInString() {
    final durationInSeconds = widget.duration.inSeconds % 60;

    return durationInSeconds.toString().padLeft(2, '0');
  }

  Duration _getDurationFromMinutes(String minutesInString) {
    final secondsInString = _secondsTextEditingController.text;
    final minutesInt = int.tryParse(minutesInString) ?? 0;
    final secondsInt = int.tryParse(secondsInString) ?? 0;

    return Duration(minutes: minutesInt, seconds: secondsInt);
  }

  Duration _getDurationFromSeconds(String secondsInString) {
    final minutesInString = _minutesTextEditingController.text;
    final minutesInt = int.tryParse(minutesInString) ?? 0;
    final secondsInt = int.tryParse(secondsInString) ?? 0;

    return Duration(minutes: minutesInt, seconds: secondsInt);
  }
}
