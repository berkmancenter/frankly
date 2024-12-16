import 'package:clock/clock.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:junto/app/junto/discussions/create_discussion/create_discussion_dialog.dart';
import 'package:junto/app/junto/discussions/create_discussion/create_discussion_dialog_model.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_provider.dart';
import 'package:junto/app/junto/discussions/platform_data.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/app_clickable_widget.dart';
import 'package:junto/common_widgets/app_radio_list_tile.dart';
import 'package:junto/common_widgets/custom_switch_tile.dart';
import 'package:junto/common_widgets/discussion_participants_list.dart';
import 'package:junto/common_widgets/junto_image.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/common_widgets/junto_text_field.dart';
import 'package:junto/common_widgets/junto_ui_migration.dart';
import 'package:junto/services/media_helper_service.dart';
import 'package:junto/styles/app_asset.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/dialogs.dart';
import 'package:junto/utils/extensions.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:provider/provider.dart';

import 'edit_discussion_contract.dart';
import 'edit_discussion_model.dart';
import 'edit_discussion_presenter.dart';

class EditDiscussionDrawer extends StatefulWidget {
  const EditDiscussionDrawer({Key? key}) : super(key: key);

  @override
  _EditDiscussionDrawerState createState() => _EditDiscussionDrawerState();
}

class _EditDiscussionDrawerState extends State<EditDiscussionDrawer> implements EditDiscussionView {
  final ScrollController _scrollController = ScrollController();
  late final EditDiscussionModel _model;
  late final EditDiscussionPresenter _presenter;

