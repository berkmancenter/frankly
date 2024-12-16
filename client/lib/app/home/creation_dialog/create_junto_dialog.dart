import 'package:flutter/material.dart';
import 'package:junto/app/home/creation_dialog/components/choose_color_section.dart';
import 'package:junto/app/home/creation_dialog/components/create_junto_image_fields.dart';
import 'package:junto/app/home/creation_dialog/components/create_junto_text_fields.dart';
import 'package:junto/app/home/creation_dialog/components/private_junto_checkbox.dart';
import 'package:junto/app/home/creation_dialog/theme_creation_utility.dart';
import 'package:junto/app/home/junto_tag_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/create_tag_widget.dart';
import 'package:junto/common_widgets/junto_list_view.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/common_widgets/junto_text_field.dart';
import 'package:junto/common_widgets/visible_exception.dart';
import 'package:junto/routing/locations.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto/utils/mixins.dart';
import 'package:junto_models/analytics/analytics_entities.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:provider/provider.dart';

class CreateJuntoDialog extends StatelessWidget with ShowDialogMixin {
  final Junto? junto;
  final Function(Junto)? createFunction;
  final Function(Junto)? updateFunction;
  final String? submitText;
  final bool compact;
  final bool showTitle;
  final bool showAttributeEdit;
  final bool showImageEdit;
  final bool showChooseColorScheme;
  final bool showChooseCustomDisplayId;
  final bool isCreateJunto;
  final void Function()? onJuntoUpdated;

  const CreateJuntoDialog({
    this.junto,
    this.createFunction,
    this.updateFunction,
    this.submitText,
    this.compact = false,
    this.showTitle = true,
    this.showAttributeEdit = true,
    this.showImageEdit = true,
    this.showChooseColorScheme = false,
    this.showChooseCustomDisplayId = false,
    this.isCreateJunto = true,
    this.onJuntoUpdated,
  });

  factory CreateJuntoDialog.updateJunto({
    required Junto junto,
    bool showChooseCustomDisplayId = false,
  }) =>
      CreateJuntoDialog(
        junto: junto,
        showChooseColorScheme: true,
        showChooseCustomDisplayId: showChooseCustomDisplayId,
      );

  @override
  Widget build(BuildContext context) {
    final updatedJunto = junto ?? Junto(id: firestoreDatabase.generateNewJuntoId(), isPublic: true);
    return ChangeNotifierProvider<CreateJuntoTagProvider>(
      create: (_) => CreateJuntoTagProvider(
        juntoId: updatedJunto.id,
        isNewJunto: junto == null,
      )..initialize(),
      builder: (context, __) => _CreateJuntoDialog(
        junto: updatedJunto,
        createFunction: createFunction,
        updateFunction: updateFunction,
        submitText: submitText,
        compact: compact,
        showTitle: showTitle,
        showAttributeEdit: showAttributeEdit,
        showChooseColorScheme: showChooseColorScheme,
        showChooseCustomDisplayId: showChooseCustomDisplayId,
        isCreateJunto: junto == null,
        onJuntoUpdated: onJuntoUpdated,
      ),
    );
  }
}

class _CreateJuntoDialog extends StatefulWidget {
  final Junto junto;
  final Function(Junto)? createFunction;
  final Function(Junto)? updateFunction;
  final String? submitText;
  final bool compact;
  final bool showTitle;
  final bool showAttributeEdit;
  final bool showImageEdit;
  final bool showChooseColorScheme;
  final bool showChooseCustomDisplayId;
  final bool isCreateJunto;
  final Function()? onJuntoUpdated;

  const _CreateJuntoDialog({
    required this.junto,
    this.createFunction,
    this.updateFunction,
    this.submitText,
    this.compact = false,
    this.showTitle = true,
    this.showAttributeEdit = true,
    this.showImageEdit = true,
    this.showChooseColorScheme = false,
    this.showChooseCustomDisplayId = false,
    this.isCreateJunto = true,
    this.onJuntoUpdated,
  });

  @override
  State<_CreateJuntoDialog> createState() => _CreateJuntoDialogState();
}

class _CreateJuntoDialogState extends State<_CreateJuntoDialog> {
  late Junto _junto;
  late String _displayId;

  @override
  void initState() {
    _junto = widget.junto;
    _displayId = _junto.displayId;
    super.initState();
  }

