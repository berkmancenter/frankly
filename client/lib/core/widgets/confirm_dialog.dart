import 'package:client/core/utils/error_utils.dart';
import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/custom_list_view.dart';
import 'package:client/services.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/data/providers/dialog_provider.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:client/core/utils/platform_utils.dart';

class _DismissNotifier with ChangeNotifier {
  @override
  void notifyListeners() => super.notifyListeners();
}

class ConfirmDialogDismisser {
  final dismissNotifier = _DismissNotifier();

  void dismiss() => dismissNotifier.notifyListeners();
}

class ConfirmDialog extends StatefulWidget {
  static const Key confirmButtonKey = Key('confirm-button');

  final String title;
  final String mainText;
  final String subText;
  final String confirmText;
  final Function(BuildContext context)? onConfirm;
  final String cancelText;
  final Function(BuildContext context)? onCancel;
  final TextAlign textAlign;
  final bool isWhiteBackground;

  const ConfirmDialog({
    this.title = '',
    this.mainText = '',
    this.subText = '',
    this.confirmText = 'Yes',
    this.onConfirm,
    this.cancelText = 'No',
    this.onCancel,
    this.textAlign = TextAlign.center,
    this.isWhiteBackground = true,
  });

  static final confirmDialogDismisser = ConfirmDialogDismisser();

  Future<bool> show({BuildContext? context}) async {
    return (await showCustomDialog(builder: (_) => this)) ?? false;
  }

  @override
  State<ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<ConfirmDialog> {
  bool _dismissed = false;

  void _closeDialog() {
    if (_dismissed) return;

    _dismissed = true;
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();

    ConfirmDialog.confirmDialogDismisser.dismissNotifier
        .addListener(_closeDialog);
  }

  @override
  void dispose() {
    ConfirmDialog.confirmDialogDismisser.dismissNotifier
        .removeListener(_closeDialog);

    super.dispose();
  }

  Widget _buildDialog(BuildContext context) {
    final onCancel = widget.onCancel;
    final onConfirm = widget.onConfirm;

    return CustomPointerInterceptor(
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () {},
          child: Container(
            constraints: BoxConstraints(maxWidth: 600),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: context.theme.colorScheme.surface,
            ),
            padding: const EdgeInsets.all(40),
            child: CustomListView(
              shrinkWrap: true,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: ActionButton(
                    height: 40,
                    padding: const EdgeInsets.all(0),
                    margin: const EdgeInsets.all(0),
                    minWidth: 50,
                    borderRadius: BorderRadius.circular(0),
                    color: Colors.transparent,
                    icon: Icon(
                      Icons.close,
                      size: 40,
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                if (!isNullOrEmpty(widget.title)) ...[
                  HeightConstrainedText(
                    widget.title,
                    style: responsiveLayoutService.isMobile(context)
                        ? AppTextStyle.headline2
                        : AppTextStyle.headline1,
                    textAlign: widget.textAlign,
                  ),
                  SizedBox(height: 10),
                ],
                if (!isNullOrEmpty(widget.mainText)) ...[
                  HeightConstrainedText(
                    widget.mainText,
                    style: AppTextStyle.body,
                    textAlign: widget.textAlign,
                  ),
                  SizedBox(height: 10),
                ],
                if (!isNullOrEmpty(widget.subText)) ...[
                  HeightConstrainedText(
                    widget.subText,
                    style: body.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (!isNullOrEmpty(widget.cancelText))
                      ActionButton(
                        height: 55,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        minWidth: 100,
                        color: Colors.transparent,
                        text: widget.cancelText,
                        textStyle: AppTextStyle.body,
                        onPressed: onCancel != null
                            ? () => onCancel(context)
                            : () => Navigator.of(context).pop(false),
                      )
                    else
                      SizedBox.shrink(),
                    ActionButton(
                      key: ConfirmDialog.confirmButtonKey,
                      height: 55,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      color: context.theme.primaryColor,
                      text: widget.confirmText,
                      onPressed: onConfirm != null
                          ? () => onConfirm(context)
                          : () => Navigator.of(context).pop(true),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Builder(
        builder: (context) => _buildDialog(context),
      ),
    );
  }
}
