import 'package:flutter/material.dart';
import 'package:client/styles/app_styles.dart';

class CircleSaveCheckButton extends StatelessWidget {
  const CircleSaveCheckButton({
    Key? key,
    this.onPressed,
    this.isEnabled = false,
  });

  final VoidCallback? onPressed;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.check),
      onPressed: isEnabled ? onPressed : null,
    );
  }
}
