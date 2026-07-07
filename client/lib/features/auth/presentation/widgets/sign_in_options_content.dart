import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/config/environment.dart';
import 'package:client/services.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:provider/provider.dart';
import 'package:client/core/localization/localization_helper.dart';
import 'package:url_launcher/url_launcher_string.dart';

FocusNode _emailFocusNode = FocusNode();

WidgetSpan buildActionText(
  BuildContext context,
  String text, {
  VoidCallback? onTap,
  TextStyle? style,
}) {
  return WidgetSpan(
    alignment: PlaceholderAlignment.baseline,
    baseline: TextBaseline.alphabetic,
    child: InkWell(
      onTap: onTap,
      child: Text(
        text,
        softWrap: true,
        style: style ??
            context.theme.textTheme.bodyMedium?.copyWith(
              decoration: TextDecoration.underline,
            ),
      ),
    ),
  );
}

// Create a widget containing information about account error messages received from our backend
class AccountErrorMessage extends StatelessWidget {
  final String errorCode;
  final Function(bool)? onSwitchView;
  final VoidCallback? onForgotPassword;

  const AccountErrorMessage({
    required this.errorCode,
    this.onSwitchView,
    this.onForgotPassword,
  });

  Widget buildForgotPasswordMessage(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: context.l10n.forgotPasswordPrefix,
          ),
          buildActionText(
            context,
            context.l10n.forgotPasswordEnterEmail,
            onTap: () => _emailFocusNode.requestFocus(),
          ),
          TextSpan(
            text: ', ${context.l10n.forgotPasswordThen}',
          ),
          buildActionText(
            context,
            context.l10n.forgotPasswordSuffix,
            onTap: () => onForgotPassword?.call(),
          ),
          TextSpan(text: '.'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    boxedErrorText({required message}) {
      return Focus(
        child: Container(
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.error.withOpacity(0.05),
          ),
          child: message,
        ),
      );
    }

    switch (errorCode) {
      case 'email-already-in-use':
        return boxedErrorText(
          message: Text.rich(
            TextSpan(
              // style: const TextStyle(textBaseline: TextBaseline.alphabetic),
              children: [
                TextSpan(
                  text: context.l10n.emailAddressAlreadyInUseLoginError,
                ),
                buildActionText(
                  context,
                  context.l10n.loggingIn,
                  onTap: () => onSwitchView?.call(false),
                ),
                TextSpan(text: context.l10n.insteadSuffix),
              ],
            ),
          ),
        );
      case 'user-not-found':
        return boxedErrorText(
          message: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: context.l10n.couldntFindAccount,
                ),
                buildActionText(
                  context,
                  context.l10n.signingUp,
                  onTap: () => onSwitchView?.call(true),
                ),
                TextSpan(text: context.l10n.insteadSuffix),
              ],
            ),
          ),
        );
      case 'invalid-credential':
      case 'wrong-password':
        return boxedErrorText(
          message: Column(
            children: [
              Text(
                context.l10n.emailAndPasswordMismatch(Environment.appName),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              Text.rich(
                TextSpan(
                  children: [
                    buildActionText(
                      context,
                      context.l10n.emailAndPasswordMismatchCheck,
                      onTap: () => _emailFocusNode.requestFocus(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${context.l10n.forgotEmail} ',
                    ),
                    buildActionText(
                      context,
                      context.l10n.contactUs,
                      onTap: () {
                        launchUrlString('mailto:${Environment.supportEmail}');
                      },
                    ),
                    TextSpan(text: '.'),
                  ],
                ),
              ),
              SizedBox(height: 15),
              buildForgotPasswordMessage(context),
            ],
          ),
        );
      case 'invalid-email':
        return boxedErrorText(
          message: Text(context.l10n.invalidEmail),
        );
      case 'too-many-requests':
        return boxedErrorText(
          message: Text(context.l10n.tooManyRequests),
        );
      case 'email-missing-pw':
        return boxedErrorText(
          message: Text(context.l10n.pleaseEnterValidEmail),
        );
      default:
        return boxedErrorText(
          message: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${context.l10n.somethingWentWrongLongPrefix}\n\n',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: '${context.l10n.somethingWentWrongLongMiddle} '),
                buildActionText(
                  context,
                  context.l10n.somethingWentWrongLongSuffix,
                  onTap: () {
                    launchUrlString('mailto:${Environment.supportEmail}');
                  },
                ),
                TextSpan(text: '${context.l10n.tryAgainLater}.'),
              ],
            ),
          ),
        );
    }
  }
}

