import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:client/app/community/utils.dart';
import 'package:client/common_widgets/action_button.dart';
import 'package:client/common_widgets/custom_text_field.dart';
import 'package:client/common_widgets/thick_outline_button.dart';
import 'package:client/environment.dart';
import 'package:client/services/services.dart';
import 'package:client/services/user_service.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/utils/height_constained_text.dart';
import 'package:client/utils/platform_utils.dart';
import 'package:provider/provider.dart';

class SignInOptionsContent extends StatefulWidget {
  static const emailSignInKey = Key('email-sign-in');
  static const newUserToggleKey = Key('new-user-toggle');
  static const nameTextFieldKey = Key('input-name');
  static const emailTextFieldKey = Key('input-email');
  static const passwordTextFieldKey = Key('input-password');
  static const signInSubmitKey = Key('sign-in-submit');

  final bool isNewUser;
  final bool isInitializedOnEmailPassword;
  final bool isPurchasingSubscription;
  final void Function()? onComplete;

  const SignInOptionsContent({
    this.isNewUser = true,
    this.isInitializedOnEmailPassword = false,
    this.isPurchasingSubscription = false,
    this.onComplete,
    Key? key,
  }) : super(key: key);

  @override
  State<SignInOptionsContent> createState() => _SignInOptionsContentState();
}

class _SignInOptionsContentState extends State<SignInOptionsContent> {
  late bool _emailSelected = widget.isInitializedOnEmailPassword;
  late bool _newUser = widget.isNewUser;

  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _submitController = SubmitNotifier();

  Future<void> _onSubmit() async {
    String name = _displayNameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    if (_newUser) {
      await context.read<UserService>().registerWithEmail(
            displayName: name,
            email: email,
            password: password,
          );
    } else {
      await context.read<UserService>().signInWithEmail(
            email: email,
            password: password,
          );
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
    widget.onComplete?.call();
  }

  Future<void> _resetPassword() {
    return alertOnError(context, () async {
      await userService.resetPassword(email: _emailController.text);
      await showAlert(
        context,
        'Password reset link sent to ${_emailController.text}',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_emailSelected)
          Align(
            alignment: Alignment.topLeft,
            child: GestureDetector(
              child: Icon(Icons.arrow_back),
              onTap: () => setState(() => _emailSelected = false),
            ),
          ),
        Column(
          children: [
            if (_emailSelected)
              ..._buildEmailWidgets()
            else
              ..._buildSignInProviderButtons(),
            SizedBox(height: 8),
            _buildTermsOfService(),
          ],
        ),
      ],
    );
  }

  String _getTitleText() {
    if (widget.isPurchasingSubscription) {
      return 'New Subscription';
    } else if (widget.isNewUser) {
      return 'New to ${Environment.appName}?';
    } else {
      return 'Sign in to ${Environment.appName}';
    }
  }

  String _getMessageText() {
    if (widget.isPurchasingSubscription) {
      return 'Sign up (or sign in using an existing account) to continue.';
    } else if (widget.isNewUser) {
      return 'Sign up to enjoy meaningful conversation!';
    } else {
      return '';
    }
  }

  List<Widget> _buildSignInProviderButtons() {
    const minWidth = 260.0;
    return [
      Align(
        alignment: Alignment.centerLeft,
        child: HeightConstrainedText(
          _getTitleText(),
          style: AppTextStyle.headline3,
        ),
      ),
      SizedBox(height: 9),
      if (_getMessageText().isNotEmpty)
        Align(
          alignment: Alignment.centerLeft,
          child: HeightConstrainedText(
            _getMessageText(),
            style: AppTextStyle.body.copyWith(color: AppColor.darkBlue),
          ),
        ),
      SizedBox(height: 9),
      if (!isWKWebView)
        ThickOutlineButton(
          minWidth: minWidth,
          onPressed: () => context.read<UserService>().signInWithGoogle(),
          icon: Padding(
            padding: const EdgeInsets.only(right: 8, top: 6, bottom: 6),
            child: Image.asset(
              'media/googleLogo.png',
              width: 22,
              height: 22,
            ),
          ),
          backgroundColor: Colors.white,
          text: 'Sign ${widget.isNewUser ? 'up' : 'in'} with Google',
        ),
      ThickOutlineButton(
        key: SignInOptionsContent.emailSignInKey,
        minWidth: minWidth,
        icon: Padding(
          padding: const EdgeInsets.only(right: 8, top: 6, bottom: 6),
          child: Icon(
            Icons.email,
            color: AppColor.darkBlue,
            size: 22,
          ),
        ),
        backgroundColor: Colors.white,
        onPressed: () => setState(() => _emailSelected = true),
        text: 'Sign ${widget.isNewUser ? 'up' : 'in'} with Email',
      ),
    ];
  }

  List<Widget> _buildEmailWidgets() {
    return [
      Center(
        child: Text(
          _newUser ? 'Create an account' : 'Sign In',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      if (_newUser)
        CustomTextField(
          key: SignInOptionsContent.nameTextFieldKey,
          controller: _displayNameController,
          labelText: 'Your Name',
        ),
      CustomTextField(
        key: SignInOptionsContent.emailTextFieldKey,
        controller: _emailController,
        labelText: 'Email',
      ),
      CustomTextField(
        key: SignInOptionsContent.passwordTextFieldKey,
        controller: _passwordController,
        onEditingComplete: () => _submitController.submit(),
        labelText: 'Password',
        maxLines: 1,
        obscureText: true,
      ),
      Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.only(top: 10),
        child: ActionButton(
          key: SignInOptionsContent.signInSubmitKey,
          controller: _submitController,
          onPressed: () => alertOnError(context, _onSubmit),
          text: _newUser ? 'Register' : 'Sign In',
        ),
      ),
      if (!_newUser)
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: TextButton(
            onPressed: _resetPassword,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
              child: Text('Forgot Password'),
            ),
          ),
        ),
      Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(2),
        child: ThickOutlineButton(
          key: SignInOptionsContent.newUserToggleKey,
          onPressed: () => setState(() => _newUser = !_newUser),
          text: _newUser ? 'Already a user? Sign In' : 'New user? Register',
        ),
      ),
    ];
  }

  Widget _buildTermsOfService() {
    return Text.rich(
      TextSpan(
        style: body.copyWith(fontSize: 12),
        children: [
          TextSpan(
            text:
                'By signing in, registering, or using ${Environment.appName}, I agree to be bound by the ',
          ),
          TextSpan(
            text: '${Environment.appName} Terms of Service',
            recognizer: TapGestureRecognizer()
              ..onTap = () => launch(Environment.termsUrl),
            style: TextStyle(
              color: Colors.blueAccent,
              decoration: TextDecoration.underline,
              fontStyle: FontStyle.italic,
            ),
          ),
          TextSpan(text: '.'),
        ],
      ),
    );
  }
}
