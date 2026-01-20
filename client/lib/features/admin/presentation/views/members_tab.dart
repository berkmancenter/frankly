import 'package:client/config/environment.dart';
import 'package:client/core/localization/localization_helper.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/utils/navigation_utils.dart';
import 'package:client/core/widgets/custom_loading_indicator.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/features/admin/utils/member_data.dart';
import 'package:data_models/user/public_user_info.dart';
import 'package:flutter/material.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/features/community/data/providers/user_admin_details_builder.dart';
import 'package:client/features/user/data/providers/user_info_builder.dart';
import 'package:client/core/utils/firestore_utils.dart';
import 'package:client/services.dart';
import 'package:client/styles/styles.dart';
import 'package:client/core/utils/extensions.dart';
import 'package:data_models/community/membership.dart';
import 'package:data_models/community/membership_request.dart';
import 'package:provider/provider.dart';
import 'package:quiver/iterables.dart';

extension StringExtension on String {
  String capitalize() {
    if (isNullOrEmpty(this)) return this;
    if (length < 2) return toUpperCase();
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

class MembersTab extends StatefulWidget {
  @override
  MembersTabState createState() => MembersTabState();
}

/*
  This class is used to display a list of memberships in a DataTable. It allows for sorting and filtering of memberships.
*/

// The DataTableSource implementation for the Memberships DataTable.
class MembershipDataSource extends DataTableSource {
  BuildContext context;

  MembershipDataSource(List<Membership>? membershipList, this.context)
      : _membershipList = membershipList ?? [];

  final List<Membership> _membershipList;

  @override
  int get rowCount => _membershipList.length;

  // Build a DataRow for each membership entry
  DataRow _buildMembershipEntry(
    int index,
    Membership membership,
  ) {
    PublicUserInfo? userInfo = UserInfoProvider.forUser(membership.userId).info;

    return DataRow(
      color: WidgetStateProperty.all(Colors.white70),
      cells: <DataCell>[
        DataCell(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    userInfo?.imageUrl ?? '',
                  ),
                ),
                SizedBox(width: 8),
                if (userInfo?.displayName != null)
                  Text(
                    userInfo?.displayName ?? '',
                  ),
              ],
            ),
          ),
        ),
        DataCell(
          ChangeMembershipDropdown(
            membership: membership,
          ),
        ),
      ],
    );
  }

  @override
  DataRow? getRow(int index) {
    final membership = _membershipList[index];
    return _buildMembershipEntry(index, membership);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}

class MembersTabState extends State<MembersTab> {
  final whiteBackground = Colors.white70;

  late Stream<List<Membership>> _memberships;
  late BehaviorSubjectWrapper<List<MembershipRequest>> _requests;

  Future<void>? _loadUsersFuture;
  String? _currentSearch;

  int _sortMemberships(Membership a, Membership b) {
    const membershipOrder = [
      MembershipStatus.owner,
      MembershipStatus.admin,
      MembershipStatus.moderator,
      MembershipStatus.facilitator,
      MembershipStatus.member,
    ];

    final aStatus = a.status;
    final bStatus = b.status;
    final aIndex = aStatus == null ? -1 : membershipOrder.indexOf(aStatus);
    final bIndex = bStatus == null ? -1 : membershipOrder.indexOf(bStatus);
    return aIndex.compareTo(bIndex);
  }

  List<Membership> _filterMemberships(List<Membership> memberships) {
    final currentSearch = _currentSearch;
    if (currentSearch == null || currentSearch.isEmpty) return memberships;

    final search = currentSearch.toLowerCase();
    final members = <Membership>[];
    for (final member in memberships) {
      final userInfo = UserInfoProvider.forUser(member.userId);
      final userAdminDetails = UserAdminDetailsProvider.forUser(member.userId);
      final nameMatch =
          userInfo.info?.displayName?.toLowerCase().contains(search) ?? false;
      final emailMatch = userAdminDetails
              .getInfo(communityId: CommunityProvider.read(context).communityId)
              ?.email
              ?.toLowerCase()
              .contains(search) ??
          false;
      if (nameMatch || emailMatch) {
        members.add(member);
      }
    }

    return members;
  }

