import 'package:flutter/cupertino.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';

class CustomSwitchTile extends StatefulWidget {
  final String? text;
  final Widget? textWidget;
  final bool val;
  final void Function(bool) onUpdate;
  final TextStyle? style;

  const CustomSwitchTile({
    Key? key,
    this.text,
    this.textWidget,
    required this.val,
    required this.onUpdate,
    this.style,
  }) : super(key: key);

  @override
  State<CustomSwitchTile> createState() => _CustomSwitchTileState();
}

class _CustomSwitchTileState extends State<CustomSwitchTile> {
  @override
  Widget build(BuildContext context) {
    final textStyle =
        widget.style ?? AppTextStyle.bodySmall.copyWith(color: AppColor.gray1);

    return CustomInkWell(
      onTap: () => widget.onUpdate(!widget.val),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        constraints: BoxConstraints(minHeight: 38),
        child: Row(
          children: [
            Expanded(
              child: widget.textWidget ??
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: HeightConstrainedText(
                      widget.text ?? '',
                      style: textStyle,
                      maxLines: 2,
                    ),
                  ),
            ),
            Container(
              width: 54,
              height: 32,
              decoration: !widget.val
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: AppColor.gray3),
                    )
                  : null,
              child: CupertinoSwitch(
                trackColor: AppColor.gray6,
                activeColor: widget.val ? AppColor.darkBlue : AppColor.gray6,
                thumbColor: widget.val ? AppColor.brightGreen : AppColor.gray2,
                value: widget.val,
                onChanged: widget.onUpdate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
