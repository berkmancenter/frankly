import 'package:flutter/material.dart';
import 'package:client/styles/styles.dart';

/// These are the play / pause  and forward / backward buttons that control the image carousel.
class CommunityCarouselControls extends StatelessWidget {
  final AnimationController controller;
  final void Function() onPause;
  final void Function() onPlay;
  final void Function() onNext;
  final void Function() onPrevious;

  const CommunityCarouselControls({
    Key? key,
    required this.controller,
    required this.onPause,
    required this.onPlay,
    required this.onNext,
    required this.onPrevious,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ControlsButton(
          onPressed: onPrevious,
          icon: Icons.arrow_back_ios,
        ),
        if (controller.isAnimating)
          ControlsButton(
            onPressed: onPause,
            icon: Icons.pause,
          )
        else
          ControlsButton(
            onPressed: onPlay,
            icon: Icons.play_arrow,
          ),
        ControlsButton(
          onPressed: onNext,
          icon: Icons.arrow_forward_ios,
        ),
      ],
    );
  }
}

class ControlsButton extends StatelessWidget {
  final IconData icon;
  final void Function() onPressed;

  const ControlsButton({
    required this.icon,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Center(
        child: IconButton(
          icon: Icon(
            icon,
            size: 25,
            color: context.theme.colorScheme.onPrimary,
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
