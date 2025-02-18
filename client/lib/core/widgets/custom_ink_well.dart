import 'package:flutter/material.dart';

class CustomInkWell extends StatefulWidget {
  final Function(bool)? onHover;
  final Function()? onTap;
  final Color? hoverColor;
  final BorderRadius? borderRadius;
  final BoxShape? boxShape;
  final Widget? child;

  /// Highlight on hover even if onTap is null.
  final bool forceHighlightOnHover;

  const CustomInkWell({
    this.onHover,
    this.onTap,
    this.hoverColor,
    this.borderRadius,
    this.boxShape,
    this.forceHighlightOnHover = false,
    this.child,
  });

  @override
  _CustomInkWellState createState() => _CustomInkWellState();
}

class _CustomInkWellState extends State<CustomInkWell> {
  var _hover = false;

  @override
  void setState(Function() setter) {
    if (mounted) {
      super.setState(setter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localOnHover = widget.onHover;

    Color hoverFillColor =
        widget.hoverColor ?? Theme.of(context).primaryColor.withOpacity(0.2);
    if (widget.onTap == null && !widget.forceHighlightOnHover) {
      hoverFillColor = Colors.transparent;
    }
    return MouseRegion(
      cursor:
          widget.onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
      onEnter: (_) {
        if (localOnHover != null) {
          localOnHover(true);
        }

        setState(() => _hover = true);
      },
      onExit: (_) {
        if (localOnHover != null) {
          localOnHover(false);
        }
        setState(() => _hover = false);
      },
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          GestureDetector(
            onTap: widget.onTap,
            behavior: HitTestBehavior.opaque,
            child: widget.child,
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  color: _hover && widget.onTap != null ? hoverFillColor : null,
                  borderRadius: widget.borderRadius,
                  shape: widget.boxShape ?? BoxShape.rectangle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
