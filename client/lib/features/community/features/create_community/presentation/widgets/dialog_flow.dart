import 'package:client/core/utils/image_utils.dart';
import 'package:client/core/utils/navigation_utils.dart';
import 'package:client/core/utils/toast_utils.dart';
import 'package:client/core/utils/validation_utils.dart';
import 'package:client/core/widgets/constrained_body.dart';
import 'package:client/styles/styles.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:client/features/community/features/create_community/presentation/widgets/choose_color_section.dart';
import 'package:client/features/community/features/create_community/presentation/widgets/create_community_image_fields.dart';
import 'package:client/features/community/features/create_community/presentation/widgets/create_community_preview_container.dart';
import 'package:client/features/community/features/create_community/presentation/widgets/create_community_tags.dart';
import 'package:client/features/community/features/create_community/presentation/widgets/create_community_text_fields.dart';
import 'package:client/features/community/features/create_community/presentation/widgets/private_community_checkbox.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/core/widgets/upgrade_icon.dart';
import 'package:client/config/environment.dart';
import 'package:client/app.dart';
import 'package:client/core/routing/locations.dart';
import 'package:client/services.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:client/features/community/features/create_community/presentation/widgets/mixins.dart';
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
        return 'Welcome to ${Environment.appName}!';
      case 2:
        return 'Create a community';
      case 3:
        return 'Brand your space';
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
      final contactEmail = _community.contactEmail;
      if (contactEmail != null &&
          contactEmail.isNotEmpty &&
          !isEmailValid(contactEmail)) {
        showRegularToast(
          context,
          'Please enter a valid email',
          toastType: ToastType.failed,
        );
        return false;
      }

      // If logo is not provided, generate random image
      if (isNullOrEmpty(_community.profileImageUrl)) {
        _community =
            _community.copyWith(profileImageUrl: generateRandomImageUrl());
      }

      if (_createCommunity) {
        _createdCommunityId = (await cloudFunctionsCommunityService
                .createCommunity(CreateCommunityRequest(community: _community)))
            .communityId;
        final createdCommunityId = _createdCommunityId;
        if (createdCommunityId != null) {
          analytics.logEvent(
            AnalyticsCreateCommunityEvent(communityId: createdCommunityId),
          );
          var hasUpdatedImage = !isNullOrEmpty(_community.profileImageUrl) ||
              !isNullOrEmpty(_community.bannerImageUrl);
          if (hasUpdatedImage) {
            analytics.logEvent(
              AnalyticsUpdateCommunityImageEvent(
                communityId: createdCommunityId,
              ),
            );
          }
          setState(
            () => _community = _community.copyWith(id: createdCommunityId),
          );
        } else {
          Navigator.of(context).pop();
          await showAlert(context, 'Something went wrong, please try again!');
          return false;
        }
      }
    }
    return true;
  }

  void _resetScroll() => Scrollable.of(context).position.jumpTo(0);

  Future<void> _updateBannerImage({
    required String imageUrl,
  }) async {
    if (isNullOrEmpty(imageUrl) || imageUrl == _community.bannerImageUrl) {
      return;
    }

    setState(() {
      _community = _community.copyWith(bannerImageUrl: imageUrl);
    });
  }

  Future<void> _updateProfileImage({
    required String imageUrl,
  }) async {
    if (isNullOrEmpty(imageUrl) || imageUrl == _community.profileImageUrl) {
      return;
    }

    setState(() {
      _community = _community.copyWith(profileImageUrl: imageUrl);
    });
  }

  Future<void> _updateContactEmail(String contactEmail) async {
    if (isNullOrEmpty(contactEmail) ||
        contactEmail == _community.contactEmail) {
      return;
    }

    setState(() {
      _community = _community.copyWith(contactEmail: contactEmail);
    });
  }

  Future<void> _removeImage({
    required bool isBannerImage,
  }) async {
    setState(() {
      _community = isBannerImage
          ? _community.copyWith(bannerImageUrl: null)
          : _community.copyWith(profileImageUrl: null);
    });
  }

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
        if (_onStep != 4) HeightConstrainedText('$_onStep of 3'),
        SizedBox(height: 10),
        HeightConstrainedText(
          _stepText,
          style: context.theme.textTheme.titleLarge,
        ),
        SizedBox(height: 10),
        _buildStepContent(),
        SizedBox(height: 40),
        if (_onStep != 2) ...[
          _buildNextButton(),
          SizedBox(height: 20),
        ],
      ],
    );
  }

  Widget _buildStepContent() {
    switch (_onStep) {
      case 1:
        // return _buildStepTwoContent();
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
        text: _onStep == 1 ? 'Agree and continue' : 'Next',
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
                text:
                    'By signing in, registering, or using ${Environment.appName}, I agree to be bound by the ',
                style: AppTextStyle.body.copyWith(
                  color: context.theme.colorScheme.onPrimaryContainer,
                ),
              ),
              TextSpan(
                text: '${Environment.appName} Terms of Service',
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
                  color: context.theme.colorScheme.onPrimaryContainer,
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
            () => _community = _community.copyWith(displayIds: [value]),
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
              text: 'Finish',
              color: context.theme.colorScheme.primary,
              textColor: context.theme.colorScheme.onPrimary,
              borderRadius: BorderRadius.circular(10),
              // padding: const EdgeInsets.all(20),
              onPressed: _isNextPageAvailable
                  ? () async {
                      if (_createCommunity) {
                        await cloudFunctionsCommunityService.updateCommunity(
                          UpdateCommunityRequest(
                            community: _community,
                            keys: [
                              Community.kFieldThemeDarkColor,
                              Community.kFieldThemeLightColor,
                            ],
                          ),
                        );
                        analytics.logEvent(
                          AnalyticsUpdateCommunityMetadataEvent(
                            communityId: _community.id,
                          ),
                        );
                      }

                      // Immediately proceed to created community
                      Navigator.of(context).pop();
                      routerDelegate.beamTo(
                        CommunityPageRoutes(
                          communityDisplayId: _community.displayId,
                        ).communityHome,
                      );
                    }
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepThreeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 30),
        ChooseColorSection(
          showTabs: false,
          setDarkColor: (val) =>
              _community = _community.copyWith(themeDarkColor: val),
          setLightColor: (val) =>
              _community = _community.copyWith(themeLightColor: val),
          community: _community,
        ),
        SizedBox(height: 22),
        if (_createdCommunityId != null) ...[
          CreateCommunityTags(_createdCommunityId!),
          SizedBox(height: 40),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ActionButton(
              text: 'Finish',
              color: context.theme.colorScheme.primary,
              textColor: context.theme.colorScheme.onPrimary,
              borderRadius: BorderRadius.circular(10),
              padding: const EdgeInsets.all(20),
              onPressed: () async {
                if (_createCommunity) {
                  await cloudFunctionsCommunityService.updateCommunity(
                    UpdateCommunityRequest(
                      community: _community,
                      keys: [
                        Community.kFieldThemeDarkColor,
                        Community.kFieldThemeLightColor,
                      ],
                    ),
                  );
                  analytics.logEvent(
                    AnalyticsUpdateCommunityMetadataEvent(
                      communityId: _community.id,
                    ),
                  );
                }

                // Immediately proceed to created community
                Navigator.of(context).pop();
                routerDelegate.beamTo(
                  CommunityPageRoutes(
                    communityDisplayId: _community.displayId,
                  ).communityHome,
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
