import 'package:client/core/utils/date_utils.dart';
import 'package:client/core/utils/toast_utils.dart';
import 'package:clock/clock.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:client/features/events/features/create_event/presentation/views/create_event_dialog.dart';
import 'package:client/features/events/features/create_event/data/providers/create_event_dialog_model.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/events/data/models/platform_data.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/action_button.dart';
import 'package:client/core/widgets/app_clickable_widget.dart';
import 'package:client/features/events/features/edit_event/presentation/widgets/app_radio_list_tile.dart';
import 'package:client/core/widgets/custom_switch_tile.dart';
import 'package:client/features/events/presentation/widgets/event_participants_list.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/core/widgets/ui_migration.dart';
import 'package:client/config/environment.dart';
import 'package:client/core/data/services/media_helper_service.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/utils/dialogs.dart';
import 'package:client/core/utils/extensions.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/community/community.dart';
import 'package:provider/provider.dart';

import 'edit_event_contract.dart';
import '../../data/models/edit_event_model.dart';
import '../edit_event_presenter.dart';

class EditEventDrawer extends StatefulWidget {
  const EditEventDrawer({Key? key}) : super(key: key);

  @override
  _EditEventDrawerState createState() => _EditEventDrawerState();
}

class _EditEventDrawerState extends State<EditEventDrawer>
    implements EditEventView {
  final ScrollController _scrollController = ScrollController();
  late final EditEventModel _model;
  late final EditEventPresenter _presenter;

  @override
  void initState() {
    super.initState();

    _model = EditEventModel();
    _presenter = EditEventPresenter(context, this, _model);
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
    final isPlatformSelectionFeatureEnabled =
        _presenter.isPlatformSelectionFeatureEnabled();
    final canBuildParticipantCountSection =
        _presenter.canBuildParticipantCountSection();

    return UIMigration(
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
                  style: AppTextStyle.headlineSmall
                      .copyWith(fontSize: 16, color: AppColor.black),
                ),
                Semantics(
                  label: 'Close Edit',
                  child: AppClickableWidget(
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
                _buildEventTypeSection(),
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

  Widget _buildEventTypeSection() {
    return Column(
      children: List.generate(
        EventType.values.length,
        (index) {
          final eventType = EventType.values[index];
          final title = _presenter.getEventTypeTitle(eventType);

          return AppRadioListTile<EventType>(
            value: eventType,
            groupValue: _model.event.eventType,
            text: title,
            onChanged: (value) => _presenter.updateEventType(value),
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
            final url = await GetIt.instance<MediaHelperService>()
                .pickImageViaCloudinary();
            if (url != null) {
              _presenter.updateImage(url);
            }
          }),
          child: ProxiedImage(
            _model.event.image,
            width: 30,
            height: 30,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return CustomTextField(
      labelText: 'Title',
      initialValue: _model.event.title,
      maxLines: 2,
      maxLength: 60,
      hideCounter: true,
      onChanged: (value) => _presenter.updateTitle(value),
    );
  }

  Widget _buildDescriptionSection() {
    return CustomTextField(
      labelText: 'Description',
      initialValue: _model.event.description,
      onChanged: (value) => _presenter.updateDescription(value),
    );
  }

  Widget _buildIsPublicSection() {
    return CustomSwitchTile(
      val: _model.event.isPublic,
      text: 'Public',
      onUpdate: (value) => _presenter.updateIsPublic(value),
    );
  }

  Widget _buildDateSection() {
    final date = _model.event.scheduledTime;
    final String dateString;

    if (date == null) {
      dateString = 'MM/DD/YY';
    } else {
      dateString = date.getFormattedTime(format: 'MM/dd/yyyy');
    }

    return CustomTextField(
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
          initialDate: _model.event.scheduledTime ?? now,
          firstDate: now,
        );

        if (dateTime != null) {
          _presenter.updateDate(dateTime);
        }
      },
    );
  }

  Widget _buildTimeSection() {
    final date = _model.event.scheduledTime;
    final String timeString;

    if (date == null) {
      timeString = 'HH : MM';
    } else {
      timeString = date.getFormattedTime(format: 'hh:mm a');
    }
    return CustomTextField(
      key: Key(timeString),
      labelText: 'Time',
      readOnly: true,
      initialValue: timeString,
      onTap: () async {
        final now = clock.now();
        final TimeOfDay? timeOfDay = await showTimePicker(
          context: context,
          initialTime:
              TimeOfDay.fromDateTime(_model.event.scheduledTime ?? now),
        );

        if (timeOfDay != null) {
          _presenter.updateTime(timeOfDay);
        }
      },
    );
  }

  Widget _buildDurationSection() {
    final duration = Duration(minutes: _model.event.durationInMinutes);
    final durationFound = _presenter.durationOptions.contains(duration);

    return DropdownButtonFormField<Duration>(
      value: durationFound ? duration : null,
      isExpanded: true,
      isDense: true,
      hint: HeightConstrainedText(
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
        label: HeightConstrainedText(
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
          ),
      ],
    );
  }

  Widget _buildParticipantCountSection() {
    final peopleCount = _model.event.maxParticipants ?? 0;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('Maximum'),
      trailing: Text('$peopleCount ${peopleCount == 1 ? 'person' : 'people'}'),
      onTap: () async {
        final isMobile = _presenter.isMobile(context);
        final maxParticipants = _model.event.maxParticipants ?? 8;

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
    return EventPageParticipantsList(_model.event);
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
          onPressed: () =>
              alertOnError(context, () => _presenter.cancelEvent()),
        ),
      ],
    );
  }

  Widget _buildPlatformSelectionSection() {
    final PlatformItem externalPlatform = _model.event.externalPlatform ??
        PlatformItem(platformKey: PlatformKey.community);

    return CustomInkWell(
      onTap: () => CreateEventDialog.show(
        context,
        pages: [CurrentPage.choosePlatform],
        eventProvider: context.read<EventProvider>(),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 40,
            width: 40,
            child: ProxiedImage(
              null,
              asset: AppAsset(externalPlatform.platformKey.info.logoUrl),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: HeightConstrainedText(
              externalPlatform.platformKey != PlatformKey.community
                  ? externalPlatform.platformKey.info.title
                  : '${Environment.appName} Video',
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.subhead,
            ),
          ),
          SizedBox(width: 10),
          if (externalPlatform.platformKey != PlatformKey.community)
            _buildCopyable(
              context: context,
              text: externalPlatform.url ?? '',
            ),
        ],
      ),
    );
  }

  Widget _buildCopyable({required BuildContext context, required String text}) {
    return CustomInkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: text));
        showRegularToast(
          context,
          'Copied to clipboard!',
          toastType: ToastType.success,
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Icon(Icons.copy, size: 20),
      ),
    );
  }
}
