import 'dart:async';

import 'package:client/config/environment.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/styles.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
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
  String _tabCheckError = '';
  String _resendSuccessMessage = '';
  bool _linkExpired = false;
  bool _editingEmail = false;
  bool _emailAlreadyInUse = false;
  late String _currentEmail;
  late TextEditingController _emailController;
  Timer? _expiryTimer;
  Timer? _verificationPollingTimer;

  @override
  void initState() {
    super.initState();
    _currentEmail = widget.email;
    _emailController = TextEditingController(text: _currentEmail);
    _emailController.addListener(() {
      if (_emailAlreadyInUse) setState(() => _emailAlreadyInUse = false);
    });
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
        _resendSuccessMessage = '';
      }),
      callback: () => setState(() {
        _linkExpired = false;
        _startExpiryTimer();
        _resendSuccessMessage = resentMessage;
        _tabCheckError = '';
        _error = '';
      }),
    );
  }

  Future<void> _updateEmail() async {
    final newEmail = _emailController.text.trim();
    if (newEmail.isEmpty || newEmail == _currentEmail) {
      setState(() {
        _editingEmail = false;
        _error = '';
      });
      return;
    }
    final userService = context.read<UserService>();
    await authMessageOnError(
      () => userService.updateEmailAndResendVerification(newEmail),
      errorCallback: (error, code) => setState(() {
        _emailAlreadyInUse = code == 'email-already-in-use';
        _error = _emailAlreadyInUse ? '' : error;
      }),
      callback: () => setState(() {
        _currentEmail = newEmail;
        _editingEmail = false;
        _linkExpired = false;
        _emailAlreadyInUse = false;
        _startExpiryTimer();
        _resendSuccessMessage = context.l10n.emailUpdatedResent(newEmail);
        _tabCheckError = '';
        _error = '';
      }),
    );
  }

  Widget _buildEmailSentText() {
    final style = context.theme.textTheme.bodyMedium;

    final sentTo = context.l10n.verificationEmailSentTo(_currentEmail);

    final wrongEmailFull = context.l10n.wrongEmailEditAddress;
    final linkText = context.l10n.editYourAddressLink;
    final linkStart = wrongEmailFull.indexOf(linkText);
    final wrongEmailSpans = <InlineSpan>[];
    if (linkStart >= 0) {
      if (linkStart > 0) {
        wrongEmailSpans.add(TextSpan(text: wrongEmailFull.substring(0, linkStart)));
      }
      wrongEmailSpans.add(
        TextSpan(
          text: linkText,
          style: const TextStyle(decoration: TextDecoration.underline),
          recognizer: TapGestureRecognizer()
            ..onTap = () => setState(() {
                  _editingEmail = true;
                  _emailController.text = '';
                  _error = '';
                }),
        ),
      );
      if (linkStart + linkText.length < wrongEmailFull.length) {
        wrongEmailSpans.add(TextSpan(text: wrongEmailFull.substring(linkStart + linkText.length)));
      }
    } else {
      wrongEmailSpans.add(TextSpan(text: wrongEmailFull));
    }

    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: sentTo),
          const TextSpan(text: '\n'),
          ...wrongEmailSpans,
          const TextSpan(text: '\n\n'),
          TextSpan(text: context.l10n.verificationAccountInstructions),
          const TextSpan(text: '\n'),
          TextSpan(text: context.l10n.verificationLinkExpiresIn),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildEmailAlreadyInUseError() {
    final bodyStyle = context.theme.textTheme.bodyMedium;
    final boldStyle = bodyStyle?.copyWith(fontWeight: FontWeight.bold);
    final linkStyle = bodyStyle?.copyWith(decoration: TextDecoration.underline);

    return Container(
      width: 348,
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFFFEDEA),
      child: Text.rich(
        TextSpan(
          style: bodyStyle,
          children: [
            TextSpan(
              text: context.l10n.emailCannotBeUsedTitle,
              style: boldStyle,
            ),
            const TextSpan(text: '\n\n'),
            TextSpan(text: context.l10n.emailCannotBeUsedBody),
            const TextSpan(text: '\n\n'),
            TextSpan(
              text: context.l10n.logInInsteadLink,
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  final userService = context.read<UserService>();
                  await userService.signOut();
                },
            ),
            TextSpan(text: context.l10n.orCheckAndTryAgain),
            TextSpan(
              text: context.l10n.tryAgainLink,
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () => setState(() => _emailAlreadyInUse = false),
            ),
            const TextSpan(text: '.\n\n'),
            TextSpan(text: context.l10n.needHelp),
            TextSpan(
              text: context.l10n.contactUsDot,
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () => launchUrlString('mailto:${Environment.supportEmail}'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditEmailView() {
    final titleStyle = context.theme.textTheme.titleLarge;

    return ListView(
      padding: const EdgeInsets.all(40) + const EdgeInsets.only(top: 30),
      shrinkWrap: true,
      children: [
        Align(
          alignment: Alignment.center,
          child: Semantics(
            label: context.l10n.franklyLogo,
            child: Image.asset(
              AppAsset.kLogoPng.path,
              height: 90,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 60),
        SizedBox(
          width: double.infinity,
          child: Text(
            context.l10n.editYourEmailAddressLink,
            style: titleStyle,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        if (_emailAlreadyInUse) ...[
          Center(child: _buildEmailAlreadyInUseError()),
          const SizedBox(height: 24),
        ],
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autofocus: true,
          onSubmitted: (_) => _updateEmail(),
          decoration: InputDecoration(
            labelText: context.l10n.email,
            labelStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
              color: _emailAlreadyInUse
                  ? context.theme.colorScheme.error
                  : const Color(0xFF47464A),
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(
                color: _emailAlreadyInUse
                    ? context.theme.colorScheme.error
                    : const Color(0xFF78767B),
              ),
            ),
            errorText: _emailAlreadyInUse
                ? context.l10n.emailCannotBeUsedFieldError
                : null,
            errorStyle: context.theme.textTheme.bodySmall?.copyWith(
              color: context.theme.colorScheme.error,
            ),
          ),
        ),
        if (_error.isNotEmpty) ...[
          const SizedBox(height: 8),
          Center(
            child: Text(
              _error,
              style: context.theme.textTheme.bodyMedium
                  ?.copyWith(color: context.theme.colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ),
        ],
        const SizedBox(height: 36),
        Row(
          children: [
            Expanded(
              child: ActionButton(
                onPressed: () => setState(() {
                  _editingEmail = false;
                  _emailAlreadyInUse = false;
                  _error = '';
                }),
                type: ActionButtonType.outline,
                color: const Color(0xFF78767B),
                textColor: const Color(0xFF201F1F),
                height: 40,
                expand: true,
                borderRadius: BorderRadius.circular(8),
                text: context.l10n.cancelEmailEdit,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: ActionButton(
                onPressed: _updateEmail,
                type: ActionButtonType.filled,
                color: const Color(0xFF201F1F),
                textColor: Colors.white,
                height: 40,
                expand: true,
                borderRadius: BorderRadius.circular(8),
                text: context.l10n.saveEmail,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_editingEmail) {
      return Scaffold(
        backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: _buildEditEmailView(),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
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
                    height: 90,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: double.infinity,
                child: HeightConstrainedText(
                  context.l10n.verifyYourEmail,
                  textAlign: TextAlign.center,
                  style: context.theme.textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 36),
              if (_tabCheckError.isNotEmpty || _resendSuccessMessage.isNotEmpty) ...[
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Focus(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        color: _resendSuccessMessage.isNotEmpty
                            ? const Color(0xFFCCFFBE)
                            : const Color(0xFFFFEDEA),
                        child: _resendSuccessMessage.isNotEmpty
                            ? Text(
                                _resendSuccessMessage,
                                style: context.theme.textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              )
                            : _linkExpired
                                ? Text.rich(
                                    TextSpan(
                                      style: context.theme.textTheme.bodyMedium,
                                      children: [
                                        TextSpan(
                                          text: context.l10n.verificationLinkExpiredTitle,
                                          style: context.theme.textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const TextSpan(text: '\n\n'),
                                        TextSpan(
                                          text: context.l10n.resendEmailAndTryAgain,
                                          style: const TextStyle(
                                            decoration: TextDecoration.underline,
                                          ),
                                          recognizer: TapGestureRecognizer()..onTap = _resendEmail,
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        context.l10n.emailNotYetVerifiedHeader,
                                        style: context.theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(text: _tabCheckError),
                                            TextSpan(
                                              text: context.l10n.resendVerificationEmailLink,
                                              style: const TextStyle(
                                                decoration: TextDecoration.underline,
                                              ),
                                              recognizer: TapGestureRecognizer()..onTap = _resendEmail,
                                            ),
                                          ],
                                        ),
                                        style: context.theme.textTheme.bodyMedium,
                                        textAlign: TextAlign.justify,
                                      ),
                                    ],
                                  ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              _buildEmailSentText(),
              const SizedBox(height: 24),
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
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: ActionButton(
                    onPressed: _resendEmail,
                    type: ActionButtonType.filled,
                    expand: true,
                    textColor: Colors.white,
                    color: Colors.black,
                    text: context.l10n.resendVerificationEmail,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _checkVerifiedInOtherTab,
                child: Text(
                  context.l10n.emailVerifiedInAnotherTab,
                  style: context.theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationStyle: TextDecorationStyle.solid,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
