import 'package:flutter/material.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';

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
        shape: MaterialStateProperty.all<OutlinedBorder>(StadiumBorder()),
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) {
            return AppColor.darkBlue;
          }
          return AppColor.gray5;
        }),
        padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 16, horizontal: 16)),
      ),
      child: JuntoText(
        label,
        style: TextStyle(color: onPressed != null ? AppColor.gray4 : AppColor.brightGreen),
      ),
      onPressed: onPressed,
    );
  }
}
