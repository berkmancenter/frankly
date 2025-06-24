import 'package:client/core/utils/navigation_utils.dart';
import 'package:client/core/utils/toast_utils.dart';
import 'package:client/core/widgets/custom_loading_indicator.dart';
import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:client/features/admin/presentation/views/members_tab.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/features/user/presentation/create_profile_tag_presenter.dart';
import 'package:client/features/user/presentation/profile_tab_controller.dart';
import 'package:client/features/user/data/models/social_media_item_data.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/buttons/app_clickable_widget.dart';
import 'package:client/features/community/presentation/widgets/create_tag_widget.dart';
import 'package:client/core/widgets/editable_image.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/features/community/presentation/widgets/community_tag_builder.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/core/widgets/profile_picture.dart';
import 'package:client/features/community/data/providers/user_admin_details_builder.dart';
import 'package:client/features/user/data/providers/user_info_builder.dart';
import 'package:client/features/user/data/services/user_data_service.dart';
import 'package:client/services.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/core/utils/dialogs.dart';
import 'package:client/core/utils/extensions.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/community/membership.dart';
import 'package:data_models/user/public_user_info.dart';
import 'package:provider/provider.dart';
import 'package:client/core/localization/localization_helper.dart';

class ProfileTab extends StatelessWidget {
  final bool showTitle;

  final bool allowEdit;

  /// Toggles if there is a button that will show the read-only version of your profile in a sidebar
  final bool isPreviewButtonVisible;

  final String currentUserId;

  /// When showing event participant profile view
  /// communityId is passed to ProfileTagController to retrieve participant membership status
  final String? communityId;

  const ProfileTab({
    Key? key,
    this.showTitle = false,
    this.allowEdit = true,
    this.isPreviewButtonVisible = false,
    required this.currentUserId,
    this.communityId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomStreamBuilder<PublicUserInfo>(
      entryFrom: 'ProfileTab.build',
      stream: UserInfoProvider.forUser(currentUserId).infoFuture.asStream(),
      builder: (_, userInfo) {
        if (userInfo == null) {
          return HeightConstrainedText(
            context.l10n.errorLoadingProfileInfo,
          );
        }
        return ChangeNotifierProvider(
          create: (_) => ProfileTabController(
            userInfo: userInfo,
            currentUserId: currentUserId,
            communityId: communityId,
          )..initialize(),
          child: ChangeNotifierProvider(
            create: (_) => CreateProfileTagPresenter(
              currentUserId: currentUserId,
            )..initialize(),
            child: _ProfileTab(
              showTitle: showTitle,
              allowEdit: allowEdit,
              isPreviewButtonVisible: isPreviewButtonVisible,
              currentUserId: currentUserId,
            ),
          ),
        );
      },
    );
  }
}

class _ProfileTab extends StatefulWidget {
  final bool showTitle;
  final bool allowEdit;
  final bool isPreviewButtonVisible;
  final String? currentUserId;

  const _ProfileTab({
    Key? key,
    this.showTitle = false,
    this.allowEdit = true,
    this.isPreviewButtonVisible = false,
    this.currentUserId,
  }) : super(key: key);

  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  static const double _imageSize = 160;

  Widget _buildMembershipIcon(MembershipStatus? status) {
    final localStatus = status;
    if (localStatus == null) return SizedBox.shrink();

    return localStatus.icon(context);
  }

  List<Widget> _buildEmail(String userId) {
    return [
      SizedBox(height: 10),
      UserAdminDetailsBuilder(
        userId: userId,
        communityId: context.watch<ProfileTabController>().communityId,
        eventPath: null,
        builder: (_, loading, detailsSnapshot) {
          if (loading) {
            return Container(
              height: 50,
              alignment: Alignment.center,
              child: CustomLoadingIndicator(),
            );
          }
          final email = detailsSnapshot.data?.email;
          if (detailsSnapshot.hasError || email == null || email.isEmpty) {
            return Text(context.l10n.errorLoadingEmail);
          }
          return SelectableText(
            email,
            style: AppTextStyle.body.copyWith(fontSize: 18),
          );
        },
      ),
    ];
  }

