import 'package:client/core/utils/error_utils.dart';
import 'package:flutter/material.dart';
import 'package:client/core/widgets/action_button.dart';
import 'package:client/core/widgets/create_dialog_ui_migration.dart';
import 'package:client/core/widgets/custom_list_view.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/services.dart';
import 'package:client/core/widgets/height_constained_text.dart';

class CreateAnnouncementDialog extends StatefulWidget {
  final String communityId;

  const CreateAnnouncementDialog({required this.communityId});

  static Future<void> show({required String communityId}) async {
    return CreateDialogUiMigration(
      builder: (_) => CreateAnnouncementDialog(communityId: communityId),
    ).show();
  }

  @override
  _CreateAnnouncementDialogState createState() =>
      _CreateAnnouncementDialogState();
}

class _CreateAnnouncementDialogState extends State<CreateAnnouncementDialog> {
  final _emailToMembers = false;
  String _title = '';
  String _message = '';

  Future<void> _createAnnouncement() async {
    return alertOnError(
      context,
      () async {
        await firestoreAnnouncementsService.createAnnouncement(
          communityId: widget.communityId,
          title: _title,
          message: _message,
          emailToMembers: _emailToMembers,
        );

        Navigator.of(context).pop();
      },
    );
  }

  Widget _buildCurrentPage() {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 600),
        child: CustomListView(
          padding: EdgeInsets.all(30),
          children: [
            SizedBox(height: 50),
            HeightConstrainedText(
              'Create New Announcement',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            CustomTextField(
              labelText: 'Enter a title',
              onChanged: (value) => setState(() => _title = value),
            ),
            CustomTextField(
              labelText: 'Enter a message',
              minLines: 4,
              maxLines: 8,
              onChanged: (value) => setState(() => _message = value),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ActionButton(
                    onPressed: _createAnnouncement,
                    color: Theme.of(context).primaryColor,
                    text: 'Create',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildCurrentPage();
  }
}
