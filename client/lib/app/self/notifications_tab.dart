import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/common_widgets/navbar/nav_bar_provider.dart';
import 'package:junto/services/junto_user_data_service.dart';
import 'package:junto/services/services.dart';
import 'package:junto/services/user_service.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto/utils/stream_utils.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:junto_models/firestore/junto_user_settings.dart';
import 'package:junto_models/firestore/membership.dart';
import 'package:provider/provider.dart';

class NotificationsTab extends StatefulHookWidget {
  final String? initialJuntoId;

  const NotificationsTab({this.initialJuntoId});

  @override
  _NotificationsTabState createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab> {
  String get _userId => context.read<UserService>().currentUserId!;

  Stream<List<Membership>> get _memberships =>
      Provider.of<JuntoUserDataService>(context).memberships.map((memberships) =>
          memberships.where((membership) => membership.isMember).toList()..sort(_sortMemberships));

  String? _activeJuntoId;

  // treat as on/off until we add more granular notification options
  NotificationEmailType _boolToNotificationEmailType({required bool value}) {
    return value ? NotificationEmailType.immediate : NotificationEmailType.none;
  }

  bool _notificationEmailTypeToBool({required NotificationEmailType? value}) {
    return value == NotificationEmailType.immediate;
  }

  Future<void> _setInitialJunto() async {
    final sidebarJunto = Provider.of<NavBarProvider>(context, listen: false).currentJunto;

    final memberships = await juntoUserDataService.memberships.first;
    final initialJuntoId =
        widget.initialJuntoId ?? sidebarJunto?.id ?? memberships.firstOrNull?.juntoId;

    if (initialJuntoId != null && juntoUserDataService.isMember(juntoId: initialJuntoId)) {
      _setActiveJunto(initialJuntoId);
    }
  }

  int _sortMemberships(Membership a, Membership b) {
    const _membershipOrder = [
      MembershipStatus.owner,
      MembershipStatus.admin,
      MembershipStatus.mod,
      MembershipStatus.facilitator,
      MembershipStatus.member
    ];

    final aIndex = _membershipOrder.indexOf(a.status ?? MembershipStatus.nonmember);
    final bIndex = _membershipOrder.indexOf(b.status ?? MembershipStatus.nonmember);
    return aIndex.compareTo(bIndex);
  }

  void _setActiveJunto(String? juntoId) {
    setState(() {
      _activeJuntoId = juntoId;
    });
  }

  Future<void> _update({
    required JuntoUserSettings settings,
    List<String> keys = const [],
  }) async {
    await firestorePrivateUserDataService
        .updateJuntoUserSettings(juntoUserSettings: settings, keys: [
      JuntoUserSettings.kFieldUserId,
      JuntoUserSettings.kFieldJuntoId,
      ...keys,
    ]);
    final activeJuntoId = _activeJuntoId;
    if (activeJuntoId != null && settings.juntoId == _activeJuntoId) {
      _setActiveJunto(activeJuntoId);
    }
  }

  Future<void> _updateNotifyAnnouncements({required String juntoId, bool notify = false}) async {
    await _update(
        settings: JuntoUserSettings().copyWith(
            userId: _userId,
            juntoId: juntoId,
            notifyAnnouncements: _boolToNotificationEmailType(value: notify)),
        keys: [JuntoUserSettings.kFieldNotifyAnnouncements]);
  }

  Future<void> _updateNotifyEvents({required String juntoId, bool notify = false}) async {
    await _update(
        settings: JuntoUserSettings().copyWith(
            userId: _userId,
            juntoId: juntoId,
            notifyEvents: _boolToNotificationEmailType(value: notify)),
        keys: [JuntoUserSettings.kFieldNotifyEvents]);
  }

  Widget _buildActiveJuntoSettings({required String juntoId, String? juntoDisplay}) {
    return JuntoStreamGetterBuilder<JuntoUserSettings>(
      streamGetter: () =>
          firestorePrivateUserDataService.getJuntoUserSettings(userId: _userId, juntoId: juntoId),
      entryFrom: '_NotificationsTabState._buildActiveJuntoSettings',
      keys: [_userId, juntoId],
      height: 100,
      width: 300,
      errorMessage: 'Something went wrong loading notification settings. Please refresh.',
      builder: (context, settings) => IntrinsicWidth(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(bottom: 12),
              child: JuntoText(
                'Settings for $juntoDisplay',
                style: TextStyle(
                  color: Color.fromARGB(128, 0, 0, 0),
                ),
              ),
            ),
            Row(
              children: [
                Checkbox(
                  activeColor: Theme.of(context).primaryColor,
                  value: _notificationEmailTypeToBool(
                    value: settings!.notifyAnnouncements,
                  ),
                  onChanged: (value) => _updateNotifyAnnouncements(
                    juntoId: juntoId,
                    notify: value ?? false,
                  ),
                ),
                Flexible(
                  child: JuntoText('Notify me about new announcements'),
                ),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  activeColor: Theme.of(context).primaryColor,
                  value: _notificationEmailTypeToBool(value: settings.notifyEvents),
                  onChanged: (value) => _updateNotifyEvents(
                    juntoId: juntoId,
                    notify: value ?? false,
                  ),
                ),
                Flexible(
                  child: JuntoText('Notify me about new events'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return JuntoStreamBuilder<List<Membership>>(
      entryFrom: '_NotificationsTabState._buildContent1',
      stream: _memberships,
      errorMessage: 'Something went wrong loading memberships. Please refresh.',
      builder: (context, membershipList) {
        final nonNullActiveJuntoId = _activeJuntoId;
        if (nonNullActiveJuntoId == null) {
          return Padding(padding: EdgeInsets.all(20), child: JuntoText('No Frankly memberships.'));
        }
        return JuntoStreamBuilder<List<Junto>>(
          entryFrom: '_NotificationsTabState._buildContent2',
          stream: Provider.of<JuntoUserDataService>(context).userCommunities,
          errorMessage: 'Something went wrong loading communities. Please refresh.',
          builder: (context, juntosList) {
            final juntoLookup = {for (var j in juntosList ?? <Junto>[]) j.id: j};

            return Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      JuntoText('Select space:'),
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.only(left: 15),
                          constraints: BoxConstraints(maxWidth: 300),
                          child: DropdownButton<String>(
                            value: _activeJuntoId,
                            onChanged: _setActiveJunto,
                            items: (membershipList ?? [])
                                .map((e) => DropdownMenuItem(
                                      value: e.juntoId,
                                      child: JuntoText(
                                        juntoLookup[e.juntoId]?.name ?? e.juntoId,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ))
                                .toList(),
                            isExpanded: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color.fromARGB(64, 0, 0, 0)),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: _buildActiveJuntoSettings(
                      juntoId: nonNullActiveJuntoId,
                      juntoDisplay: juntoLookup[_activeJuntoId]?.name ?? _activeJuntoId),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        constraints: BoxConstraints(minWidth: 280, maxWidth: 540),
        child: JuntoStreamGetterBuilder<void>(
          entryFrom: '_NotificationsTabState.build',
          streamGetter: () => _setInitialJunto().asStream(),
          builder: (_, __) => _buildContent(),
        ),
      ),
    );
  }
}
