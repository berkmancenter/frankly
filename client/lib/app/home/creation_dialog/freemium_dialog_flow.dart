import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:junto/app/home/creation_dialog/components/choose_color_section.dart';
import 'package:junto/app/home/creation_dialog/components/create_junto_image_fields.dart';
import 'package:junto/app/home/creation_dialog/components/create_junto_preview_container.dart';
import 'package:junto/app/home/creation_dialog/components/create_junto_tags.dart';
import 'package:junto/app/home/creation_dialog/components/create_junto_text_fields.dart';
import 'package:junto/app/home/creation_dialog/components/private_junto_checkbox.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/junto_text_field.dart';
import 'package:junto/common_widgets/upgrade_icon.dart';
import 'package:junto/junto_app.dart';
import 'package:junto/routing/locations.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto/utils/mixins.dart';
import 'package:junto_models/analytics/analytics_entities.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/junto.dart';

class FreemiumDialogFlow extends StatefulWidget with ShowDialogMixin {
  final bool showAppNameOnMobile;

  const FreemiumDialogFlow({
    this.showAppNameOnMobile = true,
    Key? key,
  }) : super(key: key);

  @override
  _FreemiumDialogFlowState createState() => _FreemiumDialogFlowState();
}

class _FreemiumDialogFlowState extends State<FreemiumDialogFlow> {
  final FocusNode _aboutFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _taglineFocus = FocusNode();
  Junto _junto = Junto(
    id: firestoreDatabase.generateNewJuntoId(),
    isPublic: true,
    isOnboardingOverviewEnabled: true,
  );

  int _onStep = 1;
  String? _createdJuntoId;
  PreviewContainerField? _focusedField;

  // Development flag to turn on or off sending the data to firestore
  static const bool _createJunto = true;

  String get _stepText {
    switch (_onStep) {
      case 1:
        return 'Welcome to Frankly!';
      case 2:
        return 'Create your space';
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
        return _notEmpty(_junto.name) && _notEmpty(_junto.tagLine);
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
      analytics.logEvent(AnalyticsAgreeToTermsAndConditionsEvent());
    } else if (_onStep == 2) {
      final contactEmail = _junto.contactEmail;
      if (contactEmail != null && contactEmail.isNotEmpty && !isEmailValid(contactEmail)) {
        showRegularToast(context, 'Please enter a valid email', toastType: ToastType.failed);
        return false;
      }

      // If logo is not provided, generate random image
      if (isNullOrEmpty(_junto.profileImageUrl)) {
        _junto = _junto.copyWith(profileImageUrl: generateRandomImageUrl());
      }

      if (_createJunto) {
        _createdJuntoId =
            (await cloudFunctionsService.createJunto(CreateJuntoRequest(junto: _junto))).juntoId;
        final createdJuntoId = _createdJuntoId;
        if (createdJuntoId != null) {
          analytics.logEvent(AnalyticsCreateJuntoEvent(juntoId: createdJuntoId));
          var hasUpdatedImage =
              !isNullOrEmpty(_junto.profileImageUrl) || !isNullOrEmpty(_junto.bannerImageUrl);
          if (hasUpdatedImage) {
            analytics.logEvent(AnalyticsUpdateJuntoImageEvent(juntoId: createdJuntoId));
          }
          setState(() => _junto = _junto.copyWith(id: createdJuntoId));
        } else {
          Navigator.of(context).pop();
          await showAlert(context, 'Something went wrong, please try again!');
          return false;
        }
      }
    }
    return true;
  }

  void _resetScroll() => Scrollable.of(context)?.position.jumpTo(0);

  Future<void> _updateBannerImage({
    required String imageUrl,
  }) async {
    if (isNullOrEmpty(imageUrl) || imageUrl == _junto.bannerImageUrl) return;

    setState(() {
      _junto = _junto.copyWith(bannerImageUrl: imageUrl);
    });
  }

  Future<void> _updateProfileImage({
    required String imageUrl,
  }) async {
    if (isNullOrEmpty(imageUrl) || imageUrl == _junto.profileImageUrl) return;

    setState(() {
      _junto = _junto.copyWith(profileImageUrl: imageUrl);
    });
  }

  Future<void> _updateContactEmail(String contactEmail) async {
    if (isNullOrEmpty(contactEmail) || contactEmail == _junto.contactEmail) return;

    setState(() {
      _junto = _junto.copyWith(contactEmail: contactEmail);
    });
  }

