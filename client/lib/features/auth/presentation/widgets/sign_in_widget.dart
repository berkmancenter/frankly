import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:flutter/material.dart';
import 'package:client/features/auth/presentation/views/sign_in_dialog.dart';
import 'package:client/core/localization/localization_helper.dart';

class SignInWidget extends StatelessWidget {
  @visibleForTesting
  static const signInKey = Key('sign-in');
  static const signUpKey = Key('sign-up');

  Future<void> _showLogin(BuildContext context, {bool isNewUser = true}) async {
    await SignInDialog.show(newUser: isNewUser);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ActionButton(
          type: ActionButtonType.text,
          key: signInKey,
          onPressed: () => _showLogin(context, isNewUser: false),
          text: context.l10n.signIn,
        ),
        const SizedBox(width: 8),
        ActionButton(
          type: ActionButtonType.filled,
          key: signUpKey,
          onPressed: () => _showLogin(context),
          text: context.l10n.signUp,
        ),
      ],
    );
  }
}
