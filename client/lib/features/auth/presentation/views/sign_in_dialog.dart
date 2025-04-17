import 'package:flutter/material.dart';
import 'package:client/features/auth/presentation/widgets/sign_in_options_content.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/data/providers/dialog_provider.dart';
import 'package:client/core/utils/platform_utils.dart';

class SignInDialog extends StatefulWidget {
  final bool isNewUser;
  final bool isPurchasingSubscription;
  final bool isDismissable;
  final bool showEmailFormOnly;

  const SignInDialog({
    Key? key,
    required this.isNewUser,
    this.isPurchasingSubscription = false,
    this.isDismissable = true,
    this.showEmailFormOnly = false,
  }) : super(key: key);

  static Future<void> show({
    bool newUser = true,
    bool isPurchasingSubscription = false,
    bool isDismissable = true,
    bool showEmailFormOnly = false,
    BuildContext? context,
  }) async {
    await showCustomDialog<void>(
      resizeForKeyboard: false,
      isDismissible: isDismissable,
      builder: (_) => SignInDialog(
        isNewUser: newUser,
        isPurchasingSubscription: isPurchasingSubscription,
        isDismissable: isDismissable,
        showEmailFormOnly: showEmailFormOnly,
      ),
    );
  }

  @override
  _SignInDialogState createState() => _SignInDialogState();
}

class _SignInDialogState extends State<SignInDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColor.white,
      child: Stack(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 300),
            child: ListView(
              padding: EdgeInsets.all(20) + EdgeInsets.only(top: 20),
              shrinkWrap: true,
              children: [
                SignInOptionsContent(
                  isPurchasingSubscription: widget.isPurchasingSubscription,
                  isNewUser: widget.isNewUser,
                  showEmailFormOnly: widget.showEmailFormOnly,
                ),
              ],
            ),
          ),
          if (widget.isDismissable)
            Positioned.fill(
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
