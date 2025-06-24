import 'dart:async';

import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/custom_loading_indicator.dart';
import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:client/core/widgets/height_constained_text.dart';

enum ActionButtonType { filled, outline, text }

enum ActionButtonIconSide {
  left,
  right,
}

enum ActionButtonContentAlignment {
  start,
  center,
  end,
}

class SubmitNotifier {
  final List<Future<void> Function()> _listeners = [];

  void addListener(Future<void> Function() listener) =>
      _listeners.add(listener);

  void removeListener(Future<void> Function() listener) =>
      _listeners.remove(listener);

  Future<void> submit() async {
    for (final listener in _listeners) {
      await listener();
    }
  }
}

class ActionButton extends StatefulWidget {
  /// Can be a widget or [IconData].
  final dynamic icon;
  final ActionButtonType type;
  final String? text;
  final Color? color;
  final Color? disabledColor;
  final Color? textColor;
  final TextStyle? textStyle;
  final int? maxLines;
  final double? maxTextWidth;
  final OutlinedBorder? shape;
  final BorderRadius? borderRadius;
  final double? minWidth;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final bool expand;
  final FutureOr<dynamic> Function()? onPressed;
  final String? eventName;
  final Map<String, dynamic>? eventParameters;
  final SubmitNotifier? controller;
  final ActionButtonContentAlignment contentAlign;
  final ActionButtonIconSide iconSide;

  final double? loadingHeight;
  final double? height;

  final String? tooltipText;

  /// Only used for outline button.
  final BorderSide? borderSide;

  final Widget? child;

  const ActionButton({
    Key? key,
    this.icon,
    this.type = ActionButtonType.filled,
    this.text,
    this.color,
    this.disabledColor,
    this.textColor,
    this.textStyle,
    this.maxLines,
    this.maxTextWidth,
    this.shape,
    this.borderRadius,
    this.minWidth,
    this.borderSide,
    this.padding,
    this.margin,
    this.expand = false,
    this.onPressed,
    this.eventName,
    this.eventParameters,
    this.controller,
    this.contentAlign = ActionButtonContentAlignment.center,
    this.iconSide = ActionButtonIconSide.left,
    this.loadingHeight,
    this.height,
    this.tooltipText,
    this.child,
  })  : assert(child == null || text == null, 'Cannot specify child and text'),
        super(key: key);

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  bool _waiting = false;

  @override
  void initState() {
    super.initState();

    widget.controller?.addListener(_runAction);
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller?.removeListener(_runAction);
  }

  Future<void> _runAction() async {
    if (_waiting) return;

    setState(() => _waiting = true);

    // Errors should be handled in the passed in [onPressed].
    final onPressed = widget.onPressed;
    if (onPressed != null) {
      await swallowErrors(onPressed);
    }

    setState(() => _waiting = false);
  }

  @override
  void setState(Function() stateSetter) {
    if (mounted) super.setState(stateSetter);
  }

  Widget _buildIcon() {
    if (widget.icon is Widget) {
      return widget.icon as Widget;
    } else if (widget.icon is IconData) {
      return Padding(
        padding: widget.iconSide == ActionButtonIconSide.left
            ? const EdgeInsets.only(right: 6)
            : const EdgeInsets.only(left: 6),
        child: Icon(
          widget.icon,
          size: 18,
          color: widget.textColor,
        ),
      );
    }

    throw Exception('Icon must be a Widget or IconData instance.');
  }

  Widget _buildButtonContents() {
    final text = widget.text;
    final mainAxisAlignment =
        widget.contentAlign == ActionButtonContentAlignment.center
            ? MainAxisAlignment.center
            : widget.contentAlign == ActionButtonContentAlignment.start
                ? MainAxisAlignment.start
                : MainAxisAlignment.end;
    final child = widget.child;

    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: mainAxisAlignment,
        children: [
          // Show loading indicator only if waiting for action
          if (_waiting)
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: _buildLoading(),
            ),
          if (!_waiting && widget.icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: _buildIcon(),
            ),

          if (text != null)
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: widget.maxTextWidth ?? double.infinity,
              ),
              child: HeightConstrainedText(
                text,
                maxLines: widget.maxLines,
              ),
            ),
          if (text == null && child != null) child,
        ],
      ),
    );
  }

  Widget _buildButton() {
    final shape = widget.shape ??
        RoundedRectangleBorder(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(10),
        );
    final minimumSize = Size(widget.minWidth ?? 96, widget.height ?? 50);

    final onPressed = widget.onPressed != null && !_waiting ? _runAction : null;

    final Widget button;
    switch (widget.type) {
      case ActionButtonType.filled:
        button = FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: widget.color,
            textStyle: widget.textStyle,
            foregroundColor:
                widget.textColor ?? context.theme.colorScheme.onPrimary,
            disabledBackgroundColor: widget.disabledColor,
            minimumSize: minimumSize,
            shape: shape,
          ),
          child: _buildButtonContents(),
        );
        break;
      case ActionButtonType.outline:
        button = OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: widget.borderSide ??
                BorderSide(
                  color: widget.color ?? context.theme.colorScheme.primary,
                ),
            textStyle: widget.textStyle,
            foregroundColor:
                widget.textColor ?? context.theme.colorScheme.primary,
            disabledForegroundColor: widget.disabledColor,
            minimumSize: minimumSize,
            shape: shape,
          ),
          onPressed: onPressed,
          child: _buildButtonContents(),
        );
        break;
      case ActionButtonType.text:
        button = TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            textStyle: widget.textStyle,
            foregroundColor:
                widget.textColor ?? context.theme.colorScheme.primary,
            disabledForegroundColor: widget.disabledColor,
            minimumSize: minimumSize,
            shape: shape,
          ),
          child: _buildButtonContents(),
        );
        break;
    }

    final semanticsWrappedButton = Semantics(
      button: true,
      focused: false,
      enabled: widget.onPressed != null,
      label: widget.text,
      child: button,
    );

    if (widget.expand) {
      return Expanded(child: semanticsWrappedButton);
    } else {
      return semanticsWrappedButton;
    }
  }

  Widget _buildTooltipWrappedButton() {
    final message = widget.tooltipText;
    if (message == null) return _buildButton();

    return Tooltip(
      message: message,
      child: _buildButton(),
    );
  }

  Widget _buildLoading() {
    // If color is either black, or button is filled, ensure that indicator is on primary color
    Color loadingColor =
        (widget.type == ActionButtonType.filled || widget.color == Colors.black)
            ? context.theme.colorScheme.onPrimary
            : context.theme.colorScheme.primary;
    return SizedBox(
      height: widget.loadingHeight ?? 24,
      width: widget.loadingHeight ?? 24,
      child: CustomLoadingIndicator(
        color: loadingColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTooltipWrappedButton(),
      ],
    );
  }
}
