import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:junto/app/junto/discussions/create_discussion/create_discussion_dialog_model.dart';
import 'package:junto/app/junto/discussions/create_discussion/dialog_button.dart';
import 'package:junto/common_widgets/custom_date_picker.dart';
import 'package:junto/common_widgets/junto_ui_migration.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:provider/provider.dart';

class SelectDatePage extends StatelessWidget {
  const SelectDatePage();

  @override
  Widget build(BuildContext context) {
    final dialogModel = Provider.of<CreateDiscussionDialogModel>(context);
    final timeNow = clockService.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: JuntoText(
            'Select a day',
            style: AppTextStyle.headline1,
          ),
        ),
        SizedBox(height: 20),
        SizedBox(
            width: 380,
            height: responsiveLayoutService.isMobile(context) ? 600 : 300,
            child: JuntoUiMigration(
              whiteBackground: true,
              child: CustomDatePickerDialog(
                initialDate: dialogModel.discussion.scheduledTime ?? timeNow,
                firstDate: timeNow,
                lastDate: DateTime(2101),
                handleDate: (selectedDate) => dialogModel.updateScheduledTime(DateTimeField.combine(
                  selectedDate,
                  TimeOfDay.fromDateTime(dialogModel.scheduledTime!),
                )),
              ),
            )),
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
