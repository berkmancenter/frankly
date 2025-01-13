import 'package:flutter/material.dart';
import 'package:client/app/community/events/create_event/create_event_dialog_model.dart';
import 'package:client/app/community/events/create_event/event_dialog_buttons.dart';
import 'package:client/app/community/utils.dart';
import 'package:client/common_widgets/custom_text_field.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/utils/height_constained_text.dart';
import 'package:provider/provider.dart';

class SelectTitlePage extends StatefulWidget {
  const SelectTitlePage({Key? key}) : super(key: key);

  @override
  _SelectTitlePageState createState() => _SelectTitlePageState();
}

class _SelectTitlePageState extends State<SelectTitlePage> {
  CreateEventDialogModel get editProvider =>
      Provider.of<CreateEventDialogModel>(context);
  CreateEventDialogModel get editProviderRead =>
      Provider.of<CreateEventDialogModel>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: HeightConstrainedText(
            'Enter a title',
            style: AppTextStyle.headline1,
          ),
        ),
        SizedBox(height: 15),
        CustomTextField(
          maxLines: 1,
          maxLength: titleMaxCharactersLength,
          labelText: 'Title',
          initialValue: editProvider.event.title,
          onChanged: (value) => editProviderRead.setEvent(
            editProviderRead.event.copyWith(title: value),
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
