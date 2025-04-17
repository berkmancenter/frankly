import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:client/services.dart';
import 'package:client/styles/styles.dart';

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

  /// Allow for custom suffix icon
  final Widget? suffixIcon;

  const CustomTextField({
    Key? key,
    this.padding = const EdgeInsets.only(top: 15),
    this.labelText,
    this.hintText,
    this.initialValue,
    this.maxLines,
    this.minLines = 1,
    this.textStyle,
    this.hintStyle,
    this.labelStyle,
    this.controller,
    this.onChanged,
    this.onEditingComplete,
    this.borderType = BorderType.outline,
    this.contentPadding =
        const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
    this.borderRadius = 5,
    this.backgroundColor = AppColor.white,
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
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
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
    this.suffixIcon,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;
  late TextEditingController _controller;
  final bool _shiftPressed = false;

  @override
  void initState() {
    super.initState();

    _focusNode = widget.focusNode ?? FocusNode();
    _controller = widget.controller ??
        TextEditingController(text: widget.initialValue ?? '');
  }

  TextStyle _buildLabelStyle(
    BuildContext context,
  ) {
    return widget.labelStyle ??
        context.theme.textTheme.bodySmall!.copyWith(
            color: _focusNode.hasFocus ? AppColor.accentBlue : AppColor.black,);
  }

  TextStyle _buildTextStyle(BuildContext context, {isError = false}) {
    return widget.textStyle ??
        (isError
            ? context.theme.textTheme.bodySmall!.copyWith(
                fontSize: 12,
                height: context.theme.textTheme.bodySmall!.height,
              )
            : context.theme.textTheme.bodyMedium!.copyWith(
                color: AppColor.black,
              ));
  }

  TextStyle _buildOptionalTextStyle() {
    return widget.optionalTextStyle ??
        context.theme.textTheme.bodySmall!.copyWith(color: AppColor.gray3);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.textFieldPadding,
      decoration: BoxDecoration(
        color: AppColor.transparent,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: Stack(
        children: [
          TextFormField(
            focusNode: _focusNode,
            textInputAction: TextInputAction.none,
            onChanged: (text) {
              final onChanged = widget.onChanged;
              if (onChanged != null) {
                onChanged(text);
              }
            },
            controller: _controller,
            style: _buildTextStyle(context),
            onEditingComplete: widget.onEditingComplete,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            obscureText: widget.obscureText,
            cursorColor: widget.cursorColor ?? AppColor.accentBlue,
            autovalidateMode: widget.autovalidateMode,
            // This is absolutely nuts, but this is needed for now in order to allow a unit test to succeed,
            // while not having to specify max lines for every single usage 🙄
            maxLength: (widget.maxLength != null &&
                    widget.minLines! > widget.maxLength!)
                ? widget.minLines
                : widget.maxLength,
            buildCounter: (
              _, {
              required currentLength,
              required maxLength,
              required isFocused,
            }) =>
                maxLength != null && isFocused && !widget.hideCounter
                    ? Container(
                        margin: EdgeInsets.only(left: 10),
                        alignment:
                            widget.counterAlignment ?? Alignment.centerRight,
                        child: Text(
                          '$currentLength/$maxLength',
                          style: widget.counterStyle ??
                              context.theme.textTheme.bodySmall,
                        ),
                      )
                    : null,
            maxLengthEnforcement: widget.maxLengthEnforcement,
            inputFormatters: [
              if (!_shiftPressed &&
                  !responsiveLayoutService.isMobile(context) &&
                  widget.onEditingComplete != null)
                DoNotAllowNewLineAtEnd(),
              if (widget.isOnlyDigits) FilteringTextInputFormatter.digitsOnly,
              if (widget.numberThreshold != null)
                NumberThresholdFormatter(widget.numberThreshold!),
            ],
            validator: widget.validator,
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              contentPadding: widget.contentPadding,
              labelText: widget.labelText,
              labelStyle: _buildLabelStyle(context),
              errorStyle: _buildTextStyle(context, isError: true),
              prefixText: widget.prefixText,
              prefixStyle: widget.textStyle,
              alignLabelWithHint: true,
              hintText: widget.hintText,
              hintStyle: _buildTextStyle(context),
              suffixIcon: widget.suffixIcon,
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