  Future<void> _removeImage({
    required bool isBannerImage,
  }) async {
    setState(() {
      _junto = isBannerImage
          ? _junto.copyWith(bannerImageUrl: null)
          : _junto.copyWith(profileImageUrl: null);
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
        if (responsiveLayoutService.isMobile(context) && widget.showAppNameOnMobile) ...[
          SizedBox(height: 30),
          JuntoText('Frankly', style: AppTextStyle.headline2),
          SizedBox(height: 10),
        ],
        SizedBox(height: 40),
        if (_onStep != 4) JuntoText('$_onStep of 3'),
        SizedBox(height: 10),
        JuntoText(_stepText, style: AppTextStyle.headline2),
        SizedBox(height: 10),
        _buildStepContent(),
        SizedBox(height: 40),
        if (_onStep != 3) ...[
          _buildNextButton(),
          SizedBox(height: 20),
        ]
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
        color: AppColor.darkBlue,
        textColor: AppColor.brightGreen,
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
            color: AppColor.brightGreen,
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
                text: 'By signing in, registering, or using Frankly, I agree to be bound by the ',
                style: AppTextStyle.body.copyWith(color: AppColor.gray2),
              ),
              TextSpan(
                text: 'Frankly Terms of Service',
                style: AppTextStyle.body.copyWith(
                  color: AppColor.accentBlue,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => launch('https://frankly.org/terms'),
              ),
              TextSpan(
                text: '.',
                style: AppTextStyle.body.copyWith(
                  color: AppColor.gray2,
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
        PreviewContainer(
          _junto,
          fieldToEmphasize: _focusedField,
        ),
        SizedBox(height: 30),
        CreateJuntoTextFields(
          onNameChanged: (value) => setState(() => _junto = _junto.copyWith(name: value)),
          onTaglineChanged: (value) => setState(() => _junto = _junto.copyWith(tagLine: value)),
          onAboutChanged: (value) => setState(() => _junto = _junto.copyWith(description: value)),
          aboutFocus: _aboutFocus,
          nameFocus: _nameFocus,
          taglineFocus: _taglineFocus,
          junto: _junto,
        ),
        CreateJuntoImageFields(
          bannerImageUrl: _junto.bannerImageUrl,
          profileImageUrl: _junto.profileImageUrl,
          updateBannerImage: (String imageUrl) => _updateBannerImage(imageUrl: imageUrl),
          updateProfileImage: (String imageUrl) => _updateProfileImage(imageUrl: imageUrl),
          removeImage: _removeImage,
        ),
        JuntoTextField(
          hintText: 'Contact email',
          labelText: 'Contact email',
          onChanged: (email) => _updateContactEmail(email),
          isOptional: true,
        ),
        SizedBox(height: 6),
        PrivateJuntoCheckbox(
          onUpdate: (bool? v) {
            final value = v ?? true;
            return setState(() => _junto = _junto.copyWith(isPublic: !value));
          },
          value: !(_junto.isPublic ?? true),
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
          setDarkColor: (val) => _junto = _junto.copyWith(themeDarkColor: val),
          setLightColor: (val) => _junto = _junto.copyWith(themeLightColor: val),
          junto: _junto,
        ),
        SizedBox(height: 22),
        if (kShowStripeFeatures)
          Row(
            children: [
              UpgradeIcon(),
              SizedBox(width: 10),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                        text: 'Get custom colors ',
                        style: AppTextStyle.headline2.copyWith(
                            fontWeight: FontWeight.w600, fontSize: 14, color: AppColor.gray2)),
                    TextSpan(
                        text: 'when you upgrade',
                        style: AppTextStyle.eyebrowSmall.copyWith(color: AppColor.gray3)),
                  ],
                ),
              )
            ],
          ),
        SizedBox(height: 40),
        if (_createdJuntoId != null) ...[
          CreateJuntoTags(_createdJuntoId!),
          SizedBox(height: 40),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ActionButton(
              text: 'Finish',
              color: AppColor.darkBlue,
              textColor: AppColor.brightGreen,
              borderRadius: BorderRadius.circular(10),
              padding: const EdgeInsets.all(20),
              onPressed: () async {
                if (_createJunto) {
                  await cloudFunctionsService.updateJunto(
                    UpdateJuntoRequest(
                      junto: _junto,
                      keys: [
                        Junto.kFieldThemeDarkColor,
                        Junto.kFieldThemeLightColor,
                      ],
                    ),
                  );
                  analytics.logEvent(AnalyticsUpdateJuntoMetadataEvent(juntoId: _junto.id));
                }

                // Immediately proceed to created junto
                Navigator.of(context).pop();
                routerDelegate.beamTo(JuntoPageRoutes(juntoDisplayId: _junto.displayId).juntoHome);
              },
            ),
          ],
        ),
      ],
    );
  }
}
