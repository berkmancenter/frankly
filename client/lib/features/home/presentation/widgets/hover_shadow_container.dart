import 'package:flutter/material.dart';
import 'package:client/styles/styles.dart';

/// A Widget that shows a box shadow underneath its child when hovered over
class HoverShadowContainer extends StatefulWidget {
  const HoverShadowContainer({
    required this.child,
    this.borderRadius,
    this.shadowColor,
    Key? key,
  }) : super(key: key);

  final Widget child;
  final BorderRadiusGeometry? borderRadius;
  final Color? shadowColor;

  @override
  _HoverShadowContainerState createState() => _HoverShadowContainerState();
}

class _HoverShadowContainerState extends State<HoverShadowContainer> {
  bool _elevated = false;

  void _onHover() => setState(() => _elevated = true);

  void _onHoverCancel() => setState(() => _elevated = false);

  @override
  Widget build(BuildContext context) {
    final boxShadow = [
      BoxShadow(
        color:
            widget.shadowColor ?? context.theme.colorScheme.onPrimaryContainer,
        offset: Offset(1, 1),
        blurRadius: 10,
      ),
    ];

    return MouseRegion(
      onEnter: (_) => _onHover(),
      onExit: (_) => _onHoverCancel(),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          boxShadow: _elevated ? boxShadow : null,
        ),
        child: widget.child,
      ),
    );
  }
}
