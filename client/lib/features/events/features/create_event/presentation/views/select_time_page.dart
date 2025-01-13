import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:client/features/events/features/create_event/data/providers/create_event_dialog_model.dart';
import 'package:client/features/events/features/create_event/presentation/widgets/event_dialog_buttons.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/features/events/features/create_event/presentation/widgets/custom_time_picker.dart';
import 'package:client/core/widgets/ui_migration.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:client/core/utils/platform_utils.dart';
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
    final dialogModel = context.watch<CreateEventDialogModel>();
    final scheduledTime = dialogModel.scheduledTime;
    final timezone = getTimezoneAbbreviation(scheduledTime!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: HeightConstrainedText(
            'Select a time',
            style: AppTextStyle.headline1,
          ),
        ),
        SizedBox(height: 2),
        UIMigration(
          whiteBackground: true,
          child: CustomTimePickerDialog(
            helpText: '',
            initialTime: TimeOfDay.fromDateTime(scheduledTime),
            selectedTimeOfDay: (selectedTime) {
              final selectedDateTime =
                  DateTimeField.combine(scheduledTime, selectedTime);
              dialogModel.updateScheduledTime(selectedDateTime);
            },
          ),
        ),
        HeightConstrainedText(
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
