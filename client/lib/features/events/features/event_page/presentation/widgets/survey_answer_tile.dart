import 'package:flutter/material.dart';
import 'package:client/styles/app_styles.dart';

class SurveyAnswerTile extends StatelessWidget {
  final String answer;
  final int answeredParticipants;
  final int totalParticipants;

  const SurveyAnswerTile({
    Key? key,
    required this.answer,
    this.answeredParticipants = 0,
    this.totalParticipants = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const kIndicatorHeight = 5.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 10),
        Text(
          answer,
          style: AppTextStyle.body.copyWith(color: AppColor.gray2),
        ),
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
                    step = maxWidth / totalParticipants;
                  }

                  return Stack(
                    children: [
                      // Regular, 100% indicator
                      Container(
                        height: kIndicatorHeight,
                        width: maxWidth,
                        decoration: _getBoxDecoration(AppColor.gray5),
                      ),
                      // Indicator that represents percentage of votes
                      AnimatedContainer(
                        height: kIndicatorHeight,
                        width: step * answeredParticipants,
                        decoration: _getBoxDecoration(AppColor.darkBlue),
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
              style: AppTextStyle.body.copyWith(color: AppColor.gray3),
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
