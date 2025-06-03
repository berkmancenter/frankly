import 'package:flutter/material.dart';
import 'package:client/features/auth/presentation/widgets/sign_in_options_content.dart';
import 'package:client/styles/styles.dart';
import 'package:client/core/data/providers/dialog_provider.dart';

class SignInDialog extends StatefulWidget {
  final bool showSignup;
  final bool isDismissable;
  final bool showEmailFormOnly;

  const SignInDialog({
    Key? key,
    required this.showSignup,
    this.isDismissable = true,
    this.showEmailFormOnly = false,
  }) : super(key: key);

  static Future<void> show({
    bool newUser = true,
    bool isDismissable = true,
    bool showEmailFormOnly = false,
    BuildContext? context,
  }) async {
    await showCustomDialog<void>(
      resizeForKeyboard: false,
      isDismissible: isDismissable,
      builder: (_) => SignInDialog(
        showSignup: newUser,
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
      backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
        
      ),
      child: Stack(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400),
            child: ListView(
              padding: EdgeInsets.all(40) + EdgeInsets.only(top: 30),
              shrinkWrap: true,
              children: [
                SignInOptionsContent(
                  showSignUp: widget.showSignup,
                  inModal: true,
                ),
              ],
            ),
          ),
          if (widget.isDismissable)
            Positioned.fill(
              right: 20,
              top: 20, 
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(                  
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
