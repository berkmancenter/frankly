import 'package:client/core/utils/navigation_utils.dart';
import 'package:client/features/auth/presentation/views/sign_in_dialog.dart';
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
import 'package:client/core/utils/platform_utils.dart';
import 'package:provider/provider.dart';

class SignInOptionsContent extends StatefulWidget {
  const SignInOptionsContent({
    this.isNewUser = true,
    this.isPurchasingSubscription = false,
    this.openDialogOnEmailProviderSelected = false,
    this.showEmailFormOnly = false,
    this.onComplete,
    Key? key,
  }) : super(key: key);

  static const emailSignInKey = Key('email-sign-in');
  static const newUserToggleKey = Key('new-user-toggle');
  static const nameTextFieldKey = Key('input-name');
  static const emailTextFieldKey = Key('input-email');
  static const passwordTextFieldKey = Key('input-password');
  static const signInSubmitKey = Key('sign-in-submit');

  final bool isNewUser;
  final bool isPurchasingSubscription;
  final bool openDialogOnEmailProviderSelected;
  final bool showEmailFormOnly;
  final void Function()? onComplete;

  @override
  State<SignInOptionsContent> createState() => _SignInOptionsContentState();
}

class _SignInOptionsContentState extends State<SignInOptionsContent> {
  late bool _showEmailFormFields = widget.showEmailFormOnly;
  late bool _newUser = widget.isNewUser;
  late bool _showPassword = false;

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
        if (_showEmailFormFields && !widget.showEmailFormOnly)
          Align(
            alignment: Alignment.topLeft,
            child: GestureDetector(
              child: Icon(Icons.arrow_back),
              onTap: () => setState(() => _showEmailFormFields = false),
            ),
          ),
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
      return 'Sign up to get started.';
    } else {
      return '';
    }
  }

  List<Widget> _buildSignIn() {
    const minWidth = 260.0;
    return [
      Align(
        alignment: Alignment.centerLeft,
        child: HeightConstrainedText(
          _getTitleText(),
          style: AppTextStyle.headline4,
        ),
      ),
      SizedBox(height: 9),
      if (_getMessageText().isNotEmpty)
        Align(
          alignment: Alignment.centerLeft,
          child: HeightConstrainedText(
            _getMessageText(),
            style: AppTextStyle.body,
          ),
        ),
         CustomTextField(
        key: SignInOptionsContent.nameTextFieldKey,
        controller: _displayNameController,
        labelText: 'Your Name',
        borderType: BorderType.underline,
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
          padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
          child: IconButton(
            onPressed: () => setState(() => _showPassword = !_showPassword),
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
        key: SignInOptionsContent.emailSignInKey,
        minWidth: minWidth,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        onPressed: () => setState(() => _showEmailFormFields = true),
        text: 'Sign up',
      ),
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
      // if/ (_newUser)
     
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
