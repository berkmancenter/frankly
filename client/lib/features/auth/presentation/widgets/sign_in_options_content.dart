import 'package:client/core/utils/navigation_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/action_button.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/core/widgets/thick_outline_button.dart';
import 'package:client/config/environment.dart';
import 'package:client/services.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:provider/provider.dart';

class SignInOptionsContent extends StatefulWidget {
  const SignInOptionsContent({
    this.showSignUp = true,
    this.onComplete,
    Key? key,
  }) : super(key: key);

  static const showSignUpToggleKey = Key('new-user-toggle');
  static const nameTextFieldKey = Key('input-name');
  static const emailTextFieldKey = Key('input-email');
  static const passwordTextFieldKey = Key('input-password');
  static const buttonSubmitKey = Key('submit-button');

  final bool showSignUp;
  final void Function()? onComplete;

  @override
  State<SignInOptionsContent> createState() => _SignInOptionsContentState();
}

class _SignInOptionsContentState extends State<SignInOptionsContent> {
  final _formKey = GlobalKey<FormState>();

  late bool _showSignup = widget.showSignUp;
  late bool _showPassword = false;
  // late final String _formError = '';

  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _submitController = SubmitNotifier();

  Future<void> _onSubmit() async {
     if (!_formKey.currentState!.validate()) {return;}
    String name = _displayNameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    if (_showSignup) {
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
      if (!mounted) return;
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
        // if (_showEmailFormFields && !widget.showEmailFormOnly)
        //   Align(
        //     alignment: Alignment.topLeft,
        //     child: GestureDetector(
        //       child: Icon(Icons.arrow_back),
        //       onTap: () => setState(() => _showEmailFormFields = false),
        //     ),
        //   ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ..._buildSignIn(),
            SizedBox(height: 12),
            _buildTermsOfService(),
          ],
        ),
      ],
    );
  }

  String _getTitleText() {
    if (widget.showSignUp) {
      return 'Sign up for ${Environment.appName}';
    } else {
      return 'Log into ${Environment.appName}';
    }
  }

  Widget _getMessageText() {
    return Text.rich(
      key: SignInOptionsContent.showSignUpToggleKey,
      TextSpan(
        style: AppTextStyle.bodySmall,
        children: [
          TextSpan(
            text: _showSignup
                ? 'Already have an account? '
                : 'Don\'t have an account? ',
          ),
          TextSpan(
            text: _showSignup ? 'Log in' : 'Sign up',
            recognizer: TapGestureRecognizer()
              ..onTap = () => setState(() => _showSignup = !_showSignup),
            style: TextStyle(
              decoration: TextDecoration.underline,
            ),
          ),
          TextSpan(text: '.'),
        ],
      ),
    );
  }

  List<Widget> _buildSignIn() {
    const minWidth = 260.0;
    return [
      Align(
        alignment: Alignment.center,
        child: HeightConstrainedText(
          _getTitleText(),
          style: AppTextStyle.subhead,
        ),
      ),
      SizedBox(height: 9),
      // if (_getMessageText().isNotEm pty)
      Align(
        alignment: Alignment.center,
        child: _getMessageText(),
      ),

      Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            if (_showSignup)
              CustomTextField(
              key: SignInOptionsContent.nameTextFieldKey,
              controller: _displayNameController,
              labelText: 'Your Name',
              borderType: BorderType.underline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a valid name';
                }
                return null;
              },
            ),
            CustomTextField(
              key: SignInOptionsContent.emailTextFieldKey,
              controller: _emailController,
              labelText: 'Email',
              borderType: BorderType.underline,
            ),
            CustomTextField(
              key: SignInOptionsContent.passwordTextFieldKey,
              controller: _passwordController,
              onEditingComplete: () => _submitController.submit(),
              labelText: 'Password',
              obscureText: !_showPassword,
              borderType: BorderType.underline,
              suffixIcon: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 4, 0),
                child: IconButton(
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                  icon: Icon(
                    _showPassword
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    size: 24,
                  ),
                ),
              ),
            ),
            SizedBox(height: 9),
            ThickOutlineButton(
              key: SignInOptionsContent.buttonSubmitKey,
              minWidth: minWidth,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              // onPressed: () => setState(() => _showSignup = true),
              onPressed: () => _onSubmit(),
              text: !_showSignup ? 'Log in' : 'Sign up',
            ),
          ],
        ),
      ),
      SizedBox(height: 9),
      Align(
        alignment: Alignment.center,
        child: Text(
          'or',
          style: AppTextStyle.bodySmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      SizedBox(height: 9),
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
        text: 'Continue with Google',
      ),
    ];
  }

  Widget _buildTermsOfService() {
    return Text.rich(
      TextSpan(
        style: AppTextStyle.bodySmall,
        children: [
          TextSpan(
            text:
                'By signing in, registering, or using ${Environment.appName}, I agree to be bound by the ',
          ),
          TextSpan(
            text: '${Environment.appName} Terms of Service',
            recognizer: TapGestureRecognizer()
              ..onTap = () => launch(Environment.termsUrl),
            style: AppTextStyle.bodySmall.copyWith(
              decoration: TextDecoration.underline,
            ),
          ),
          TextSpan(text: '.'),
        ],
      ),
    );
  }
}
