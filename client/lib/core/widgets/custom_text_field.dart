import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:client/styles/styles.dart';
import 'package:client/core/localization/localization_helper.dart';
import 'package:universal_html/js.dart' as universal_js;
import 'package:markdown_editor_plus/markdown_editor_plus.dart';

enum BorderType {
  none,
  underline,
  outline,
}

/// A customizable text field widget.
/// This widget provides various options to customize its appearance and behavior,
/// including border type, padding, text styles, and more.
///
/// {@tool snippet}
/// ```dart
/// CustomTextField(
///   hintText: 'Enter message',
///   initialValue: 'Hello, welcome to Frankly!',
///   borderType: BorderType.outline,
///   borderRadius: 10,
///   maxLength: 200,
///   minLines: 3,
///   maxLines: null,
///   keyboardType: TextInputType.multiline,
///   onChanged: (text) => updateEnteredMessage(text),
///   validator: (text) => validateMessage(text),
/// ),
/// ```
/// {@end-tool}
///
class CustomTextField extends StatefulWidget {
  /// The amount of padding to apply around the text field widget.
  final EdgeInsets padding;

  /// The text to display as the label above the text field.
  final String? labelText;

  /// The text to display as a hint inside the text field when it is empty.
  final String? hintText;

  /// The helper text to display below the text field.
  final String? helperText;

  /// The initial value to display in the text field when it is first built.
  final String? initialValue;

  /// If null, this will be ignored and the text field will expand infinitely.
  final int? maxLines;

  /// If null, this will default to 1.
  /// If [maxLines] is not null, [minLines] will not be allowed to be more than [maxLines].
  /// If [maxLines] is null, [minLines] will be allowed to be any value.
  final int minLines;

  /// If null, this will default to the theme's bodyMedium text style.
  final TextStyle? textStyle;

  /// If null, this will default to the theme's bodyMedium text style with a
  /// slightly lighter color.
  final TextStyle? hintStyle;

  /// The controller for managing the text being edited.
  final TextEditingController? controller;

  /// Callback function that is called whenever the text changes.
  final Function(String)? onChanged;

  /// Callback function that is called when editing is complete.
  final Function()? onEditingComplete;

  /// Defines the type of border to display around the text field.
  /// Defaults to [BorderType.outline].
  final BorderType? borderType;

  /// The amount of padding to apply to the content inside the text field.
  final EdgeInsets? contentPadding;

  /// The radius of the border for the text field.
  final double borderRadius;

  /// The style to use for the label text.
  final TextStyle? labelStyle;

  /// The background color of the text field.
  final Color? backgroundColor;

  /// The focus node for the text field.
  final FocusNode? focusNode;

  /// The padding inside the text field.
  final EdgeInsets? textFieldPadding;

  /// The color of the text field's border.
  final Color? borderColor;

  /// Whether to unfocus the text field when submitting.
  final bool unfocusOnSubmit;

  /// Whether to show a border when the text field is focused.
  /// If true, displays a focused border.
  final bool showFocusedBorder;

  /// The maximum number of characters allowed in the text field.
  /// If null, no limit is enforced.
  final int? maxLength;

  /// Determines how the max length is enforced.
  final MaxLengthEnforcement? maxLengthEnforcement;

  /// The style to use for the character counter text.
  final TextStyle? counterStyle;

  /// The custom text to display for the character counter.
  final String? counterText;

  /// The validator function for the text field.
  final FormFieldValidator<String>? validator;

  /// Whether the text field should autofocus when the widget is built.
  final bool autofocus;

  /// The fill color of the text field.
  final Color? fillColor;

  /// The color of the cursor in the text field.
  /// If null, uses the default cursor color.
  final Color? cursorColor;

  /// Whether the text field is read-only.
  /// If true, the field cannot be edited.
  final bool readOnly;

  /// The auto validation mode for the text field.
  /// Controls when the field is validated.
  final AutovalidateMode? autovalidateMode;

  /// The prefix text to display before the input.
  /// Useful for adding static text before user input.
  final String? prefixText;

  /// Whether the text field only accepts digits.
  /// If true, restricts input to numeric characters.
  final bool isOnlyDigits;

  /// The alignment of the character counter.
  /// Controls the position of the counter within the field.
  /// If null, defaults to Alignment.centerRight.
  final Alignment? counterAlignment;

  /// Whether to hide the character counter.
  /// If true, the counter is not displayed.
  final bool hideCounter;

  /// The callback function to invoke when the text field is tapped.
  /// Used to handle tap events on the field.
  final void Function()? onTap;

  /// Whether to obscure the text input.
  /// If true, hides the input (e.g., for passwords).
  final bool obscureText;

  /// Defines if `Optional` is present at the end of the line.
  final bool isOptional;

