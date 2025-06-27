import 'package:client/core/localization/localization_helper.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/utils/toast_utils.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:client/features/community/features/create_community/presentation/widgets/choose_color_section.dart';
import 'package:client/features/community/features/create_community/presentation/widgets/create_community_image_fields.dart';
import 'package:client/features/community/features/create_community/presentation/widgets/create_community_text_fields.dart';
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
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: mobile ? 0 : 46, vertical: 16),
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

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints:
                BoxConstraints(minHeight: viewportConstraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildSection(
                  context.l10n.basicSettings,
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 8.0,
                      ),
                      child: CreateCommunityTextFields(
                        showAllFields: true,
                        showChooseCustomDisplayId: true,
                        onCustomDisplayIdChanged: (value) => _displayId = value,
                        onNameChanged: (value) => setState(
                          () => _community = _community.copyWith(name: value),
                        ),
                        onTaglineChanged: (value) => setState(
                          () =>
                              _community = _community.copyWith(tagLine: value),
                        ),
                        onAboutChanged: (value) => setState(
                          () => _community =
                              _community.copyWith(description: value),
                        ),
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
                        horizontal: 6.0,
                        vertical: 8.0,
                      ),
                      child: Column(
                        children: [
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

    if (!isNullOrEmpty(_community.id)) {
      await cloudFunctionsCommunityService.updateCommunity(
        UpdateCommunityRequest(
          community: _community,
          keys: [Community.kFieldProfileImageUrl],
        ),
      );
      analytics.logEvent(
        AnalyticsUpdateCommunityImageEvent(communityId: _community.id),
      );
    }
  }

  Future<void> _removeImage({
    required bool isBannerImage,
  }) async {
    setState(() {
      _community = isBannerImage
          ? _community.copyWith(bannerImageUrl: null)
          : _community.copyWith(profileImageUrl: null);
    });

    if (!isNullOrEmpty(_community.id)) {
      await cloudFunctionsCommunityService.updateCommunity(
        UpdateCommunityRequest(
          community: _community,
          keys: [
            isBannerImage
                ? Community.kFieldBannerImageUrl
                : Community.kFieldProfileImageUrl,
          ],
        ),
      );
      analytics.logEvent(
        AnalyticsUpdateCommunityImageEvent(communityId: _community.id),
      );
    }
  }

  @override
  void showMessage(String message, {ToastType toastType = ToastType.neutral}) {
    showRegularToast(context, message, toastType: toastType);
  }

  @override
  void updateView() {
    setState(() {});
  }
}
