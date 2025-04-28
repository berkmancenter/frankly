import 'package:client/core/utils/navigation_utils.dart';
import 'package:client/styles/styles.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/config/environment.dart';
import 'package:client/services.dart';
import 'package:client/features/user/data/services/user_service.dart';
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
  static const buttonGoogleKey = Key('google-button');

  final bool showSignUp;
  final void Function()? onComplete;

  @override
  State<SignInOptionsContent> createState() => _SignInOptionsContentState();
}

class _SignInOptionsContentState extends State<SignInOptionsContent> {
  final _formKey = GlobalKey<FormState>();

  late bool _showSignup = widget.showSignUp;
  late bool _showPassword = false;
  // This is used to ignore password validation when user is asking to reset password
  late bool _ignorePassword;
  late String _formError = '';
  late String _formMessage = '';

  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _submitController = SubmitNotifier();

  bool isEmailValid(String email) {
    return RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(email);
  }

  bool isPasswordValid(String password) {
    // Password must be at least 12 characters long, and contain one lowercase and one uppercase letter
    return RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z]).{12,}$').hasMatch(password);
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
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

// Create a widget containing information about account error messages received from our backend
  Widget _accountErrorMessageBuilder(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return Text.rich(
          TextSpan(
            style: context.theme.textTheme.bodyMedium?.copyWith(
              color: context.theme.colorScheme.error,
            ),
            children: [
              TextSpan(
                text: 'This email is already in use. Try ',
              ),
              TextSpan(
                text: 'logging in',
                recognizer: TapGestureRecognizer()
                  ..onTap = () => setState(() {
                        _showSignup = false;
                        _formError = '';
                      }),
                style: context.theme.textTheme.bodyMedium?.copyWith(
                  decoration: TextDecoration.underline,
                  color: context.theme.colorScheme.error,
                ),
              ),
              TextSpan(text: ' instead.'),
            ],
          ),
        );
      case 'user-not-found':
        return Text.rich(
          TextSpan(
            style: context.theme.textTheme.bodyMedium?.copyWith(
              color: context.theme.colorScheme.error,
            ),
            children: [
              TextSpan(
                text: 'We couldn’t find an account with this email. Try ',
              ),
              TextSpan(
                text: 'signing up',
                recognizer: TapGestureRecognizer()
                  ..onTap = () => setState(() {
                        _showSignup = true;
                        _formError = '';
                      }),
                style: context.theme.textTheme.bodyMedium?.copyWith(
                  decoration: TextDecoration.underline,
                  color: context.theme.colorScheme.error,
                ),
              ),
              TextSpan(text: ' instead.'),
            ],
          ),
        );
      case 'email-missing-pw':
        return Text(
          'Please enter a valid email address.',
          style: context.theme.textTheme.bodyMedium?.copyWith(
            color: context.theme.colorScheme.error,
          ),
        );

      default:
        return Text(
          'Something went wrong. Please try again.',
          style: context.theme.textTheme.bodySmall,
        );
    }
  }

  Future<void> _resetPassword() async {
    await authMessageOnError(
      () => userService.resetPassword(email: _emailController.text),
      errorCallback: (error, msg) => {
        if (msg == 'Email must be entered to reset password.')
          setState(() {
            _formError = 'email-missing-pw';
            _ignorePassword = false;
          })
        else
          setState(() {
            _formError = msg;
            _ignorePassword = false;
          }),
      },
      callback: () => {
        setState(() {
          _formMessage = 'Password reset link sent to ${_emailController.text}';
          _ignorePassword = false;
        }),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ..._buildSignIn(),
            SizedBox(height: 15),
            _buildTermsOfService(),
          ],
        ),
      ],
    );
  }

  String _getTitleText() {
    if (_showSignup) {
      return 'Sign up for ${Environment.appName}';
    } else {
      return 'Log into ${Environment.appName}';
    }
  }

  Widget _getMessageText() {
    return Text.rich(
      key: SignInOptionsContent.showSignUpToggleKey,
      TextSpan(
        style: context.theme.textTheme.bodyMedium,
        children: [
          TextSpan(
            text: _showSignup
                ? 'Already have an account? '
                : 'Don\'t have an account? ',
          ),
          TextSpan(
            text: _showSignup ? 'Log in' : 'Sign up',
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                if (_formError.isNotEmpty) {
                  _formKey.currentState!.reset();
                }
                setState(() {
                  _showSignup = !_showSignup;
                  _formError = '';
                });
              },
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
          style: context.theme.textTheme.titleLarge,
        ),
      ),
      SizedBox(height: 9),
      Align(
        alignment: Alignment.center,
        child: _getMessageText(),
      ),
      Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            if (_showSignup)
              Column(
                children: [
                  CustomTextField(
                    key: SignInOptionsContent.nameTextFieldKey,
                    borderType: BorderType.underline,
                    controller: _displayNameController,
                    labelText: 'Full Name',
                    hintText: 'e.g. Jane Doe',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a valid name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                ],
              ),
            CustomTextField(
              key: SignInOptionsContent.emailTextFieldKey,
              borderType: BorderType.underline,
              controller: _emailController,
              labelText: 'Email',
              validator: (value) {
                if (value == null || value.isEmpty || !isEmailValid(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            CustomTextField(
              key: SignInOptionsContent.passwordTextFieldKey,
              borderType: BorderType.underline,
              controller: _passwordController,
              onEditingComplete: () => _submitController.submit(),
              labelText: 'Password',
              obscureText: !_showPassword,
              suffixIcon: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 4, 0),
                child: Semantics(
                  label: _showPassword ? 'Hide password' : 'Show password',
                  button: true,
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
              validator: (value) {
                if (_ignorePassword) {
                  return null;
                }
                // If the user is not signing up, just validate if any value is entered, not format;
                // Because they may have a legacy account before we started enforcing complexity
                if (!_showSignup && (value == null || value.isEmpty)) {
                  return 'Please enter a password';
                } else if (_showSignup &&
                    (value == null ||
                        value.isEmpty ||
                        !isPasswordValid(value))) {
                  return 'Please enter a valid password';
                }
                return null;
              },
            ),
            SizedBox(height: 5),
            if (_showSignup)
              Text(
                'Must be at least 12 characters long, and contain one lowercase and one uppercase letter',
                style: context.theme.textTheme.bodySmall,
              ),
            if (!_showSignup)
              Align(
                alignment: Alignment.topLeft,
                child: Text.rich(
                  TextSpan(
                    text: 'Forgot your password?',
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // We have to disable password validation for now so the form validation can succeed without it
                        setState(() {
                          _ignorePassword = true;
                        });
                        if(_formKey.currentState!.validate()){
                          _resetPassword();}
                      },
                    style: context.theme.textTheme.bodySmall?.copyWith(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            SizedBox(height: 9),
            if (_formError.isNotEmpty) _accountErrorMessageBuilder(_formError),
            if (_formMessage.isNotEmpty)
              Text(
                _formMessage,
                style: context.theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            SizedBox(height: 9),
            ActionButton(
              key: SignInOptionsContent.buttonSubmitKey,
              onPressed: () => authMessageOnError(
                _onSubmit,
                errorCallback: (error, code) => setState(
                  () => _formError = code,
                ),
              ),
              sendingIndicatorAlign: ActionButtonSendingIndicatorAlign.none,
              type: ActionButtonType.filled,
              minWidth: minWidth,
              textColor: Colors.white,
              color: Colors.black,
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
          style: context.theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      SizedBox(height: 9),
      ActionButton(
        key: SignInOptionsContent.buttonGoogleKey,
        minWidth: minWidth,
        onPressed: () => context.read<UserService>().signInWithGoogle(),
        type: ActionButtonType.outline,
        icon: Padding(
          padding: const EdgeInsets.only(right: 8, top: 6, bottom: 6),
          child: Image.asset(
            'media/googleLogo.png',
            width: 22,
            height: 22,
          ),
        ),
        text: 'Continue with Google',
      ),
    ];
  }

  Widget _buildTermsOfService() {
    return Text.rich(
      TextSpan(
        style: context.theme.textTheme.bodyMedium,
        children: [
          TextSpan(
            text:
                'By signing in, registering, or using ${Environment.appName}, I agree to be bound by the ',
          ),
          TextSpan(
            text: '${Environment.appName} Terms of Service',
            recognizer: TapGestureRecognizer()
              ..onTap = () => launch(Environment.termsUrl),
            style: context.theme.textTheme.bodyMedium?.copyWith(
              decoration: TextDecoration.underline,
            ),
          ),
          TextSpan(text: '.'),
        ],
      ),
    );
  }
}
