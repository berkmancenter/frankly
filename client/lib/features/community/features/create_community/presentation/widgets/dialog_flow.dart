import 'package:client/core/data/services/logging_service.dart';
import 'package:client/core/utils/navigation_utils.dart';
import 'package:client/core/widgets/constrained_body.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/styles.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:client/features/community/features/create_community/presentation/widgets/create_community_preview_container.dart';
import 'package:client/features/community/features/create_community/presentation/widgets/create_community_text_fields.dart';
import 'package:client/features/community/features/create_community/presentation/widgets/private_community_checkbox.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/config/environment.dart';
import 'package:client/services.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:client/features/community/features/create_community/presentation/widgets/mixins.dart';
import 'package:client/core/localization/localization_helper.dart';
import 'package:data_models/analytics/analytics_entities.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/community/community.dart';

class DialogFlow extends StatefulWidget with ShowDialogMixin {
  final bool showAppNameOnMobile;

  const DialogFlow({
    this.showAppNameOnMobile = true,
    Key? key,
  }) : super(key: key);

  @override
  _DialogFlowState createState() => _DialogFlowState();
}

class _DialogFlowState extends State<DialogFlow> {
  final FocusNode _aboutFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _taglineFocus = FocusNode();
  Community _community = Community(
    id: firestoreDatabase.generateNewCommunityId(),
    isPublic: true,
    isOnboardingOverviewEnabled: true,
  );

  int _onStep = 1;
  String? _createdCommunityId;
  PreviewContainerField? _focusedField;

  // Development flag to turn on or off sending the data to firestore
  static const bool _createCommunity = true;

  String get _stepText {
    switch (_onStep) {
      case 1:
        return context.l10n.welcomeToApp(Environment.appName);
      case 2:
        return context.l10n.createACommunity;
      default:
        return '';
    }
  }

  bool get _isNextPageAvailable {
    switch (_onStep) {
      case 1:
        return true;
      case 2:
        return _notEmpty(_community.name);
      default:
        return false;
    }
  }

  bool _notEmpty(String? val) => !isNullOrEmpty(val?.trim());

  @override
  void initState() {
    _listenToFocusNodes();
    super.initState();
  }

  void _listenToFocusNodes() {
    _aboutFocus.addListener(() {
      if (_aboutFocus.hasFocus) {
        setState(() => _focusedField = PreviewContainerField.about);
      }
    });
    _nameFocus.addListener(() {
      if (_nameFocus.hasFocus) {
        setState(() => _focusedField = PreviewContainerField.name);
      }
    });
    _taglineFocus.addListener(() {
      if (_taglineFocus.hasFocus) {
        setState(() => _focusedField = PreviewContainerField.tagline);
      }
    });
  }

  /// Returns true if UI should move to next step
  Future<bool> _nextButtonAction() async {
    if (_onStep == 1) {
      analytics.logEvent(
        AnalyticsAgreeToTermsAndConditionsEvent(
          userId: userService.currentUserId!,
        ),
      );
    } else if (_onStep == 2) {
      if (_createCommunity) {
        try {
          _createdCommunityId =
              (await cloudFunctionsCommunityService.createCommunity(
            CreateCommunityRequest(community: _community),
          ))
                  .communityId;
        } catch (e, s) {
          loggingService.log(e, logType: LogType.error);
          loggingService.log(s, logType: LogType.error);

          final sanitizedError = sanitizeError(e.toString());

          _createdCommunityId = null;
        }
        final createdCommunityId = _createdCommunityId;
        if (createdCommunityId != null) {
          analytics.logEvent(
            AnalyticsCreateCommunityEvent(communityId: createdCommunityId),
          );
          setState(
            () => _community = _community.copyWith(id: createdCommunityId),
          );
        } else {
          Navigator.of(context).pop();
          await showAlert(context, context.l10n.somethingWentWrongTryAgain);
          return false;
        }
      }
    }
    return true;
  }

