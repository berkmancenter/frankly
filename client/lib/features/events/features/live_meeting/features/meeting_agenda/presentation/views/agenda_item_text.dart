import 'package:client/core/utils/navigation_utils.dart';
import 'package:client/core/widgets/markdown_serializing_text_editor.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/utils/agenda_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_text_data.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/core/widgets/ui_migration.dart';
import 'package:client/styles/app_styles.dart';

class AgendaItemText extends StatelessWidget {
  final bool isEditMode;
  final AgendaItemTextData agendaItemTextData;
  final void Function(AgendaItemTextData) onChanged;

  const AgendaItemText({
    Key? key,
    required this.isEditMode,
    required this.agendaItemTextData,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isEditMode) {
      return Column(
        children: [
          CustomTextField(
            initialValue: agendaItemTextData.title,
            labelText: 'Title',
            maxLength: agendaTitleCharactersLength,
            maxLines: 1,
            counterStyle: AppTextStyle.bodySmall.copyWith(
              color: AppColor.darkBlue,
            ),
            onChanged: (value) {
              agendaItemTextData.title = value;
              onChanged(agendaItemTextData);
            },
          ),
          SizedBox(height: 20),
          MarkdownSerializingTextEditor(
            initialValue: agendaItemTextData.content,
            onChanged: (value) {
              agendaItemTextData.content = value;
              onChanged(agendaItemTextData);
            },
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UIMigration(
            whiteBackground: true,
            child: MarkdownBody(
              data: agendaItemTextData.content,
              shrinkWrap: true,
              selectable: true,
              onTapLink: (text, href, _) {
                if (href != null) {
                  launch(href);
                }
              },
            ),
          ),
        ],
      );
    }
  }
}
