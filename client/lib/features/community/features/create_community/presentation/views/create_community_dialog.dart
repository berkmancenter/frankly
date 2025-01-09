import 'package:client/core/utils/toast_utils.dart';
import 'package:client/core/utils/validation_utils.dart';
import 'package:flutter/material.dart';
import 'package:client/features/community/features/create_community/presentation/widgets/choose_color_section.dart';
import 'package:client/features/community/features/create_community/presentation/widgets/create_community_image_fields.dart';
import 'package:client/features/community/features/create_community/presentation/widgets/create_community_text_fields.dart';
import 'package:client/features/community/features/create_community/presentation/widgets/private_community_checkbox.dart';
import 'package:client/features/community/utils/theme_creation_utility.dart';
import 'package:client/features/community/features/create_community/data/providers/community_tag_provider.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/action_button.dart';
import 'package:client/features/community/presentation/widgets/create_tag_widget.dart';
import 'package:client/core/widgets/custom_list_view.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/core/utils/visible_exception.dart';
import 'package:client/core/routing/locations.dart';
import 'package:client/services.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:client/features/community/features/create_community/presentation/widgets/mixins.dart';
import 'package:data_models/analytics/analytics_entities.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/community/community.dart';
import 'package:provider/provider.dart';

class CreateCommunityDialog extends StatelessWidget with ShowDialogMixin {
  final Community? community;
  final Function(Community)? createFunction;
  final Function(Community)? updateFunction;
  final String? submitText;
  final bool compact;
  final bool showTitle;
  final bool showAttributeEdit;
  final bool showImageEdit;
  final bool showChooseColorScheme;
  final bool showChooseCustomDisplayId;
  final bool isCreateCommunity;
  final void Function()? onCommunityUpdated;

  const CreateCommunityDialog({
    this.community,
    this.createFunction,
    this.updateFunction,
    this.submitText,
    this.compact = false,
    this.showTitle = true,
    this.showAttributeEdit = true,
    this.showImageEdit = true,
    this.showChooseColorScheme = false,
    this.showChooseCustomDisplayId = false,
    this.isCreateCommunity = true,
    this.onCommunityUpdated,
  });

  factory CreateCommunityDialog.updateCommunity({
    required Community community,
    bool showChooseCustomDisplayId = false,
  }) =>
      CreateCommunityDialog(
        community: community,
        showChooseColorScheme: true,
        showChooseCustomDisplayId: showChooseCustomDisplayId,
      );

  @override
  Widget build(BuildContext context) {
    final updatedCommunity = community ??
        Community(
          id: firestoreDatabase.generateNewCommunityId(),
          isPublic: true,
        );
    return ChangeNotifierProvider<CreateCommunityTagProvider>(
      create: (_) => CreateCommunityTagProvider(
        communityId: updatedCommunity.id,
        isNewCommunity: community == null,
      )..initialize(),
      builder: (context, __) => _CreateCommunityDialog(
        community: updatedCommunity,
        createFunction: createFunction,
        updateFunction: updateFunction,
        submitText: submitText,
        compact: compact,
        showTitle: showTitle,
        showAttributeEdit: showAttributeEdit,
        showChooseColorScheme: showChooseColorScheme,
        showChooseCustomDisplayId: showChooseCustomDisplayId,
        isCreateCommunity: community == null,
        onCommunityUpdated: onCommunityUpdated,
      ),
    );
  }
}

class _CreateCommunityDialog extends StatefulWidget {
  final Community community;
  final Function(Community)? createFunction;
  final Function(Community)? updateFunction;
  final String? submitText;
  final bool compact;
  final bool showTitle;
  final bool showAttributeEdit;
  final bool showImageEdit;
  final bool showChooseColorScheme;
  final bool showChooseCustomDisplayId;
  final bool isCreateCommunity;
  final Function()? onCommunityUpdated;

  const _CreateCommunityDialog({
    required this.community,
    this.createFunction,
    this.updateFunction,
    this.submitText,
    this.compact = false,
    this.showTitle = true,
    this.showAttributeEdit = true,
    this.showImageEdit = true,
    this.showChooseColorScheme = false,
    this.showChooseCustomDisplayId = false,
    this.isCreateCommunity = true,
    this.onCommunityUpdated,
  });

