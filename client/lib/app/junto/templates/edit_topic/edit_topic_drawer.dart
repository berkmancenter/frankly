import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:junto/app/junto/templates/create_topic/create_topic_tag_presenter.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/app_clickable_widget.dart';
import 'package:junto/common_widgets/create_tag_widget.dart';
import 'package:junto/common_widgets/custom_switch_tile.dart';
import 'package:junto/common_widgets/junto_image.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/common_widgets/junto_text_field.dart';
import 'package:junto/common_widgets/junto_ui_migration.dart';
import 'package:junto/services/media_helper_service.dart';
import 'package:junto/styles/app_asset.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/dialogs.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:junto_models/firestore/junto_tag.dart';
import 'package:provider/provider.dart';

import 'edit_topic_contract.dart';
import 'edit_topic_model.dart';
import 'edit_topic_presenter.dart';

class EditTopicDrawer extends StatefulWidget {
  const EditTopicDrawer({Key? key}) : super(key: key);

  @override
  _EditTopicDrawerState createState() => _EditTopicDrawerState();
}

class _EditTopicDrawerState extends State<EditTopicDrawer> implements EditTopicView {
  final ScrollController _scrollController = ScrollController();
  late final EditTopicModel _model;
  late final EditTopicPresenter _presenter;

  @override
  void initState() {
    super.initState();

    _model = EditTopicModel();
    _presenter = EditTopicPresenter(context, this, _model);
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
    return JuntoUiMigration(
      whiteBackground: true,
      child: Column(
        children: [
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit template',
                  style: AppTextStyle.headlineSmall.copyWith(fontSize: 16, color: AppColor.black),
                ),
                AppClickableWidget(
                  child: JuntoImage(
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
                if (_presenter.showFeatureToggle) ...[
                  _buildFeaturedSection(),
                  SizedBox(height: 20),
                ],
                _buildTagsSection(),
                SizedBox(height: 20),
                _buildBottomButtonsSection(),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void closeDrawer() {
    if (mounted) Navigator.pop(context);
  }

  Widget _buildImageSection() {
    return Row(
      children: [
        Text(
          'Image',
          style: AppTextStyle.body.copyWith(color: AppColor.gray2),
        ),
        Spacer(),
        InkWell(
          onTap: () => alertOnError(context, () async {
            final url = await GetIt.instance<MediaHelperService>().pickImageViaCloudinary();
            if (url != null) {
              _presenter.updateImage(url);
            }
          }),
          child: JuntoImage(
            _model.topic.image,
            width: 30,
            height: 30,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return JuntoTextField(
      labelText: 'Title',
      initialValue: _model.topic.title,
      maxLines: 2,
      maxLength: 80,
      hideCounter: true,
      onChanged: (value) => _presenter.updateTitle(value),
    );
  }

  Widget _buildDescriptionSection() {
    return JuntoTextField(
      labelText: 'Description',
      initialValue: _model.topic.description,
      onChanged: (value) => _presenter.updateDescription(value),
    );
  }

  Widget _buildFeaturedSection() {
    final junto = _presenter.getJunto();

    return JuntoStreamBuilder<List<Featured>>(
      entryFrom: 'EditTopicDrawer._buildFeaturedSection',
      stream: _presenter.getFeaturedStream(),
      showLoading: false,
      builder: (_, featuredItems) {
        // Initialise only first time
        _model.isFeatured ??= _presenter.isFeatured(featuredItems);
        _model.initialFeatured ??= _presenter.isFeatured(featuredItems);

        return CustomSwitchTile(
          val: _model.isFeatured ?? false,
          text: 'Feature on ${junto.name} homepage',
          onUpdate: (value) => _presenter.updateIsFeatured(value),
        );
      },
    );
  }

  Widget _buildTagsSection() {
    final topicTagPresenter = context.read<CreateTopicTagPresenter>();

    return JuntoStreamBuilder<List<JuntoTag>>(
      entryFrom: 'EditTopicDrawer._buildTagsSection',
      stream: topicTagPresenter.tagsStream,
      builder: (context, tags) {
        return CreateTagWidget(
          tags: tags ?? [],
          onAddTag: (text) => alertOnError(context, () => topicTagPresenter.addTag(text)),
          checkIsSelected: (tag) => topicTagPresenter.isSelected(tag),
          onTapTag: (tag) => alertOnError(context, () => topicTagPresenter.onTapTag(tag)),
        );
      },
    );
  }

  Widget _buildBottomButtonsSection() {
    final topicToggleButtonText = _presenter.getTopicButtonToggleText();
    final topicToggleButtonColor = _presenter.getTopicButtonToggleColor();
    final canToggleTopic = _presenter.canDeleteTopic();

    return Column(
      children: [
        ActionButton(
          expand: true,
          text: 'Save template',
          color: Theme.of(context).colorScheme.primary,
          textColor: Theme.of(context).colorScheme.secondary,
          onPressed: () => alertOnError(
            context,
            () => _presenter.saveChanges(),
          ),
        ),
        if (canToggleTopic) ...[
          SizedBox(height: 20),
          ActionButton(
            expand: true,
            type: ActionButtonType.outline,
            textColor: topicToggleButtonColor,
            text: topicToggleButtonText,
            onPressed: () => alertOnError(
              context,
              () => _presenter.toggleTopicStatus(),
            ),
          ),
        ],
      ],
    );
  }
}
