import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';

class AddMoreButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final bool isWhiteBackground;

  const AddMoreButton({
    Key? key,
    required this.onPressed,
    required this.label,
    this.isWhiteBackground = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      color: AppColor.gray4,
      dashPattern: const [10, 10],
      child: JuntoInkWell(
        onTap: onPressed,
        child: Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: isWhiteBackground ? AppColor.gray6 : Colors.transparent,
          ),
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 25,
                height: 25,
                decoration: ShapeDecoration(
                  color: isWhiteBackground ? AppColor.darkBlue : AppColor.brightGreen,
                  shape: CircleBorder(),
                ),
                child: Icon(Icons.add,
                    size: 12, color: isWhiteBackground ? AppColor.lightGreen : AppColor.darkBlue),
              ),
              SizedBox(width: 5),
              JuntoText(
                label,
                style: AppTextStyle.subhead
                    .copyWith(color: isWhiteBackground ? AppColor.darkBlue : AppColor.white),
              )
            ],
          ),
        ),
      ),
    );
  }
}
