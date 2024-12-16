import 'package:flutter/material.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/styles/app_styles.dart';

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    Key? key,
    required this.onPressed,
    required this.toolTipText,
    required this.icon,
  }) : super(key: key);

  final VoidCallback onPressed;
  final String toolTipText;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return JuntoInkWell(
      onTap: onPressed,
      boxShape: BoxShape.circle,
      child: Tooltip(
        message: toolTipText,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColor.gray6,
          ),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: icon,
          ),
        ),
      ),
    );
  }
}
