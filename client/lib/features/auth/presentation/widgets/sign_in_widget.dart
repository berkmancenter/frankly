import 'package:client/core/routing/locations.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:flutter/material.dart';
import 'package:client/core/localization/localization_helper.dart';

class SignInWidget extends StatelessWidget {
  @visibleForTesting
  static const signInKey = Key('sign-in');
  static const signUpKey = Key('sign-up');
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ActionButton(
          type: ActionButtonType.text,
          key: signInKey,
            onPressed: () => routerDelegate.beamTo(HomeLocation(showLoginByDefault: true)),
          text: context.l10n.signIn,
        ),
        const SizedBox(width: 8),
        ActionButton(
          type: ActionButtonType.filled,
          key: signUpKey,
          onPressed: () => routerDelegate.beamTo(HomeLocation()),
          text: context.l10n.signUp,
        ),
      ],
    );
  }
}
