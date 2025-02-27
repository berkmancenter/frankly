import 'package:client/core/utils/toast_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/views/agenda_item_image.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/views/agenda_item_poll.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/views/agenda_item_text.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/views/agenda_item_user_suggestions.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/views/agenda_item_video.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/widgets/agenda_item_word_cloud.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/providers/meeting_agenda_provider.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/confirm_dialog.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/core/widgets/ui_migration.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/widgets/time_input_form.dart';
import 'package:client/services.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/utils/extensions.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:provider/provider.dart';

import 'agenda_item_contract.dart';
import '../../data/models/agenda_item_model.dart';
import '../agenda_item_presenter.dart';

enum WordCloudViewType { list, cloud, mine }

class AgendaItemCard extends StatefulWidget {
  final AgendaItem agendaItem;

  const AgendaItemCard({
    Key? key,
    required this.agendaItem,
  }) : super(key: key);

  @override
  _AgendaItemCardState createState() => _AgendaItemCardState();
}

class _AgendaItemCardState extends State<AgendaItemCard>
    implements AgendaItemView {
  late AgendaItemModel _model;
  late AgendaItemPresenter _presenter;

  void _init() {
    _model = AgendaItemModel(widget.agendaItem);
    _presenter = AgendaItemPresenter(context, this, _model);
    _presenter.init();
  }

  @override
  void initState() {
    super.initState();

    _init();

    if (_presenter.isCardUnsaved()) {
      _presenter.toggleEditMode();

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Scrollable.ensureVisible(context);
      });
    }
  }

  @override
  void didUpdateWidget(AgendaItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.agendaItem != widget.agendaItem) {
      _init();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AgendaProvider>(
      builder: (_, __, ___) {
        return ReorderableItem(
          key: Key(_model.agendaItem.id),
          childBuilder: (context, state) => state == ReorderableItemState.normal
              ? _buildCard()
              : Opacity(opacity: 0.4, child: _buildCard()),
        );
      },
    );
  }

  @override
  void updateView() {
    setState(() {});
  }

  Widget _buildCard() {
    final bool isCollapsed = _presenter.isCollapsed();
    final bool allowEdit = _presenter.doesAllowEdit();

    return CustomInkWell(
      onTap: () => _presenter.toggleCardExpansion(),
      hoverColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: AppColor.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTopSection(),
            if (!isCollapsed) ...[
              SizedBox(height: 30),
              Padding(
                padding: EdgeInsets.only(
                  bottom: allowEdit ? 6 : 16,
                  left: 16,
                  right: 16,
                ),
                child: _buildCardFields(),
              ),
              SizedBox(height: 30),
              if (allowEdit) _buildBottomSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    final isCardActive = _presenter.isCardActive();
    final isCompleted = _presenter.isCompleted();
    final isCollapsed = _presenter.isCollapsed();
    final allowEdit = _presenter.doesAllowEdit();
    final isEditMode = _model.isEditMode;
    final canReorder =
        _presenter.canReorder(allowEdit, isEditMode, isCompleted, isCardActive);
    final agendaItemType = _model.agendaItem.type;
    final title = _presenter.getTitle();
    final formattedTime =
        Duration(seconds: _model.agendaItem.timeInSeconds ?? 0)
            .getFormattedTime(showHours: false);
    final isMobile = responsiveLayoutService.isMobile(context);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (canReorder)
                // Have reordering linked only to specific widget.
                // We cannot have it liked to overall Row, because there is some logical glitch
                // that when row is clicked - it's expanded and then it gets immediately collapsed
                // or vice-versa. Therefore for now, only do reordering if dragging this particular
                // widget (Icon).
                ReorderableListener(
                  canStart: () {
                    _presenter.reorder();
                    return true;
                  },
                  child: Icon(
                    Icons.reorder,
                    size: 24,
                    color: AppColor.darkBlue,
                  ),
                ),
              SizedBox(width: 8),
              ProxiedImage(
                null,
                asset: agendaItemType.pngIconPath,
                width: 24,
                height: 24,
              ),
              SizedBox(width: 10),
              Expanded(
                child: HeightConstrainedText(
                  title,
                  style: AppTextStyle.headline4.copyWith(color: AppColor.gray1),
                ),
              ),
              if (!_model.isEditMode && !isMobile) ...[
                HeightConstrainedText(
                  formattedTime,
                  style: AppTextStyle.body.copyWith(color: AppColor.gray2),
                ),
                SizedBox(width: 10),
                ProxiedImage(
                  null,
                  asset: AppAsset.clock(),
                  width: 20,
                  height: 20,
                ),
                SizedBox(width: 20),
              ],
              // Currently when we are in Edit mode and click to collapse - we cannot.
              // Therefore hiding icon in order to indicate that the card is not collapsable
              Icon(
                isCollapsed ? Icons.expand_more : Icons.expand_less,
                color: AppColor.darkBlue,
              ),
            ],
          ),
          if (!isCollapsed && _model.isEditMode) ...[
            SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.spaceBetween,
              children: [
                _buildDropDownButton(),
                TimeInputForm(
                  isWhiteBackground: true,
                  duration: Duration(
                    seconds: _model.agendaItem.timeInSeconds ??
                        AgendaItem.kDefaultTimeInSeconds,
                  ),
                  onUpdate: (duration) => _presenter.updateTime(duration),
                  isClockShowing: true,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIconAndText(AgendaItemType agendaItemType) {
    return Row(
      children: [
        SizedBox(width: 8),
        ProxiedImage(
          null,
          asset: agendaItemType.pngIconPath,
          width: 24,
          height: 24,
        ),
        SizedBox(width: 8),
        HeightConstrainedText(
          agendaItemType.text,
          style: AppTextStyle.body.copyWith(color: AppColor.darkerBlue),
        ),
      ],
    );
  }

  Widget _buildDropDownButton() {
    final List<AgendaItemType> values = AgendaItemType.values.toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.gray4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<AgendaItemType>(
        alignment: Alignment.centerLeft,
        isExpanded: false,
        underline: SizedBox.shrink(),
        value: _model.agendaItem.type,
        icon: Icon(
          Icons.keyboard_arrow_down,
          size: 24,
          color: AppColor.darkBlue,
        ),
        selectedItemBuilder: (context) {
          return [
            for (final agendaItemType in values)
              Container(
                // Add alignment, because by default it show on top
                alignment: Alignment.centerLeft,
                child: _buildIconAndText(agendaItemType),
              ),
          ];
        },
        items: values.map((agendaItemType) {
          return DropdownMenuItem<AgendaItemType>(
            value: agendaItemType,
            // Button which is in the selection list (when expanded)
            child: _buildIconAndText(agendaItemType),
          );
        }).toList(),
        // Whenever button from dropdown is changed
        onChanged: (AgendaItemType? agendaItemType) async {
          if (agendaItemType != null &&
              _model.agendaItem.type != agendaItemType) {
            _presenter.changeAgendaType(agendaItemType);
          }
        },
      ),
    );
  }

  Widget _buildCardFields() {
    final agendaItemType = _model.agendaItem.type;

    final isEditMode = _model.isEditMode;

    switch (agendaItemType) {
      case AgendaItemType.text:
        return AgendaItemText(
          isEditMode: isEditMode,
          agendaItemTextData: _model.agendaItemTextData,
          onChanged: (data) => _presenter.updateAgendaItemTextData(data),
        );
      case AgendaItemType.video:
        return AgendaItemVideo(
          isEditMode: isEditMode,
          agendaItemVideoData: _model.agendaItemVideoData,
          onChanged: (data) => _presenter.updateAgendaItemVideoData(data),
        );
      case AgendaItemType.image:
        return AgendaItemImage(
          isEditMode: isEditMode,
          agendaItemImageData: _model.agendaItemImageData,
          onChanged: (data) => _presenter.updateAgendaItemImageData(data),
        );
      case AgendaItemType.poll:
        return AgendaItemPoll(
          isEditMode: isEditMode,
          agendaItemPollData: _model.agendaItemPollData,
          onChanged: (data) => _presenter.updateAgendaItemPollData(data),
        );
      case AgendaItemType.wordCloud:
        return AgendaItemWordCloud(
          isEditMode: isEditMode,
          wordCloudData: _model.agendaItemWordCloudData,
          onChanged: (data) => _presenter.updateAgendaItemWordCloudData(data),
        );
      case AgendaItemType.userSuggestions:
        return AgendaItemUserSuggestions(
          isEditMode: isEditMode,
          userSuggestionsData: _model.agendaItemUserSuggestionsData,
          onChanged: (data) =>
              _presenter.updateAgendaItemUserSuggestionsData(data),
        );
    }
  }

  Widget _buildBottomSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(height: 1, thickness: 1, color: AppColor.gray5),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: _model.isEditMode
              ? _buildEditBottomSection()
              : _buildPreviewBottomSection(),
        ),
      ],
    );
  }

  Future<void> _showDeleteDialog() async {
    final delete = await ConfirmDialog(
      title: 'Delete Agenda Item',
      mainText: 'Are you sure you want to delete?',
    ).show(context: context);

    if (delete) {
      await alertOnError(context, () => _presenter.deleteAgendaItem());
    }
  }

  Widget _buildEditBottomSection() {
    final hasBeenEdited = _presenter.hasBeenEdited();
    final isCardUnsaved = _presenter.isCardUnsaved();

    return UIMigration(
      child: Row(
        children: [
          if (!isCardUnsaved)
            FloatingActionButton(
              tooltip: 'Delete Agenda Item',
              elevation: 0,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: AppColor.gray6,
              child: Icon(
                CupertinoIcons.delete,
                color: AppColor.darkBlue,
              ),
              onPressed: () => _showDeleteDialog(),
            ),
          Spacer(),
          FloatingActionButton(
            tooltip: 'Cancel',
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            backgroundColor: AppColor.gray6,
            elevation: 0,
            child: Icon(
              Icons.close,
              color: AppColor.darkBlue,
            ),
            onPressed: () async {
              if (hasBeenEdited) {
                final isDiscardChangesConfirmed = await ConfirmDialog(
                  mainText: 'Are you sure you want to discard changes?',
                ).show(context: context);

                if (isDiscardChangesConfirmed) {
                  _presenter.cancelChanges();
                }
              } else {
                _presenter.cancelChanges();
              }
            },
          ),
          SizedBox(width: 10),
          FloatingActionButton(
            tooltip: 'Save Agenda Item',
            elevation: 0,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            backgroundColor: hasBeenEdited || isCardUnsaved
                ? AppColor.darkBlue
                : AppColor.gray6,
            onPressed: hasBeenEdited || isCardUnsaved
                ? () => alertOnError(context, () => _presenter.saveContent())
                : null,
            child: Icon(
              Icons.check,
              color: hasBeenEdited || isCardUnsaved
                  ? AppColor.white
                  : AppColor.gray4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewBottomSection() {
    return UIMigration(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: [
          FloatingActionButton(
            tooltip: 'Duplicate Item',
            backgroundColor: AppColor.gray6,
            elevation: 0,
            child: Icon(
              Icons.copy,
              color: AppColor.darkBlue,
            ),
            onPressed: () => _presenter.duplicateCard(),
          ),
          SizedBox(width: 10),
          FloatingActionButton(
            tooltip: 'Edit Item',
            elevation: 0,
            backgroundColor: AppColor.gray6,
            child: Icon(
              Icons.edit,
              color: AppColor.darkBlue,
            ),
            onPressed: () => _presenter.toggleEditMode(),
          ),
        ],
      ),
    );
  }

  @override
  void showMessage(String message, {ToastType toastType = ToastType.neutral}) {
    showRegularToast(context, message, toastType: toastType);
  }
}
