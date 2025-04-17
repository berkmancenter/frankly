import 'dart:async';

import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/custom_loading_indicator.dart';
import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:client/core/widgets/height_constained_text.dart';

enum ActionButtonSendingIndicatorAlign {
  left,
  right,

  /// Loading indicator is not shown.
  none,
  interior,
}

enum ActionButtonType {
  outline,
  flat,
}

enum ActionButtonIconSide {
  left,
  right,
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
  final Color? overlayColor;
  final TextStyle? textStyle;
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
  final ActionButtonSendingIndicatorAlign sendingIndicatorAlign;
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
    this.type = ActionButtonType.flat,
    this.text,
    this.color,
    this.disabledColor,
    this.textColor,
    this.overlayColor,
    this.textStyle,
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
    this.sendingIndicatorAlign = ActionButtonSendingIndicatorAlign.left,
    this.iconSide = ActionButtonIconSide.left,
    this.loadingHeight,
    this.height,
    this.tooltipText,
    this.child,
  })  : assert(
          textStyle == null || textColor == null,
          'Cannot specify textStyle and textColor',
        ),
        assert(child == null || text == null, 'Cannot specify child and text'),
        super(key: key);

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  bool _isSending = false;

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
    if (_isSending) return;

    setState(() => _isSending = true);

    // Errors should be handled in the passed in [onPressed].
    final onPressed = widget.onPressed;
    if (onPressed != null) {
      await swallowErrors(onPressed);
    }

    setState(() => _isSending = false);
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
          color: _getTextColor(),
        ),
      );
    }

    throw Exception('Icon must be a Widget or IconData instance.');
  }

  Color _getTextColor() {
    if (widget.type == ActionButtonType.outline) {
      return widget.textColor ??
          widget.borderSide?.color ??
          context.theme.colorScheme.primary;
    }

    Color defaultTextColor = context.theme.colorScheme.onPrimary;
    if (widget.color == context.theme.colorScheme.primary) {
      defaultTextColor = context.theme.colorScheme.onPrimary;
    } else if (widget.color == context.theme.colorScheme.secondary) {
      defaultTextColor = context.theme.colorScheme.primary;
    } else if (widget.color == context.theme.colorScheme.error) {
      defaultTextColor = context.theme.colorScheme.onError;
    }

    return widget.textColor ?? defaultTextColor;
  }

  Widget _buildButtonContents() {
    final showSendingIndicatorInterior = widget.sendingIndicatorAlign ==
            ActionButtonSendingIndicatorAlign.interior &&
        _isSending;
    final text = widget.text;
    final child = widget.child;

    return Container(
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.iconSide == ActionButtonIconSide.left &&
              widget.icon != null &&
              !showSendingIndicatorInterior)
            _buildIcon(),
          if (showSendingIndicatorInterior) ...[
            SizedBox(
              height: 18,
              width: 18,
              child: CustomLoadingIndicator(),
            ),
            SizedBox(width: 10),
          ],
          if (text != null)
            HeightConstrainedText(
              text,
              textAlign: TextAlign.center,
              style: body.copyWith(color: _getTextColor()).merge(
                    widget.textStyle ?? TextStyle(),
                  ),
            )
          else if (child != null)
            child,
          if (widget.iconSide == ActionButtonIconSide.right &&
              widget.icon != null &&
              !showSendingIndicatorInterior)
            _buildIcon(),
        ],
      ),
    );
  }

  Widget _buildButton() {
    final overlayColor = widget.overlayColor != null
        ? WidgetStateProperty.all(widget.overlayColor)
        : null;
    final shape = widget.shape ??
        RoundedRectangleBorder(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(10),
        );
    final minimumSize = WidgetStateProperty.all(
      Size(widget.minWidth ?? 96, widget.height ?? 50),
    );
    final onPressed =
        widget.onPressed != null && !_isSending ? _runAction : null;

    final Widget button;
    if (widget.type == ActionButtonType.flat) {
      button = TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return widget.disabledColor ??
                  context.theme.colorScheme.onSurface.withOpacity(0.38);
            }
            return widget.color ?? context.theme.colorScheme.primary;
          }),
          overlayColor: overlayColor,
          minimumSize: minimumSize,
          shape: WidgetStateProperty.all(shape),
        ),
        child: _buildButtonContents(),
      );
    } else if (widget.type == ActionButtonType.outline) {
      button = OutlinedButton(
        style: ButtonStyle(
          overlayColor: overlayColor,
          side: WidgetStateProperty.all(
            widget.borderSide ??
                BorderSide(
                  color: _getTextColor(),
                ),
          ),
          padding: WidgetStateProperty.all(EdgeInsets.zero),
          minimumSize: minimumSize,
          shape: WidgetStateProperty.all(shape),
        ),
        onPressed: onPressed,
        child: _buildButtonContents(),
      );
    } else {
      button = SizedBox.shrink();
    }

    if (widget.expand) {
      return Expanded(child: button);
    }

    return button;
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
    if (widget.loadingHeight == null) {
      return CustomLoadingIndicator();
    } else {
      return SizedBox(
        height: widget.loadingHeight,
        width: widget.loadingHeight,
        child: CustomLoadingIndicator(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.margin ?? const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.sendingIndicatorAlign ==
                  ActionButtonSendingIndicatorAlign.left &&
              _isSending)
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: _buildLoading(),
            ),
          _buildTooltipWrappedButton(),
          if (widget.sendingIndicatorAlign ==
                  ActionButtonSendingIndicatorAlign.right &&
              _isSending)
            Padding(
              padding: const EdgeInsets.only(left: 14),
              child: _buildLoading(),
            ),
        ],
      ),
    );
  }
}
