import 'package:client/core/utils/toast_utils.dart';
import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:client/features/events/features/event_page/data/models/event_settings_model.dart';
import 'package:client/features/events/features/event_page/presentation/event_settings_presenter.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/buttons/app_clickable_widget.dart';
import 'package:client/core/widgets/custom_switch_tile.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_list_view.dart';
import 'package:client/config/environment.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/core/utils/dialogs.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/events/event.dart';
import 'package:provider/provider.dart';
import 'package:simple_tooltip/simple_tooltip.dart';
import 'package:client/core/localization/localization_helper.dart';

import 'event_settings_contract.dart';

enum EventSettingsDrawerType {
  template,
  event,
}

class EventSettingsDrawer extends StatefulWidget {
  final EventSettingsDrawerType eventSettingsDrawerType;

  const EventSettingsDrawer({
    required this.eventSettingsDrawerType,
    Key? key,
  }) : super(key: key);

  @override
  State<EventSettingsDrawer> createState() => _EventSettingsDrawerState();
}

class _EventSettingsDrawerState extends State<EventSettingsDrawer>
    implements EventSettingsView {
  late final EventSettingsModel _model;
  late final EventSettingsPresenter _presenter;

  @override
  void initState() {
    super.initState();

    _model = EventSettingsModel(widget.eventSettingsDrawerType);
    _presenter = EventSettingsPresenter(context, this, _model);
    _presenter.init();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppDrawerProvider>();

    return Material(
      color: context.theme.colorScheme.surfaceContainerLowest,
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    final floatingChatToggleValue = _presenter.getFloatingChatToggleValue();
    final title = _presenter.getTitle();
    final restoreDefaultButtonEnabled =
        _presenter.isDefaultSettingsButtonEnabled;
    return Container(
      width: AppSize.kSidebarWidth,
      color: context.theme.colorScheme.surfaceContainerLowest,
      child: CustomListView(
        padding: const EdgeInsets.all(30),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              HeightConstrainedText(
                title,
                style: context.theme.textTheme.headlineSmall,
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
          SizedBox(height: 40),
          _SwitchAndTooltip(
            onUpdate: (isSelected) => _presenter.updateSetting(
              EventSettings.kFieldChat,
              isSelected,
            ),
            text: context.l10n.chat,
            val: _model.eventSettings.chat ?? false,
            isIndicatorShown: _presenter
                .isSettingNotDefaultIndicatorShown((settings) => settings.chat),
          ),
          SizedBox(height: 16),
          _SwitchAndTooltip(
            onUpdate: (isSelected) => _presenter.updateSetting(
              EventSettings.kFieldShowChatMessagesInRealTime,
              isSelected,
            ),
            text: context.l10n.floatingChat,
            val: floatingChatToggleValue,
            isIndicatorShown: _presenter.isSettingNotDefaultIndicatorShown(
              (settings) => settings.showChatMessagesInRealTime,
            ),
          ),
          SizedBox(height: 16),
          _SwitchAndTooltip(
            onUpdate: (isSelected) => _presenter.updateSetting(
              EventSettings.kFieldAlwaysRecord,
              isSelected,
            ),
            text: context.l10n.record,
            val: _model.eventSettings.alwaysRecord ?? false,
            isIndicatorShown: _presenter.isSettingNotDefaultIndicatorShown(
              (settings) => settings.alwaysRecord,
            ),
          ),
          SizedBox(height: 16),
          _SwitchAndTooltip(
            onUpdate: (isSelected) => _presenter.updateSetting(
              EventSettings.kFieldTalkingTimer,
              isSelected,
            ),
            text: context.l10n.odometer,
            val: _model.eventSettings.talkingTimer ?? false,
            isIndicatorShown: _presenter.isSettingNotDefaultIndicatorShown(
              (settings) => settings.talkingTimer,
            ),
          ),
          SizedBox(height: 16),
          CustomSwitchTile(
            onUpdate: (isSelected) => _presenter.updateSetting(
              EventSettings.kFieldAgendaPreview,
              isSelected,
            ),
            text: context.l10n.previewAgenda,
            val: _model.eventSettings.agendaPreview ?? true,
            style: context.theme.textTheme.bodyMedium,
          ),
          SizedBox(height: 40),
          ActionButton(
            expand: true,
            text: context.l10n.saveSettings,
            onPressed: () => _presenter.saveSettings(),
            color: context.theme.colorScheme.primary,
            textColor: context.theme.colorScheme.onPrimary,
          ),
          SizedBox(height: 16),
          ActionButton(
            expand: true,
            type: ActionButtonType.filled,
            color: context.theme.colorScheme.surfaceContainer,
            textColor: context.theme.colorScheme.onSurface,
            text: context.l10n.restoreSettings,
            onPressed: restoreDefaultButtonEnabled
                ? _presenter.restoreDefaultSettings
                : null,
          ),
          if (Environment.enableDevEventSettings) ...[
            SizedBox(height: 40),
            HeightConstrainedText(
              context.l10n.devSettings,
              style: context.theme.textTheme.headlineSmall!,
            ),
            SizedBox(height: 40),
            for (final feature in _model.eventSettings.toJson().keys.toList())
              CustomSwitchTile(
                onUpdate: (isSelected) =>
                    _presenter.updateSetting(feature, isSelected),
                text: feature,
                val: _model.eventSettings.toJson()[feature] ?? false,
                style: context.theme.textTheme.bodyMedium,
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
    final bool isConstrainedHorizontally =
        MediaQuery.of(context).size.width < 475;
    return GestureDetector(
      onTap: activateTooltip,
      child: MouseRegion(
        onEnter: (_) => activateTooltip(),
        child: SimpleTooltip(
          tooltipDirection: isConstrainedHorizontally
              ? TooltipDirection.right
              : TooltipDirection.up,
          animationDuration: const Duration(milliseconds: 250),
          borderWidth: 0,
          ballonPadding: const EdgeInsets.all(8),
          content: HeightConstrainedText(
            context.l10n.changedFromDefault,
            style: context.theme.textTheme.bodyMedium,
            textAlign: TextAlign.left,
          ),
          show: _visible,
          child: Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.theme.colorScheme.primary,
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
        HeightConstrainedText(
          text,
          style: context.theme.textTheme.bodyMedium,
          maxLines: 2,
        ),
      ],
    );
  }
}
