import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';

class SurveyAnswerTile extends StatelessWidget {
  const SurveyAnswerTile({
    Key? key,
    required this.answer,
    this.answeredParticipants,
    this.totalParticipants,
  })  : assert(
          (answeredParticipants == null && totalParticipants == null) ||
              (answeredParticipants != null && totalParticipants != null),
          'answeredParticipants and totalParticipants must be provided together OR both be null.',
        ),
        super(key: key);

  final String answer;
  final int? answeredParticipants;
  final int? totalParticipants;

  @override
  Widget build(BuildContext context) {
    const kIndicatorHeight = 5.0;
    final showOptionData =
        answeredParticipants != null && totalParticipants != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 10),
        Row(
          children: [
            if (!showOptionData)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(
                  Icons.radio_button_unchecked,
                  color: context.theme.colorScheme.onSurfaceVariant,
                ),
              ),
            Text(
              answer,
              style: context.theme.textTheme.bodyMedium!
                  .copyWith(color: context.theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        if (showOptionData)
          Row(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxWidth = constraints.maxWidth;
                    final double step;

                    // Secure against 0
                    if (totalParticipants == 0) {
                      step = maxWidth;
                    } else {
                      step = maxWidth / totalParticipants!;
                    }

                    return Stack(
                      children: [
                        // Regular, 100% indicator
                        Container(
                          height: kIndicatorHeight,
                          width: maxWidth,
                          decoration: _getBoxDecoration(
                            context.theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        // Indicator that represents percentage of votes
                        AnimatedContainer(
                          height: kIndicatorHeight,
                          width: step * answeredParticipants!,
                          decoration: _getBoxDecoration(
                            context.theme.colorScheme.primary,
                          ),
                          duration: kTabScrollDuration,
                        ),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(width: 10),
              Text(
                '$answeredParticipants/$totalParticipants',
                style: context.theme.textTheme.bodyMedium!.copyWith(
                  color: context.theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        SizedBox(height: 10),
      ],
    );
  }

  BoxDecoration _getBoxDecoration(Color color) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: color,
    );
  }
}
