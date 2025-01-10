import 'package:flutter/material.dart';
import 'package:client/styles/app_styles.dart';

class CircleSaveCheckButton extends StatelessWidget {
  const CircleSaveCheckButton({
    Key? key,
    this.onPressed,
    this.isEnabled = false,
    this.isWhiteBackground = false,
  });

  final VoidCallback? onPressed;
  final bool isEnabled;
  final bool isWhiteBackground;

  @override
  Widget build(BuildContext context) {
    final borderColor = isWhiteBackground ? AppColor.white : AppColor.darkBlue;
    final backgroundColor =
        isWhiteBackground ? AppColor.darkBlue : Colors.transparent;

    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: Container(
        decoration: ShapeDecoration(
          color: isEnabled ? backgroundColor : AppColor.gray4,
          shape: CircleBorder(
            side: BorderSide(
              color: isEnabled ? borderColor : AppColor.gray4,
            ),
          ),
        ),
        child: IconButton(
          icon: Icon(Icons.check, size: 15),
          color: isEnabled ? borderColor : AppColor.white,
          onPressed: isEnabled ? onPressed : null,
        ),
      ),
    );
  }
}
