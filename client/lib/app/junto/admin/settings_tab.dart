import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:junto/app/home/creation_dialog/components/upgrade_perks.dart';
import 'package:junto/app/junto/junto_provider.dart';

import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/custom_switch_tile.dart';
import 'package:junto/common_widgets/junto_list_view.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/junto_app.dart';
import 'package:junto/utils/dialogs.dart';
import 'package:junto_models/analytics/analytics_entities.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';

import 'package:junto/utils/junto_text.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/junto.dart';

import 'package:junto_models/firestore/partner_agreement.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

class SettingsTab extends StatefulHookWidget {
  final void Function() onUpgradeTap;

  const SettingsTab({required this.onUpgradeTap});

  @override
  _SettingsTabState createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final blueBackground = AppColor.darkBlue.withOpacity(0.1);

  final whiteBackground = Colors.white70;

  Junto get junto => Provider.of<JuntoProvider>(context).junto;

  Widget _buildSettingsToggle(
    String title,
    bool value,
    void Function(dynamic) onUpdate,
    Color background, {
    bool hasWarning = false,
  }) {
    return Material(
      color: background,
      child: CustomSwitchTile(
        text: title,
        style: AppTextStyle.body.copyWith(color: hasWarning ? AppColor.redLightMode : null),
        val: value,
        onUpdate: onUpdate,
      ),
    );
  }