  /// Style for the `Optional` text.
  /// If null, defaults to `AppTextStyle.bodySmall.copyWith(color: context.theme.colorScheme.onSurfaceVariant)`.
  /// Note that the color will not automatically adjust based on focus state.
  /// If you want it to change color based on focus, provide a custom [optionalTextStyle].
  final TextStyle? optionalTextStyle;

  /// Padding for the `Optional` text.
  /// If null, defaults to `EdgeInsets.only(top: 16, right: 12.0)`.
  final EdgeInsets? optionalPadding;

  /// Variable which is used to define maximum entered value.
  /// If [numberThreshold] is not null, [NumberThresholdFormatter] will be used.
  final num? numberThreshold;

  /// Allow for custom suffix icon
  final Widget? suffixIcon;

  /// Allow for custom keyboard type
  /// If null, defaults to [TextInputType.text]
  final TextInputType keyboardType;

  /// Allow for custom input formatters
  final TextInputFormatter? inputFormatters;

  final bool markdownEditor;

  const CustomTextField({
    Key? key,
    this.padding = const EdgeInsets.only(top: 15),
    this.labelText,
    this.hintText,
    this.initialValue,
    this.maxLines = 1,
    this.minLines = 1,
    this.textStyle,
    this.hintStyle,
    this.helperText,
    this.labelStyle,
    this.controller,
    this.onChanged,
    this.onEditingComplete,
    this.borderType = BorderType.outline,
    this.contentPadding,
    this.borderRadius = 5,
    this.backgroundColor,
    this.focusNode,
    this.textFieldPadding,
    this.borderColor,
    this.unfocusOnSubmit = true,
    this.showFocusedBorder = true,
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
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.markdownEditor = false,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;
  late TextEditingController _controller;
  bool _hasFocus = false;
  bool _hasMouseHover = false;

  void _unfocus() {
    if (kIsWeb) {
      universal_js.context.callMethod('focus');
    }
    FocusNode().requestFocus();
  }

  void _onExitMouse(PointerEvent details) {
    setState(() {
      _hasMouseHover = false;
    });
  }

  void _onEnterMouse(PointerEvent details) {
    setState(() {
      _hasMouseHover = true;
    });
  }

  @override
  void initState() {
    super.initState();

    _focusNode = widget.focusNode ?? FocusNode();
    _controller = widget.controller ??
        TextEditingController(text: widget.initialValue ?? '');

    _focusNode.addListener(() {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
    });
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

  InputBorder _getFocusedBorder({bool isError = false}) {
    if (!widget.showFocusedBorder) {
      return InputBorder.none;
    }
    if (widget.borderType == BorderType.underline) {
      return UnderlineInputBorder(
        borderSide: BorderSide(
          color: _getBorderColor(isError: isError),
          width: 2.0,
        ),
      );
    }
    return OutlineInputBorder(
      borderSide: BorderSide(
        color: _getBorderColor(isError: isError),
        width: 2.0,
      ),
      borderRadius: BorderRadius.circular(widget.borderRadius),
    );
  }

  Color _getBorderColor({bool isError = false}) {
    return isError
        ? context.theme.colorScheme.errorContainer
        : _focusNode.hasFocus || _hasMouseHover
            ? context.theme.colorScheme.primary
            : context.theme.colorScheme.onPrimaryContainer;
  }

  TextStyle _buildLabelStyle() {
    return widget.labelStyle ??
        AppTextStyle.bodySmall.copyWith(
          color: _focusNode.hasFocus
              ? context.theme.colorScheme.primary
              : context.theme.colorScheme.onSurfaceVariant,
          fontWeight: _hasFocus ? FontWeight.bold : FontWeight.normal,
        );
  }

  TextStyle _buildOptionalTextStyle() {
    return widget.optionalTextStyle ??
        AppTextStyle.bodySmall
            .copyWith(color: context.theme.colorScheme.onSurfaceVariant);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: MouseRegion(
        onEnter: _onEnterMouse,
        onExit: _onExitMouse,
        child: Container(
          padding: widget.textFieldPadding,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child: Stack(
            children: [
              if (widget.markdownEditor)
                MarkdownAutoPreview(
                  emojiConvert: true,
                  minLines: 4,
                  maxLines: 10,
                  writeOnly: true,
                  onChanged: (text) {
                    final onChanged = widget.onChanged;
                    if (onChanged != null) {
                      onChanged(text);
                    }
                  },
                  toolbarBackground: Colors.transparent,
                  controller: _controller,
                  decoration: InputDecoration(
                    // make room with contentPadding for toolbar
                    contentPadding: EdgeInsets.fromLTRB(
                      widget.contentPadding?.left ?? 12,
                      (widget.contentPadding?.top ?? 12) + 110,
                      widget.contentPadding?.right ?? 12,
                      widget.contentPadding?.bottom ?? 12,
                    ),
                    border: _getBorder(),
                    focusedBorder: _getFocusedBorder(),
                    enabledBorder: _getBorder(),
                    errorBorder: _getBorder(isError: true),
                    focusedErrorBorder: _getFocusedBorder(isError: true),
                    labelText: widget.labelText,
                    labelStyle: _buildLabelStyle(),
                    errorStyle: context.theme.textTheme.labelMedium!
                        .copyWith(color: context.theme.colorScheme.error),
                    prefixText: widget.prefixText,
                    prefixStyle: widget.textStyle,
                    alignLabelWithHint: true,
                    hintText: widget.hintText,
                    hintStyle: context.theme.textTheme.bodyMedium,
                    helperText: widget.helperText,
                    fillColor: widget.fillColor,
                    filled: widget.fillColor != null,
                    suffixIcon: widget.suffixIcon,
                  ),
                  borderColor: _getBorderColor(),
                  autofocus: widget.autofocus,
                  readOnly: widget.readOnly,
                  enabled: !widget.readOnly,
                  keyboardType: widget.keyboardType,
                ),
              if (!widget.markdownEditor)
                TextFormField(
                  onTap: () {
                    _unfocus();
                    final localOnTap = widget.onTap;
                    if (localOnTap != null) {
                      localOnTap();
                    }
                  },
                  onChanged: (text) {
                    final onChanged = widget.onChanged;
                    if (onChanged != null) {
                      onChanged(text);
                    }
                  },
                  onFieldSubmitted: (value) {
                    widget.onEditingComplete?.call();
                  },
                  focusNode: _focusNode,
                  textInputAction: TextInputAction.none,
                  controller: _controller,
                  style: widget.textStyle ?? context.theme.textTheme.bodyMedium,
                  onEditingComplete: widget.onEditingComplete,
                  // This is absolutely nuts, but this is needed for now in order to allow a unit test to succeed,
                  // while not having to specify max lines for every single usage 🙄
                  maxLines: widget.maxLines == null
                      ? null
                      : !widget.minLines.compareTo(widget.maxLines!).isNegative
                          ? widget.minLines
                          : widget.maxLines,
                  minLines: widget.minLines,
                  obscureText: widget.obscureText,
                  cursorColor:
                      widget.cursorColor ?? context.theme.colorScheme.primary,
                  cursorHeight: 20,
                  autovalidateMode: widget.autovalidateMode,
                  maxLength: widget.maxLength,
                  buildCounter: (
                    _, {
                    required currentLength,
                    required maxLength,
                    required isFocused,
                  }) =>
                      maxLength != null && !widget.hideCounter
                          ? Container(
                              margin: EdgeInsets.only(left: 10),
                              alignment: widget.counterAlignment ??
                                  Alignment.centerRight,
                              child: isFocused
                                  ? Text(
                                      '$currentLength/$maxLength',
                                      style: widget.counterStyle ??
                                          AppTextStyle.bodySmall,
                                    )
                                  : SizedBox.square(
                                      dimension: widget.counterStyle?.fontSize ??
                                          AppTextStyle.bodySmall.fontSize,
                                    ),
                            )
                          : null,
                  maxLengthEnforcement: widget.maxLengthEnforcement,
                  inputFormatters: [
                    if (widget.isOnlyDigits)
                      FilteringTextInputFormatter.digitsOnly,
                    if (widget.numberThreshold != null)
                      NumberThresholdFormatter(widget.numberThreshold!)
                    else if (widget.inputFormatters != null)
                      widget.inputFormatters!,
                  ],
                  validator: widget.validator,
                  decoration: InputDecoration(
                    contentPadding: widget.contentPadding,
                    border: _getBorder(),
                    focusedBorder: _getFocusedBorder(),
                    enabledBorder: _getBorder(),
                    errorBorder: _getBorder(isError: true),
                    focusedErrorBorder: _getFocusedBorder(isError: true),
                    labelText: widget.labelText,
                    labelStyle: _buildLabelStyle(),
                    errorStyle: context.theme.textTheme.labelMedium!
                        .copyWith(color: context.theme.colorScheme.error),
                    prefixText: widget.prefixText,
                    prefixStyle: widget.textStyle,
                    alignLabelWithHint: true,
                    hintText: widget.hintText,
                    hintStyle: context.theme.textTheme.bodyMedium,
                    helperText: widget.helperText,
                    fillColor: widget.fillColor,
                    filled: widget.fillColor != null,
                    suffixIcon: widget.suffixIcon,
                  ),
                  autofocus: widget.autofocus,
                  readOnly: widget.readOnly,
                  enabled: !widget.readOnly,
                  keyboardType: widget.keyboardType,
                ),
              if (!widget.markdownEditor &&
                  widget.isOptional &&
                  !_focusNode.hasFocus &&
                  _controller.text.isEmpty)
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: _buildOptionalPadding(),
                    child: Text(
                      context.l10n.optional,
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
