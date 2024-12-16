import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';

class DottedBorderButton extends StatelessWidget {
  const DottedBorderButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.borderColor = AppColor.gray1,
    this.iconBackgroundColor = AppColor.white,
    this.iconColor = AppColor.gray1,
    this.textColor = AppColor.gray1,
    this.onDelete,
    this.onEdit,
  }) : super(key: key);

  final Function onPressed;
  final String text;
  final Color borderColor;
  final Color iconBackgroundColor;
  final Color textColor;
  final Color iconColor;
  final Function? onDelete;
  final Function? onEdit;

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      color: borderColor,
      dashPattern: const [10, 10],
      child: JuntoInkWell(
        onTap: () => onPressed(),
        child: SizedBox(
          height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 150,
                child: Icon(
                  Icons.add,
                  size: 18,
                  color: iconColor,
                ),
                color: iconBackgroundColor,
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerLeft,
                  child: JuntoText(
                    text,
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
