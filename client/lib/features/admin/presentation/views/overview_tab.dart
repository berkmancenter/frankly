import 'package:client/core/localization/localization_helper.dart';
import 'package:client/core/routing/locations.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/utils/visible_exception.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:client/features/community/features/create_community/presentation/widgets/choose_color_section.dart';
import 'package:client/features/community/features/create_community/presentation/widgets/create_community_image_fields.dart';
import 'package:client/features/community/features/create_community/presentation/widgets/create_community_text_fields.dart';
import 'package:client/features/community/utils/community_theme_utils.dart.dart';
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
  _OverviewTabState createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  late Community _community;
  late String _displayId;

  final int titleMaxCharactersLength = 80;
  final int customIdMaxCharactersLength = 80;

  Widget _buildSection(String label, Widget sectionContent, bool mobile) {
    return Flex(
      direction: mobile ? Axis.vertical : Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: mobile ? 0 : 46, vertical: 28),
          child: HeightConstrainedText(
            label,
            style: context.theme.textTheme.titleLarge,
            maxLines: 1,
          ),
        ),
        sectionContent,
        if (!mobile) Spacer(flex: 1),
      ],
    );
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildSection(
                    context.l10n.basicInformation,
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6.0,
                          vertical: 36.0,
                        ),
                        child: CreateCommunityTextFields(
                          showAllFields: true,
                          showChooseCustomDisplayId: true,
                          borderType: BorderType.outline,
                          onCustomDisplayIdChanged: (value) =>
                              _displayId = value,
                          onNameChanged: (value) => {
                            _community = _community.copyWith(name: value),
                          },
                          onTaglineChanged: (value) => {
                            _community = _community.copyWith(tagLine: value),
                          },
                          onAboutChanged: (value) => {
                            _community =
                                _community.copyWith(description: value),
                          },
                          community: _community,
                        ),
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
                    context.l10n.brandingAndTheme,
                    Flexible(
                      child: Padding(
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
                          ],
                        ),
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
          Community.kFieldThemeLightColor,
          Community.kFieldThemeDarkColor,
        ],
      ),
    );

    analytics.logEvent(
      AnalyticsUpdateCommunityMetadataEvent(communityId: _community.id),
    );
  }

  void _verifyContrastOfSelectedTheme() {
    final light = _community.themeLightColor ?? '';
    final dark = _community.themeDarkColor ?? '';
    if (light.isEmpty && dark.isEmpty) return;
    if (!ThemeUtils.isColorValid(light)) {
      _community = _community.copyWith(
        themeLightColor:
            ThemeUtils.convertToHexString(context.theme.colorScheme.surface),
      );
    }
    if (!ThemeUtils.isColorValid(dark)) {
      _community = _community.copyWith(
        themeDarkColor:
            ThemeUtils.convertToHexString(context.theme.colorScheme.primary),
      );
    }

    final valid = ThemeUtils.isColorComboValid(
      context,
      _community.themeLightColor,
      _community.themeDarkColor,
    );

    if (!valid) {
      _community = _community.copyWith(themeDarkColor: '', themeLightColor: '');
    }
  }

  Future<void> _submitFunction() async {
    final regex = RegExp('^[a-zA-Z0-9-]*\$');
    if (!regex.hasMatch(_displayId)) {
      throw VisibleException(
        context.l10n.displayIdWarning,
      );
    }
    if( isNullOrEmpty(_displayId)) {
      throw VisibleException(
        context.l10n.errorCommunityUrlEmpty,
      );
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

    _verifyContrastOfSelectedTheme();

    await _updateCommunity();
    if (isNewDisplayId) {
      routerDelegate.beamTo(
        CommunityPageRoutes(
          communityDisplayId: _displayId,
        ).communityAdmin(),
      );
    }
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
