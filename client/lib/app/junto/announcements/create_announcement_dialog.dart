import 'package:flutter/material.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/create_dialog_ui_migration.dart';
import 'package:junto/common_widgets/junto_list_view.dart';
import 'package:junto/common_widgets/junto_text_field.dart';
import 'package:junto/services/services.dart';
import 'package:junto/utils/junto_text.dart';

class CreateAnnouncementDialog extends StatefulWidget {
  final String juntoId;

  const CreateAnnouncementDialog({required this.juntoId});

  static Future<void> show({required String juntoId}) async {
    return CreateDialogUiMigration(
      builder: (_) => CreateAnnouncementDialog(juntoId: juntoId),
    ).show();
  }

  @override
  _CreateAnnouncementDialogState createState() => _CreateAnnouncementDialogState();
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
          juntoId: widget.juntoId,
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
        child: JuntoListView(
          padding: EdgeInsets.all(30),
          children: [
            SizedBox(height: 50),
            JuntoText(
              'Create New Announcement',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            JuntoTextField(
              labelText: 'Enter a title',
              onChanged: (value) => setState(() => _title = value),
            ),
            JuntoTextField(
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
