import 'package:client/core/localization/localization_helper.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/features/admin/presentation/accept_take_rate_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:client/features/community/data/providers/community_provider.dart';

import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/custom_switch_tile.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/config/environment.dart';
import 'package:client/app.dart';
import 'package:data_models/analytics/analytics_entities.dart';
import 'package:client/services.dart';
import 'package:client/styles/styles.dart';

import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/community/community.dart';

import 'package:data_models/admin/partner_agreement.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

/// Enum to define the position of the toggle switch in settings
enum TogglePosition {
  none,
  top,
  bottom,
}

class SettingsTab extends StatefulHookWidget {
  const SettingsTab();

  @override
  _SettingsTabState createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final whiteBackground = Colors.white70;
  Community get community => Provider.of<CommunityProvider>(context).community;

  final _updateLoading = List.filled(11, false);

  Widget _buildSettingsToggle(
    String title,
    bool value,
    void Function(dynamic) onUpdate, {
    TogglePosition position = TogglePosition.none,
    bool hasWarning = false,
    int loadingIndex = 0,
    String supportingText = '',
  }) {
    // If the position is none, we don't need to apply any special border radius
    BorderRadius radius = BorderRadius.zero;
    if (position == TogglePosition.top) {
      radius = BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      );
    } else if (position == TogglePosition.bottom) {
      radius = BorderRadius.only(
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      );
    }
    return Material(
      shape: RoundedRectangleBorder(
        borderRadius: radius,
      ),
      color: hasWarning
          ? context.theme.colorScheme.error.withOpacity(0.1)
          : whiteBackground,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomSwitchTile(
              text: title,
              style: AppTextStyle.body.copyWith(
                color: hasWarning ? context.theme.colorScheme.error : null,
              ),
              val: value,
              onUpdate: onUpdate,
              loading: _updateLoading[loadingIndex],
            ),
            SizedBox(height: 8),
            if (supportingText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 28, 16),
                child: Text(
                  supportingText,
                  style: AppTextStyle.body.copyWith(
                    color: context.theme.colorScheme.onSurfaceVariant,
                    fontSize: context.theme.textTheme.bodySmall?.fontSize,
                  ),
                ),
              ),
            if (position != TogglePosition.bottom)
              Divider(
                height: 1,
                color: context.theme.colorScheme.onSurface.withOpacity(0.12),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required Widget helperText,
    required List<Widget> toggles,
    bool isMobile = false,
  }) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          helperText,
          SizedBox(height: 16),
          ...toggles,
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: helperText,
        ),
        Expanded(flex: 4, child: Column(children: toggles)),
      ],
    );
  }

  Widget _buildSettings(bool isMobile) {
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
        return Column(
          children: [
            _buildSettingsSection(
              isMobile: isMobile,
              helperText: HeightConstrainedText(
                context.l10n.communitySettings,
                style: context.theme.textTheme.titleLarge,
                maxLines: 1,
              ),
              toggles: [
                _buildSettingsToggle(
                  'Allow members to create events',
                  !settings.dontAllowMembersToCreateMeetings,
                  loadingIndex: 0,
                  (val) => _toggleCommunitySetting(
                    settings.copyWith(
                      dontAllowMembersToCreateMeetings:
                          !settings.dontAllowMembersToCreateMeetings,
                    ),
                    loadingIndex: 0,
                  ),
                  position: TogglePosition.top,
                ),
                _buildSettingsToggle(
                  'Allow members to create templates',
                  settings.allowUnofficialTemplates,
                  loadingIndex: 1,
                  (val) => _toggleCommunitySetting(
                    settings.copyWith(
                      allowUnofficialTemplates:
                          !settings.allowUnofficialTemplates,
                    ),
                    loadingIndex: 1,
                  ),
                ),
                _buildSettingsToggle(
                  'Require approval for new members',
                  settings.requireApprovalToJoin,
                  loadingIndex: 2,
                  (val) => _toggleCommunitySetting(
                    settings.copyWith(
                      requireApprovalToJoin: !settings.requireApprovalToJoin,
                    ),
                    loadingIndex: 2,
                  ),
                ),
                _buildSettingsToggle(
                  'Enable weekly email digests of upcoming events',
                  !settings.disableEmailDigests,
                  loadingIndex: 3,
                  (val) => _toggleCommunitySetting(
                    settings.copyWith(
                      disableEmailDigests: !settings.disableEmailDigests,
                    ),
                    loadingIndex: 3,
                  ),
                  position: !kShowStripeFeatures
                      ? TogglePosition.bottom
                      : TogglePosition.none,
                ),
                if (kShowStripeFeatures) ...[
                  _buildSettingsToggle(
                    'Allow users to donate funds${donationWarning ? ' *' : ''}',
                    settings.allowDonations,
                    loadingIndex: 4,
                    (val) => _toggleCommunitySetting(
                      settings.copyWith(
                        allowDonations: !settings.allowDonations,
                      ),
                      loadingIndex: 4,
                    ),
                    hasWarning: donationWarning,
                    position: TogglePosition.bottom,
                  ),
                  if (donationWarning)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: HeightConstrainedText(
                        '* Your payee account has not been fully set up, so donations will not '
                        'currently be accepted. You may need to link a bank account or accept '
                        'Stripe\'s terms of service.',
                        style:
                            TextStyle(color: context.theme.colorScheme.error),
                      ),
                    ),
                  SizedBox(height: 8),
                  _buildStripeConnectLink(context, agreement!),
                ],
              ],
            ),
            SizedBox(height: 20),
            _buildSettingsSection(
              isMobile: isMobile,
              helperText: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.eventSettings,
                    style: context.theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    context.l10n.eventSettingsDescription,
                    style: context.theme.textTheme.bodySmall,
                  ),
                ],
              ),
              toggles: [
                _buildSettingsToggle(
                  'Chat',
                  eventSettings.chat ?? true,
                  loadingIndex: 5,
                  (val) => _toggleEventSetting(
                    eventSettings.copyWith(
                      chat: !(eventSettings.chat ?? true),
                    ),
                    loadingIndex: 5,
                  ),
                  position: TogglePosition.top,
                  supportingText: context.l10n.settingHelperChat,
                ),
                _buildSettingsToggle(
                  'Floating Chat',
                  eventSettings.showChatMessagesInRealTime ?? true,
                  loadingIndex: 6,
                  (val) => _toggleEventSetting(
                    eventSettings.copyWith(
                      showChatMessagesInRealTime:
                          !(eventSettings.showChatMessagesInRealTime ?? true),
                    ),
                    loadingIndex: 6,
                  ),
                  supportingText: context.l10n.settingHelperFloatingChat,
                ),
                _buildSettingsToggle(
                  'Record',
                  eventSettings.alwaysRecord ?? true,
                  loadingIndex: 7,
                  (val) => _toggleEventSetting(
                    eventSettings.copyWith(
                      alwaysRecord: !(eventSettings.alwaysRecord ?? true),
                    ),
                    loadingIndex: 7,
                  ),
                  supportingText: context.l10n.settingHelperRecord,
                ),
                _buildSettingsToggle(
                  'Odometer',
                  eventSettings.talkingTimer ?? true,
                  loadingIndex: 8,
                  (val) => _toggleEventSetting(
                    eventSettings.copyWith(
                      talkingTimer: !(eventSettings.talkingTimer ?? true),
                    ),
                    loadingIndex: 8,
                  ),
                  supportingText: context.l10n.settingHelperTalkTimer,
                ),
                _buildSettingsToggle(
                  'Agenda preview',
                  eventSettings.agendaPreview ?? true,
                  loadingIndex: 9,
                  (val) => _toggleEventSetting(
                    eventSettings.copyWith(
                      agendaPreview: !(eventSettings.agendaPreview ?? true),
                    ),
                    loadingIndex: 9,
                  ),
                  position: TogglePosition.bottom,
                  supportingText: context.l10n.settingHelperAgendaPreview,
                ),
              ],
            ),
            SizedBox(height: 20),
            if (Environment.enableDevAdminSettings)
              _buildDevSettingsSection(isMobile),
          ],
        );
      },
    );
  }

  Future<void> _toggleCommunitySetting(
    CommunitySettings communitySettings, {
    int loadingIndex = -1,
  }) async {
    setState(() {
      _updateLoading[loadingIndex] = true;
    });

    try {
      await cloudFunctionsCommunityService
          .updateCommunity(
        UpdateCommunityRequest(
          community: context
              .read<CommunityProvider>()
              .community
              .copyWith(communitySettings: communitySettings),
          keys: [Community.kFieldCommunitySettings],
        ),
      )
          .then((_) {
        setState(() {
          _updateLoading[loadingIndex] = false;
        });
        return;
      });
    } finally {
      setState(() {
        _updateLoading[loadingIndex] = false;
      });
    }
  }

  Future<void> _toggleEventSetting(
    EventSettings eventSettings, {
    int loadingIndex = -1,
  }) async {
    _updateLoading[loadingIndex] = true;

    try {
      await cloudFunctionsCommunityService
          .updateCommunity(
        UpdateCommunityRequest(
          community: context
              .read<CommunityProvider>()
              .community
              .copyWith(eventSettings: eventSettings),
          keys: [Community.kFieldEventSettings],
        ),
      )
          .then((_) {
        _updateLoading[loadingIndex] = false;
        return;
      });
    } finally {
      _updateLoading[loadingIndex] = false;
    }
  }

  Widget _buildStripeConnectLink(
    BuildContext context,
    PartnerAgreement agreement,
  ) {
    return Center(
      child: ActionButton(
        text:
            '${agreement.stripeConnectedAccountId == null ? 'Set' : 'Edit'} Linked Payee Account',
        onPressed: () =>
            alertOnError(context, () => _stripeButtonPressed(agreement)),
      ),
    );
  }

  Widget _buildDevSettingsSection(bool isMobile) {
    final settingsMap = context.watch<CommunityProvider>().settings.toJson();
    final settings = settingsMap.keys
        .where((element) => settingsMap[element] is bool)
        .toList();

    final eventSettingsMap =
        context.watch<CommunityProvider>().eventSettings.toJson();
    final eventSettings = eventSettingsMap.keys
        .where((element) => settingsMap[element] is bool?)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dev Settings',
          style: context.theme.textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: Colors.deepPurpleAccent,
          ),
        ),
        if (_updateLoading[10])
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: LinearProgressIndicator(),
          ),
        SizedBox(height: 8),
        Text(
          'Community Settings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.purpleAccent,
              ),
        ),
        SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 1 : 3,
            childAspectRatio: 4,
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
          ),
          itemCount: settings.length,
          itemBuilder: (context, i) => _devCommunitySettingsToggle(
            settings[i],
            settingsMap,
            whiteBackground,
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Event Settings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.purpleAccent,
              ),
        ),
        SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 1 : 3,
            childAspectRatio: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: eventSettings.length,
          itemBuilder: (context, i) => _devEventSettingsToggle(
            eventSettings[i],
            eventSettingsMap,
            i.isEven
                ? whiteBackground
                : context.theme.colorScheme.primary.withOpacity(0.1),
          ),
        ),
      ],
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
      loadingIndex: 10,
      (val) => _toggleCommunitySetting(CommunitySettings.fromJson(newSettings), loadingIndex: 10),
      position: TogglePosition.bottom,
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
      (val) => _toggleEventSetting(EventSettings.fromJson(newSettings),),
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
    return ListView(
      children: [
        if (!isMobile) SizedBox(height: 38),
        _buildSettings(isMobile),
        if (!isMobile) Spacer(flex: 1),
      ],
    );
  }
}