  @override
  void initState() {
    super.initState();

    _model = EditDiscussionModel();
    _presenter = EditDiscussionPresenter(context, this, _model);
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
    final isPlatformSelectionFeatureEnabled = _presenter.isPlatformSelectionFeatureEnabled();
    final canBuildParticipantCountSection = _presenter.canBuildParticipantCountSection();

    return JuntoUiMigration(
      whiteBackground: true,
      child: Column(
        children: [
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit event',
                  style: AppTextStyle.headlineSmall.copyWith(fontSize: 16, color: AppColor.black),
                ),
                Semantics(
                  label: 'Close Edit',
                  child: AppClickableWidget(
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
                _buildDiscussionTypeSection(),
                SizedBox(height: 20),
                _buildImageSection(),
                SizedBox(height: 20),
                _buildTitleSection(),
                SizedBox(height: 20),
                _buildDescriptionSection(),
                SizedBox(height: 20),
                _buildIsPublicSection(),
                SizedBox(height: 20),
                _buildDateSection(),
                SizedBox(height: 20),
                _buildTimeSection(),
                // Have slightly higher spacing, because for some reason,
                // widget above have less spacing around itself. Thus by having more spacing all
                // spacing visually looks equal.
                SizedBox(height: 30),
                _buildDurationSection(),
                SizedBox(height: 20),
                if (_presenter.showFeatureToggle) ...[
                  _buildFeaturedSection(),
                  SizedBox(height: 20),
                ],
                if (isPlatformSelectionFeatureEnabled) ...[
                  _buildPlatformSelectionSection(),
                  SizedBox(height: 20),
                ],
                if (canBuildParticipantCountSection) ...[
                  _buildParticipantCountSection(),
                  SizedBox(height: 20),
                ],
                _buildParticipantsSection(),
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

  Widget _buildDiscussionTypeSection() {
    return Column(
      children: List.generate(
        DiscussionType.values.length,
        (index) {
          final discussionType = DiscussionType.values[index];
          final title = _presenter.getDiscussionTypeTitle(discussionType);

          return AppRadioListTile<DiscussionType>(
            value: discussionType,
            groupValue: _model.discussion.discussionType,
            text: title,
            onChanged: (value) => _presenter.updateDiscussionType(value),
          );
        },
      ),
    );
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
            _model.discussion.image,
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
      initialValue: _model.discussion.title,
      maxLines: 2,
      maxLength: 60,
      hideCounter: true,
      onChanged: (value) => _presenter.updateTitle(value),
    );
  }

  Widget _buildDescriptionSection() {
    return JuntoTextField(
      labelText: 'Description',
      initialValue: _model.discussion.description,
      onChanged: (value) => _presenter.updateDescription(value),
    );
  }

  Widget _buildIsPublicSection() {
    return CustomSwitchTile(
      val: _model.discussion.isPublic,
      text: 'Public',
      onUpdate: (value) => _presenter.updateIsPublic(value),
    );
  }

  Widget _buildDateSection() {
    final date = _model.discussion.scheduledTime;
    final String dateString;

    if (date == null) {
      dateString = 'MM/DD/YY';
    } else {
      dateString = date.getFormattedTime(format: 'MM/dd/yyyy');
    }

    return JuntoTextField(
      key: Key(dateString),
      labelText: 'Date',
      readOnly: true,
      initialValue: dateString,
      maxLength: null,
      onTap: () async {
        final now = clock.now();
        final DateTime? dateTime = await showDatePicker(
          context: context,
          lastDate: DateTime(2101),
          initialDate: _model.discussion.scheduledTime ?? now,
          firstDate: now,
        );

        if (dateTime != null) {
          _presenter.updateDate(dateTime);
        }
      },
    );
  }

  Widget _buildTimeSection() {
    final date = _model.discussion.scheduledTime;
    final String timeString;

    if (date == null) {
      timeString = 'HH : MM';
    } else {
      timeString = date.getFormattedTime(format: 'hh:mm a');
    }
    return JuntoTextField(
      key: Key(timeString),
      labelText: 'Time',
      readOnly: true,
      initialValue: timeString,
      onTap: () async {
        final now = clock.now();
        final TimeOfDay? timeOfDay = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(_model.discussion.scheduledTime ?? now),
        );

        if (timeOfDay != null) {
          _presenter.updateTime(timeOfDay);
        }
      },
    );
  }

  Widget _buildDurationSection() {
    final duration = Duration(minutes: _model.discussion.durationInMinutes);
    final durationFound = _presenter.durationOptions.contains(duration);

    return DropdownButtonFormField<Duration>(
      value: durationFound ? duration : null,
      isExpanded: true,
      isDense: true,
      hint: JuntoText(
        'Choose duration',
        style: AppTextStyle.bodySmall.copyWith(
          color: AppColor.gray1,
        ),
      ),
      icon: Icon(
        CupertinoIcons.chevron_down,
        color: AppColor.darkBlue,
      ),
      iconSize: 20,
      elevation: 16,
      decoration: InputDecoration(
        fillColor: AppColor.white,
        filled: true,
        label: JuntoText(
          'Length',
          style: AppTextStyle.bodySmall.copyWith(
            color: AppColor.gray4,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: AppColor.gray4),
        ),
      ),
      iconEnabledColor: AppColor.darkBlue,
      onChanged: (value) {
        if (value != null) {
          _presenter.updateEventDuration(value);
        }
      },
      items: [
        for (final duration in _presenter.durationOptions)
          DropdownMenuItem<Duration>(
            value: duration,
            enabled: true,
            child: Container(
              // Add alignment, because by default it show on top
              alignment: Alignment.centerLeft,
              child: Text(
                durationString(duration, readAsHuman: true),
                style: AppTextStyle.body.copyWith(color: AppColor.darkBlue),
              ),
            ),
          )
      ],
    );
  }

  Widget _buildFeaturedSection() {
    return JuntoStreamBuilder<List<Featured>>(
      entryFrom: 'EditDiscussionDrawer._buildFeaturedSection',
      stream: _presenter.getFeaturedStream(),
      showLoading: false,
      builder: (_, featuredItems) {
        // Initialise only first time
        _model.isFeatured ??= _presenter.isFeatured(featuredItems);
        _model.initialFeatured ??= _presenter.isFeatured(featuredItems);

        return CustomSwitchTile(
          val: _model.isFeatured ?? false,
          text: 'Feature on homepage',
          onUpdate: (value) => _presenter.updateIsFeatured(value),
        );
      },
    );
  }

  Widget _buildParticipantCountSection() {
    final peopleCount = _model.discussion.maxParticipants ?? 0;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('Maximum'),
      trailing: Text('$peopleCount ${peopleCount == 1 ? 'person' : 'people'}'),
      onTap: () async {
        final isMobile = _presenter.isMobile(context);
        final maxParticipants = _model.discussion.maxParticipants ?? 8;

        final selectedNumber = await Dialogs.showSelectNumberDialog(
          context,
          isMobile: isMobile,
          title: 'Select max. participant count',
          minNumber: 2,
          maxNumber: 50,
          currentNumber: maxParticipants.toDouble(),
          buttonText: 'Update',
        );

        if (selectedNumber != null) {
          _presenter.updateMaxParticipants(selectedNumber);
        }
      },
    );
  }

  Widget _buildParticipantsSection() {
    return DiscussionPageParticipantsList(_model.discussion);
  }

  Widget _buildBottomButtonsSection() {
    return Column(
      children: [
        ActionButton(
          expand: true,
          text: 'Save Event',
          color: Theme.of(context).colorScheme.primary,
          textColor: Theme.of(context).colorScheme.secondary,
          onPressed: () => alertOnError(
            context,
            () => _presenter.saveChanges(),
          ),
        ),
        SizedBox(height: 20),
        ActionButton(
          expand: true,
          type: ActionButtonType.outline,
          textColor: AppColor.redLightMode,
          text: 'Cancel event',
          onPressed: () => alertOnError(context, () => _presenter.cancelEvent()),
        ),
      ],
    );
  }

  Widget _buildPlatformSelectionSection() {
    final PlatformItem _externalPlatform =
        _model.discussion.externalPlatform ?? PlatformItem(platformKey: PlatformKey.junto);

    return JuntoInkWell(
      onTap: () => CreateDiscussionDialog.show(
        context,
        pages: [CurrentPage.choosePlatform],
        discussionProvider: context.read<DiscussionProvider>(),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 40,
            width: 40,
            child: JuntoImage(
              null,
              asset: AppAsset(_externalPlatform.platformKey.info.logoUrl),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: JuntoText(
              _externalPlatform.platformKey != PlatformKey.junto
                  ? _externalPlatform.platformKey.info.title
                  : 'Frankly Video',
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.subhead,
            ),
          ),
          SizedBox(width: 10),
          if (_externalPlatform.platformKey != PlatformKey.junto)
            _buildCopyable(
              context: context,
              text: _externalPlatform.url ?? '',
            ),
        ],
      ),
    );
  }

  Widget _buildCopyable({required BuildContext context, required String text}) {
    return JuntoInkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: text));
        showRegularToast(context, 'Copied to clipboard!', toastType: ToastType.success);
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Icon(Icons.copy, size: 20),
      ),
    );
  }
}
