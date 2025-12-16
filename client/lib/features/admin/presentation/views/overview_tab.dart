import 'package:client/core/localization/localization_helper.dart';
import 'package:client/core/routing/locations.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/features/community/features/create_community/presentation/widgets/choose_color_section.dart';
import 'package:client/features/community/features/create_community/presentation/widgets/create_community_image_fields.dart';
import 'package:client/features/community/features/create_community/presentation/widgets/create_community_text_fields.dart';
import 'package:client/features/community/utils/community_theme_utils.dart';
import 'package:client/services.dart';
import 'package:data_models/analytics/analytics_entities.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:flutter/material.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/styles/styles.dart';

import 'package:data_models/community/community.dart';
import 'package:provider/provider.dart';

class OverviewTab extends StatefulWidget {
  @override
  OverviewTabState createState() => OverviewTabState();
}

class OverviewTabState extends State<OverviewTab> {
  late Community _community;
  late String _displayId;

  final int titleMaxCharactersLength = 80;
  final int customIdMaxCharactersLength = 80;

  bool _formHasErrors = false;

  _alertOnSave(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Container(
            constraints: BoxConstraints(maxWidth: 300),
            child: Text(context.l10n.yourChangesToProfileCantBeSaved),
            ),
          content: Container(
            constraints: BoxConstraints(maxWidth: 300),
            child: Text(message),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(context.l10n.close),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSection(String label, Widget sectionContent, bool mobile) {
    if (mobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                label,
                style: context.theme.textTheme.titleLarge,
              ),
            ),
          ),
          sectionContent,
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.fromLTRB(50, 30, 0, 0),
                child: Text(
                  label,
                  style: context.theme.textTheme.titleLarge,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: sectionContent,
          ),
          Spacer(flex: 1),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mobile = responsiveLayoutService.isMobile(context);
    _community = Provider.of<CommunityProvider>(context).community;
    _displayId = _community.displayId;

    context.watch<CommunityProvider>();

    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    context.l10n.basicInformation,
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 36.0,
                      ),
                      child: CreateCommunityTextFields(
                        fieldsView: FieldsView.edit,
                        borderType: BorderType.outline,
                        autoGenerateUrl: false,
                        // Catch form errors from child widget
                        onFieldsHaveErrors: (hasErrors) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!mounted) return;
                            setState(() {
                              _formHasErrors = hasErrors;
                            });
                          });
                        },
                        onCustomDisplayIdChanged: (value) => _displayId = value,
                        onNameChanged: (value) => {
                          _community = _community.copyWith(name: value),
                        },
                        onTaglineChanged: (value) => {
                          _community = _community.copyWith(tagLine: value),
                        },
                        onAboutChanged: (value) => {
                          _community = _community.copyWith(description: value),
                        },
                        onEmailChanged: (value) => {
                          _community = _community.copyWith(contactEmail: value),
                        },
                        community: _community,
                      ),
                    ),
                    mobile,
                  ),
                  Divider(
                    color: context.theme.colorScheme.onPrimaryContainer
                        .withOpacity(0.5),
                    height: 1,
                  ),
                  _buildSection(
                    context.l10n.links,
                    CreateCommunityTextFields(
                      fieldsView: FieldsView.links,
                      borderType: BorderType.outline,
                      // Catch form errors from child widget
                      onFieldsHaveErrors: (hasErrors) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          setState(() {
                            _formHasErrors = hasErrors;
                          });
                        });
                      },
                      onWebsiteUrlChanged: (value) => {
                        _community = _community.copyWith(websiteUrl: value),
                      },
                      onFacebookUrlChanged: (value) => {
                        _community = _community.copyWith(facebookUrl: value),
                      },
                      onLinkedinUrlChanged: (value) => {
                        _community = _community.copyWith(linkedinUrl: value),
                      },
                      onTwitterUrlChanged: (value) => {
                        _community = _community.copyWith(twitterUrl: value),
                      },
                      onBlueskyUrlChanged: (value) => {
                        _community = _community.copyWith(blueskyUrl: value),
                      },
                      community: _community,
                    ),
                    mobile,
                  ),
                  Divider(
                    color: context.theme.colorScheme.onPrimaryContainer
                        .withOpacity(0.5),
                    height: 1,
                  ),
                  _buildSection(
                    context.l10n.brandingAndTheme,
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 18.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 15),
                          CreateCommunityImageFields(
                            profileImageUrl: _community.profileImageUrl,
                            updateProfileImage: (String imageUrl) =>
                                _updateProfileImage(imageUrl: imageUrl),
                            removeImage: _removeImage,
                          ),
                          SizedBox(height: 30),
                          ChooseColorSection(
                            community: _community,
                            setDarkColor: (val) => _community =
                                _community.copyWith(themeDarkColor: val),
                            setLightColor: (val) => _community =
                                _community.copyWith(themeLightColor: val),
                          ),
                          if (mobile) SizedBox(height: 90),
                        ],
                      ),
                    ),
                    mobile,
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: ActionButton(
        onPressed: () => alertOnError(context, _submitFunction),
        text: context.l10n.save,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Future<void> _updateCommunity() async {
    await cloudFunctionsCommunityService.updateCommunity(
      UpdateCommunityRequest(
        community: _community,
        keys: [
          Community.kFieldName,
          Community.kFieldDisplayIds,
          Community.kFieldTagLine,
          Community.kFieldDescription,
          Community.kFieldContactEmail,
          Community.kFieldWebsiteUrl,
          Community.kFieldFacebookUrl,
          Community.kFieldLinkedinUrl,
          Community.kFieldTwitterUrl,
          Community.kFieldBlueskyUrl,
          Community.kFieldThemeLightColor,
          Community.kFieldThemeDarkColor,
        ],
      ),
    );

    analytics.logEvent(
      AnalyticsUpdateCommunityMetadataEvent(communityId: _community.id),
    );
  }

  bool _verifyContrastOfSelectedTheme() {
    final light = _community.themeLightColor ?? '';
    final dark = _community.themeDarkColor ?? '';
    if (light.isEmpty && dark.isEmpty) return true;
    if (!ThemeUtils.isColorValid(light)) {
      _community = _community.copyWith(
        themeLightColor:
            ThemeUtils.convertToHexString(context.theme.colorScheme.surface),
      );
      return false;
    }
    if (!ThemeUtils.isColorValid(dark)) {
      _community = _community.copyWith(
        themeDarkColor:
            ThemeUtils.convertToHexString(context.theme.colorScheme.primary),
      );
      return false;
    }

    final valid = ThemeUtils.isColorComboValid(
      context,
      _community.themeLightColor,
      _community.themeDarkColor,
    );

    if (!valid) {

      return false;
    }
    return true;
  }

  Future<void> _submitFunction() async {
    final regex = RegExp('^[a-zA-Z0-9-]*\$');

    final validationErrors = [
      if (isNullOrEmpty(_community.name)) context.l10n.errorCommunityNameEmpty,
      if (isNullOrEmpty(_displayId)) context.l10n.errorCommunityUrlEmpty,
      if (!regex.hasMatch(_displayId)) context.l10n.displayIdWarning,
    ];

    if (validationErrors.isNotEmpty) {
      _alertOnSave(validationErrors.first);
      return;
    }

    bool isNewDisplayId =
        !isNullOrEmpty(_displayId) && _displayId != _community.displayId;
    if (isNewDisplayId) {
      _community = _community.copyWith(
        displayIds: [
          _displayId,
          _displayId.toLowerCase(),
          ..._community.displayIds,
        ],
      );
    }

    // Check for form errors from child widgets
    if (_formHasErrors) {
      _alertOnSave(context.l10n.errorCommunityProfile);
      return;
    }

    bool isContrastValid = _verifyContrastOfSelectedTheme();

    if (!isContrastValid) {
      _alertOnSave(context.l10n.selectedColorsContrastError);
      return;
    }

    await _updateCommunity();
    if (isNewDisplayId) {
      routerDelegate.beamTo(
        CommunityPageRoutes(
          communityDisplayId: _displayId,
        ).communityAdmin(),
      );
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.changesSaved),
        duration: Duration(seconds: 2),
      ),
    );
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

    await cloudFunctionsCommunityService.updateProfileImage(
      imageUrl: imageUrl,
      community: _community,
    );
  }

  Future<void> _removeImage() async {
    setState(() {
      _community = _community.copyWith(profileImageUrl: null);
    });
    await cloudFunctionsCommunityService.removeImage(
      community: _community,
    );
  }
}
