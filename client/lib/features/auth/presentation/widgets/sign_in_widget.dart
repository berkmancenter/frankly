import 'package:flutter/material.dart';
import 'package:client/core/widgets/navbar/nav_button.dart';
import 'package:client/features/auth/presentation/views/sign_in_dialog.dart';
import 'package:client/services.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:client/styles/app_styles.dart';
import 'package:provider/provider.dart';

class SignInWidget extends StatelessWidget {
  @visibleForTesting
  static const signInKey = Key('sign-in');
  static const signUpKey = Key('sign-up');

  Future<void> _showLogin(BuildContext context, {bool isNewUser = true}) async {
    await SignInDialog.show(newUser: isNewUser);
  }

  Widget _buildSignedIn(BuildContext context) {
    return NavButton(
      onPressed: () => userService.signOut(),
      text: 'Sign Out',
    );
  }

  Widget _buildSignedOut(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        NavButton(
          key: signInKey,
          onPressed: () => _showLogin(context, isNewUser: false),
          text: 'Log In',
        ),
        NavButton(
          key: signUpKey,
          onPressed: () => _showLogin(context),
          text: 'Sign Up',
          backgroundColor: AppColor.darkBlue,
          textColor: AppColor.white,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSignedIn = context.watch<UserService>().isSignedIn;
    return isSignedIn ? _buildSignedIn(context) : _buildSignedOut(context);
  }
}
