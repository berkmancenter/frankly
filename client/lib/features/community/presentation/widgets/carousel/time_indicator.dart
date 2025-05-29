import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:client/styles/styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';

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
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HeightConstrainedText(
            DateFormat('MMM').format(time).toUpperCase(),
            style: context.theme.textTheme.bodySmall!.copyWith(
              color: isDisabled
                  ? context.theme.colorScheme.onSurface.withOpacity(0.75)
                  : context.theme.colorScheme.onSurface,
            ),
          ),
          HeightConstrainedText(
            time.day.toString(),
            style: context.theme.textTheme.headlineMedium!.copyWith(
              color: isDisabled
                  ? context.theme.colorScheme.onSurface.withOpacity(0.75)
                  : context.theme.colorScheme.onSurface,
            ),
          ),
          HeightConstrainedText(
            DateFormat('EEE').format(time),
            style: context.theme.textTheme.bodyMedium!.copyWith(
              color: isDisabled
                  ? context.theme.colorScheme.onSurface.withOpacity(0.75)
                  : context.theme.colorScheme.onSurface,
            ),
          ),
          HeightConstrainedText(
            _timeString,
            style: context.theme.textTheme.bodyMedium!.copyWith(
              fontSize: 14,
              color: isDisabled
                  ? context.theme.colorScheme.onSurface.withOpacity(0.75)
                  : context.theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
