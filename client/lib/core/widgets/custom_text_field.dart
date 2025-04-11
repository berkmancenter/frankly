import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:client/services.dart';
import 'package:client/styles/styles.dart';
import 'package:universal_html/js.dart' as universal_js;

enum BorderType {
  none,
  underline,
  outline,
}

class CustomTextField extends StatefulWidget {
  final EdgeInsets padding;
  final String? labelText;
  final String? hintText;
  final String? initialValue;
  final int? maxLines;
  final int? minLines;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Function()? onEditingComplete;
  final BorderType? borderType;
  final EdgeInsets? contentPadding;
  final double borderRadius;
  final TextStyle? labelStyle;
  final Color? backgroundColor;
  final FocusNode? focusNode;
  final EdgeInsets? textFieldPadding;
  final Color? borderColor;
  final bool unfocusOnSubmit;
  final int? maxLength;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final TextStyle? counterStyle;
  final String? counterText;
  final FormFieldValidator<String>? validator;
  final bool autofocus;
  final Color? fillColor;
  final Color? cursorColor;
  final bool readOnly;
  final AutovalidateMode? autovalidateMode;
  final String? prefixText;
  final bool isOnlyDigits;
  final Alignment? counterAlignment;
  final bool hideCounter;
  final void Function()? onTap;
  final bool obscureText;

  /// Defines if `Optional` is present at the end of the line.
  final bool isOptional;
  final TextStyle? optionalTextStyle;

  /// When having custom text style for `optional`, if font size changes, padding needs
  /// to be re-adjusted to match UI centred experience.
  final EdgeInsets? optionalPadding;

  /// Variable which is used to define maximum entered value.
  /// If [numberThreshold] is not null, [NumberThresholdFormatter] will be used.
  final num? numberThreshold;

