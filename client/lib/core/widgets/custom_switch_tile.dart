import 'package:client/styles/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:flutter/material.dart';

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
                      style: widget.style ?? context.theme.textTheme.bodyLarge,
                      maxLines: 2,
                    ),
                  ),
            ),
            SizedBox(
              width: 52,
              height: 32,
              child: Switch(
                // trackColor: WidgetStateProperty.all(
                //     context.theme.colorScheme.onSurface.withOpacity(0.12),
                // ),
                // activeColor: Colors.amber,
                thumbColor: WidgetStateProperty.all(context.theme.colorScheme.surface),
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