  Future<void> _submitFunction() async {
    final regex = RegExp('^[a-zA-Z0-9-]*\$');
    if (!regex.hasMatch(_displayId)) {
      throw VisibleException('URL display name can only contain letters, numbers, and dashes.');
    }

    bool isNewDisplayId = !isNullOrEmpty(_displayId) && _displayId != widget.junto.displayId;
    final create = widget.isCreateJunto;
    if (isNewDisplayId) {
      _junto =
          _junto.copyWith(displayIds: [_displayId, _displayId.toLowerCase(), ..._junto.displayIds]);
    }

    _verifyContrastOfSelectedTheme();

    final contactEmail = _junto.contactEmail;
    if (contactEmail != null && contactEmail.isNotEmpty && !isEmailValid(contactEmail)) {
      showRegularToast(context, 'Please enter a valid email', toastType: ToastType.failed);
      return;
    }

    if (create) {
      final localCreateFunction = widget.createFunction;

      if (localCreateFunction != null) {
        await localCreateFunction(_junto);
      } else {
        await _createJunto();
      }
      await context.read<CreateJuntoTagProvider>().submit();
    } else {
      final localUpdateFunction = widget.updateFunction;
      if (localUpdateFunction != null) {
        await localUpdateFunction(_junto);
      } else {
        await _updateJunto();
      }
      await context.read<CreateJuntoTagProvider>().submit();

      final localOnJuntoUpdated = widget.onJuntoUpdated;
      if (localOnJuntoUpdated != null) {
        localOnJuntoUpdated();
      } else if (isNewDisplayId) {
        routerDelegate.beamTo(JuntoPageRoutes(
          juntoDisplayId: _displayId,
        ).juntoHome);
      }
    }
  }

  void _verifyContrastOfSelectedTheme() {
    final light = _junto.themeLightColor ?? '';
    final dark = _junto.themeDarkColor ?? '';
    if (light.isEmpty && dark.isEmpty) return;
    if (!ThemeUtils.isColorValid(light)) {
      _junto = _junto.copyWith(themeLightColor: ThemeUtils.convertToHexString(AppColor.gray6));
    }
    if (!ThemeUtils.isColorValid(dark)) {
      _junto = _junto.copyWith(themeDarkColor: ThemeUtils.convertToHexString(AppColor.darkBlue));
    }

    final valid = ThemeUtils.isColorComboValid(_junto.themeLightColor, _junto.themeDarkColor);

    if (!valid) {
      _junto = _junto.copyWith(themeDarkColor: '', themeLightColor: '');
    }
  }

  Future<void> _createJunto() async {
    final createdJuntoId =
        (await cloudFunctionsService.createJunto(CreateJuntoRequest(junto: _junto))).juntoId;
    analytics.logEvent(AnalyticsCreateJuntoEvent(juntoId: createdJuntoId));

    Navigator.of(context).pop();

    routerDelegate.beamTo(JuntoPageRoutes(juntoDisplayId: createdJuntoId).juntoHome);
  }

  Future<void> _updateJunto() async {
    await cloudFunctionsService.updateJunto(UpdateJuntoRequest(
      junto: _junto,
      keys: [
        Junto.kFieldName,
        Junto.kFieldContactEmail,
        Junto.kFieldDisplayIds,
        Junto.kFieldTagLine,
        Junto.kFieldDescription,
        Junto.kFieldIsPublic,
        Junto.kFieldThemeLightColor,
        Junto.kFieldThemeDarkColor
      ],
    ));

    analytics.logEvent(AnalyticsUpdateJuntoMetadataEvent(juntoId: _junto.id));
    Navigator.of(context).pop();
  }

  Future<void> _updateBannerImage({
    required String imageUrl,
  }) async {
    if (isNullOrEmpty(imageUrl) || imageUrl == _junto.bannerImageUrl) return;

    setState(() {
      _junto = _junto.copyWith(bannerImageUrl: imageUrl);
    });

    if (!isNullOrEmpty(_junto.id)) {
      await cloudFunctionsService.updateJunto(UpdateJuntoRequest(
        junto: _junto,
        keys: [Junto.kFieldBannerImageUrl],
      ));
      analytics.logEvent(AnalyticsUpdateJuntoImageEvent(juntoId: _junto.id));
    }
  }