  @override
  void initState() {
    final communityId =
        Provider.of<CommunityProvider>(context, listen: false).community.id;
    _memberships = firestoreMembershipService
        .communityMembershipsStream(communityId: communityId)
        .stream
        .map(
          (memberships) => memberships.where((m) => m.isAttendee).toList()
            ..sort(_sortMemberships),
        );

    _requests = firestoreCommunityJoinRequestsService.getRequestsForCommunityId(
      communityId: communityId,
    );

    super.initState();
  }

  @override
  void dispose() {
    _requests.dispose();
    super.dispose();
  }

  /// Load user info details in batches of 500
  Future<void> _loadAllUserInfoDetails(List<Membership> memberships) async {
    final batches = partition(memberships, 500);

    for (final batch in batches) {
      await Future.wait(
        batch.map((m) => UserInfoProvider.forUser(m.userId).infoFuture),
      );

      await Future.microtask(() => Future.value());
    }
  }

  Widget _buildSearchBar(List<Membership> memberships) {
    return Flexible(
      child: Container(
        constraints: BoxConstraints(maxWidth: 450),
        child: Row(
          children: [
            Expanded(
              child: CustomTextField(
                hintText: 'Filter member list by name',
                prefixIcon: Icon(Icons.search),
                onChanged: (value) {
                  setState(() {
                    _currentSearch = value;
                    _loadUsersFuture ??= Future.wait([
                      _loadAllUserInfoDetails(memberships),
                    ]);
                  });
                },
              ),
            ),
            SizedBox(
              width: 80,
              child: FutureBuilder(
                future: _loadUsersFuture,
                builder: (_, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CustomLoadingIndicator(),
                    );
                  }

                  return SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(DataTableSource dataSource) {
    return PaginatedDataTable(
      headingRowColor:
          WidgetStateProperty.all(context.theme.colorScheme.surfaceContainer),
      columns: <DataColumn>[
        DataColumn(label: Text('Member')),
        DataColumn(
          label: Row(
            children: [
              Text('Role'),
              Tooltip(
                enableTapToDismiss: false,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.24),
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: Offset(
                        2,
                        2,
                      ),
                    ),
                  ],
                  color: context.theme.colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                ),
                richMessage: TextSpan(
                  children: <InlineSpan>[
                    WidgetSpan(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              context.l10n.rolesTooltip,
                              style: TextStyle(
                                color:
                                    context.theme.colorScheme.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          TextButton(
                            onPressed: () => launch(
                              Environment.helpCenterManagingCommunityUrl,
                            ),
                            child: Text(
                              context.l10n.seeManagingYourCommunity,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // The child widget that triggers the tooltip
                child: IconButton(
                  icon: Icon(Icons.info_outline),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ],
      source: dataSource,
    );
  }

  Widget _buildMembersSection() {
    return CustomStreamBuilder<List<Membership>>(
      stream: _memberships,
      entryFrom: '_MembersTabState._buildMembersSection',
      errorMessage: context.l10n.errorLoadingMemberships,
      builder: (context, allMembershipDocs) {
        // Filter out invisible members and those who are attendees but not members
        final membershipList = allMembershipDocs
            ?.where(
              (element) =>
                  !element.invisible &&
                  !(element.isAttendee && !element.isMember),
            )
            .toList();

        if (membershipList != null && membershipList.isNotEmpty) {
          // If there is a current search, run filter and return filtered table
          if (!isNullOrEmpty(_currentSearch)) {
            final filteredMembers = _filterMemberships(membershipList);
            if (filteredMembers.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(8),
                child: Text(context.l10n.noMatchingMembersFound),
              );
            }
            return _buildTable(MembershipDataSource(filteredMembers, context));
          }

          // If there is no current search, return table with all memberships
          _loadUsersFuture = Future.wait([
            _loadAllUserInfoDetails(membershipList),
          ]);
          return FutureBuilder(
            future: _loadUsersFuture,
            builder: (_, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CustomLoadingIndicator(),
                );
              }

              return _buildTable(MembershipDataSource(membershipList, context));
            },
          );
        } else if (membershipList == null) {
          return Center(
            child: CustomLoadingIndicator(),
          );
        }
        // There is a problem
        return Center(
          child: Text(context.l10n.errorLoadingMemberships),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = responsiveLayoutService.isMobile(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8),
          CustomStreamBuilder<List<Membership>>(
            stream: _memberships,
            entryFrom: '_MembersTabState._build',
            errorMessage: context.l10n.errorLoadingMemberships,
            builder: (context, membershipList) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSearchBar(membershipList ?? []),
                  if (!isMobile)
                    ActionButton(
                      text: context.l10n.downloadMembersData,
                      type: ActionButtonType.text,
                      icon: Icon(Icons.file_download_outlined),
                      onPressed: () => MemberDataUtils.downloadMembersData(
                        context,
                        membershipList ?? [],
                      ),
                    ),
                ],
              );
            },
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMembersSection(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RolePermissionListTile extends StatelessWidget {
  final String title;
  final List<String> permissions;
  final Widget icon;

  const RolePermissionListTile({
    Key? key,
    required this.title,
    required this.permissions,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            icon,
            SizedBox(width: 10),
            Text(
              title,
              style: AppTextStyle.bodyMedium,
            ),
          ],
        ),
        for (var item in permissions)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 40),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Icon(
                  Icons.circle,
                  size: 4,
                  color: context.theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  item,
                  style: context.theme.textTheme.bodyMedium!.copyWith(
                    color: context.theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class ChangeMembershipDropdown extends StatefulWidget {
  final Membership membership;

  const ChangeMembershipDropdown({
    required this.membership,
  });

  @override
  _ChangeMembershipDropdownState createState() =>
      _ChangeMembershipDropdownState();
}

class _ChangeMembershipDropdownState extends State<ChangeMembershipDropdown> {
  bool _isLoading = false;

  bool get _isCurrentOwner =>
      widget.membership.status == MembershipStatus.owner;

  Future<bool> confirmOwnerDialog(String communityName) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.l10n.areYouSure),
          content: Flexible(
            child: SizedBox(
              width: 250,
              child: Text(
                context.l10n.confirmMakeOwner(
                  UserInfoProvider.forUser(widget.membership.userId)
                          .info
                          ?.displayName ??
                      '{NAME NOT FOUND}',
                  communityName,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(context.l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(context.l10n.confirm),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateMembership(MembershipStatus? newStatus) async {
    CommunityProvider communityProvider =
        Provider.of<CommunityProvider>(context, listen: false);
    // Warn user if they are changing to owner
    if (newStatus == MembershipStatus.owner) {
      final confirm = await confirmOwnerDialog(
        communityProvider.community.name ?? 'Community',
      );
      if (!confirm) return;
    }
    setState(() => _isLoading = true);
    await alertOnError(
      context,
      () => userDataService.changeCommunityMembership(
        communityId: communityProvider.community.id,
        userId: widget.membership.userId,
        newStatus: newStatus!,
      ),
    );
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final disableDropdown = _isLoading;

    if (_isLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: CustomLoadingIndicator(),
      );
    }

    if (_isCurrentOwner) {
      return Text(context.l10n.owner, style: context.theme.textTheme.bodyLarge);
    }

    return Container(
      width: double.infinity,
      height: 100,
      constraints: BoxConstraints(maxWidth: 280, maxHeight: 400),
      child: DropdownButton<MembershipStatus>(
        value: widget.membership.status,
        onChanged: disableDropdown ? null : _updateMembership,
        itemHeight: null,
        selectedItemBuilder: (context) => _isCurrentOwner
            ? [
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Owner',
                  ),
                ),
              ]
            : MembershipStatus.values
                .map(
                  (status) => Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      status.name.capitalize(),
                    ),
                  ),
                )
                .toList(),
        items: MembershipStatus.values
            // Exclude nonmember, attendee, and banned statuses
            .where(
              (value) =>
                  value.name != 'nonmember' &&
                  value.name != 'attendee' &&
                  value.name != 'banned',
            )
            .map(
              (value) => DropdownMenuItem<MembershipStatus>(
                value: value,
                // Exclude owner from being selectable, for now
                // We also adjust opacity of owner field below; this is slightly hacky,
                // but prevents us from having to filter the enum in a few places
                enabled: !_isCurrentOwner && value.name != 'owner',
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value.name.capitalize(),
                        style: context.theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: value.name == 'owner'
                              ? context.theme.textTheme.bodyLarge?.color
                                  ?.withOpacity(0.5)
                              : context.theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      Text(
                        value.permissions(context),
                        style: context.theme.textTheme.bodySmall?.copyWith(
                          color: value.name == 'owner'
                              ? context.theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.5)
                              : context.theme.textTheme.bodySmall?.color,
                        ),
                        softWrap: true,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
