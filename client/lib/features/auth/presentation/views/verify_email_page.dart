import 'dart:async';

import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:client/styles/app_asset.dart';
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
  static const _pollingInterval = Duration(seconds: 5);

  String _error = '';
  String _message = '';
  String _tabCheckError = '';
  bool _editingEmail = false;
  bool _linkExpired = false;
  late String _currentEmail;
  late TextEditingController _emailController;
  Timer? _expiryTimer;
  Timer? _verificationPollingTimer;

  @override
  void initState() {
    super.initState();
    _currentEmail = widget.email;
    _emailController = TextEditingController(text: _currentEmail);
    _startExpiryTimer();
    _startVerificationPolling();
    // Eagerly reload on mount so that a user who already verified (e.g. via
    // Firebase's hosted action page, which processes the code itself before
    // redirecting back without an oobCode) is sent straight to home without
    // waiting for the first polling tick.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      try {
        await context.read<UserService>().refreshEmailVerificationStatus();
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _expiryTimer?.cancel();
    _verificationPollingTimer?.cancel();
    super.dispose();
  }

  // Automatically poll Firebase Auth so that browsers like Brave — which block
  // Firestore's WebChannel — still detect verification without the user having
  // to manually press "Continue". reload() uses identitytoolkit.googleapis.com,
  // which is not blocked by Brave's shields.
  void _startVerificationPolling() {
    _verificationPollingTimer = Timer.periodic(_pollingInterval, (_) async {
      if (!mounted) return;
      final userService = context.read<UserService>();
      try {
        await userService.refreshEmailVerificationStatus();
        if (userService.firebaseAuth.currentUser?.emailVerified == true) {
          _verificationPollingTimer?.cancel();
        }
      } catch (_) {
        // Silently ignore.
      }
    });
  }

  void _startExpiryTimer() {
    _expiryTimer?.cancel();
    _expiryTimer = Timer(_linkExpiryDuration, () {
      if (mounted) setState(() => _linkExpired = true);
    });
  }


  Future<void> _checkVerifiedInOtherTab() async {
    final userService = context.read<UserService>();
    try {
      await userService.refreshEmailVerificationStatus();
    } catch (_) {}
    if (!mounted) return;
    if (userService.firebaseAuth.currentUser?.emailVerified == true) {
      // Verified — InitialLoadingWidget observes UserService and will navigate home.
      return;
    }
    setState(() => _tabCheckError = context.l10n.emailNotYetVerified);
  }

  Future<void> _resendEmail() async {
    final userService = context.read<UserService>();
    final resentMessage = context.l10n.verificationEmailResent(_currentEmail);
    await userService.refreshEmailVerificationStatus();
    if (userService.firebaseAuth.currentUser?.emailVerified == true) {
      // Already verified — InitialLoadingWidget observes UserService and will navigate home.
      return;
    }
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

  // This functionality for a user to correct a typo in their email address was removed in the latest design iteration, but the code is left here for now in case we want to easily re-enable it in the future.
  // Future<void> _updateEmail() async {
  //   final newEmail = _emailController.text.trim();
  //   if (newEmail == _currentEmail) {
  //     setState(() => _editingEmail = false);
  //     return;
  //   }
  //   final userService = context.read<UserService>();
  //   await authMessageOnError(
  //     () => userService.updateEmailAndResendVerification(newEmail),
  //     errorCallback: (error, _) => setState(() {
  //       _error = error;
  //       _message = '';
  //     }),
  //     callback: () => setState(() {
  //       _currentEmail = newEmail;
  //       _editingEmail = false;
  //       _linkExpired = false;
  //       _startExpiryTimer();
  //       _message = context.l10n.emailUpdatedResent(newEmail);
  //       _error = '';
  //     }),
  //   );
  // }

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
                child: Semantics(
                  label: context.l10n.franklyLogo,
                  child: Image.asset(
                    AppAsset.kLogoPng.path,
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 24),
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
                  style: context.theme.textTheme.bodyMedium?.copyWith(
                    color: context.theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                // const SizedBox(height: 4),
                // Align(
                //   alignment: Alignment.center,
                //   child: TextButton(
                //     style: TextButton.styleFrom(
                //       padding: EdgeInsets.zero,
                //       minimumSize: Size.zero,
                //       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                //     ),
                //     onPressed: () => setState(() {
                //       _editingEmail = true;
                //       _emailController.text = _currentEmail;
                //       _error = '';
                //       _message = '';
                //     }),
                //     child: Text(
                //       context.l10n.wrongEmail,
                //       style: context.theme.textTheme.bodySmall?.copyWith(
                //         color: context.theme.colorScheme.primary,
                //       ),
                //     ),
                //   ),
                // ),
              // ] else ...[
              //   TextField(
              //     controller: _emailController,
              //     keyboardType: TextInputType.emailAddress,
              //     autofocus: true,
              //     decoration: const InputDecoration(
              //       labelText: 'Email',
              //       border: OutlineInputBorder(),
              //       isDense: true,
              //     ),
              //     onSubmitted: (_) => _updateEmail(),
              //   ),
              //   const SizedBox(height: 8),
              //   Row(
              //     mainAxisAlignment: MainAxisAlignment.end,
              //     children: [
              //       TextButton(
              //         onPressed: () => setState(() {
              //           _editingEmail = false;
              //           _error = '';
              //         }),
              //         child: Text(context.l10n.cancelEmailEdit),
              //       ),
              //       const SizedBox(width: 8),
              //       FilledButton(
              //         onPressed: _updateEmail,
              //         child: Text(context.l10n.updateEmail),
              //       ),
              //     ],
              //   ),
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
                  onPressed: _resendEmail,
                  type: ActionButtonType.filled,
                  expand: true,
                  textColor: Colors.white,
                  color: Colors.black,
                  text: context.l10n.resendVerificationEmail,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _checkVerifiedInOtherTab,
                child: Text(
                  'I verified my email in another tab or window',
                  style: context.theme.textTheme.bodySmall?.copyWith(
                    decoration: TextDecoration.underline,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (_tabCheckError.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  _tabCheckError,
                  style: context.theme.textTheme.bodySmall?.copyWith(
                    color: context.theme.colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
