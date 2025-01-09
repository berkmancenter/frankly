import 'package:flutter/material.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_word_cloud_data.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/core/widgets/ui_migration.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';

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
      return UIMigration(
        whiteBackground: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
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
            HeightConstrainedText(
              'Participants will be asked to respond with a list of words or short phrases',
              style: AppTextStyle.body.copyWith(color: AppColor.gray2),
            ),
          ],
        ),
      );
    } else {
      return UIMigration(
        whiteBackground: true,
        child: ProxiedImage(
          null,
          asset: AppAsset.kWordCloudPlaceholderPng,
          fit: BoxFit.cover,
        ),
      );
    }
  }
}
