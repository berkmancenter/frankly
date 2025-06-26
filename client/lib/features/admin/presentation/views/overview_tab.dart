import 'package:client/core/localization/localization_helper.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/utils/toast_utils.dart';
import 'package:client/core/widgets/height_constained_text.dart';
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

// import '../../data/models/overview_model.dart';
// import '../overview_presenter.dart';

class OverviewTab extends StatefulWidget {
  @override
  _OverviewTabState createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  // late final OverviewModel _model;
  // late final OverviewPresenter _presenter;

  late Community _community;
  late String _displayId;

  final int titleMaxCharactersLength = 80;
  final int customIdMaxCharactersLength = 80;
  // @override
  // void initState() {
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    final mobile = responsiveLayoutService.isMobile(context);
    _community = Provider.of<CommunityProvider>(context).community;
    _displayId = _community.displayId;

    context.watch<CommunityProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flex(
          direction: mobile ? Axis.vertical : Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 46, vertical: 16),
              child: HeightConstrainedText(
                context.l10n.basicSettings,
                style: context.theme.textTheme.titleLarge,
                maxLines: 1,

              ),
            ),
            Flexible(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
                child: CreateCommunityTextFields(
                  showAllFields: true,
                  showChooseCustomDisplayId: true,
                  onCustomDisplayIdChanged: (value) => _displayId = value,
                  onNameChanged: (value) => setState(
                    () => _community = _community.copyWith(name: value),
                  ),
                  onTaglineChanged: (value) => setState(
                    () => _community = _community.copyWith(tagLine: value),
                  ),
                  onAboutChanged: (value) => setState(
                    () => _community = _community.copyWith(description: value),
                  ),
                  community: _community,
                ),
              ),
            ),
            if(!mobile)
            Spacer(flex:  1),
          ],
        ),
        Divider(
          color: context.theme.colorScheme.onPrimaryContainer.withOpacity(0.5),
          height: 1,
        ),
      ],
      // HeightConstrainedText(
      //   context.l10n.brandingAndTheme,
      //   style: context.theme.textTheme.titleLarge,
      //   maxLines: 1,
      // )

      // SizedBox(height: 10),
      // HeightConstrainedText(
      //   context.l10n.brandingAndTheme,
      //   style: context.theme.textTheme.titleLarge,
      //   maxLines: 1,
      // ),
      // SizedBox(height: 10),
      //  CreateCommunityImageFields(
      //   profileImageUrl: _community.profileImageUrl,
      //   updateProfileImage: (String imageUrl) =>
      //       _updateProfileImage(imageUrl: imageUrl),
      //   removeImage: _removeImage,
      // ),
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