  Future<void> _updateProfileImage({
    required String imageUrl,
  }) async {
    if (isNullOrEmpty(imageUrl) || imageUrl == _junto.profileImageUrl) return;

    setState(() {
      _junto = _junto.copyWith(profileImageUrl: imageUrl);
    });

    if (!isNullOrEmpty(_junto.id)) {
      await cloudFunctionsService.updateJunto(UpdateJuntoRequest(
        junto: _junto,
        keys: [Junto.kFieldProfileImageUrl],
      ));
      analytics.logEvent(AnalyticsUpdateJuntoImageEvent(juntoId: _junto.id));
    }
  }

  Future<void> _removeImage({
    required bool isBannerImage,
  }) async {
    setState(() {
      _junto = isBannerImage
          ? _junto.copyWith(bannerImageUrl: null)
          : _junto.copyWith(profileImageUrl: null);
    });

    if (!isNullOrEmpty(_junto.id)) {
      await cloudFunctionsService.updateJunto(UpdateJuntoRequest(
        junto: _junto,
        keys: [isBannerImage ? Junto.kFieldBannerImageUrl : Junto.kFieldProfileImageUrl],
      ));
      analytics.logEvent(AnalyticsUpdateJuntoImageEvent(juntoId: _junto.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = responsiveLayoutService.isMobile(context);

    return JuntoListView(
      padding: EdgeInsets.symmetric(
        vertical: widget.compact ? 0 : 60,
        horizontal: widget.compact ? 0 : (isMobile ? 16 : 40),
      ),
      children: [
        if (widget.showTitle) ...[
          JuntoText(
            widget.isCreateJunto ? 'Create your Community' : 'Edit your Community',
            style: AppTextStyle.eyebrow.copyWith(fontSize: 40),
          ),
          SizedBox(height: 30)
        ],
        if (widget.showAttributeEdit)
          CreateJuntoTextFields(
            showChooseCustomDisplayId: widget.showChooseCustomDisplayId,
            onCustomDisplayIdChanged: (value) => _displayId = value,
            onNameChanged: (value) => setState(() => _junto = _junto.copyWith(name: value)),
            onTaglineChanged: (value) => setState(() => _junto = _junto.copyWith(tagLine: value)),
            onAboutChanged: (value) => setState(() => _junto = _junto.copyWith(description: value)),
            junto: _junto,
          ),
        if (widget.showImageEdit)
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
          initialValue: _junto.contactEmail,
          onChanged: (value) => setState(() => _junto = _junto.copyWith(contactEmail: value)),
          isOptional: true,
        ),
        SizedBox(height: 10),
        PrivateJuntoCheckbox(
          onUpdate: (value) {
            if (value != null) {
              setState(() => _junto = _junto.copyWith(isPublic: !value));
            }
          },
          value: _junto.isPublic == null ? false : !_junto.isPublic!,
        ),
        if (widget.showChooseColorScheme)
          ChooseColorSection(
            junto: _junto,
            setDarkColor: (val) => _junto = _junto.copyWith(themeDarkColor: val),
            setLightColor: (val) => _junto = _junto.copyWith(themeLightColor: val),
            bigTitle: true,
          ),
        _buildAddTagsSection(),
        SizedBox(height: 30),
        _buildSubmit(),
      ],
    );
  }

  Widget _buildSubmit() {
    final submitText = widget.isCreateJunto ? 'Create' : 'Update';
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
    final createJuntoTagProvider = Provider.of<CreateJuntoTagProvider>(context);
    return JuntoStreamBuilder(
      entryFrom: 'CreateJuntoDialog._buildAddTagsSection',
      stream: createJuntoTagProvider.juntoTagsStream,
      builder: (context, _) => CreateTagWidget(
        titleText: 'Add Tags',
        titleTextStyle: AppTextStyle.body.copyWith(fontSize: 24),
        showIcon: false,
        tags: Provider.of<CreateJuntoTagProvider>(context).tags,
        onAddTag: (title) => alertOnError(context, () => createJuntoTagProvider.addTag(title)),
        checkIsSelected: (tag) => createJuntoTagProvider.isSelected(tag),
        onTapTag: (tag) => createJuntoTagProvider.onTapTag(tag),
      ),
    );
  }
}
