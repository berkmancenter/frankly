import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:junto/app/junto/discussions/create_discussion/create_discussion_dialog_model.dart';
import 'package:junto/app/junto/discussions/create_discussion/dialog_button.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/custom_time_picker.dart';
import 'package:junto/common_widgets/junto_ui_migration.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto/utils/platform_utils.dart';
import 'package:provider/provider.dart';

class SelectTimePage extends StatefulWidget {
  final bool isEdit;

  const SelectTimePage({this.isEdit = false});

  @override
  _SelectTimePageState createState() => _SelectTimePageState();
}

class _SelectTimePageState extends State<SelectTimePage> {
  @override
  Widget build(BuildContext context) {
    final dialogModel = context.watch<CreateDiscussionDialogModel>();
    final scheduledTime = dialogModel.scheduledTime;
    final timezone = getTimezoneAbbreviation(scheduledTime!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: JuntoText(
            'Select a time',
            style: AppTextStyle.headline1,
          ),
        ),
        SizedBox(height: 2),
        JuntoUiMigration(
          whiteBackground: true,
          child: CustomTimePickerDialog(
            helpText: '',
            initialTime: TimeOfDay.fromDateTime(scheduledTime),
            selectedTimeOfDay: (selectedTime) {
              final selectedDateTime = DateTimeField.combine(scheduledTime, selectedTime);
              dialogModel.updateScheduledTime(selectedDateTime);
            },
          ),
        ),
        JuntoText(
          isNullOrEmpty(timezone) ? '' : 'Time shown in $timezone',
          textAlign: TextAlign.right,
        ),
        SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            DialogBackButton(),
            NextOrSubmitButton(),
          ],
        ),
      ],
    );
  }
}
