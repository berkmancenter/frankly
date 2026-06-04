import 'dart:async';

import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/utils/visible_exception.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:client/core/localization/localization_helper.dart';

class VerifyEmailPage extends StatefulWidget {
  final String email;

  const VerifyEmailPage({required this.email, Key? key}) : super(key: key);

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  static const _linkExpiryDuration = Duration(minutes: 30);

  String _error = '';
  String _message = '';
  bool _editingEmail = false;
  bool _linkExpired = false;
  late String _currentEmail;
  late TextEditingController _emailController;
  Timer? _expiryTimer;

  @override
  void initState() {
    super.initState();
    _currentEmail = widget.email;
    _emailController = TextEditingController(text: _currentEmail);
    _startExpiryTimer();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _expiryTimer?.cancel();
    super.dispose();
  }

  void _startExpiryTimer() {
    _expiryTimer?.cancel();
    _expiryTimer = Timer(_linkExpiryDuration, () {
      if (mounted) setState(() => _linkExpired = true);
    });
  }

  Future<void> _checkVerification() async {
    final userService = context.read<UserService>();
    final notVerifiedMessage = context.l10n.emailNotYetVerified;
    await authMessageOnError(
      () async {
        await userService.refreshEmailVerificationStatus();
        final verified =
            userService.firebaseAuth.currentUser?.emailVerified ?? false;
        if (!verified) throw VisibleException(notVerifiedMessage);
        // InitialLoadingWidget observes UserService and will render the app on the next frame
      },
      errorCallback: (error, _) => setState(() {
        _error = error;
        _message = '';
      }),
    );
  }

  Future<void> _resendEmail() async {
    final userService = context.read<UserService>();
    final resentMessage = context.l10n.verificationEmailResent(_currentEmail);
    await authMessageOnError(
      () => userService.verifyEmail(),
      errorCallback: (error, _) => setState(() {
        _error = error;
        _message = '';
      }),
      callback: () => setState(() {
        _linkExpired = false;
        _startExpiryTimer();
        _message = resentMessage;
        _error = '';
      }),
    );
  }

  Future<void> _updateEmail() async {
    final newEmail = _emailController.text.trim();
    if (newEmail == _currentEmail) {
      setState(() => _editingEmail = false);
      return;
    }
    final userService = context.read<UserService>();
    await authMessageOnError(
      () => userService.updateEmailAndResendVerification(newEmail),
      errorCallback: (error, _) => setState(() {
        _error = error;
        _message = '';
      }),
      callback: () => setState(() {
        _currentEmail = newEmail;
        _editingEmail = false;
        _linkExpired = false;
        _startExpiryTimer();
        _message = context.l10n.emailUpdatedResent(newEmail);
        _error = '';
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: ListView(
            padding: const EdgeInsets.all(40) + const EdgeInsets.only(top: 30),
            shrinkWrap: true,
            children: [
              Align(
                alignment: Alignment.center,
                child: HeightConstrainedText(
                  context.l10n.verifyYourEmail,
                  style: context.theme.textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 16),
              if (!_editingEmail) ...[
                Text(
                  context.l10n.verificationEmailSent(_currentEmail),
                  style: context.theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  context.l10n.verificationLinkExpiresIn,
                  style: context.theme.textTheme.bodySmall?.copyWith(
                    color: context.theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => setState(() {
                      _editingEmail = true;
                      _emailController.text = _currentEmail;
                      _error = '';
                      _message = '';
                    }),
                    child: Text(
                      context.l10n.wrongEmail,
                      style: context.theme.textTheme.bodySmall?.copyWith(
                        color: context.theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _updateEmail(),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => setState(() {
                        _editingEmail = false;
                        _error = '';
                      }),
                      child: Text(context.l10n.cancelEmailEdit),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _updateEmail,
                      child: Text(context.l10n.updateEmail),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              if (_linkExpired)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    context.l10n.verificationLinkExpired,
                    style: context.theme.textTheme.bodySmall?.copyWith(
                      color: context.theme.colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _error,
                    style: context.theme.textTheme.bodyMedium
                        ?.copyWith(color: context.theme.colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_message.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _message,
                    style: context.theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ActionButton(
                  onPressed: _checkVerification,
                  type: ActionButtonType.filled,
                  expand: true,
                  textColor: Colors.white,
                  color: Colors.black,
                  text: context.l10n.continueAfterVerification,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ActionButton(
                  onPressed: _resendEmail,
                  type: ActionButtonType.outline,
                  expand: true,
                  text: context.l10n.resendVerificationEmail,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
