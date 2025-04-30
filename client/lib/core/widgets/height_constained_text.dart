import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';

class HeightConstrainedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final String? semanticsLabel;
  final bool softWrap;

  const HeightConstrainedText(
    this.text, {
    this.style,
    this.maxLines,
    this.textAlign,
    this.overflow,
    this.semanticsLabel,
    this.softWrap = true,
  });

  @override
  Widget build(BuildContext context) {
    var textStyle = context.theme.textTheme.bodyMedium!
        .merge(DefaultTextStyle.of(context).style)
        .merge(style ?? TextStyle());

    final localMaxLines = maxLines;
    final localFontSize = textStyle.fontSize;
    final localHeight = textStyle.height;
    if (localMaxLines != null && localFontSize != null && localHeight != null) {
      // Work around horizontal scrollbar bug temporarily
      // https://github.com/flutter/flutter/issues/82176

      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: localFontSize * localHeight * localMaxLines,
        ),
        child: Text(
          text,
          textAlign: textAlign,
          style: textStyle,
          softWrap: softWrap,
          semanticsLabel: semanticsLabel,
        ),
      );
    } else {
      return Text(
        text,
        textAlign: textAlign,
        overflow: overflow,
        style: textStyle,
        softWrap: softWrap,
        semanticsLabel: semanticsLabel,
      );
    }
  }
}
