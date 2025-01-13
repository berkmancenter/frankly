import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/data/providers/dialog_provider.dart';
import 'package:client/core/widgets/height_constained_text.dart';

class KickDialogResult {
  final bool kickParticipant;
  final bool lockRoom;

  KickDialogResult({required this.kickParticipant, required this.lockRoom});
}

class KickDialog extends StatefulWidget {
  final String? userName;

  const KickDialog({this.userName});

  Future<KickDialogResult?> show() async {
    return showCustomDialog<KickDialogResult?>(
      builder: (_) => this,
    );
  }

  @override
  _KickDialogState createState() => _KickDialogState();
}

class _KickDialogState extends State<KickDialog> {
  var _lockRoom = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColor.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Color(0xFF5568FF),
          width: 5,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 12),
      title: Text('Remove Participant'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HeightConstrainedText(
              'Remove ${widget.userName ?? 'this user'} from the meeting? '
              'They will not be able to rejoin.'),
          FormBuilderCheckbox(
            name: 'lock',
            onChanged: (value) => _lockRoom = value ?? false,
            initialValue: false,
            decoration: InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
            ),
            title: HeightConstrainedText(
              'Lock room to prevent any new registrants from joining?',
            ),
          ),
        ],
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: TextButton(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Text('Remove Participant'),
            ),
            onPressed: () => Navigator.of(context).pop(
              KickDialogResult(
                kickParticipant: true,
                lockRoom: _lockRoom,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: TextButton(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Text('No, Cancel'),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }
}
