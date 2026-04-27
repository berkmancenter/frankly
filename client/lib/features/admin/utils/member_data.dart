import 'dart:convert';

import 'package:client/core/localization/localization_helper.dart';
import 'package:client/core/utils/visible_exception.dart';
import 'package:flutter/material.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/services.dart';
import 'package:csv/csv.dart';
import 'package:data_models/community/membership.dart';
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages
import 'package:enum_to_string/enum_to_string.dart';
import 'package:universal_html/html.dart' as html;

// Utility class for member data operations
class MemberDataUtils {
  // Downloads provided members' data as a CSV file
  static Future<void> downloadMembersData(
    BuildContext context,
    List<Membership> membershipList,
  ) async {
    if (membershipList.isEmpty) {
      return;
    }
    Future<void> downloadMembersData(List<Membership> membershipList) async {
      final membersList =
          membershipList.map((member) => member.userId).toList();

      final communityId =
          Provider.of<CommunityProvider>(context, listen: false).communityId;

      final noMembersFoundToExportMsg = context.l10n.noMembersFoundToExport;

      if (membersList.isNotEmpty) {
        await alertOnError(context, () async {
          final members = await userService.getMemberDetails(
            membersList: membersList,
            communityId: communityId,
          );
          // Export should not include Attendees or Non-members.
          final filteredMembers = members
              .where(
                (value) =>
                    value.membership?.status != MembershipStatus.attendee &&
                    value.membership?.status != MembershipStatus.owner,
              )
              .toList();
          if (filteredMembers.isNotEmpty) {
            List<List<dynamic>> rows = [];

            List<dynamic> firstRow = [];
            firstRow.add('#');
            firstRow.add('Name');
            firstRow.add('Email');
            firstRow.add('Member status');
            rows.add(firstRow);

            for (var member in filteredMembers) {
              final memberIndex = filteredMembers.indexOf(member);
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
          } else {
            throw VisibleException(noMembersFoundToExportMsg);
          }
        });
      } else {
        throw VisibleException(noMembersFoundToExportMsg);
      }
    }

    await downloadMembersData(membershipList);
  }
}
