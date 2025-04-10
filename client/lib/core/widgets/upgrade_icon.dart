import 'package:flutter/material.dart';
import 'package:client/styles/styles.dart';

class UpgradeIcon extends StatelessWidget {
  final bool isColorInverted;
  final bool isDisabledColor;

  const UpgradeIcon({
    this.isColorInverted = false,
    this.isDisabledColor = false,
    Key? key,
  }) : super(key: key);

  Color _iconColor(BuildContext context) {
    if (isDisabledColor) {
      return AppColor.white;
    } else if (isColorInverted) {
      return context.theme.colorScheme.primary;
    } else {
      return AppColor.brightGreen;
    }
  }

  Color _containerColor(BuildContext context) {
    if (isDisabledColor) {
      return AppColor.gray1.withOpacity(.5);
    } else if (isColorInverted) {
      return AppColor.brightGreen;
    } else {
      return context.theme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _containerColor(context),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.star,
        color: _iconColor(context),
        size: 12,
      ),
    );
  }
}
