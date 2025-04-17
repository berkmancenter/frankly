import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:client/core/widgets/custom_ink_well.dart';

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    Key? key,
    required this.onPressed,
    required this.toolTipText,
    required this.icon,
  }) : super(key: key);

  final VoidCallback onPressed;
  final String toolTipText;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return CustomInkWell(
      onTap: onPressed,
      boxShape: BoxShape.circle,
      child: Tooltip(
        message: toolTipText,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.theme.colorScheme.primary,
          ),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Icon(icon, color: context.theme.colorScheme.onPrimary),
          ),
        ),
      ),
    );
  }
}