  @override
  State<_CreateCommunityDialog> createState() => _CreateCommunityDialogState();
}

class _CreateCommunityDialogState extends State<_CreateCommunityDialog> {
  late Community _community;
  late String _displayId;

  @override
  void initState() {
    _community = widget.community;
    _displayId = _community.displayId;
    super.initState();
  }

  Future<void> _submitFunction() async {
    final regex = RegExp('^[a-zA-Z0-9-]*\$');
    if (!regex.hasMatch(_displayId)) {
      throw VisibleException(
        'URL display name can only contain letters, numbers, and dashes.',
      );
    }

    bool isNewDisplayId =
        !isNullOrEmpty(_displayId) && _displayId != widget.community.displayId;
    final create = widget.isCreateCommunity;
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

    final contactEmail = _community.contactEmail;
    if (contactEmail != null &&
        contactEmail.isNotEmpty &&
        !isEmailValid(contactEmail)) {
      showRegularToast(
        context,
        'Please enter a valid email',
        toastType: ToastType.failed,
      );
      return;
    }

    if (create) {
      final localCreateFunction = widget.createFunction;

      if (localCreateFunction != null) {
        await localCreateFunction(_community);
      } else {
        await _createCommunity();
      }
      await context.read<CreateCommunityTagProvider>().submit();
    } else {
      final localUpdateFunction = widget.updateFunction;
      if (localUpdateFunction != null) {
        await localUpdateFunction(_community);
      } else {
        await _updateCommunity();
      }
      await context.read<CreateCommunityTagProvider>().submit();

      final localOnCommunityUpdated = widget.onCommunityUpdated;
      if (localOnCommunityUpdated != null) {
        localOnCommunityUpdated();
      } else if (isNewDisplayId) {
        routerDelegate.beamTo(
          CommunityPageRoutes(
            communityDisplayId: _displayId,
          ).communityHome,
        );
      }
    }
  }

  void _verifyContrastOfSelectedTheme() {
    final light = _community.themeLightColor ?? '';
    final dark = _community.themeDarkColor ?? '';
    if (light.isEmpty && dark.isEmpty) return;
    if (!ThemeUtils.isColorValid(light)) {
      _community = _community.copyWith(
        themeLightColor: ThemeUtils.convertToHexString(AppColor.gray6),
      );
    }
    if (!ThemeUtils.isColorValid(dark)) {
      _community = _community.copyWith(
        themeDarkColor: ThemeUtils.convertToHexString(AppColor.darkBlue),
      );
    }

    final valid = ThemeUtils.isColorComboValid(
      _community.themeLightColor,
      _community.themeDarkColor,
    );

    if (!valid) {
      _community = _community.copyWith(themeDarkColor: '', themeLightColor: '');
    }
  }

  Future<void> _createCommunity() async {
    final createdCommunityId = (await cloudFunctionsCommunityService
            .createCommunity(CreateCommunityRequest(community: _community)))
        .communityId;
    analytics.logEvent(
      AnalyticsCreateCommunityEvent(communityId: createdCommunityId),
    );

    Navigator.of(context).pop();

    routerDelegate.beamTo(
      CommunityPageRoutes(communityDisplayId: createdCommunityId).communityHome,
    );
  }

  Future<void> _updateCommunity() async {
    await cloudFunctionsCommunityService.updateCommunity(
      UpdateCommunityRequest(
        community: _community,
        keys: [
          Community.kFieldName,
          Community.kFieldContactEmail,
          Community.kFieldDisplayIds,
          Community.kFieldTagLine,
          Community.kFieldDescription,
          Community.kFieldIsPublic,
          Community.kFieldThemeLightColor,
          Community.kFieldThemeDarkColor,
        ],
      ),
    );

    analytics.logEvent(
      AnalyticsUpdateCommunityMetadataEvent(communityId: _community.id),
    );
    Navigator.of(context).pop();
  }

