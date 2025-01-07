import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:client/common_widgets/custom_stream_builder.dart';
import 'package:client/common_widgets/navbar/nav_bar_provider.dart';
import 'package:client/environment.dart';
import 'package:client/services/user_data_service.dart';
import 'package:client/services/services.dart';
import 'package:client/services/user_service.dart';
import 'package:client/utils/height_constained_text.dart';
import 'package:client/utils/stream_utils.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/community/community_user_settings.dart';
import 'package:data_models/community/membership.dart';
import 'package:provider/provider.dart';

class NotificationsTab extends StatefulHookWidget {
  final String? initialCommunityId;

  const NotificationsTab({this.initialCommunityId});

  @override
  _NotificationsTabState createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab> {
  String get _userId => context.read<UserService>().currentUserId!;

  Stream<List<Membership>> get _memberships =>
      Provider.of<UserDataService>(context).memberships.map(
            (memberships) =>
                memberships.where((membership) => membership.isMember).toList()
                  ..sort(_sortMemberships),
          );

  String? _activeCommunityId;

  // treat as on/off until we add more granular notification options
  NotificationEmailType _boolToNotificationEmailType({required bool value}) {
    return value ? NotificationEmailType.immediate : NotificationEmailType.none;
  }

  bool _notificationEmailTypeToBool({required NotificationEmailType? value}) {
    return value == NotificationEmailType.immediate;
  }

  Future<void> _setInitialCommunity() async {
    final sidebarCommunity =
        Provider.of<NavBarProvider>(context, listen: false).currentCommunity;

    final memberships = await userDataService.memberships.first;
    final initialCommunityId = widget.initialCommunityId ??
        sidebarCommunity?.id ??
        memberships.firstOrNull?.communityId;

    if (initialCommunityId != null &&
        userDataService.isMember(communityId: initialCommunityId)) {
      _setActiveCommunity(initialCommunityId);
    }
  }

  int _sortMemberships(Membership a, Membership b) {
    const membershipOrder = [
      MembershipStatus.owner,
      MembershipStatus.admin,
      MembershipStatus.mod,
      MembershipStatus.facilitator,
      MembershipStatus.member,
    ];

    final aIndex =
        membershipOrder.indexOf(a.status ?? MembershipStatus.nonmember);
    final bIndex =
        membershipOrder.indexOf(b.status ?? MembershipStatus.nonmember);
    return aIndex.compareTo(bIndex);
  }

  void _setActiveCommunity(String? communityId) {
    setState(() {
      _activeCommunityId = communityId;
    });
  }

  Future<void> _update({
    required CommunityUserSettings settings,
    List<String> keys = const [],
  }) async {
    await firestorePrivateUserDataService.updateCommunityUserSettings(
      communityUserSettings: settings,
      keys: [
        CommunityUserSettings.kFieldUserId,
        CommunityUserSettings.kFieldCommunityId,
        ...keys,
      ],
    );
    final activeCommunityId = _activeCommunityId;
    if (activeCommunityId != null &&
        settings.communityId == _activeCommunityId) {
      _setActiveCommunity(activeCommunityId);
    }
  }

  Future<void> _updateNotifyAnnouncements({
    required String communityId,
    bool notify = false,
  }) async {
    await _update(
      settings: CommunityUserSettings().copyWith(
        userId: _userId,
        communityId: communityId,
        notifyAnnouncements: _boolToNotificationEmailType(value: notify),
      ),
      keys: [CommunityUserSettings.kFieldNotifyAnnouncements],
    );
  }

  Future<void> _updateNotifyEvents({
    required String communityId,
    bool notify = false,
  }) async {
    await _update(
      settings: CommunityUserSettings().copyWith(
        userId: _userId,
        communityId: communityId,
        notifyEvents: _boolToNotificationEmailType(value: notify),
      ),
      keys: [CommunityUserSettings.kFieldNotifyEvents],
    );
  }

  Widget _buildActiveCommunitySettings({
    required String communityId,
    String? communityDisplay,
  }) {
    return CustomStreamGetterBuilder<CommunityUserSettings>(
      streamGetter: () => firestorePrivateUserDataService
          .getCommunityUserSettings(userId: _userId, communityId: communityId),
      entryFrom: '_NotificationsTabState._buildActiveCommunitySettings',
      keys: [_userId, communityId],
      height: 100,
      width: 300,
      errorMessage:
          'Something went wrong loading notification settings. Please refresh.',
      builder: (context, settings) => IntrinsicWidth(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(bottom: 12),
              child: HeightConstrainedText(
                'Settings for $communityDisplay',
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
                    communityId: communityId,
                    notify: value ?? false,
                  ),
                ),
                Flexible(
                  child: HeightConstrainedText(
                    'Notify me about new announcements',
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  activeColor: Theme.of(context).primaryColor,
                  value: _notificationEmailTypeToBool(
                    value: settings.notifyEvents,
                  ),
                  onChanged: (value) => _updateNotifyEvents(
                    communityId: communityId,
                    notify: value ?? false,
                  ),
                ),
                Flexible(
                  child: HeightConstrainedText('Notify me about new events'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return CustomStreamBuilder<List<Membership>>(
      entryFrom: '_NotificationsTabState._buildContent1',
      stream: _memberships,
      errorMessage: 'Something went wrong loading memberships. Please refresh.',
      builder: (context, membershipList) {
        final nonNullActiveCommunityId = _activeCommunityId;
        if (nonNullActiveCommunityId == null) {
          return Padding(
            padding: EdgeInsets.all(20),
            child:
                HeightConstrainedText('No ${Environment.appName} memberships.'),
          );
        }
        return CustomStreamBuilder<List<Community>>(
          entryFrom: '_NotificationsTabState._buildContent2',
          stream: Provider.of<UserDataService>(context).userCommunities,
          errorMessage:
              'Something went wrong loading communities. Please refresh.',
          builder: (context, communitiesList) {
            final communityLookup = {
              for (var j in communitiesList ?? <Community>[]) j.id: j,
            };

            return Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      HeightConstrainedText('Select space:'),
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.only(left: 15),
                          constraints: BoxConstraints(maxWidth: 300),
                          child: DropdownButton<String>(
                            value: _activeCommunityId,
                            onChanged: _setActiveCommunity,
                            items: (membershipList ?? [])
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e.communityId,
                                    child: HeightConstrainedText(
                                      communityLookup[e.communityId]?.name ??
                                          e.communityId,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
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
                  child: _buildActiveCommunitySettings(
                    communityId: nonNullActiveCommunityId,
                    communityDisplay:
                        communityLookup[_activeCommunityId]?.name ??
                            _activeCommunityId,
                  ),
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
        child: CustomStreamGetterBuilder<void>(
          entryFrom: '_NotificationsTabState.build',
          streamGetter: () => _setInitialCommunity().asStream(),
          builder: (_, __) => _buildContent(),
        ),
      ),
    );
  }
}