  void _resetScroll() => Scrollable.of(context).position.jumpTo(0);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBody(
      maxWidth: 444,
      child: _buildDialogContent(),
    );
  }

  Widget _buildDialogContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (responsiveLayoutService.isMobile(context) &&
            widget.showAppNameOnMobile) ...[
          SizedBox(height: 30),
          HeightConstrainedText(
            Environment.appName,
            style: AppTextStyle.headline2,
          ),
          SizedBox(height: 10),
        ],
        SizedBox(height: 40),
        HeightConstrainedText('$_onStep ${context.l10n.ofTotal(3)}'),
        SizedBox(height: 10),
        HeightConstrainedText(
          _stepText,
          style: context.theme.textTheme.titleLarge,
        ),
        SizedBox(height: 10),
        _buildStepContent(),
        SizedBox(height: 40),
        if (_onStep == 1) ...[
          _buildNextButton(),
          SizedBox(height: 20),
        ],
      ],
    );
  }

  Widget _buildStepContent() {
    switch (_onStep) {
      case 1:
        return _buildStepOneContent();

      case 2:
        return _buildStepTwoContent();

      case 3:
        return _buildStepThreeContent();

      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildNextButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: ActionButton(
        color: context.theme.colorScheme.primary,
        textColor: context.theme.colorScheme.onPrimary,
        onPressed: _isNextPageAvailable
            ? () async {
                if (await _nextButtonAction()) {
                  _resetScroll();
                  setState(() => _onStep++);
                }
              }
            : null,
        text: _onStep == 1 ? context.l10n.agreeAndContinue : context.l10n.next,
        iconSide: ActionButtonIconSide.right,
        icon: Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: Icon(
            Icons.arrow_forward_ios,
            color: context.theme.colorScheme.onPrimary,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildStepOneContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: context.l10n
                    .bySigningInRegisteringOrUsing(Environment.appName),
                style: AppTextStyle.body.copyWith(
                  color: context.theme.colorScheme.onSurfaceVariant,
                ),
              ),
              TextSpan(
                text: context.l10n.appNameTermsOfService(Environment.appName),
                style: AppTextStyle.body.copyWith(
                  color: context.theme.colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => launch(Environment.termsUrl),
              ),
              TextSpan(
                text: '.',
                style: AppTextStyle.body.copyWith(
                  color: context.theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 40),
      ],
    );
  }

  Widget _buildStepTwoContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 30),
        CreateCommunityTextFields(
          onNameChanged: (value) =>
              setState(() => _community = _community.copyWith(name: value)),
          onCustomDisplayIdChanged: (value) => setState(
            () => _community = _community.copyWith(
              displayIds: value.isNotEmpty ? [value] : [],
            ),
          ),
          nameFocus: _nameFocus,
          community: _community,
        ),
        SizedBox(height: 6),
        PrivateCommunityCheckbox(
          onUpdate: (bool? v) {
            final value = v ?? true;
            return setState(
              () => _community = _community.copyWith(isPublic: !value),
            );
          },
          value: !(_community.isPublic ?? true),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ActionButton(
              text: context.l10n.finish,
              color: context.theme.colorScheme.primary,
              textColor: context.theme.colorScheme.onPrimary,
              borderRadius: BorderRadius.circular(10),
              onPressed: () async {
                if (await _nextButtonAction()) {
                  _resetScroll();
                  setState(() => _onStep++);
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepThreeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(height: 10),
        Image.asset(
          AppAsset.kCongratulations.path,
          width: 80,
          height: 80,
          fit: BoxFit.contain,
        ),
        SizedBox(height: 10),
        HeightConstrainedText(
          context.l10n.congratulations,
          textAlign: TextAlign.center,
          style: context.theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: context.l10n.communitySuccessPrefix,
                style: context.theme.textTheme.bodyLarge,
              ),
              TextSpan(text: '\n'),
              TextSpan(
                text: _community.name,
                style: context.theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: '.',
                style: context.theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Text(
          context.l10n.communitySuccessSuffix,
          textAlign: TextAlign.center,
          style: context.theme.textTheme.bodyLarge,
        ),
      ],
    );
  }
}
