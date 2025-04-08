import 'package:flutter/material.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';

class RoundedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;

  const RoundedButton({
    Key? key,
    required this.label,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        shape: WidgetStateProperty.all<OutlinedBorder>(StadiumBorder()),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return context.theme.colorScheme.primary;
          }
          return AppColor.gray5;
        }),
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
      onPressed: onPressed,
      child: HeightConstrainedText(
        label,
        style: TextStyle(
          color: onPressed != null ? AppColor.gray4 : AppColor.brightGreen,
        ),
      ),
    );
  }
}
