import 'package:flutter/material.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/agenda_item_card/items/word_cloud/agenda_item_word_cloud_data.dart';
import 'package:junto/common_widgets/junto_image.dart';
import 'package:junto/common_widgets/junto_text_field.dart';
import 'package:junto/common_widgets/junto_ui_migration.dart';
import 'package:junto/styles/app_asset.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';

class AgendaItemWordCloud extends StatelessWidget {
  final bool isEditMode;
  final AgendaItemWordCloudData wordCloudData;
  final void Function(AgendaItemWordCloudData) onChanged;

  const AgendaItemWordCloud({
    Key? key,
    required this.isEditMode,
    required this.wordCloudData,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isEditMode) {
      return JuntoUiMigration(
        whiteBackground: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            JuntoTextField(
              initialValue: wordCloudData.prompt,
              labelText: 'Word Cloud Prompt',
              hintText: 'Enter Word Cloud prompt',
              maxLines: null,
              onChanged: (value) {
                wordCloudData.prompt = value;
                onChanged(wordCloudData);
              },
            ),
            SizedBox(height: 20),
            JuntoText(
              'Participants will be asked to respond with a list of words or short phrases',
              style: AppTextStyle.body.copyWith(color: AppColor.gray2),
            ),
          ],
        ),
      );
    } else {
      return JuntoUiMigration(
        whiteBackground: true,
        child: JuntoImage(
          null,
          asset: AppAsset.kWordCloudPlaceholderPng,
          fit: BoxFit.cover,
        ),
      );
    }
  }
}
