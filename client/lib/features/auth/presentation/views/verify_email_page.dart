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
  // If changed, this value should also be updated in l10n messages referencing the expiry duration.
  static const _linkExpiryDuration = Duration(minutes: 30);
  static const _pollingInterval = Duration(seconds: 5);

  String _error = '';
  String _tabCheckError = '';
  String _resendSuccessMessage = '';
  bool _linkExpired = false;
  bool _editingEmail = false;
  bool _emailAlreadyInUse = false;
  bool _pendingEmailChange = false;
  String _emailValidationError = '';
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
      if (_emailAlreadyInUse || _emailValidationError.isNotEmpty) {
        setState(() {
          _emailAlreadyInUse = false;
          _emailValidationError = '';
        });
      }
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
    _verificationPollingTimer?.cancel();
    var pollInFlight = false;
    _verificationPollingTimer = Timer.periodic(_pollingInterval, (_) async {
      if (!mounted || pollInFlight) return;
      pollInFlight = true;
      final userService = context.read<UserService>();
      try {
        await userService.refreshEmailVerificationStatus();
        if (userService.isCurrentUserEmailVerified) {
          _verificationPollingTimer?.cancel();
        }
      } catch (_) {
        // Silently ignore.
      } finally {
        pollInFlight = false;
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
    if (userService.isCurrentUserEmailVerified) {
      // Verified — InitialLoadingWidget observes UserService and will navigate home.
      return;
    }
    setState(() {
      _tabCheckError = context.l10n.emailNotYetVerified;
      _resendSuccessMessage = '';
    });
  }

  Future<void> _resendEmail() async {
    final userService = context.read<UserService>();
    final resentMessage = context.l10n.verificationEmailResent(_currentEmail);
    try {
      await userService.refreshEmailVerificationStatus();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = context.l10n.somethingWentWrongTryAgain;
        _resendSuccessMessage = '';
      });
      return;
    }
    if (userService.isCurrentUserEmailVerified) {
      // Already verified — InitialLoadingWidget observes UserService and will navigate home.
      return;
    }
    await authMessageOnError(
      () => _pendingEmailChange
          ? userService.updateEmailAndResendVerification(_currentEmail)
          : userService.verifyEmail(),
      errorCallback: (error, code) => setState(() {
        if (_pendingEmailChange && code == 'email-already-in-use') {
          _emailAlreadyInUse = true;
          _editingEmail = true;
        } else {
          _error = error;
        }
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

  bool _isEmailValid(String email) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  }

  Future<void> _updateEmail() async {
    final newEmail = _emailController.text.trim();
    if (newEmail.isEmpty || !_isEmailValid(newEmail)) {
      setState(() => _emailValidationError = context.l10n.pleaseEnterValidEmail);
      return;
    }
    if (newEmail == _currentEmail) {
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
        _pendingEmailChange = true;
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
    final boldStyle = GoogleFonts.inter(textStyle: bodyStyle, fontWeight: FontWeight.bold);
    final linkStyle = bodyStyle?.copyWith(decoration: TextDecoration.underline);
    final contactUsFull = context.l10n.contactUsDot;
    final contactUsLinkText = contactUsFull.replaceFirst(RegExp(r'\.\s*$'), '');
    final contactUsStart = contactUsFull.indexOf(contactUsLinkText);
    final contactUsSpans = <InlineSpan>[];

    if (contactUsStart > 0) {
      contactUsSpans.add(TextSpan(text: contactUsFull.substring(0, contactUsStart)));
    }

    contactUsSpans.add(
      TextSpan(
        text: contactUsLinkText,
        style: linkStyle,
        recognizer: TapGestureRecognizer()
          ..onTap = () => launchUrlString('mailto:${Environment.supportEmail}'),
      ),
    );

    if (contactUsStart + contactUsLinkText.length < contactUsFull.length) {
      contactUsSpans.add(
        TextSpan(text: contactUsFull.substring(contactUsStart + contactUsLinkText.length)),
      );
    }

    return Container(
      width: 348,
      padding: const EdgeInsets.all(16),
      color: context.theme.colorScheme.errorContainer,
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
            ...contactUsSpans,
          ],
        ),
      ),
    );
  }

  Widget _buildLinkExpiredContainer() {
    final bodyStyle = context.theme.textTheme.bodyMedium;
    final boldStyle = GoogleFonts.inter(textStyle: bodyStyle, fontWeight: FontWeight.bold);
    final linkStyle = bodyStyle?.copyWith(decoration: TextDecoration.underline);

    final full = context.l10n.resendEmailAndTryAgain;
    final linkText = full.replaceFirst(RegExp(r'\.\s*$'), '');
    final linkStart = full.indexOf(linkText);
    final linkSpans = <InlineSpan>[];

    if (linkStart > 0) {
      linkSpans.add(TextSpan(text: full.substring(0, linkStart)));
    }

    linkSpans.add(
      TextSpan(
        text: linkText,
        style: linkStyle,
        recognizer: TapGestureRecognizer()..onTap = _resendEmail,
      ),
    );

    if (linkStart + linkText.length < full.length) {
      linkSpans.add(TextSpan(text: full.substring(linkStart + linkText.length)));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 40),
      color: context.theme.colorScheme.errorContainer,
      child: Text.rich(
        TextSpan(
          style: bodyStyle,
          children: [
            TextSpan(text: context.l10n.verificationLinkExpiredTitle, style: boldStyle),
            const TextSpan(text: '\n\n'),
              ...linkSpans,
          ],
        ),
      ),
    );
  }

  Widget _buildAuthErrorContainer() {
    final bodyStyle = context.theme.textTheme.bodyMedium;
    final boldStyle = GoogleFonts.inter(textStyle: bodyStyle, fontWeight: FontWeight.bold);
    final linkStyle = bodyStyle?.copyWith(decoration: TextDecoration.underline);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 40),
      color: context.theme.colorScheme.errorContainer,
      child: Text.rich(
        TextSpan(
          style: bodyStyle,
          children: [
            TextSpan(text: context.l10n.emailCannotBeVerifiedTitle, style: boldStyle),
            const TextSpan(text: '\n\n'),
            TextSpan(text: context.l10n.emailCannotBeVerifiedBodyBeforeLink),
            TextSpan(
              text: context.l10n.contactUs,
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () => launchUrlString('mailto:${Environment.supportEmail}'),
            ),
            TextSpan(text: context.l10n.emailCannotBeVerifiedBodyAfterLink),
          ],
        ),
      ),
    );
  }

  Widget _buildEditEmailView() {

    return ListView(
      padding: const EdgeInsets.all(40),
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
        const SizedBox(height: 32),
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
          child: Text(
            context.l10n.editYourEmailAddressLink,
            style: context.theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        if (_emailAlreadyInUse) ...[
          Center(child: _buildEmailAlreadyInUseError()),
          const SizedBox(height: 24),
        ] else if (_error.isNotEmpty) ...[
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Focus(
                child: _buildAuthErrorContainer(),
              ),
            ),
          ),
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
              color: (_emailAlreadyInUse || _emailValidationError.isNotEmpty)
                  ? context.theme.colorScheme.error
                  : context.theme.colorScheme.onSurfaceVariant,
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(
                color: (_emailAlreadyInUse || _emailValidationError.isNotEmpty)
                    ? context.theme.colorScheme.error
                    : context.theme.colorScheme.outline,
              ),
            ),
            errorText: _emailAlreadyInUse
                ? context.l10n.emailCannotBeUsedFieldError
                : _emailValidationError.isNotEmpty
                    ? _emailValidationError
                    : null,
            errorStyle: context.theme.textTheme.bodySmall?.copyWith(
              color: context.theme.colorScheme.error,
            ),
          ),
        ),
        const SizedBox(height: 36),
        Row(
          children: [
            Expanded(
              child: ActionButton(
                onPressed: () => setState(() {
                  _editingEmail = false;
                  _emailAlreadyInUse = false;
                  _emailValidationError = '';
                  _error = '';
                }),
                type: ActionButtonType.outline,
                color: context.theme.colorScheme.outline,
                textColor: context.theme.colorScheme.onSurface,
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
                color: context.theme.colorScheme.onSurface,
                textColor: context.theme.colorScheme.onPrimary,
                height: 40,
                expand: true,
                borderRadius: BorderRadius.circular(8),
                text: context.l10n.sendVerification,
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
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: _buildEditEmailView(),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.all(40),
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
              const SizedBox(height: 24),
              if (_linkExpired) ...[
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Focus(
                      child: _buildLinkExpiredContainer(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
                if (!_linkExpired && (_tabCheckError.isNotEmpty || _resendSuccessMessage.isNotEmpty)) ...[
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Focus(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        color: _resendSuccessMessage.isNotEmpty
                            ? context.theme.colorScheme.success.colorContainer
                            : context.theme.colorScheme.errorContainer,
                        child: _resendSuccessMessage.isNotEmpty
                            ? Builder(builder: (_) {
                                final parts = _resendSuccessMessage.split('\n\n');
                                return Text.rich(
                                  TextSpan(
                                    style: context.theme.textTheme.bodyMedium,
                                    children: [
                                      TextSpan(
                                        text: parts.first,
                                        style: GoogleFonts.inter(
                                          textStyle: context.theme.textTheme.bodyMedium,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (parts.length > 1) ...[
                                        const TextSpan(text: '\n\n'),
                                        TextSpan(text: parts.sublist(1).join('\n\n')),
                                      ],
                                    ],
                                  ),
                                  textAlign: TextAlign.left,
                                );
                              },)
                            : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        context.l10n.emailNotYetVerifiedHeader,
                                        style: GoogleFonts.inter(
                                          textStyle: context.theme.textTheme.bodyMedium,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Builder(
                                        builder: (_) {
                                          final resendFull = context.l10n.resendVerificationEmailLink;
                                          final linkText = resendFull.replaceFirst(
                                            RegExp(r'\.\s*$'),
                                            '',
                                          );
                                          final linkStart = resendFull.indexOf(linkText);
                                          final resendSpans = <InlineSpan>[];

                                          if (linkStart > 0) {
                                            resendSpans.add(
                                              TextSpan(text: resendFull.substring(0, linkStart)),
                                            );
                                          }

                                          resendSpans.add(
                                            TextSpan(
                                              text: linkText,
                                              style: const TextStyle(
                                                decoration: TextDecoration.underline,
                                              ),
                                              recognizer: TapGestureRecognizer()..onTap = _resendEmail,
                                            ),
                                          );

                                          if (linkStart + linkText.length < resendFull.length) {
                                            resendSpans.add(
                                              TextSpan(
                                                text: resendFull.substring(linkStart + linkText.length),
                                              ),
                                            );
                                          }

                                          return Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(text: _tabCheckError),
                                                ...resendSpans,
                                              ],
                                            ),
                                            style: context.theme.textTheme.bodyMedium,
                                            textAlign: TextAlign.justify,
                                          );
                                        },
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
                    type: ActionButtonType.outline,
                    expand: true,
                    textColor: Colors.black,
                    text: context.l10n.resendVerificationEmail,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _checkVerifiedInOtherTab,
                child: Text(
                  context.l10n.emailVerifiedInAnotherTab,
                  style: GoogleFonts.inter(
                    textStyle: context.theme.textTheme.bodyMedium,
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
