import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:client/common_widgets/custom_ink_well.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/utils/height_constained_text.dart';

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
      child: CustomInkWell(
        onTap: () => onPressed(),
        child: SizedBox(
          height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 150,
                color: iconBackgroundColor,
                child: Icon(
                  Icons.add,
                  size: 18,
                  color: iconColor,
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerLeft,
                  child: HeightConstrainedText(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
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
