import 'package:flutter/material.dart';

class CustomLoadingIndicator extends StatelessWidget {
  final Color? color;

  const CustomLoadingIndicator({
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CircularProgressIndicator(
        strokeWidth: 4.0,
        color: color,
      ),
    );
  }
}
