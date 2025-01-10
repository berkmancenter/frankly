import 'package:flutter/material.dart';

class CustomLoadingIndicator extends StatelessWidget {
  final double strokeWidth;
  final Color? color;

  const CustomLoadingIndicator({
    this.strokeWidth = 4.0,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: color,
      ),
    );
  }
}