  const CustomTextField({
    Key? key,
    this.padding = const EdgeInsets.only(top: 15),
    this.labelText,
    this.hintText,
    this.initialValue,
    this.maxLines = 3,
    this.minLines = 1,
    this.textStyle,
    this.hintStyle,
    this.labelStyle,
    this.controller,
    this.onChanged,
    this.onEditingComplete,
    this.borderType = BorderType.outline,
    this.contentPadding =
        const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
    this.borderRadius = 5,
    this.backgroundColor,
    this.focusNode,
    this.textFieldPadding,
    this.borderColor,
    this.unfocusOnSubmit = true,
    this.maxLength,
    this.maxLengthEnforcement,
    this.counterStyle,
    this.counterText,
    this.validator,
    this.autofocus = false,
    this.readOnly = false,
    this.fillColor,
    this.cursorColor,
    this.autovalidateMode,
    this.prefixText,
    this.isOnlyDigits = false,
    this.numberThreshold,
    this.counterAlignment,
    this.hideCounter = false,
    this.onTap,
    this.obscureText = false,
    this.isOptional = false,
    this.optionalTextStyle,
    this.optionalPadding,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;
  late TextEditingController _controller;
  bool _shiftPressed = false;

  void _unfocus() {
    if (kIsWeb) {
      universal_js.context.callMethod('focus');
    }
    FocusNode().requestFocus();
  }

  @override
  void initState() {
    super.initState();

    _focusNode = widget.focusNode ?? FocusNode();
    _controller = widget.controller ??
        TextEditingController(text: widget.initialValue ?? '');
  }

  InputBorder _getBorder({bool isError = false}) {
    if (widget.borderType == BorderType.outline) {
      return OutlineInputBorder(
        borderSide: BorderSide(
          color: widget.borderColor ?? _getBorderColor(isError: isError),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(widget.borderRadius),
      );
    } else if (widget.borderType == BorderType.underline) {
      return UnderlineInputBorder(
        borderSide: BorderSide(
          color: widget.borderColor ?? _getBorderColor(isError: isError),
          width: 1.0,
        ),
      );
    }

    return InputBorder.none;
  }

  Color _getBorderColor({bool isError = false}) {
    return isError
        ? AppColor.lightRed
        : _focusNode.hasFocus
            ? AppColor.accentBlue
            : AppColor.gray4;
  }

  TextStyle _buildLabelStyle() {
    return widget.labelStyle ??
        AppTextStyle.bodySmall.copyWith(
          color: _focusNode.hasFocus ? AppColor.accentBlue : AppColor.gray4,
        );
  }

  TextStyle _buildTextStyle({bool isError = false}) {
    return widget.textStyle ??
        AppTextStyle.body.copyWith(
          color: isError ? AppColor.redLightMode : AppColor.gray2,
        );
  }

  TextStyle _buildOptionalTextStyle() {
    return widget.optionalTextStyle ??
        AppTextStyle.bodySmall.copyWith(color: AppColor.gray3);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Container(
        padding: widget.textFieldPadding,
        decoration: BoxDecoration(
          color: widget.backgroundColor ??
              context.theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: KeyboardListener(
          focusNode: FocusNode(),
          onKeyEvent: (event) {
            final isEventShiftKey =
                event.logicalKey == LogicalKeyboardKey.shiftLeft ||
                    event.logicalKey == LogicalKeyboardKey.shiftRight;
            if (_shiftPressed != isEventShiftKey) {
              setState(() => _shiftPressed = isEventShiftKey);
            }

            if (widget.onEditingComplete != null &&
                event.runtimeType == KeyDownEvent &&
                !isEventShiftKey &&
                event.logicalKey == LogicalKeyboardKey.enter) {
              widget.onEditingComplete!();
              if (widget.unfocusOnSubmit) {
                _unfocus();
              }
            }
          },
          child: Stack(
            children: [
              TextFormField(
                onTap: () {
                  _unfocus();
                  final localOnTap = widget.onTap;
                  if (localOnTap != null) {
                    localOnTap();
                  }
                },
                focusNode: _focusNode,
                textInputAction: TextInputAction.none,
                onChanged: (text) {
                  final onChanged = widget.onChanged;
                  if (onChanged != null) {
                    onChanged(text);
                  }
                },
                controller: _controller,
                style: _buildTextStyle(),
                onEditingComplete: widget.onEditingComplete,
                maxLines: widget.maxLines,
                minLines: widget.minLines,
                obscureText: widget.obscureText,
                cursorColor: widget.cursorColor ?? AppColor.accentBlue,
                autovalidateMode: widget.autovalidateMode,
                maxLength: widget.maxLength,
                buildCounter: (
                  _, {
                  required currentLength,
                  required maxLength,
                  required isFocused,
                }) =>
                    maxLength != null && isFocused && !widget.hideCounter
                        ? Container(
                            margin: EdgeInsets.only(left: 10),
                            alignment: widget.counterAlignment ??
                                Alignment.centerRight,
                            child: Text(
                              '$currentLength/$maxLength',
                              style:
                                  widget.counterStyle ?? AppTextStyle.bodySmall,
                            ),
                          )
                        : null,
                maxLengthEnforcement: widget.maxLengthEnforcement,
                inputFormatters: [
                  if (!_shiftPressed &&
                      !responsiveLayoutService.isMobile(context) &&
                      widget.onEditingComplete != null)
                    DoNotAllowNewLineAtEnd(),
                  if (widget.isOnlyDigits)
                    FilteringTextInputFormatter.digitsOnly,
                  if (widget.numberThreshold != null)
                    NumberThresholdFormatter(widget.numberThreshold!),
                ],
                validator: widget.validator,
                decoration: InputDecoration(
                  contentPadding: widget.contentPadding,
                  border: _getBorder(),
                  focusedBorder: _getBorder(),
                  enabledBorder: _getBorder(),
                  errorBorder: _getBorder(isError: true),
                  labelText: widget.labelText,
                  labelStyle: _buildLabelStyle(),
                  errorStyle: _buildTextStyle(isError: true),
                  prefixText: widget.prefixText,
                  prefixStyle: widget.textStyle,
                  alignLabelWithHint: true,
                  hintText: widget.hintText,
                  hintStyle: _buildTextStyle(),
                  fillColor: widget.fillColor,
                  filled: widget.fillColor != null,
                ),
                autofocus: widget.autofocus,
                readOnly: widget.readOnly,
                keyboardType: TextInputType.multiline,
              ),
              if (widget.isOptional &&
                  !_focusNode.hasFocus &&
                  _controller.text.isEmpty)
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: _buildOptionalPadding(),
                    child: Text(
                      'Optional',
                      style: _buildOptionalTextStyle(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  EdgeInsetsGeometry _buildOptionalPadding() {
    return widget.optionalPadding ??
        const EdgeInsets.only(top: 16, right: 12.0);
  }
}

class DoNotAllowNewLineAtEnd extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text;
    while (newText.characters.length > oldValue.text.characters.length) {
      if (newText.characters.last != '\n') break;

      newText = newText.substring(0, newText.characters.length - 1);
    }

    return newValue.copyWith(text: newText);
  }
}

/// Checks if input is more than [value] - if it it, returns old value.
///
/// This is particularly used with [TimeInputForm] in order to avoid overspill in formatting.
/// For example if input seconds are 61, making 1m1s. This formatter avoids it.
class NumberThresholdFormatter extends TextInputFormatter {
  final num value;

  NumberThresholdFormatter(this.value);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final number = num.tryParse(newValue.text) ?? 0;
    return number > value ? oldValue : newValue;
  }
}
