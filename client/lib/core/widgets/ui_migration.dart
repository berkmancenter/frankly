import 'package:flutter/material.dart';

class UIMigration extends StatelessWidget {
  final Widget child;
  final bool whiteBackground;

  const UIMigration({
    Key? key,
    required this.child,
    this.whiteBackground = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: whiteBackground ? Colors.white : null,
      child: child,
    );
  }
} 