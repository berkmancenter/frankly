import 'package:client/styles/styles.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:flutter/material.dart';

class CustomSwitchTile extends StatefulWidget {
  final String? text;
  final Widget? textWidget;
  final bool val;
  final bool loading;
  final void Function(bool) onUpdate;
  final TextStyle? style;

  const CustomSwitchTile({
    Key? key,
    this.text,
    this.textWidget,
    required this.val,
    required this.onUpdate,
    this.loading = false,
    this.style,
  }) : super(key: key);

  @override
  State<CustomSwitchTile> createState() => _CustomSwitchTileState();
}

class _CustomSwitchTileState extends State<CustomSwitchTile> {
  @override
  Widget build(BuildContext context) {
    return CustomInkWell(
      hoverColor: Colors.transparent,
      onTap: () => widget.loading ?  null : widget.onUpdate(!widget.val),
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
                    child: Row(
                      children: [
                        Flexible(
                          child: HeightConstrainedText(
                          widget.text ?? '',
                          style:
                            widget.style ?? context.theme.textTheme.bodyLarge,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.loading)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(strokeWidth: 1.5,),
                            ),
                          ),
                      ],
                    ),
                  ),
            ),
            SizedBox(
              width: 52,
              height: 32,
              child: Switch(
                thumbColor:
                    WidgetStateProperty.all(context.theme.colorScheme.surface),
                value: widget.val,
                onChanged: widget.loading ? null : widget.onUpdate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
