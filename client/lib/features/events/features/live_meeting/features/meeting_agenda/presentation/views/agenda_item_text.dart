import 'package:client/core/utils/navigation_utils.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/utils/agenda_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_text_data.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/styles/styles.dart';

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
            counterStyle: context.theme.textTheme.labelMedium,
            onChanged: (value) {
              agendaItemTextData.title = value;
              onChanged(agendaItemTextData);
            },
          ),
          SizedBox(height: 20),
          CustomTextField(
            initialValue: agendaItemTextData.content,
            labelText: 'Content',
            hintText:
                'Keep it short! You don’t want people to spend time reading.',
            maxLines: null,
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
          MarkdownBody(
            data: agendaItemTextData.content.replaceAll('\n', '\n\n'),
            shrinkWrap: true,
            selectable: true,
            onTapLink: (text, href, _) {
              if (href != null) {
                launch(href);
              }
            },
          ),
        ],
      );
    }
  }
}
