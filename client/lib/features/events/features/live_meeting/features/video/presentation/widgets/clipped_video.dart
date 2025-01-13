import 'package:flutter/material.dart';

class ClippedVideo extends StatefulWidget {
  final double? width;
  final double? height;
  final Widget child;

  const ClippedVideo({
    Key? key,
    this.width,
    this.height,
    required this.child,
  }) : super(key: key);

  @override
  _ClippedVideoState createState() => _ClippedVideoState();
}

class _ClippedVideoState extends State<ClippedVideo> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        border: Border.all(
          color: Colors.white24,
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        child: widget.child,
      ),
    );
  }
}