  Future<void> _updateBannerImage({
    required String imageUrl,
  }) async {
    if (isNullOrEmpty(imageUrl) || imageUrl == _community.bannerImageUrl) {
      return;
    }

    setState(() {
      _community = _community.copyWith(bannerImageUrl: imageUrl);
    });

    if (!isNullOrEmpty(_community.id)) {
      await cloudFunctionsCommunityService.updateCommunity(
        UpdateCommunityRequest(
          community: _community,
          keys: [Community.kFieldBannerImageUrl],
        ),
      );
      analytics.logEvent(
        AnalyticsUpdateCommunityImageEvent(communityId: _community.id),
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
  Widget build(BuildContext context) {
    final isMobile = responsiveLayoutService.isMobile(context);

    return CustomListView(
      padding: EdgeInsets.symmetric(
        vertical: widget.compact ? 0 : 60,
        horizontal: widget.compact ? 0 : (isMobile ? 16 : 40),
      ),
      children: [
        if (widget.showTitle) ...[
          HeightConstrainedText(
            widget.isCreateCommunity
                ? 'Create your Community'
                : 'Edit your Community',
            style: AppTextStyle.eyebrow.copyWith(fontSize: 40),
          ),
          SizedBox(height: 30),
        ],
        if (widget.showAttributeEdit)
          CreateCommunityTextFields(
            showChooseCustomDisplayId: widget.showChooseCustomDisplayId,
            onCustomDisplayIdChanged: (value) => _displayId = value,
            onNameChanged: (value) =>
                setState(() => _community = _community.copyWith(name: value)),
            onTaglineChanged: (value) => setState(
              () => _community = _community.copyWith(tagLine: value),
            ),
            onAboutChanged: (value) => setState(
              () => _community = _community.copyWith(description: value),
            ),
            community: _community,
          ),
        if (widget.showImageEdit)
          CreateCommunityImageFields(
            bannerImageUrl: _community.bannerImageUrl,
            profileImageUrl: _community.profileImageUrl,
            updateBannerImage: (String imageUrl) =>
                _updateBannerImage(imageUrl: imageUrl),
            updateProfileImage: (String imageUrl) =>
                _updateProfileImage(imageUrl: imageUrl),
            removeImage: _removeImage,
          ),
        CustomTextField(
          hintText: 'Contact email',
          labelText: 'Contact email',
          initialValue: _community.contactEmail,
          onChanged: (value) => setState(
            () => _community = _community.copyWith(contactEmail: value),
          ),
          isOptional: true,
        ),
        SizedBox(height: 10),
        PrivateCommunityCheckbox(
          onUpdate: (value) {
            if (value != null) {
              setState(
                () => _community = _community.copyWith(isPublic: !value),
              );
            }
          },
          value: _community.isPublic == null ? false : !_community.isPublic!,
        ),
        if (widget.showChooseColorScheme)
          ChooseColorSection(
            community: _community,
            setDarkColor: (val) =>
                _community = _community.copyWith(themeDarkColor: val),
            setLightColor: (val) =>
                _community = _community.copyWith(themeLightColor: val),
            bigTitle: true,
          ),
        _buildAddTagsSection(),
        SizedBox(height: 30),
        _buildSubmit(),
      ],
    );
  }

  Widget _buildSubmit() {
    final submitText = widget.isCreateCommunity ? 'Create' : 'Update';
    final button = ActionButton(
      onPressed: () => alertOnError(context, _submitFunction),
      text: widget.submitText ?? submitText,
      expand: widget.compact,
      color: Theme.of(context).primaryColor,
      sendingIndicatorAlign: ActionButtonSendingIndicatorAlign.left,
    );
    if (widget.compact) {
      return button;
    } else {
      return Align(
        alignment: Alignment.centerRight,
        child: button,
      );
    }
  }

  Widget _buildAddTagsSection() {
    final createCommunityTagProvider =
        Provider.of<CreateCommunityTagProvider>(context);
    return CustomStreamBuilder(
      entryFrom: 'CreateCommunityDialog._buildAddTagsSection',
      stream: createCommunityTagProvider.communityTagsStream,
      builder: (context, _) => CreateTagWidget(
        titleText: 'Add Tags',
        titleTextStyle: AppTextStyle.body.copyWith(fontSize: 24),
        showIcon: false,
        tags: Provider.of<CreateCommunityTagProvider>(context).tags,
        onAddTag: (title) => alertOnError(
          context,
          () => createCommunityTagProvider.addTag(title),
        ),
        checkIsSelected: (tag) => createCommunityTagProvider.isSelected(tag),
        onTapTag: (tag) => createCommunityTagProvider.onTapTag(tag),
      ),
    );
  }
}
