import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';

/// A widget to detail the month, day, weekday, and time of a particular DateTime
///
/// Text is contained in a rounded container with vertical aspect ratio and box shadow
class VerticalTimeAndDateIndicator extends StatelessWidget {
  final DateTime time;
  final bool shadow;
  final bool isDisabled;
  final EdgeInsetsGeometry padding;

  const VerticalTimeAndDateIndicator({
    required this.time,
    this.shadow = true,
    this.isDisabled = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    Key? key,
  }) : super(key: key);

  String get _timeString {
    final timeString = DateFormat('h:mma').format(time);
    final correctlyFormattedTimeString =
        timeString.substring(0, timeString.length - 1).toLowerCase();

    return correctlyFormattedTimeString;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isDisabled ? AppColor.white.withOpacity(0.3) : AppColor.white,
        boxShadow: shadow
            ? const [
                AppDecoration.lightBoxShadow,
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          JuntoText(
            DateFormat('MMM').format(time).toUpperCase(),
            style: AppTextStyle.body.copyWith(
              fontSize: 14,
              color: isDisabled ? AppColor.black.withOpacity(0.5) : AppColor.black,
            ),
          ),
          JuntoText(
            time.day.toString(),
            style: AppTextStyle.headline2Light.copyWith(
              height: .9,
              fontSize: 34,
              color: isDisabled ? AppColor.black.withOpacity(0.5) : AppColor.black,
            ),
          ),
          JuntoText(
            DateFormat('EEE').format(time),
            style: AppTextStyle.body.copyWith(
              fontSize: 14,
              color: isDisabled ? AppColor.black.withOpacity(0.5) : AppColor.black,
            ),
          ),
          JuntoText(
            _timeString,
            style: AppTextStyle.body.copyWith(
              fontSize: 14,
              color: isDisabled ? AppColor.black.withOpacity(0.5) : AppColor.black,
            ),
          ),
        ],
      ),
    );
  }
}
