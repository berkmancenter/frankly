import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:client/core/widgets/custom_ink_well.dart';

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    Key? key,
    required this.onPressed,
    required this.toolTipText,
    required this.icon,
    this.color,
    this.iconColor,
  }) : super(key: key);

  final VoidCallback onPressed;
  final String toolTipText;
  final IconData icon;
  final Color? color;
  final Color? iconColor;

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
            color: color ?? context.theme.colorScheme.primary,
          ),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Icon(
              icon,
              color: iconColor ?? context.theme.colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
