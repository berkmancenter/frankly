import 'package:flutter/material.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';

class NavButton extends StatefulWidget {
  final String text;
  final Function()? onPressed;
  final Color? backgroundColor;
  final Color? textColor;

  const NavButton({
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    Key? key,
  }) : super(key: key);

  @override
  _NavButtonState createState() => _NavButtonState();
}

class _NavButtonState extends State<NavButton> {
  @override
  Widget build(BuildContext context) {
    final selectedColor = AppColor.white.withOpacity(0.2);
    return JuntoInkWell(
      onTap: widget.onPressed,
      hoverColor: selectedColor,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 48,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: JuntoText(
          widget.text,
          style: AppTextStyle.body.copyWith(color: widget.textColor ?? AppColor.darkBlue),
        ),
      ),
    );
  }
}
