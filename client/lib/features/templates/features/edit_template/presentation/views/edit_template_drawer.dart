import 'package:client/core/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:client/features/templates/features/create_template/presentation/create_template_tag_presenter.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/buttons/app_clickable_widget.dart';
import 'package:client/features/community/presentation/widgets/create_tag_widget.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/core/data/services/media_helper_service.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/utils/dialogs.dart';
import 'package:data_models/community/community_tag.dart';
import 'package:provider/provider.dart';

import 'edit_template_contract.dart';
import '../../data/models/edit_template_model.dart';
import '../edit_template_presenter.dart';

import 'package:client/services.dart';
import 'package:client/core/localization/localization_helper.dart';

class EditTemplateDrawer extends StatefulWidget {
  const EditTemplateDrawer({Key? key}) : super(key: key);

  @override
  _EditTemplateDrawerState createState() => _EditTemplateDrawerState();
}

class _EditTemplateDrawerState extends State<EditTemplateDrawer>
    implements EditTemplateView {
  final ScrollController _scrollController = ScrollController();
  late final EditTemplateModel _model;
  late final EditTemplatePresenter _presenter;

  @override
  void initState() {
    super.initState();

    _model = EditTemplateModel();
    _presenter = EditTemplatePresenter(context, this, _model);
    _presenter.init();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppDrawerProvider>();

    return Material(
      color: AppColor.white,
      child: _buildBody(),
    );
  }

  @override
  void showMessage(String message, {ToastType toastType = ToastType.neutral}) {
    if (mounted) showRegularToast(context, message, toastType: toastType);
  }

  @override
  void updateView() {
    if (mounted) setState(() {});
  }

  Widget _buildBody() {

    final l10n = appLocalizationService.getLocalization();

    return Column(
      children: [
        SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.editTemplate,
                style: AppTextStyle.headlineSmall
                    .copyWith(fontSize: 16, color: AppColor.black),
              ),
              AppClickableWidget(
                child: ProxiedImage(
                  null,
                  asset: AppAsset.kXPng,
                  width: 24,
                  height: 24,
                ),
                onTap: () {
                  if (_presenter.wereChangesMade()) {
                    _presenter.showConfirmChangesDialog();
                  } else {
                    closeDrawer();
                  }
                },
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            controller: _scrollController,
            children: [
              _buildImageSection(),
              SizedBox(height: 20),
              _buildTitleSection(),
              SizedBox(height: 20),
              _buildDescriptionSection(),
              SizedBox(height: 20),
              _buildTagsSection(),
              SizedBox(height: 20),
              _buildBottomButtonsSection(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void closeDrawer() {
    if (mounted) Navigator.pop(context);
  }

  Widget _buildImageSection() {
    final l10n = appLocalizationService.getLocalization();
    return Row(
      children: [
        Text(
          l10n.image,
          style: AppTextStyle.body.copyWith(color: AppColor.gray2),
        ),
        Spacer(),
        InkWell(
          onTap: () => alertOnError(context, () async {
            final url = await GetIt.instance<MediaHelperService>()
                .pickImageViaCloudinary();
            if (url != null) {
              _presenter.updateImage(url);
            }
          }),
          child: ProxiedImage(
            _model.template.image,
            width: 30,
            height: 30,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    final l10n = appLocalizationService.getLocalization();
    return CustomTextField(
      labelText: l10n.templateTitle,
      initialValue: _model.template.title,
      maxLines: 2,
      maxLength: 80,
      hideCounter: true,
      onChanged: (value) => _presenter.updateTitle(value),
    );
  }

  Widget _buildDescriptionSection() {
    final l10n = appLocalizationService.getLocalization();
    return CustomTextField(
      labelText: l10n.templateDescription,
      initialValue: _model.template.description,
      onChanged: (value) => _presenter.updateDescription(value),
    );
  }

  Widget _buildTagsSection() {
    final templateTagPresenter = context.read<CreateTemplateTagPresenter>();

    return CustomStreamBuilder<List<CommunityTag>>(
      entryFrom: 'EditTemplateDrawer._buildTagsSection',
      stream: templateTagPresenter.tagsStream,
      builder: (context, tags) {
        return CreateTagWidget(
          tags: tags ?? [],
          onAddTag: (text) =>
              alertOnError(context, () => templateTagPresenter.addTag(text)),
          checkIsSelected: (tag) => templateTagPresenter.isSelected(tag),
          onTapTag: (tag) =>
              alertOnError(context, () => templateTagPresenter.onTapTag(tag)),
        );
      },
    );
  }

  Widget _buildBottomButtonsSection() {
    final templateToggleButtonText = _presenter.getTemplateButtonToggleText();
    final templateToggleButtonColor = _presenter.getTemplateButtonToggleColor();
    final canToggleTemplate = _presenter.canDeleteTemplate();
    final l10n = appLocalizationService.getLocalization();

    return Column(
      children: [
        ActionButton(
          expand: true,
          text: l10n.saveTemplate,
          color: Theme.of(context).colorScheme.primary,
          textColor: Theme.of(context).colorScheme.secondary,
          onPressed: () => alertOnError(
            context,
            () => _presenter.saveChanges(),
          ),
        ),
        if (canToggleTemplate) ...[
          SizedBox(height: 20),
          ActionButton(
            expand: true,
            type: ActionButtonType.outline,
            textColor: templateToggleButtonColor,
            text: templateToggleButtonText,
            onPressed: () => alertOnError(
              context,
              () => _presenter.toggleTemplateStatus(),
            ),
          ),
        ],
      ],
    );
  }
}
