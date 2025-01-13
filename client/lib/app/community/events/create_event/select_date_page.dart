import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:client/app/community/events/create_event/create_event_dialog_model.dart';
import 'package:client/app/community/events/create_event/event_dialog_buttons.dart';
import 'package:client/common_widgets/custom_date_picker.dart';
import 'package:client/common_widgets/ui_migration.dart';
import 'package:client/services/services.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/utils/height_constained_text.dart';
import 'package:provider/provider.dart';

class SelectDatePage extends StatelessWidget {
  const SelectDatePage();

  @override
  Widget build(BuildContext context) {
    final dialogModel = Provider.of<CreateEventDialogModel>(context);
    final timeNow = clockService.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: HeightConstrainedText(
            'Select a day',
            style: AppTextStyle.headline1,
          ),
        ),
        SizedBox(height: 20),
        SizedBox(
          width: 380,
          height: responsiveLayoutService.isMobile(context) ? 600 : 300,
          child: UIMigration(
            whiteBackground: true,
            child: CustomDatePickerDialog(
              initialDate: dialogModel.event.scheduledTime ?? timeNow,
              firstDate: timeNow,
              lastDate: DateTime(2101),
              handleDate: (selectedDate) => dialogModel.updateScheduledTime(
                DateTimeField.combine(
                  selectedDate,
                  TimeOfDay.fromDateTime(dialogModel.scheduledTime!),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
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
