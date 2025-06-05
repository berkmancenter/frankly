import 'package:flutter/material.dart';

/// Applies UnfocusOnKeyboardDismiss, and UnfocusOnTap, and/or ResizeForKeyboard to address issues
/// related to the mobile on-screen keyboard
class FocusFixer extends StatelessWidget {
  final Widget child;
  final bool resizeForKeyboard;
  final bool unfocusOnKeyboardDismiss;

  const FocusFixer({
    required this.child,
    this.unfocusOnKeyboardDismiss = true,
    this.resizeForKeyboard = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _unfocusOnKeyboardDismissIfTrue(
      child: _resizeForKeyboardIfTrue(
        child: child,
      ),
    );
  }

  Widget _unfocusOnKeyboardDismissIfTrue({required Widget child}) =>
      unfocusOnKeyboardDismiss
          ? _UnfocusOnKeyboardDismiss(child: child)
          : child;

  Widget _resizeForKeyboardIfTrue({required Widget child}) =>
      resizeForKeyboard ? _ResizeForKeyboard(child: child) : child;
}

/// When the keyboard is dismissed this widget calls .unfocus() to avoid the keyboard reappearing on
/// the next build
class _UnfocusOnKeyboardDismiss extends StatefulWidget {
  final Widget child;

  const _UnfocusOnKeyboardDismiss({required this.child, Key? key})
      : super(key: key);

  @override
  _UnfocusOnKeyboardDismissState createState() =>
      _UnfocusOnKeyboardDismissState();
}

class _UnfocusOnKeyboardDismissState extends State<_UnfocusOnKeyboardDismiss> {
  bool _keyboardWasOpen = false;

  bool get _isKeyboardOpen => MediaQuery.of(context).viewInsets.bottom != 0;

  void _checkSize() {
    if (_keyboardWasOpen && !_isKeyboardOpen) {
      FocusScope.of(context).unfocus();
    }
    _keyboardWasOpen = _isKeyboardOpen;
  }

  @override
  void didChangeDependencies() {
    _checkSize();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Only builds its content in the space not occupied by the on-screen keyboard. This is handled
/// by scaffolds automatically so this is only needed in dialogs outside of scaffolds
class _ResizeForKeyboard extends StatelessWidget {
  final Widget child;

  const _ResizeForKeyboard({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        height: MediaQuery.of(context).size.height -
            MediaQuery.of(context).viewInsets.bottom,
        child: child,
      ),
    );
  }
}
