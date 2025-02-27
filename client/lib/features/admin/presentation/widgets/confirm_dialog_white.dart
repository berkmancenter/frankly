import 'package:client/core/utils/error_utils.dart';
import 'package:flutter/material.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/action_button.dart';
import 'package:client/core/widgets/custom_list_view.dart';
import 'package:client/core/widgets/ui_migration.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/data/providers/dialog_provider.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:client/core/utils/platform_utils.dart';

class _DismissNotifier with ChangeNotifier {
  @override
  // ignore: unnecessary_overrides
  void notifyListeners() => super.notifyListeners();
}

class ConfirmDialogWhiteDismisser {
  final dismissNotifier = _DismissNotifier();

  void dismiss() => dismissNotifier.notifyListeners();
}

class ConfirmDialogWhite extends StatefulWidget {
  final String title;
  final String mainText;
  final String confirmText;
  final Function(BuildContext context)? onConfirm;
  final String cancelText;
  final Function(BuildContext context)? onCancel;

  const ConfirmDialogWhite({
    this.title = '',
    this.mainText = '',
    this.confirmText = 'Yes',
    this.onConfirm,
    this.cancelText = 'No',
    this.onCancel,
  });

  static final confirmDialogDismisser = ConfirmDialogWhiteDismisser();

  Future<bool> show({BuildContext? context}) async {
    return (await showCustomDialog(builder: (_) => this)) ?? false;
  }

  @override
  State<ConfirmDialogWhite> createState() => _ConfirmDialogWhiteState();
}

class _ConfirmDialogWhiteState extends State<ConfirmDialogWhite> {
  bool _dismissed = false;

  void _closeDialog() {
    if (_dismissed) return;

    _dismissed = true;
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();

    ConfirmDialogWhite.confirmDialogDismisser.dismissNotifier
        .addListener(_closeDialog);
  }

  @override
  void dispose() {
    ConfirmDialogWhite.confirmDialogDismisser.dismissNotifier
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
            constraints: BoxConstraints(maxWidth: 523),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColor.white,
            ),
            padding: const EdgeInsets.all(40),
            child: CustomListView(
              shrinkWrap: true,
              children: [
                if (!isNullOrEmpty(widget.title)) ...[
                  HeightConstrainedText(
                    widget.title,
                    style: AppTextStyle.headline3
                        .copyWith(color: AppColor.darkBlue),
                  ),
                  SizedBox(height: 10),
                ],
                if (!isNullOrEmpty(widget.mainText)) ...[
                  HeightConstrainedText(
                    widget.mainText,
                    style: AppTextStyle.body.copyWith(color: AppColor.darkBlue),
                  ),
                  SizedBox(height: 10),
                ],
                SizedBox(height: 10),
                ActionButton(
                  margin: EdgeInsets.all(4).copyWith(bottom: 0),
                  expand: true,
                  height: 48,
                  text: widget.confirmText,
                  color: AppColor.darkBlue,
                  textStyle: AppTextStyle.bodyMedium
                      .copyWith(color: AppColor.brightGreen),
                  onPressed: onConfirm != null
                      ? () => onConfirm(context)
                      : () => Navigator.of(context).pop(true),
                ),
                if (!isNullOrEmpty(widget.cancelText))
                  ActionButton(
                    margin:
                        EdgeInsets.symmetric(horizontal: 4).copyWith(top: 10),
                    expand: true,
                    height: 24,
                    color: Colors.transparent,
                    text: widget.cancelText,
                    textStyle: AppTextStyle.bodyMedium
                        .copyWith(color: AppColor.darkBlue),
                    onPressed: onCancel != null
                        ? () => onCancel(context)
                        : () => Navigator.of(context).pop(false),
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
