import 'dart:convert';

import 'package:client/core/localization/localization_helper.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/custom_loading_indicator.dart';
import 'package:csv/csv.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/confirm_dialog.dart';
import 'package:client/core/widgets/custom_list_view.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/core/widgets/upgrade_icon.dart';
import 'package:client/features/admin/presentation/widgets/upgrade_tooltip.dart';
import 'package:client/features/community/data/providers/user_admin_details_builder.dart';
import 'package:client/features/user/data/providers/user_info_builder.dart';
import 'package:client/features/user/presentation/widgets/user_profile_chip.dart';
import 'package:client/app.dart';
import 'package:client/core/utils/firestore_utils.dart';
import 'package:client/services.dart';
import 'package:client/styles/styles.dart';
import 'package:client/core/utils/extensions.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:client/core/widgets/stream_utils.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/community/membership.dart';
import 'package:data_models/community/membership_request.dart';
import 'package:data_models/admin/plan_capability_list.dart';
import 'package:provider/provider.dart';
import 'package:quiver/iterables.dart';
import 'package:universal_html/html.dart' as html;

extension StringExtension on String {
  String capitalize() {
    if (isNullOrEmpty(this)) return this;
    if (length < 2) return toUpperCase();
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

const _adminStatusMap = <MembershipStatus, String>{
  MembershipStatus.mod: 'Moderator',
};

class MembersTab extends StatefulWidget {
  @override
  _MembersTabState createState() => _MembersTabState();
}

class _MembersTabState extends State<MembersTab> {
  final whiteBackground = Colors.white70;

  late Stream<List<Membership>> _memberships;
  late BehaviorSubjectWrapper<List<MembershipRequest>> _requests;

  Future<void>? _loadUsersFuture;
  String? _currentSearch;

  int _sortMemberships(Membership a, Membership b) {
    const membershipOrder = [
      MembershipStatus.owner,
      MembershipStatus.admin,
      MembershipStatus.mod,
      MembershipStatus.facilitator,
      MembershipStatus.member,
      MembershipStatus.attendee,
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

  Widget _buildSearchBarField(List<Membership> memberships) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search',
        border: InputBorder.none,
      ),
      onChanged: (value) {
        setState(() {
          _currentSearch = value;
          _loadUsersFuture ??= Future.wait([
            _loadAllUserInfoDetails(memberships),
            ...memberships.map(
              (m) => UserAdminDetailsProvider.forUser(m.userId).getInfoFuture(
                communityId: CommunityProvider.read(context).communityId,
              ),
            ),
          ]);
        });
      },
    );
  }

  Widget _buildSearchBar(List<Membership> memberships) {
    return Container(
      constraints: BoxConstraints(maxWidth: 450),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: context.theme.colorScheme.surfaceContainerLowest,
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(
                      Icons.search,
                      color: context.theme.colorScheme.secondary,
                    ),
                  ),
                  Expanded(
                    child: _buildSearchBarField(memberships),
                  ),
                ],
              ),
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
    );
  }

  Widget _buildMembershipEntry(
    int index,
    Membership membership,
    bool allowPromoteToAdmin,
    bool allowPromoteToFacilitator,
  ) {
    return Container(
      key: Key(membership.userId),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      color: index.isEven
          ? context.theme.colorScheme.primary.withOpacity(0.1)
          : Colors.white70,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 50,
        runSpacing: 8,
        children: [
          UserProfileChip(
            key: Key('user-profile-chip-${membership.userId}'),
            userId: membership.userId,
            imageHeight: 32,
            textStyle: TextStyle(
              color: context.theme.colorScheme.primary,
            ),
          ),
          ChangeMembershipDropdown(
            membership: membership,
            allowPromoteToAdmin: allowPromoteToAdmin,
            allowPromoteToFacilitator: allowPromoteToFacilitator,
          ),
        ],
      ),
    );
  }

  Future<void> _resolveRequest({
    required MembershipRequest request,
    required bool approve,
  }) async {
    await cloudFunctionsCommunityService.resolveJoinRequest(
      ResolveJoinRequestRequest(
        communityId: request.communityId,
        userId: request.userId,
        approve: approve,
      ),
    );
  }

  Future<void> _downloadMembersData(List<Membership> membershipList) async {
    final membersList = membershipList.map((member) => member.userId).toList();
    final communityId =
        Provider.of<CommunityProvider>(context, listen: false).communityId;

    if (membersList.isNotEmpty) {
      await alertOnError(context, () async {
        final members = await userService.getMemberDetails(
          membersList: membersList,
          communityId: communityId,
        );
        if (members.isNotEmpty) {
          List<List<dynamic>> rows = [];

          List<dynamic> firstRow = [];
          firstRow.add('#');
          firstRow.add('Name');
          firstRow.add('Email');
          firstRow.add('Member status');
          rows.add(firstRow);

          for (var member in members) {
            final memberIndex = members.indexOf(member);
            rows.add([
              memberIndex + 1,
              member.displayName ?? '',
              member.email,
              EnumToString.convertToString(member.membership?.status),
            ]);
          }

          String csv = const ListToCsvConverter().convert(rows);

          final base64String = utf8.fuse(base64);
          final content = base64String.encode(csv);
          final fileName = 'members-data-$communityId.csv';

          html.AnchorElement(
            href:
                'data:application/octet-stream;charset=utf-16le;base64,$content',
          )
            ..setAttribute('download', fileName)
            ..click();
        }
      });
    }
  }

  Widget _buildRequestEntry(int index, MembershipRequest request) {
    return Container(
      key: Key(request.userId),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 6),
      color: index.isEven
          ? context.theme.colorScheme.primary.withOpacity(0.1)
          : Colors.white70,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          IntrinsicWidth(
            child: UserProfileChip(
              key: Key('user-profile-chip-${request.userId}'),
              userId: request.userId,
              imageHeight: 32,
              textStyle: TextStyle(
                color: context.theme.colorScheme.primary,
              ),
            ),
          ),
          UserAdminDetailsBuilder(
            userId: request.userId,
            communityId: request.communityId,
            builder: (_, loading, detailsSnapshot) {
              if (loading) {
                return Container(
                  height: 50,
                  width: 50,
                  alignment: Alignment.center,
                  child: CustomLoadingIndicator(),
                );
              }

              final email = detailsSnapshot.data?.email;
              final isError =
                  detailsSnapshot.hasError || email == null || email.isEmpty;

              const errorText = 'Error loading email.';

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: SelectableText(
                  isError ? errorText : email,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: !responsiveLayoutService.isMobile(context)
                ? MainAxisSize.min
                : MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: ActionButton(
                  height: 44,
                  minWidth: 44,
                  padding: EdgeInsets.zero,
                  color: context.theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  sendingIndicatorAlign: ActionButtonSendingIndicatorAlign.none,
                  onPressed: () => alertOnError(
                    context,
                    () => _resolveRequest(request: request, approve: true),
                  ),
                  child: Icon(
                    Icons.check,
                    color: context.theme.colorScheme.tertiaryFixed,
                    size: 20,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: ActionButton(
                  height: 44,
                  minWidth: 44,
                  padding: EdgeInsets.zero,
                  type: ActionButtonType.outline,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  borderSide:
                      BorderSide(color: context.theme.colorScheme.error),
                  sendingIndicatorAlign: ActionButtonSendingIndicatorAlign.none,
                  onPressed: () => alertOnError(
                    context,
                    () => _resolveRequest(request: request, approve: false),
                  ),
                  child: Icon(
                    Icons.close,
                    color: context.theme.colorScheme.error,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequestList(List<MembershipRequest> requestList) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 400, maxWidth: 600),
      child: ListView(
        shrinkWrap: true,
        children: [
          for (var i = 0; i < requestList.length; i++)
            _buildRequestEntry(i, requestList[i]),
        ],
      ),
    );
  }

  Widget _buildRequestsSection() {
    return CustomStreamBuilder<List<MembershipRequest>>(
      entryFrom: '_MembersTabState._buildRequestsSection',
      stream: _requests,
      errorMessage: 'Something went wrong loading requests. Please refresh.',
      showLoading: false,
      builder: (context, requestList) {
        if ((requestList ?? []).isEmpty) {
          return SizedBox.shrink();
        }
        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeightConstrainedText(
                requestList!.isEmpty
                    ? 'No Pending Join Requests'
                    : 'Manage Join Requests (${requestList.length})',
                style: AppTextStyle.headline4,
              ),
              SizedBox(height: 8),
              if (requestList.isNotEmpty) _buildRequestList(requestList),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMembersSection() {
    return CustomStreamBuilder<List<Membership>>(
      stream: _memberships,
      entryFrom: '_MembersTabState._buildMembersSection',
      errorMessage: 'Something went wrong loading memberships. Please refresh.',
      builder: (context, allMembershipDocs) =>
          MemoizedStreamBuilder<PlanCapabilityList>(
        streamGetter: () => cloudFunctionsCommunityService
            .getCommunityCapabilities(
              GetCommunityCapabilitiesRequest(
                communityId: context.read<CommunityProvider>().communityId,
              ),
            )
            .asStream(),
        entryFrom: '_MembersTabState._buildMembersSection_2',
        builder: (context, caps) {
          final membershipList = allMembershipDocs
              ?.where((element) => !(element.invisible))
              .toList();

          final adminCapabilityCount = caps?.adminCount ?? 0;
          // Count mods + admins in total allowed admin count
          final adminCount =
              membershipList?.where((element) => element.isMod).length;
          final allowPromoteToAdmin =
              adminCount != null && adminCount < adminCapabilityCount;

          final facilitatorCapabilityCount = caps?.facilitatorCount ?? 0;
          final facilitatorCount = membershipList
              ?.where(
                (element) => element.status == MembershipStatus.facilitator,
              )
              .length;
          final allowPromoteToFacilitator = facilitatorCount != null &&
              facilitatorCount < facilitatorCapabilityCount;

          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeightConstrainedText(
                    'Manage Members (${membershipList!.length})',
                    style: AppTextStyle.headline4,
                  ),
                  Tooltip(
                    message: 'Download members data',
                    child: ActionButton(
                      height: 40,
                      minWidth: 60,
                      onPressed: () => _downloadMembersData(membershipList),
                      borderRadius: BorderRadius.circular(15),
                      padding: EdgeInsets.zero,
                      color: context.theme.colorScheme.primary,
                      icon: Icon(
                        Icons.download,
                        color: context.theme.colorScheme.onPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 400,
                      maxWidth: !responsiveLayoutService.isMobile(context)
                          ? 600
                          : 400,
                    ),
                    child: AnimatedBuilder(
                      animation: Listenable.merge(
                        [
                          ...membershipList
                              .map((m) => UserInfoProvider.forUser(m.userId)),
                          ...membershipList.map(
                            (m) => UserAdminDetailsProvider.forUser(m.userId),
                          ),
                        ],
                      ),
                      builder: (_, __) {
                        final filteredMembers =
                            _filterMemberships(membershipList);
                        if (filteredMembers.isEmpty &&
                            !isNullOrEmpty(_currentSearch)) {
                          return Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text('No matching members found.'),
                          );
                        }

                        return ListView(
                          shrinkWrap: true,
                          children: [
                            for (var i = 0; i < filteredMembers.length; i++)
                              _buildMembershipEntry(
                                i,
                                filteredMembers[i],
                                allowPromoteToAdmin,
                                allowPromoteToFacilitator,
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requiresApproval =
        context.read<CommunityProvider>().settings.requireApprovalToJoin;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        CustomStreamBuilder<List<Membership>>(
          stream: _memberships,
          entryFrom: '_MembersTabState._build',
          errorMessage:
              'Something went wrong loading memberships. Please refresh.',
          builder: (context, membershipList) =>
              _buildSearchBar(membershipList ?? []),
        ),
        SizedBox(height: 20),
        if (responsiveLayoutService.isMobile(context))
          _buildMobileView(requiresApproval: requiresApproval)
        else
          _buildDesktopView(requiresApproval: requiresApproval),
      ],
    );
  }

  Widget _buildDesktopView({required bool requiresApproval}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: CustomListView(
            children: [
              if (requiresApproval) ...[
                _buildRequestsSection(),
                SizedBox(height: 20),
              ],
              _buildMembersSection(),
            ],
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          child: _buildPermissionMessage(),
        ),
      ],
    );
  }

  Widget _buildMobileView({required bool requiresApproval}) {
    return Column(
      children: [
        CustomListView(
          children: [
            if (requiresApproval) ...[
              _buildRequestsSection(),
              SizedBox(height: 20),
            ],
            _buildMembersSection(),
          ],
        ),
        SizedBox(height: 20),
        _buildPermissionMessage(),
      ],
    );
  }

  CustomListView _buildPermissionMessage() {
    return CustomListView(
      children: [
        Text(
          'Roles',
          style: AppTextStyle.headline3,
        ),
        SizedBox(height: 20),
        RolePermissionListTile(
          title: context.l10n.roleOwner,
          icon: MembershipStatus.owner.icon(context),
          permissions: MembershipStatus.owner.permissions,
        ),
        SizedBox(height: 20),
        RolePermissionListTile(
          title: context.l10n.roleAdmin,
          icon: MembershipStatus.admin.icon(context),
          permissions: MembershipStatus.admin.permissions,
        ),
        SizedBox(height: 20),
        RolePermissionListTile(
          title: context.l10n.roleModerator,
          icon: MembershipStatus.mod.icon(context),
          permissions: MembershipStatus.mod.permissions,
        ),
        SizedBox(height: 20),
        RolePermissionListTile(
          title: context.l10n.roleFacilitator,
          icon: MembershipStatus.facilitator.icon(context),
          permissions: MembershipStatus.facilitator.permissions,
        ),
        SizedBox(height: 20),
        RolePermissionListTile(
          title: context.l10n.roleMember,
          icon: MembershipStatus.member.icon(context),
          permissions: MembershipStatus.member.permissions,
        ),
        SizedBox(height: 20),
        RolePermissionListTile(
          title: context.l10n.roleAttendee,
          icon: MembershipStatus.member.icon(context),
          permissions: MembershipStatus.attendee.permissions,
        ),
      ],
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
                  color: context.theme.colorScheme.onPrimaryContainer,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  item,
                  style: AppTextStyle.body.copyWith(
                    color: context.theme.colorScheme.onPrimaryContainer,
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
  final bool allowPromoteToAdmin;
  final bool allowPromoteToFacilitator;

  const ChangeMembershipDropdown({
    required this.membership,
    required this.allowPromoteToAdmin,
    required this.allowPromoteToFacilitator,
  });

  @override
  _ChangeMembershipDropdownState createState() =>
      _ChangeMembershipDropdownState();
}

class _ChangeMembershipDropdownState extends State<ChangeMembershipDropdown> {
  bool _isLoading = false;
  bool _showUpgradeTooltip = false;

  bool get _disableOverride =>
      widget.membership.status == MembershipStatus.owner;

  Future<void> _updateMembership(MembershipStatus? newStatus) async {
    if ((newStatus?.isMod ?? false) && !widget.allowPromoteToAdmin) {
      setState(() => _showUpgradeTooltip = true);
      return;
    } else if (newStatus == MembershipStatus.facilitator &&
        !widget.allowPromoteToFacilitator) {
      setState(() => _showUpgradeTooltip = true);
      return;
    }

    if (newStatus == MembershipStatus.nonmember) {
      final delete = await ConfirmDialog(
        mainText: 'Are you sure you want to remove member?',
      ).show(context: context);
      if (!delete) return;
    }
    setState(() => _isLoading = true);
    await alertOnError(
      context,
      () => userDataService.changeCommunityMembership(
        communityId:
            Provider.of<CommunityProvider>(context, listen: false).communityId,
        userId: widget.membership.userId,
        newStatus: newStatus!,
      ),
    );
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final disableDropdown = _isLoading || _disableOverride;
    final isMobile = responsiveLayoutService.isMobile(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isLoading)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: CustomLoadingIndicator(),
          ),
        if (!isMobile) Flexible(flex: 3, child: SizedBox()),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                width: 1,
                color: context.theme.colorScheme.onPrimaryContainer,
              ),
            ),
            child: UpgradeTooltip(
              isTooltipVisible:
                  kShowStripeFeatures ? _showUpgradeTooltip : false,
              isBelowIcon: false,
              onCloseIconTap: () => setState(() => _showUpgradeTooltip = false),
              child: DropdownButton<MembershipStatus>(
                itemHeight: null,
                value: widget.membership.status,
                icon: Icon(Icons.arrow_drop_down),
                iconSize: 24,
                elevation: 16,
                isExpanded: true,
                borderRadius: BorderRadius.circular(10),
                style: TextStyle(
                  color: disableDropdown
                      ? context.theme.colorScheme.onPrimaryContainer
                      : context.theme.colorScheme.primary,
                ),
                underline: SizedBox.shrink(),
                iconEnabledColor: context.theme.colorScheme.primary,
                onChanged: disableDropdown ? null : _updateMembership,
                selectedItemBuilder: (BuildContext context) => [
                  if (widget.membership.status == MembershipStatus.owner)
                    MembershipStatus.owner,
                  MembershipStatus.admin,
                  MembershipStatus.mod,
                  MembershipStatus.facilitator,
                  MembershipStatus.member,
                  MembershipStatus.attendee,
                  MembershipStatus.nonmember,
                ]
                    .map(
                      (value) => DropdownMenuItem<MembershipStatus>(
                        value: value,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            value.icon(context),
                            SizedBox(width: 4),
                            Text(
                              _adminStatusMap[value] ??
                                  value
                                      .toString()
                                      .replaceFirst('MembershipStatus.', '')
                                      .capitalize(),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                items: [
                  if (widget.membership.status == MembershipStatus.owner)
                    MembershipStatus.owner,
                  MembershipStatus.admin,
                  MembershipStatus.mod,
                  MembershipStatus.facilitator,
                  MembershipStatus.member,
                  MembershipStatus.attendee,
                  MembershipStatus.nonmember,
                ].map(
                  (value) {
                    final isCurrentStatus = widget.membership.status == value;
                    final isUnallowedAdminPromotion =
                        !widget.allowPromoteToAdmin && value.isMod;
                    final isUnallowedFacilitatorPromotion =
                        !widget.allowPromoteToFacilitator &&
                            value == MembershipStatus.facilitator;
                    final isDisabled = !isCurrentStatus &&
                        (isUnallowedAdminPromotion ||
                            isUnallowedFacilitatorPromotion);
                    final textStyle = AppTextStyle.body.copyWith(
                      color: isDisabled
                          ? context.theme.colorScheme.secondary.withOpacity(.5)
                          : context.theme.colorScheme.secondary,
                    );
                    return DropdownMenuItem<MembershipStatus>(
                      value: value,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          isDisabled
                              ? UpgradeIcon(isDisabledColor: true)
                              : value.icon(context),
                          SizedBox(width: 5),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                HeightConstrainedText(
                                  _adminStatusMap[value] ??
                                      value
                                          .toString()
                                          .replaceFirst('MembershipStatus.', '')
                                          .capitalize(),
                                  style: textStyle,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
      ],
    );
  }
}
