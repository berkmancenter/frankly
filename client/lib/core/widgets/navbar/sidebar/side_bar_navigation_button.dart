import 'package:flutter/material.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';

class SideBarNavigationButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  final TextStyle? style;
  final double verticalPadding;

  const SideBarNavigationButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.style,
    this.verticalPadding = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomInkWell(
      onTap: () {
        Navigator.of(context).pop();

        if (onTap != null) onTap?.call();
      },
      child: Container(
        padding: EdgeInsets.only(
          top: verticalPadding,
          bottom: verticalPadding,
          left: 8,
        ),
        alignment: Alignment.centerLeft,
        child: HeightConstrainedText(
          text,
          textAlign: TextAlign.start,
          style: style ?? AppTextStyle.body.copyWith(color: AppColor.gray2),
        ),
      ),
    );
  }
}
