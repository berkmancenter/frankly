import 'package:client/core/widgets/height_constained_text.dart';
import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';

/// Displays the time remaining for an agenda item in a fixed-width cell.
///
/// Scales the text down rather than wrapping so the timer always renders on a
/// single line, regardless of the formatted time's length or the user's text
/// scale. See https://github.com/berkmancenter/frankly/issues/477.
class AgendaItemTimer extends StatelessWidget {
  final String formattedTime;
  final bool negative;

  const AgendaItemTimer({
    required this.formattedTime,
    this.negative = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      alignment: Alignment.centerRight,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: HeightConstrainedText(
          formattedTime,
          style: AppTextStyle.body.copyWith(
            color: negative
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
