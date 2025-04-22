import 'package:client/styles/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
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
                      style: AppTextStyle.body,
                      maxLines: 2,
                    ),
                  ),
            ),
            SizedBox(
              width: 54,
              height: 32,
              child: CupertinoSwitch(
                trackColor:
                    context.theme.colorScheme.onSurface.withOpacity(0.12),
                activeColor: context.theme.colorScheme.primary,
                thumbColor: context.theme.colorScheme.surface,
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
