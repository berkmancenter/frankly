import 'package:client/core/data/providers/dialog_provider.dart';
import 'package:client/core/localization/localization_helper.dart';
import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';

/// Standard confirmation dialog for destructive actions.
///
/// Uses the default Material [AlertDialog] with a Cancel and a red Delete
/// action. Focus order is Cancel, then Delete. There is no close icon.
class DeleteDialog extends StatelessWidget {
  static const Key confirmButtonKey = Key('delete-dialog-confirm-button');
  static const Key cancelButtonKey = Key('delete-dialog-cancel-button');

  /// Maximum dialog width, from the design.
  static const double maxWidth = 312;
  static const double _screenMargin = 24;

  final String title;
  final String? content;

  /// Defaults to the localized "Delete".
  final String? confirmText;

  /// Defaults to the localized "Cancel".
  final String? cancelText;

  /// Runs when the user confirms. Defaults to popping the dialog with `true`.
  final Function(BuildContext context)? onConfirm;

  const DeleteDialog({
    required this.title,
    this.content,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
  });

  /// Resolves to `true` only when the user confirms.
  Future<bool> show({BuildContext? context}) async {
    return (await showCustomDialog<bool>(
          context: context,
          builder: (_) => this,
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final onConfirm = this.onConfirm;
    final content = this.content;

    // AlertDialog sizes to its content (up to 560), which makes long messages
    // wide. Cap the width to match the design, keeping a screen margin on
    // narrow phones.
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: _screenMargin),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxWidth),
          child: AlertDialog(
            insetPadding: const EdgeInsets.symmetric(vertical: _screenMargin),
            title: Text(title),
            content:
                (content == null || content.isEmpty) ? null : Text(content),
            actions: [
              TextButton(
                key: cancelButtonKey,
                autofocus: true,
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(cancelText ?? context.l10n.cancel),
              ),
              TextButton(
                key: confirmButtonKey,
                style: TextButton.styleFrom(
                  foregroundColor: context.theme.colorScheme.error,
                ),
                onPressed: onConfirm != null
                    ? () => onConfirm(context)
                    : () => Navigator.of(context).pop(true),
                child: Text(confirmText ?? context.l10n.delete),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
