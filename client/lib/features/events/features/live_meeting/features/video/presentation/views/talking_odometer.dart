import 'dart:math';

import 'package:flutter/material.dart';
import 'package:client/features/events/features/live_meeting/features/video/presentation/views/talking_odometer_contract.dart';
import 'package:client/features/events/features/live_meeting/features/video/data/models/talking_odometer_model.dart';
import 'package:client/features/events/features/live_meeting/features/video/presentation/talking_odometer_presenter.dart';
import 'package:client/features/events/features/live_meeting/features/video/presentation/widgets/colorful_meter.dart';
import 'package:client/styles/styles.dart';
import 'package:client/core/utils/extensions.dart';
import 'package:client/core/localization/localization_helper.dart';

/// Shows a meter indicating to the user if they have been speaking more, less, or the same as
/// everyone else in the meeting.
class TalkingOdometer extends StatefulWidget {
  const TalkingOdometer({Key? key}) : super(key: key);

  @override
  State<TalkingOdometer> createState() => _TalkingOdometerState();
}

class _TalkingOdometerState extends State<TalkingOdometer>
    with SingleTickerProviderStateMixin
    implements TalkingOdometerView {
  static const bounceDuration = Duration(milliseconds: 400);

  late final TalkingOdometerModel _model;
  late final TalkingOdometerPresenter _presenter;
  late AnimationController _warningController;

  @override
  void initState() {
    super.initState();
    _model = TalkingOdometerModel();
    _presenter = TalkingOdometerPresenter(context, this, _model);
    _presenter.init();
    _warningController =
        AnimationController(vsync: this, duration: bounceDuration);
  }

  @override
  void dispose() {
    _presenter.dispose();
    _warningController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _warningController,
      builder: (_, __) => _buildContent(),
    );
  }

  Widget _buildContent() {
    final value = _presenter.getOdometerIndicatorValue();
    final message = _presenter.getMessage();
    final applyWarning = value.abs() == 1;
    // Exponent gives animation a bounce effect
    final double adjustedValue =
        (value * .8) + (value * .2 * pow(_warningController.value, 2));

    return Center(
      child: Tooltip(
        key: _model.tooltipKey,
        triggerMode: TooltipTriggerMode.manual,
        message: message,
        textStyle: AppTextStyle.body
            .copyWith(color: context.theme.colorScheme.primary),
        verticalOffset: 40,
        preferBelow: false,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: context.theme.colorScheme.surfaceContainerLowest,
        ),
        child: ColorfulMeter(
          value: applyWarning ? adjustedValue : value,
          title: _presenter.userTotalTalkingTime
              .getFormattedTime(showHours: false),
          subtitle: context.l10n.mins,
        ),
      ),
    );
  }

  @override
  void updateView() {
    setState(() {});
  }

  @override
  void cancelAnimation() {
    _warningController.stop();
  }

  @override
  void startAnimation() {
    _warningController.value = 1;
    _warningController.repeat(reverse: true);
  }
}
