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
import 'package:client/core/localization/localization_helper.dart';

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
  late bool _ignorePassword = false;
  late String _formError = '';
  late String _formMessage = '';

  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
                text: context.l10n.emailAddressAlreadyInUseLoginError,
              ),
              TextSpan(
                text: context.l10n.loggingIn,
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
              TextSpan(text: context.l10n.insteadSuffix),
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
                text: context.l10n.couldntFindAccount,
              ),
              TextSpan(
                text: context.l10n.signingUp,
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
              TextSpan(text: context.l10n.insteadSuffix),
            ],
          ),
        );
      case 'email-missing-pw':
        return Text(
          context.l10n.pleaseEnterValidEmail,
          style: context.theme.textTheme.bodyMedium?.copyWith(
            color: context.theme.colorScheme.error,
          ),
        );

      default:
        return Text(
          context.l10n.somethingWentWrongTryAgain,
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
          _formMessage =
              context.l10n.passwordResetLinkSent(_emailController.text);
          _ignorePassword = false;
        }),
      },
    );
  }

  void _submitForm() {
    authMessageOnError(
      _onSubmit,
      errorCallback: (error, code) => setState(
        () => _formError = code,
      ),
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
      return context.l10n.newToApp(Environment.appName);
    } else {
      return context.l10n.signInToApp(Environment.appName);
    }
  }

  Widget _getMessageText() {
    return Text.rich(
      key: SignInOptionsContent.showSignUpToggleKey,
      TextSpan(
        style: context.theme.textTheme.bodyMedium,
        children: [
          TextSpan(
            text:
                '${_showSignup ? context.l10n.alreadyUserSignIn : context.l10n.notUserSignUp} ',
          ),
          TextSpan(
            text: _showSignup ? context.l10n.signIn : context.l10n.signUp,
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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (_showSignup)
              Column(
                children: [
                  CustomTextField(
                    key: SignInOptionsContent.nameTextFieldKey,
                    borderType: BorderType.underline,
                    controller: _displayNameController,
                    labelText: context.l10n.yourName,
                    hintText: 'e.g. Jane Doe',
                    onEditingComplete: () => _submitForm(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return context.l10n.enterValidName;
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
              labelText: context.l10n.email,
              onEditingComplete: () => _submitForm(),
              validator: (value) {
                if (value == null || value.isEmpty || !isEmailValid(value)) {
                  return context.l10n.pleaseEnterValidEmail;
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            CustomTextField(
              key: SignInOptionsContent.passwordTextFieldKey,
              borderType: BorderType.underline,
              controller: _passwordController,
              onEditingComplete: () => _submitForm(),
              labelText: context.l10n.password,
              obscureText: !_showPassword,
              suffixIcon: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 4, 0),
                child: Semantics(
                  label: _showPassword
                      ? context.l10n.hidePassword
                      : context.l10n.showPassword,
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
                  return context.l10n.pleaseEnterValidPassword;
                } else if (_showSignup &&
                    (value == null ||
                        value.isEmpty ||
                        !isPasswordValid(value))) {
                  return context.l10n.pleaseEnterPassword;
                }
                return null;
              },
            ),
            SizedBox(height: 5),
            if (_showSignup)
              Text(
                context.l10n.passwordRequirements,
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
                        if (_formKey.currentState!.validate()) {
                          _resetPassword();
                        }
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ActionButton(
                key: SignInOptionsContent.buttonSubmitKey,
                onPressed: () => authMessageOnError(
                  _onSubmit,
                  errorCallback: (error, code) => setState(
                    () => _formError = code,
                  ),
                ),
                sendingIndicatorAlign: ActionButtonSendingIndicatorAlign.none,
                type: ActionButtonType.filled,
                expand: true,
                textColor: Colors.white,
                color: Colors.black,
                text: !_showSignup ? context.l10n.signIn : context.l10n.signUp,
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 9),
      Align(
        alignment: Alignment.center,
        child: Text(
          context.l10n.or, 
          style: context.theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      SizedBox(height: 9),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ActionButton(
          key: SignInOptionsContent.buttonGoogleKey,
          // minWidth: minWidth,
          maxTextWidth: 140,
          expand: true,
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
          text: _showSignup
              ? context.l10n.signUpWithGoogle
              : context.l10n.signInWithGoogle,
        ),
      ),
    ];
  }

  Widget _buildTermsOfService() {
    return Text.rich(
      TextSpan(
        style: context.theme.textTheme.bodyMedium,
        children: [
          TextSpan(
            text: context.l10n.termsAgreementPrefix(Environment.appName),
          ),
          TextSpan(
            text: context.l10n.termsOfService(Environment.appName),
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