  Widget _buildSettingsSection() {
    final settings = Provider.of<JuntoProvider>(context).settings;
    final discussionSettings = Provider.of<JuntoProvider>(context).discussionSettings;
    return JuntoStreamBuilder<PartnerAgreement?>(
      stream: useMemoized(
        () => firestoreAgreementsService.getAgreementForJuntoStream(junto.id),
        [junto.id],
      ),
      entryFrom: '_SettingsTabState._buildSettingsSection',
      builder: (context, agreement) {
        final donationWarning = !(agreement?.stripeConnectedAccountActive ?? false) &&
            junto.settingsMigration.allowDonations;
        return Align(
          alignment: Alignment.topLeft,
          child: Container(
            constraints: BoxConstraints(maxWidth: 585),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Settings', style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: 8),
                _buildSettingsToggle(
                  'Allow members to create events',
                  !settings.dontAllowMembersToCreateMeetings,
                  (val) => _toggleCommunitySetting(settings.copyWith(
                      dontAllowMembersToCreateMeetings:
                          !settings.dontAllowMembersToCreateMeetings)),
                  blueBackground,
                ),
                _buildSettingsToggle(
                  'Allow members to create templates',
                  settings.allowUnofficialTopics,
                  (val) => _toggleCommunitySetting(
                      settings.copyWith(allowUnofficialTopics: !settings.allowUnofficialTopics)),
                  whiteBackground,
                ),
                _buildSettingsToggle(
                  'Require approval for new members',
                  settings.requireApprovalToJoin,
                  (val) => _toggleCommunitySetting(
                      settings.copyWith(requireApprovalToJoin: !settings.requireApprovalToJoin)),
                  blueBackground,
                ),
                _buildSettingsToggle(
                  'Enable weekly email digests of upcoming events',
                  !settings.disableEmailDigests,
                  (val) => _toggleCommunitySetting(
                      settings.copyWith(disableEmailDigests: !settings.disableEmailDigests)),
                  whiteBackground,
                ),
                if (kShowStripeFeatures ? agreement?.allowPayments ?? false : false) ...[
                  _buildSettingsToggle(
                    'Allow users to donate funds${donationWarning ? ' *' : ''}',
                    settings.allowDonations,
                    (val) => _toggleCommunitySetting(
                        settings.copyWith(allowDonations: !settings.allowDonations)),
                    blueBackground,
                    hasWarning: donationWarning,
                  ),
                  if (donationWarning)
                    JuntoText(
                      '* Your payee account has not been fully set up, so donations will not '
                      'currently be accepted. You may need to link a bank account or accept '
                      'Stripe\'s terms of service.',
                      style: TextStyle(color: AppColor.redLightMode),
                    ),
                  SizedBox(height: 8),
                  _buildStripeConnectLink(context, agreement!),
                ],
                SizedBox(height: 30),
                JuntoText('Default event settings', style: AppTextStyle.subhead),
                _buildSettingsToggle(
                  'Chat',
                  discussionSettings.chat ?? true,
                  (val) => _toggleDiscussionSetting(
                    discussionSettings.copyWith(chat: !(discussionSettings.chat ?? true)),
                  ),
                  whiteBackground,
                ),
                _buildSettingsToggle(
                  'Floating Chat',
                  discussionSettings.showChatMessagesInRealTime ?? true,
                  (val) => _toggleDiscussionSetting(
                    discussionSettings.copyWith(
                        showChatMessagesInRealTime:
                            !(discussionSettings.showChatMessagesInRealTime ?? true)),
                  ),
                  blueBackground,
                ),
                _buildSettingsToggle(
                  'Record',
                  discussionSettings.alwaysRecord ?? true,
                  (val) => _toggleDiscussionSetting(
                    discussionSettings.copyWith(
                        alwaysRecord: !(discussionSettings.alwaysRecord ?? true)),
                  ),
                  whiteBackground,
                ),
                _buildSettingsToggle(
                  'Odometer',
                  discussionSettings.talkingTimer ?? true,
                  (val) => _toggleDiscussionSetting(
                    discussionSettings.copyWith(
                        talkingTimer: !(discussionSettings.talkingTimer ?? true)),
                  ),
                  blueBackground,
                ),
                _buildSettingsToggle(
                  'Agenda preview',
                  discussionSettings.agendaPreview ?? true,
                  (val) => _toggleDiscussionSetting(
                    discussionSettings.copyWith(
                        agendaPreview: !(discussionSettings.agendaPreview ?? true)),
                  ),
                  whiteBackground,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleCommunitySetting(CommunitySettings communitySettings) {
    return cloudFunctionsService.updateJunto(UpdateJuntoRequest(
      junto: context.read<JuntoProvider>().junto.copyWith(communitySettings: communitySettings),
      keys: [Junto.kFieldCommunitySettings],
    ));
  }

  Future<void> _toggleDiscussionSetting(DiscussionSettings discussionSettings) {
    return cloudFunctionsService.updateJunto(UpdateJuntoRequest(
        junto: context.read<JuntoProvider>().junto.copyWith(discussionSettings: discussionSettings),
        keys: [Junto.kFieldDiscussionSettings]));
  }

  Widget _buildStripeConnectLink(BuildContext context, PartnerAgreement agreement) {
    return ActionButton(
      text: '${agreement.stripeConnectedAccountId == null ? 'Set' : 'Edit'} Linked Payee Account',
      onPressed: () => alertOnError(context, () => _stripeButtonPressed(agreement)),
      sendingIndicatorAlign: ActionButtonSendingIndicatorAlign.right,
    );
  }

  Widget _buildDevSettingsSection() {
    final settingsMap = context.watch<JuntoProvider>().settings.toJson();
    final settings = settingsMap.keys.where((element) => settingsMap[element] is bool).toList();

    final discussionSettingsMap = context.watch<JuntoProvider>().discussionSettings.toJson();
    final discussionSettings =
        discussionSettingsMap.keys.where((element) => settingsMap[element] is bool?).toList();

    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dev Settings - Community Settings',
                style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 8),
            for (var i = 0; i < settings.length; i++)
              _devCommunitySettingsToggle(
                settings[i],
                settingsMap,
                i.isEven ? whiteBackground : blueBackground,
              ),
            SizedBox(height: 20),
            Text('Dev Settings - Default Event Settings',
                style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 8),
            for (var i = 0; i < discussionSettings.length; i++)
              _devDiscussionSettingsToggle(
                discussionSettings[i],
                discussionSettingsMap,
                i.isEven ? whiteBackground : blueBackground,
              ),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _devCommunitySettingsToggle(
    String settingKey,
    Map<String, dynamic> settingMap,
    Color background,
  ) {
    final newSettings = Map<String, dynamic>.from(settingMap)
      ..addEntries([
        MapEntry<String, bool>(
          settingKey,
          !(settingMap[settingKey] ?? true),
        )
      ]);

    return _buildSettingsToggle(
      settingKey,
      settingMap[settingKey] ?? true,
      (val) => _toggleCommunitySetting(CommunitySettings.fromJson(newSettings)),
      background,
    );
  }

  Widget _devDiscussionSettingsToggle(
    String settingKey,
    Map<String, dynamic> settingMap,
    Color background,
  ) {
    final newSettings = {
      ...settingMap,
      settingKey: !(settingMap[settingKey] ?? true),
    };

    return _buildSettingsToggle(
      settingKey,
      settingMap[settingKey] ?? true,
      (val) => _toggleDiscussionSetting(DiscussionSettings.fromJson(newSettings)),
      background,
    );
  }

  Future<void> _stripeButtonPressed(PartnerAgreement agreement) async {
    final juntoProvider = Provider.of<JuntoProvider>(context, listen: false);
    if (agreement.stripeConnectedAccountId == null) {
      final accepted = await Dialogs.showAcceptTakeRateDialog(context, juntoProvider);
      if (!accepted) {
        return;
      }

      await cloudFunctionsService.createStripeConnectedAccount(
          CreateStripeConnectedAccountRequest(agreementId: agreement.id));
      analytics.logEvent(AnalyticsLinkStripeAccountEvent());
    }

    final response = await cloudFunctionsService.getStripeConnectedAccountLink(
        GetStripeConnectedAccountLinkRequest(
            agreementId: agreement.id, responsePath: 'space/${agreement.juntoId}/admin'));

    html.window.location.assign(response.url);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = responsiveLayoutService.isMobile(context);

    if (isMobile) {
      return _buildMobileLayout();
    } else {
      return _buildDesktopLayout();
    }
  }

  Widget _buildMobileLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSettings(),
        SizedBox(height: 40),
        UpgradePerks(onUpgradeTap: () => widget.onUpgradeTap()),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 5, child: _buildSettings()),
        Spacer(),
        Expanded(
          flex: 2,
          child: UpgradePerks(
            onUpgradeTap: () => widget.onUpgradeTap(),
          ),
        ),
      ],
    );
  }

  Widget _buildSettings() {
    return JuntoListView(
      children: [
        _buildSettingsSection(),
        SizedBox(height: 80),
        if (isDev) ContentHorizontalPadding(child: _buildDevSettingsSection()),
        if (userService.isUnverifiedSuperAdmin)
          ActionButton(
            text: 'Send Email Verification',
            onPressed: () => userService.verifyEmail(),
          ),
      ],
    );
  }
}
