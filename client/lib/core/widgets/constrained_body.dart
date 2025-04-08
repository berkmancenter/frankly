import 'package:flutter/material.dart';
import 'package:client/styles/styles.dart';

class ConstrainedBody extends StatelessWidget {
  final double maxWidth;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  static const double defaultMaxWidth = AppSize.kPageContentMaxWidthDesktop;
  static const double outerPadding = 20;

  const ConstrainedBody({
    this.maxWidth = defaultMaxWidth,
    this.padding,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: outerPadding),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
