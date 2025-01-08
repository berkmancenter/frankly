import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/utils/height_constained_text.dart';
import 'package:rainbow_color/rainbow_color.dart';

/// Gauge widget inspired from https://pub.dev/packages/pretty_gauge .
/// Paints gauge ([_ArcPainter]) in gradient colors and shows [_GaugeIndicatorClipper]
/// in range of [0:1].
///
/// [value] is the value of the [_GaugeIndicatorClipper].
/// [size] is the optional size of the widget. If [size] is not provided, it will take parent's size.
/// [title] is the title of the gauge.
/// [subtitle] is the subtitle of the gauge.
class ColorfulMeter extends StatefulWidget {
  final double value;
  final double? size;
  final String? title;
  final String? subtitle;

  @override
  _ColorfulMeterState createState() => _ColorfulMeterState();

  const ColorfulMeter({
    Key? key,
    required this.value,
    this.size,
    this.title,
    this.subtitle,
  })  : assert(value >= -1 && value <= 1, 'value must be between -1 and 1'),
        super(key: key);
}

class _ColorfulMeterState extends State<ColorfulMeter> {
  /// Default size of the widget.
  static const double kDefaultSize = 100;

  @override
  Widget build(BuildContext context) {
    final currentValue = widget.value;

    const double startingIndicatorAngle = math.pi;
    // 0.6 because we draw arc slightly more than half of rect. Half of rect - 0.5.
    final double endingIndicatorAngle = currentValue * 0.6 * math.pi;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double sizeFromConstraints;
        // Calculations for backup size.
        if (constraints.maxWidth != double.infinity) {
          sizeFromConstraints = constraints.maxWidth;
        } else if (constraints.maxHeight != double.infinity) {
          sizeFromConstraints = constraints.maxHeight;
        } else {
          sizeFromConstraints = kDefaultSize;
        }

        final double size;

        // If widget size is provided but parent's size is smaller than provided size,
        // use maximum size available within the parent.
        if (constraints.maxWidth < (widget.size ?? 0)) {
          size = constraints.maxWidth;
        } else if (constraints.maxHeight < (widget.size ?? 0)) {
          size = constraints.maxHeight;
        } else {
          size = widget.size ?? sizeFromConstraints;
        }

        // Using only for retrieving correct color from same color spectrum, which is used
        // in rendering gauge arc line.
        final rainbow = Rainbow(
          spectrum: AppColor.odometerColors,
          rangeStart: 1,
          rangeEnd: -1,
        );

        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            // Make sure that `indicator` has full rendering within UI.
            // When with `1` it slightly cuts off in couple places (being too close to width)
            widthFactor: 1.01,
            // Remove unused bottom space for this widget. `0.7` seems like a go.
            heightFactor: 0.7,
            child: SizedBox(
              height: size,
              width: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size(size, size),
                    painter: _ArcPainter(),
                  ),
                  Transform.rotate(
                    angle: startingIndicatorAngle + endingIndicatorAngle,
                    child: ClipPath(
                      clipper: _GaugeIndicatorClipper(),
                      child: Container(color: rainbow[currentValue]),
                    ),
                  ),
                  _buildText(size),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildText(double size) {
    // Text rendering happens within the Column. We want to make sure text is being rendered
    // at certain space in the widget. In this case, slightly above center. Therefore using
    // empty space as the first child in the `Column` to provide some `mock top padding`.
    final heightCompensation = size / 4;
    final fontSize = size / 8;
    final title = widget.title;
    final subtitle = widget.subtitle;

    if (title == null && subtitle == null) {
      return SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(height: heightCompensation),
        if (title != null)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size / 4),
            child: HeightConstrainedText(
              title,
              maxLines: 1,
              style: TextStyle(fontSize: fontSize, color: AppColor.gray4),
              textAlign: TextAlign.center,
            ),
          ),
        if (subtitle != null)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size / 7),
            child: HeightConstrainedText(
              subtitle,
              maxLines: 1,
              style: TextStyle(fontSize: fontSize, color: AppColor.gray4),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}

class _GaugeIndicatorClipper extends CustomClipper<Path> {
  // This comment bellow is from library mentioned above - not sure if it's legit.
  //
  // Note that x,y coordinate system starts at the bottom right of the canvas
  // with x moving from right to left and y moving from bottom to top.
  // Bottom right is 0,0 and top left is x,y.
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.95);
    path.lineTo(size.width * 0.55, size.height);
    path.lineTo(size.width * 0.7, size.height);
    path.lineTo(size.width * 0.45, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

/// Painter which draws the gradient line of the [ColorfulMeter].
class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final widthOfColorfulLine = size.width * 0.075;

    // Making rect slightly smaller because we need to use an indicator outside it.
    final rect = Rect.fromLTRB(
      size.width * 0.1,
      size.height * 0.1,
      size.width * 0.9,
      size.height * 0.9,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = widthOfColorfulLine
      ..shader = LinearGradient(
        begin: Alignment.bottomRight,
        end: Alignment.bottomLeft,
        colors: AppColor.odometerColors,
      ).createShader(rect);

    // Voodoo math to match drawn arc to UI Design.
    canvas.drawArc(rect, 0.9 * math.pi, 1.2 * math.pi, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
