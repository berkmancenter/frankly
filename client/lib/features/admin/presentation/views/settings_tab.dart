import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/content_horizontal_padding.dart';
import 'package:client/features/admin/presentation/accept_take_rate_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:client/features/community/features/create_community/presentation/widgets/upgrade_perks.dart';
import 'package:client/features/community/data/providers/community_provider.dart';

import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/action_button.dart';
import 'package:client/core/widgets/custom_switch_tile.dart';
import 'package:client/core/widgets/custom_list_view.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/config/environment.dart';
import 'package:client/app.dart';
import 'package:client/core/utils/dialogs.dart';
import 'package:data_models/analytics/analytics_entities.dart';
import 'package:client/services.dart';
import 'package:client/styles/app_styles.dart';

import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/community/community.dart';

import 'package:data_models/admin/partner_agreement.dart';
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

  Community get community => Provider.of<CommunityProvider>(context).community;

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
        style: AppTextStyle.body
            .copyWith(color: hasWarning ? AppColor.redLightMode : null),
        val: value,
        onUpdate: onUpdate,
      ),
    );
  }

  Widget _buildSettingsSection() {
    final settings = Provider.of<CommunityProvider>(context).settings;
    final eventSettings = Provider.of<CommunityProvider>(context).eventSettings;
    return CustomStreamBuilder<PartnerAgreement?>(
      stream: useMemoized(
        () => firestoreAgreementsService
            .getAgreementForCommunityStream(community.id),
        [community.id],
      ),
      entryFrom: '_SettingsTabState._buildSettingsSection',
      builder: (context, agreement) {
        final donationWarning =
            !(agreement?.stripeConnectedAccountActive ?? false) &&
                community.settingsMigration.allowDonations;
        return Align(
          alignment: Alignment.topLeft,
          child: Container(
            constraints: BoxConstraints(maxWidth: 585),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 8),
                _buildSettingsToggle(
                  'Allow members to create events',
                  !settings.dontAllowMembersToCreateMeetings,
                  (val) => _toggleCommunitySetting(
                    settings.copyWith(
                      dontAllowMembersToCreateMeetings:
                          !settings.dontAllowMembersToCreateMeetings,
                    ),
                  ),
                  blueBackground,
                ),
                _buildSettingsToggle(
                  'Allow members to create templates',
                  settings.allowUnofficialTemplates,
                  (val) => _toggleCommunitySetting(
                    settings.copyWith(
                      allowUnofficialTemplates:
                          !settings.allowUnofficialTemplates,
                    ),
                  ),
                  whiteBackground,
                ),
                _buildSettingsToggle(
                  'Require approval for new members',
                  settings.requireApprovalToJoin,
                  (val) => _toggleCommunitySetting(
                    settings.copyWith(
                      requireApprovalToJoin: !settings.requireApprovalToJoin,
                    ),
                  ),
                  blueBackground,
                ),
                _buildSettingsToggle(
                  'Enable weekly email digests of upcoming events',
                  !settings.disableEmailDigests,
                  (val) => _toggleCommunitySetting(
                    settings.copyWith(
                      disableEmailDigests: !settings.disableEmailDigests,
                    ),
                  ),
                  whiteBackground,
                ),
                if (kShowStripeFeatures
                    ? agreement?.allowPayments ?? false
                    : false) ...[
                  _buildSettingsToggle(
                    'Allow users to donate funds${donationWarning ? ' *' : ''}',
                    settings.allowDonations,
                    (val) => _toggleCommunitySetting(
                      settings.copyWith(
                        allowDonations: !settings.allowDonations,
                      ),
                    ),
                    blueBackground,
                    hasWarning: donationWarning,
                  ),
                  if (donationWarning)
                    HeightConstrainedText(
                      '* Your payee account has not been fully set up, so donations will not '
                      'currently be accepted. You may need to link a bank account or accept '
                      'Stripe\'s terms of service.',
                      style: TextStyle(color: AppColor.redLightMode),
                    ),
                  SizedBox(height: 8),
                  _buildStripeConnectLink(context, agreement!),
                ],
                SizedBox(height: 30),
                HeightConstrainedText(
                  'Default event settings',
                  style: AppTextStyle.subhead,
                ),
                _buildSettingsToggle(
                  'Chat',
                  eventSettings.chat ?? true,
                  (val) => _toggleEventSetting(
                    eventSettings.copyWith(
                      chat: !(eventSettings.chat ?? true),
                    ),
                  ),
                  whiteBackground,
                ),
                _buildSettingsToggle(
                  'Floating Chat',
                  eventSettings.showChatMessagesInRealTime ?? true,
                  (val) => _toggleEventSetting(
                    eventSettings.copyWith(
                      showChatMessagesInRealTime:
                          !(eventSettings.showChatMessagesInRealTime ?? true),
                    ),
                  ),
                  blueBackground,
                ),
                _buildSettingsToggle(
                  'Record',
                  eventSettings.alwaysRecord ?? true,
                  (val) => _toggleEventSetting(
                    eventSettings.copyWith(
                      alwaysRecord: !(eventSettings.alwaysRecord ?? true),
                    ),
                  ),
                  whiteBackground,
                ),
                _buildSettingsToggle(
                  'Odometer',
                  eventSettings.talkingTimer ?? true,
                  (val) => _toggleEventSetting(
                    eventSettings.copyWith(
                      talkingTimer: !(eventSettings.talkingTimer ?? true),
                    ),
                  ),
                  blueBackground,
                ),
                _buildSettingsToggle(
                  'Agenda preview',
                  eventSettings.agendaPreview ?? true,
                  (val) => _toggleEventSetting(
                    eventSettings.copyWith(
                      agendaPreview: !(eventSettings.agendaPreview ?? true),
                    ),
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
    return cloudFunctionsCommunityService.updateCommunity(
      UpdateCommunityRequest(
        community: context
            .read<CommunityProvider>()
            .community
            .copyWith(communitySettings: communitySettings),
        keys: [Community.kFieldCommunitySettings],
      ),
    );
  }

  Future<void> _toggleEventSetting(EventSettings eventSettings) {
    return cloudFunctionsCommunityService.updateCommunity(
      UpdateCommunityRequest(
        community: context
            .read<CommunityProvider>()
            .community
            .copyWith(eventSettings: eventSettings),
        keys: [Community.kFieldEventSettings],
      ),
    );
  }

  Widget _buildStripeConnectLink(
    BuildContext context,
    PartnerAgreement agreement,
  ) {
    return ActionButton(
      text:
          '${agreement.stripeConnectedAccountId == null ? 'Set' : 'Edit'} Linked Payee Account',
      onPressed: () =>
          alertOnError(context, () => _stripeButtonPressed(agreement)),
      sendingIndicatorAlign: ActionButtonSendingIndicatorAlign.right,
    );
  }

  Widget _buildDevSettingsSection() {
    final settingsMap = context.watch<CommunityProvider>().settings.toJson();
    final settings = settingsMap.keys
        .where((element) => settingsMap[element] is bool)
        .toList();

    final eventSettingsMap =
        context.watch<CommunityProvider>().eventSettings.toJson();
    final eventSettings = eventSettingsMap.keys
        .where((element) => settingsMap[element] is bool?)
        .toList();

    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dev Settings - Community Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            for (var i = 0; i < settings.length; i++)
              _devCommunitySettingsToggle(
                settings[i],
                settingsMap,
                i.isEven ? whiteBackground : blueBackground,
              ),
            SizedBox(height: 20),
            Text(
              'Dev Settings - Default Event Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            for (var i = 0; i < eventSettings.length; i++)
              _devEventSettingsToggle(
                eventSettings[i],
                eventSettingsMap,
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
        ),
      ]);

    return _buildSettingsToggle(
      settingKey,
      settingMap[settingKey] ?? true,
      (val) => _toggleCommunitySetting(CommunitySettings.fromJson(newSettings)),
      background,
    );
  }

  Widget _devEventSettingsToggle(
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
      (val) => _toggleEventSetting(EventSettings.fromJson(newSettings)),
      background,
    );
  }

  Future<void> _stripeButtonPressed(PartnerAgreement agreement) async {
    final communityProvider =
        Provider.of<CommunityProvider>(context, listen: false);
    if (agreement.stripeConnectedAccountId == null) {
      final accepted = await AcceptTakeRatePresenter.showAcceptTakeRateDialog(
        context,
        communityProvider,
      );
      if (!accepted) {
        return;
      }

      await cloudFunctionsPaymentsService.createStripeConnectedAccount(
        CreateStripeConnectedAccountRequest(agreementId: agreement.id),
      );
      analytics.logEvent(AnalyticsLinkStripeAccountEvent());
    }

    final response =
        await cloudFunctionsPaymentsService.getStripeConnectedAccountLink(
      GetStripeConnectedAccountLinkRequest(
        agreementId: agreement.id,
        responsePath: 'space/${agreement.communityId}/admin',
      ),
    );

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
    return CustomListView(
      children: [
        _buildSettingsSection(),
        SizedBox(height: 80),
        if (Environment.enableDevAdminSettings)
          ContentHorizontalPadding(child: _buildDevSettingsSection()),
      ],
    );
  }
}