  List<Widget> _buildContentList(PublicUserInfo userInfo) {
    final controller = context.watch<ProfileTabController>();
    final createTagPresenter = context.watch<CreateProfileTagPresenter>();

    final changeRecord = controller.changeRecord;
    final initialUrl = changeRecord.imageUrl ??
        'https://picsum.photos/seed/${userInfo.id}/$_imageSize';

    final profileIsSelf =
        userInfo.id == Provider.of<UserService>(context).currentUserId;
    final communityId = controller.communityId;
    final adminViewingUser = communityId != null &&
        Provider.of<UserDataService>(context)
            .getMembership(communityId)
            .isAdmin;

    return [
      if (widget.showTitle) ..._buildTitle(),
      SizedBox(height: 20),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: _imageSize,
            height: _imageSize,
            child: EditableImage(
              borderRadius: BorderRadius.circular(160),
              initialUrl: initialUrl,
              allowEdit: widget.allowEdit,
              child: ProfilePicture(
                borderRadius: 160,
                imageUrl: initialUrl,
              ),
              onImageSelect: (img) {
                controller.updateImage(img);
              },
            ),
          ),
          SizedBox(width: 20),
          if (widget.allowEdit)
            Expanded(
              child: CustomTextField(
                labelText: 'Name',
                initialValue: changeRecord.displayName,
                borderType: BorderType.outline,
                borderRadius: 5,
                textStyle: TextStyle(
                  color: context.theme.colorScheme.primary,
                  fontSize: 16,
                ),
                onChanged: (value) {
                  controller.onChangedName(value);
                  context.read<AppDrawerProvider>().setUnsavedChanges(true);
                },
              ),
            ),
        ],
      ),
      if (!widget.allowEdit) ...[
        SizedBox(height: 20),
        HeightConstrainedText(
          changeRecord.displayName ?? '',
          style: AppTextStyle.headline3,
        ),
        if (profileIsSelf || adminViewingUser) ..._buildEmail(userInfo.id),
        SizedBox(height: 10),
        if (controller.communityId != null)
          CustomStreamBuilder<Membership?>(
            entryFrom: '_ProfileTabState._buildContentList',
            stream: controller.membershipStream,
            builder: (_, value) {
              if (value == null) return SizedBox.shrink();
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMembershipIcon(value.status),
                  SizedBox(width: 7),
                  Text(
                    value.status
                        .toString()
                        .replaceFirst('MembershipStatus.', '')
                        .capitalize(),
                    style: AppTextStyle.body,
                  ),
                ],
              );
            },
          ),
        SizedBox(height: 20),
        Row(
          children: [
            for (final SocialMediaItem item in changeRecord.socialMediaItems)
              _buildSocialIcon(item),
          ],
        ),
      ],
      SizedBox(height: 20),
      ..._buildAboutSection(),
      if (widget.allowEdit) ...[
        SizedBox(height: 20),
        for (final platform in controller.socialMediaItems) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 18.0),
            child: SocialInputField(
              platform: platform,
              onChanged: (value) {
                controller.onEditSocialMedia(value: value, platform: platform);
                context.read<AppDrawerProvider>().setUnsavedChanges(true);
              },
            ),
          ),
        ],
      ],
      SizedBox(height: 30),
      _buildProfileTagSection(),
      if (widget.allowEdit) ...[
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.isPreviewButtonVisible)
              ActionButton(
                height: 48,
                onPressed: () => Dialogs.showAppDrawer(
                  context,
                  AppDrawerSide.right,
                  ProfileTab(
                    showTitle: true,
                    allowEdit: false,
                    currentUserId: userService.currentUserId!,
                  ),
                ),
                sendingIndicatorAlign: ActionButtonSendingIndicatorAlign.none,
                text: 'Preview',
                expand: false,
              ),
            ActionButton(
              height: 48,
              borderRadius: BorderRadius.circular(10),
              onPressed: controller.changeKeys.isNotEmpty ||
                      createTagPresenter.unsavedTags.isNotEmpty
                  ? () => alertOnError(context, () => _saveChanges())
                  : null,
              text: 'Update Profile',
              expand: false,
            ),
          ],
        ),
      ],
    ];
  }

  Future<void> _saveChanges() async {
    final controller = context.read<ProfileTabController>();
    final createTagPresenter = context.read<CreateProfileTagPresenter>();

    await controller.submitPressed();
    await createTagPresenter.submit();
    showRegularToast(
      context,
      'Profile updated',
      toastType: ToastType.success,
    );

    // Only close drawer if `preview` button is not visible. Preview button is only visible
    // in `Profile` tab in `Settings`.
    if (!widget.isPreviewButtonVisible) {
      // Close drawer
      Navigator.pop(context);
    }
  }

  List<Widget> _buildAboutSection() {
    final controller = context.watch<ProfileTabController>();
    final changeRecord = controller.changeRecord;
    return [
      if (widget.allowEdit)
        CustomTextField(
          labelText: 'About me',
          maxLines: 6,
          minLines: 6,
          keyboardType: TextInputType.multiline,
          borderRadius: 5,
          padding: EdgeInsets.zero,
          textStyle:
              TextStyle(color: context.theme.colorScheme.primary, fontSize: 16),
          initialValue: changeRecord.about,
          onChanged: (value) {
            controller.onChangedAboutMe(value);
            context.read<AppDrawerProvider>().setUnsavedChanges(true);
          },
        )
      else if (changeRecord.about?.isNotEmpty ?? false)
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: HeightConstrainedText(
            changeRecord.about ?? '',
            style: AppTextStyle.body.copyWith(
              color: context.theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
    ];
  }

  Widget _buildProfileTagSection() {
    final createTagPresenter = context.watch<CreateProfileTagPresenter>();

    return CustomStreamBuilder(
      entryFrom: '_ProfileTabState._buildContentList',
      stream: createTagPresenter.tagsStream,
      builder: (_, __) {
        final tags = context.watch<CreateProfileTagPresenter>().tags;
        if (!widget.allowEdit) {
          return tags.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HeightConstrainedText(
                      'Tags',
                      style: AppTextStyle.headline4.copyWith(
                        color: context.theme.colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        for (var tag in tags)
                          CommunityTagBuilder(
                            tagDefinitionId: tag.definitionId,
                            builder: (_, __, definition) => definition == null
                                ? SizedBox.shrink()
                                : HeightConstrainedText(
                                    '#${definition.title} ',
                                    style: AppTextStyle.body,
                                  ),
                          ),
                      ],
                    ),
                  ],
                )
              : SizedBox.shrink();
        }
        return CreateTagWidget(
          tags: tags,
          onAddTag: (text) async {
            await alertOnError(context, () => createTagPresenter.addTag(text));
            context.read<AppDrawerProvider>().setUnsavedChanges(true);
          },
          checkIsSelected: (tag) => createTagPresenter.isSelected(tag),
          onTapTag: (tag) =>
              alertOnError(context, () => createTagPresenter.onTapTag(tag)),
        );
      },
    );
  }

  List<Widget> _buildTitle() {
    return [
      SizedBox(height: 30),
      Row(
        children: [
          HeightConstrainedText(
            widget.allowEdit ? 'Edit your profile' : '',
            style: AppTextStyle.headlineSmall.copyWith(
              fontSize: 16,
              color: context.theme.colorScheme.primary,
            ),
          ),
          Spacer(),
          AppClickableWidget(
            child: ProxiedImage(
              null,
              asset: AppAsset.kXPng,
              width: 24,
              height: 24,
            ),
            onTap: () {
              final appDrawerProvider = context.read<AppDrawerProvider>();

              if (appDrawerProvider.hasDrawerUnsavedChanges) {
                appDrawerProvider.showConfirmChangesDialogLayer();
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    ];
  }

  Widget _buildFAIcon(
    BuildContext context,
    IconData icon, {
    required void Function() onTap,
  }) {
    final foregroundColor = context.theme.colorScheme.primary;

    final size = responsiveLayoutService.getDynamicSize(context, 35.0);
    final iconSize = responsiveLayoutService.getDynamicSize(context, 20.0);
    return CustomInkWell(
      onTap: onTap,
      boxShape: BoxShape.circle,
      child: AnimatedContainer(
        margin: EdgeInsets.all(5),
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: foregroundColor,
        ),
        duration: kTabScrollDuration,
        child: Padding(
          padding: EdgeInsets.all(6.0),
          child: Icon(
            icon,
            color: context.theme.colorScheme.onPrimary,
            size: iconSize,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(SocialMediaItem item) {
    final key = item.socialMediaKey;
    if (key == null) return SizedBox.shrink();
    switch (key) {
      case SocialMediaKey.facebook:
        return _buildFAIcon(
          context,
          FontAwesomeIcons.facebookF,
          onTap: () => launch(item.url!),
        );
      case SocialMediaKey.instagram:
        return _buildFAIcon(
          context,
          FontAwesomeIcons.instagram,
          onTap: () => launch(item.url!),
        );
      case SocialMediaKey.linkedin:
        return _buildFAIcon(
          context,
          FontAwesomeIcons.linkedin,
          onTap: () => launch(item.url!),
        );
      case SocialMediaKey.twitter:
        return _buildFAIcon(
          context,
          FontAwesomeIcons.twitter,
          onTap: () => launch(item.url!),
        );
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<AppDrawerProvider>().setOnSaveChanges(
      onSaveChanges: () async {
        await alertOnError(context, () => _saveChanges());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppDrawerProvider>();
    final controller = context.watch<ProfileTabController>();

    // This is tech debt. Preview button is only visible when `ProfileTab` is built via
    // TAB and not `drawer`. It's only possible (as of 26/11/2021) to experience it in `Settings` page.
    // This influence building our UI, since this widget can be either in the drawer or the page itself.
    if (widget.isPreviewButtonVisible) {
      return Material(
        // Since `Settings` page is not a drawer, we can't assign color to it. With White color it looks off.
        color: Colors.transparent,
        // We can't wrap it with Column, as we do in other branch, as it does not render.
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildContentList(controller.userInfo),
          ),
        ),
      );
    } else {
      return Material(
        color: context.theme.colorScheme.surfaceContainerLowest,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildContentList(controller.userInfo),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}

class SocialInputField extends StatelessWidget {
  final SocialMediaItem platform;
  final void Function(String) onChanged;

  const SocialInputField({
    Key? key,
    required this.platform,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: ProxiedImage(
            null,
            asset: AppAsset(
              platform.socialMediaKey?.getInfo(context).logoUrl ?? '',
            ),
            width: 30,
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: CustomTextField(
            labelText: platform.socialMediaKey?.getInfo(context).title,
            initialValue: platform.url,
            borderType: BorderType.outline,
            borderRadius: 5,
            textStyle: TextStyle(
              color: context.theme.colorScheme.primary,
              fontSize: 16,
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
