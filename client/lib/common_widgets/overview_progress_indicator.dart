import 'package:flutter/material.dart';
import 'package:junto/styles/app_styles.dart';

class OnboardingOverviewProgressIndicator extends StatelessWidget {
  final int completedStepCount;
  final int totalSteps;
  final Color backgroundColor;
  final Color progressColor;

  const OnboardingOverviewProgressIndicator({
    Key? key,
    required this.completedStepCount,
    required this.totalSteps,
    this.backgroundColor = AppColor.gray5,
    this.progressColor = AppColor.darkBlue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              height: 4,
              color: backgroundColor,
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final widthStep = constraints.maxWidth / totalSteps;

              return AnimatedContainer(
                duration: kTabScrollDuration,
                height: 4,
                width: completedStepCount * widthStep,
                color: progressColor,
              );
            },
          ),
        ],
      ),
    );
  }
}
