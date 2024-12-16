import 'package:flutter/material.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_settings/discussion_settings_model.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_settings/discussion_settings_presenter.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/app_clickable_widget.dart';
import 'package:junto/common_widgets/custom_switch_tile.dart';
import 'package:junto/common_widgets/junto_image.dart';
import 'package:junto/common_widgets/junto_list_view.dart';
import 'package:junto/junto_app.dart';
import 'package:junto/styles/app_asset.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/dialogs.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:provider/provider.dart';
import 'package:simple_tooltip/simple_tooltip.dart';

import 'discussion_settings_contract.dart';

enum DiscussionSettingsDrawerType {
  topic,
  discussion,
}

class DiscussionSettingsDrawer extends StatefulWidget {
  final DiscussionSettingsDrawerType discussionSettingsDrawerType;

  const DiscussionSettingsDrawer({
    required this.discussionSettingsDrawerType,
    Key? key,
  }) : super(key: key);

  @override
  State<DiscussionSettingsDrawer> createState() => _DiscussionSettingsDrawerState();
}

class _DiscussionSettingsDrawerState extends State<DiscussionSettingsDrawer>
    implements DiscussionSettingsView {
  late final DiscussionSettingsModel _model;
  late final DiscussionSettingsPresenter _presenter;

  @override
  void initState() {
    super.initState();

    _model = DiscussionSettingsModel(widget.discussionSettingsDrawerType);
    _presenter = DiscussionSettingsPresenter(context, this, _model);
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

  Widget _buildBody() {
    final floatingChatToggleValue = _presenter.getFloatingChatToggleValue();
    final title = _presenter.getTitle();
    final restoreDefaultButtonEnabled = _presenter.isDefaultSettingsButtonEnabled;
    return Container(
      width: AppSize.kSidebarWidth,
      color: AppColor.white,
      child: JuntoListView(
        padding: const EdgeInsets.all(30),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              JuntoText(
                title,
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
          SizedBox(height: 40),
          _SwitchAndTooltip(
            onUpdate: (isSelected) => _presenter.updateSetting(
              DiscussionSettings.kFieldChat,
              isSelected,
            ),
            text: 'Chat',
            val: _model.discussionSettings.chat ?? false,
            isIndicatorShown:
                _presenter.isSettingNotDefaultIndicatorShown((settings) => settings.chat),
          ),
          SizedBox(height: 16),
          _SwitchAndTooltip(
            onUpdate: (isSelected) => _presenter.updateSetting(
              DiscussionSettings.kFieldShowChatMessagesInRealTime,
              isSelected,
            ),
            text: 'Floating Chat',
            val: floatingChatToggleValue,
            isIndicatorShown: _presenter.isSettingNotDefaultIndicatorShown(
                (settings) => settings.showChatMessagesInRealTime),
          ),
          SizedBox(height: 16),
          _SwitchAndTooltip(
            onUpdate: (isSelected) => _presenter.updateSetting(
              DiscussionSettings.kFieldAlwaysRecord,
              isSelected,
            ),
            text: 'Record',
            val: _model.discussionSettings.alwaysRecord ?? false,
            isIndicatorShown:
                _presenter.isSettingNotDefaultIndicatorShown((settings) => settings.alwaysRecord),
          ),
          SizedBox(height: 16),
          _SwitchAndTooltip(
            onUpdate: (isSelected) => _presenter.updateSetting(
              DiscussionSettings.kFieldTalkingTimer,
              isSelected,
            ),
            text: 'Odometer',
            val: _model.discussionSettings.talkingTimer ?? false,
            isIndicatorShown:
                _presenter.isSettingNotDefaultIndicatorShown((settings) => settings.talkingTimer),
          ),
          SizedBox(height: 16),
          CustomSwitchTile(
            onUpdate: (isSelected) => _presenter.updateSetting(
              DiscussionSettings.kFieldAgendaPreview,
              isSelected,
            ),
            text: 'Preview agenda',
            val: _model.discussionSettings.agendaPreview ?? true,
          ),
          SizedBox(height: 40),
          ActionButton(
            expand: true,
            text: 'Save settings',
            onPressed: () => _presenter.saveSettings(),
            color: Theme.of(context).colorScheme.primary,
            textColor: Theme.of(context).colorScheme.secondary,
          ),
          SizedBox(height: 16),
          ActionButton(
            expand: true,
            type: ActionButtonType.outline,
            text: 'Restore settings',
            onPressed: restoreDefaultButtonEnabled ? _presenter.restoreDefaultSettings : null,
            textColor: restoreDefaultButtonEnabled
                ? Theme.of(context).colorScheme.primary
                : AppColor.gray3,
            borderSide: BorderSide(
                color: restoreDefaultButtonEnabled
                    ? Theme.of(context).colorScheme.primary
                    : AppColor.gray3),
          ),
          if (isDev) ...[
            SizedBox(height: 40),
            JuntoText(
              'Dev Settings',
              style: AppTextStyle.headlineSmall.copyWith(fontSize: 16, color: AppColor.gray1),
            ),
            SizedBox(height: 40),
            for (final feature in _model.discussionSettings.toJson().keys.toList())
              CustomSwitchTile(
                onUpdate: (isSelected) => _presenter.updateSetting(feature, isSelected),
                text: feature,
                val: _model.discussionSettings.toJson()[feature] ?? false,
              ),
          ],
        ],
      ),
    );
  }

  @override
  void closeDrawer() {
    Navigator.pop(context);
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

/// Holds the state of whether to show the tooltip over the switch
class _SwitchAndTooltip extends StatefulWidget {
  final void Function(bool) onUpdate;
  final bool val;
  final bool isIndicatorShown;
  final String text;

  const _SwitchAndTooltip({
    Key? key,
    required this.val,
    required this.isIndicatorShown,
    required this.onUpdate,
    required this.text,
  }) : super(key: key);

  @override
  _SwitchAndTooltipState createState() => _SwitchAndTooltipState();
}

class _SwitchAndTooltipState extends State<_SwitchAndTooltip> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return CustomSwitchTile(
      onUpdate: widget.onUpdate,
      textWidget: _buildSwitchText(widget.text, widget.isIndicatorShown),
      val: widget.val,
    );
  }

  void activateTooltip() async {
    if (!_visible) {
      setState(() => _visible = true);
      await Future.delayed(
        const Duration(seconds: 3),
        () {
          if (_visible && mounted) {
            setState(() => _visible = false);
          }
        },
      );
    }
  }

  Widget _buildIndicator() {
    const size = 6.0;
    final bool isConstrainedHorizontally = MediaQuery.of(context).size.width < 475;
    return GestureDetector(
      onTap: activateTooltip,
      child: MouseRegion(
        onEnter: (_) => activateTooltip(),
        child: SimpleTooltip(
          tooltipDirection:
              isConstrainedHorizontally ? TooltipDirection.right : TooltipDirection.up,
          animationDuration: const Duration(milliseconds: 250),
          borderWidth: 0,
          ballonPadding: const EdgeInsets.all(8),
          content: JuntoText(
            'This has been changed from\nthe default setting',
            style: AppTextStyle.eyebrowSmall,
            textAlign: TextAlign.left,
          ),
          show: _visible,
          child: Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColor.darkBlue,
              ),
              height: size,
              width: size,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchText(String text, bool isIndicatorShown) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isIndicatorShown) _buildIndicator(),
        JuntoText(
          text,
          style: AppTextStyle.body.copyWith(color: AppColor.gray1),
          maxLines: 2,
        )
      ],
    );
  }
}