class SignInOptionsContent extends StatefulWidget {
  const SignInOptionsContent({
    this.showSignUp = true,
    this.inModal = false,
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
  final bool inModal;
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
    if (!userService.isCurrentUserEmailVerified) {
      await userService.verifyEmail();
      if (mounted) {
        TextInput.finishAutofillContext(shouldSave: true);
        Navigator.of(context).pop();
      }
      return;
    }
    if (mounted) {
      TextInput.finishAutofillContext(shouldSave: true);
      Navigator.of(context).pop();
    }
    widget.onComplete?.call();
  }

  Future<void> _resetPassword() async {
    await authMessageOnError(
      () => userService.resetPassword(email: _emailController.text),
      errorCallback: (error, msg) => {
        if (msg == 'Email must be entered to reset password.')
          setState(() {
            _formMessage = '';
            _formError = 'email-missing-pw';
            _ignorePassword = false;
          })
        else
          setState(() {
            _formMessage = '';
            _formError = msg;
            _ignorePassword = false;
          }),
      },
      callback: () => {
        setState(() {
          _formError = '';
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
            SizedBox(height: 20),
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
      return context.l10n.logIntoApp(Environment.appName);
    }
  }

  Widget _buildSignUpLogInMessage() {
    return Text.rich(
      key: SignInOptionsContent.showSignUpToggleKey,
      TextSpan(
        style: context.theme.textTheme.bodyMedium,
        children: [
          TextSpan(
            text:
                '${_showSignup ? context.l10n.alreadyUserSignIn : context.l10n.notUserSignUp} ',
          ),
          buildActionText(
            context,
            _showSignup ? context.l10n.login : context.l10n.signUp,
            onTap: () {
              if (_formError.isNotEmpty) {
                _formKey.currentState!.reset();
              }
              setState(() {
                _showSignup = !_showSignup;
                _formError = '';
              });
            },
          ),
          TextSpan(text: '.'),
        ],
      ),
    );
  }

  List<Widget> _buildSignIn() {
    double screenWidth = MediaQuery.of(context).size.width;
    double googleButtonWidth = double.infinity;
    if (widget.inModal && screenWidth <= 375) {
      googleButtonWidth = 80;
    }

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
        child: _buildSignUpLogInMessage(),
      ),
      if (_formError.isNotEmpty)
        AccountErrorMessage(
          errorCode: _formError,
          onSwitchView: (bool value) {
            setState(() {
              _showSignup = value;
              _formError = '';
            });
          },
          onForgotPassword: _resetPassword,
        ),
      if (_formMessage.isNotEmpty)
        Column(
          children: [
            SizedBox(height: 9),
            Text(
              _formMessage,
              style: context.theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
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
            AutofillGroup(
              child: Column(
                children: [
                  CustomTextField(
                    key: SignInOptionsContent.emailTextFieldKey,
                    borderType: BorderType.underline,
                    controller: _emailController,
                    labelText: context.l10n.email,
                    autofillHints: const [
                      AutofillHints.email,
                      AutofillHints.username,
                    ],
                    keyboardType: TextInputType.emailAddress,
                    onEditingComplete: () => _submitForm(),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !isEmailValid(value)) {
                        return context.l10n.pleaseEnterValidEmail;
                      }
                      return null;
                    },
                    focusNode: _emailFocusNode,
                  ),
                  SizedBox(height: 10),
                  CustomTextField(
                    key: SignInOptionsContent.passwordTextFieldKey,
                    borderType: BorderType.underline,
                    controller: _passwordController,
                    onEditingComplete: () => _submitForm(),
                    labelText: context.l10n.password,
                    obscureText: !_showPassword,
                    autofillHints: _showSignup
                        ? const [AutofillHints.newPassword]
                        : const [AutofillHints.password],
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
                                ? Icons.visibility_off
                                : Icons.visibility,
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
                ],
              ),
            ),
            SizedBox(height: 20),
            if (_showSignup)
              Text(
                context.l10n.passwordRequirements,
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
              type: ActionButtonType.filled,
              expand: true,
              textColor: Colors.white,
              color: Colors.black,
              text: !_showSignup ? context.l10n.signIn : context.l10n.signUp,
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
      ActionButton(
        key: SignInOptionsContent.buttonGoogleKey,
        expand: true,
        maxTextWidth: googleButtonWidth,
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
            : context.l10n.logInWithGoogle,
      ),
      SizedBox(height: 20),
      if (!_showSignup)
        Align(
          alignment: Alignment.center,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: context.l10n.forgotAccountEmailOrNeedHelp,
                ),
                TextSpan(
                  text: ' ',
                ),
                buildActionText(
                  context,
                  context.l10n.contactUs,
                  onTap: () {
                    launchUrlString('mailto:${Environment.supportEmail}');
                  },
                ),
                TextSpan(text: '.'),
              ],
            ),
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
          buildActionText(
            context,
            context.l10n.termsOfService(Environment.appName),
            onTap: () => launchUrlString(Environment.termsUrl),
          ),
          TextSpan(text: '.'),
        ],
      ),
    );
  }
}