import 'package:client/core/widgets/constrained_body.dart';
import 'package:flutter/material.dart';

class ContentHorizontalPadding extends StatelessWidget {
  final Widget child;

  const ContentHorizontalPadding({required this.child});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBody(child: child);
  }
}
