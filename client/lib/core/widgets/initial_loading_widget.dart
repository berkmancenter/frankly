import 'package:beamer/beamer.dart';
import 'package:client/app.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/custom_loading_indicator.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:client/core/routing/locations.dart';
import 'package:client/core/data/services/logging_service.dart';
import 'package:client/services.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:client/styles/styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

class InitialLoadingWidget extends StatefulWidget {
  final Widget child;

  const InitialLoadingWidget({required this.child});

  @override
  _InitialLoadingWidgetState createState() => _InitialLoadingWidgetState();
}

class _InitialLoadingWidgetState extends State<InitialLoadingWidget> {
  bool _initialized = false;
  bool _showedRedirectSignInError = false;
  Object? _initializationError;

  @override
  void initState() {
    super.initState();

    _initialize();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (userService.redirectErrorMessage != null &&
        !_showedRedirectSignInError) {
      _showedRedirectSignInError = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => showAlert(
          context,
          sanitizeError(userService.redirectErrorMessage!),
        ),
      );
    }
  }

  Future<void> _initialize() async {
    try {
      await initializeServices();

      _storeQueryParameters();
    } catch (e, stacktrace) {
      loggingService.log(
        '_InitialLoadingWidgetState._initialize error',
        logType: LogType.error,
        error: e,
        stackTrace: stacktrace,
      );
      setState(() => _initializationError = e);
      rethrow;
    }
    setState(() => _initialized = true);
  }

  void _storeQueryParameters() {
    var parameters = botJoinParameters ??
        Uri.tryParse(html.window.location.href)?.queryParameters;

    if (parameters != null && parameters.isNotEmpty) {
      final pathParameters =
          (routerDelegate.currentBeamLocation.state as BeamState)
              .queryParameters;
      final eventIdParameter =
          pathParameters[CommunityLocation.eventIdParameter];
      final allParameters = {
        ...parameters,
        if (eventIdParameter != null) 'eventId': eventIdParameter,
      };
      queryParametersService.addQueryParameters(allParameters);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (context.watch<UserService>().signInState == SignInState.signedIn &&
        _initialized) {
      return widget.child;
    } else if (context.watch<UserService>().signInState ==
        SignInState.awaitingEmailVerification) {
      return const _VerifyEmailScreen();
    } else if (context.watch<UserService>().signInState ==
        SignInState.signedOut) {
      return Scaffold(
        body: Center(
          child: HeightConstrainedText(
            'You have been signed out. Please refresh to sign back in',
            style: AppTextStyle.subhead,
          ),
        ),
      );
    } else if (_initializationError != null) {
      final showError = (routerDelegate.currentBeamLocation.state as BeamState)
              .queryParameters['debug'] ==
          'true';
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              HeightConstrainedText(
                'There was an unexpected error during initialization.',
                style: AppTextStyle.subhead,
              ),
              if (showError) ...[
                SizedBox(height: 10),
                HeightConstrainedText(
                  _initializationError.toString(),
                  style: AppTextStyle.body,
                ),
              ],
            ],
          ),
        ),
      );
    }

    return const Scaffold(
      body: Center(
        child: CustomLoadingIndicator(),
      ),
    );
  }
}

class _VerifyEmailScreen extends StatefulWidget {
  const _VerifyEmailScreen();

  @override
  State<_VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<_VerifyEmailScreen> {
  late final TextEditingController _emailController = TextEditingController(
    text: userService.firebaseAuth.currentUser?.email ?? '',
  );

  late String _sentToEmail =
      userService.firebaseAuth.currentUser?.email ?? '';

  bool _editingEmail = false;
  bool _saving = false;
  bool _resent = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveEmail() async {
    final newEmail = _emailController.text.trim();
    if (newEmail.isEmpty) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    await authMessageOnError(
      () => userService.updateEmailAndResendVerification(newEmail),
      errorCallback: (msg, _) => setState(() {
        _error = msg;
        _saving = false;
      }),
      callback: () => setState(() {
        _sentToEmail = newEmail;
        _editingEmail = false;
        _resent = true;
        _saving = false;
      }),
    );
  }

  Future<void> _resend() async {
    if (_sentToEmail.isEmpty) return;
    setState(() {
      _saving = true;
      _error = null;
      _resent = false;
    });
    await authMessageOnError(
      () => userService.sendMagicVerificationLink(_sentToEmail),
      errorCallback: (msg, _) => setState(() {
        _error = msg;
        _saving = false;
      }),
      callback: () => setState(() {
        _resent = true;
        _saving = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final linkError = context.watch<UserService>().emailVerificationError;
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeightConstrainedText(
                  'Check your email',
                  style: AppTextStyle.subhead,
                ),
                const SizedBox(height: 12),
                if (linkError != null) ...[
                  HeightConstrainedText(
                    linkError,
                    style: AppTextStyle.body.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (!_editingEmail) ...[
                  HeightConstrainedText(
                    'Check your inbox for the verification link sent to $_sentToEmail.',
                    style: AppTextStyle.body,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => setState(() {
                      _editingEmail = true;
                      _resent = false;
                      _error = null;
                    }),
                    child: const Text('Typo in your email address? Click here to edit it.'),
                  ),
                ] else ...[
                  CustomTextField(
                    controller: _emailController,
                    labelText: 'Email address',
                    borderType: BorderType.underline,
                    keyboardType: TextInputType.emailAddress,
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ActionButton(
                        type: ActionButtonType.filled,
                        text: 'Save & resend',
                        onPressed: _saving ? null : _saveEmail,
                      ),
                      const SizedBox(width: 12),
                      ActionButton(
                        type: ActionButtonType.text,
                        text: 'Cancel',
                        onPressed: _saving
                            ? null
                            : () => setState(() => _editingEmail = false),
                      ),
                    ],
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  HeightConstrainedText(
                    _error!,
                    style: AppTextStyle.body.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                if (_resent && _error == null) ...[
                  const SizedBox(height: 8),
                  HeightConstrainedText(
                    'Verification email sent.',
                    style: AppTextStyle.body,
                  ),
                ],
                if (!_editingEmail) ...[
                  const SizedBox(height: 24),
                  ActionButton(
                    type: ActionButtonType.outline,
                    text: 'Resend verification email',
                    onPressed: _saving ? null : _resend,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
