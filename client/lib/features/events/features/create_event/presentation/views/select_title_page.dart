import 'package:flutter/material.dart';
import 'package:client/features/events/features/create_event/data/providers/create_event_dialog_model.dart';
import 'package:client/features/events/features/create_event/presentation/widgets/event_dialog_buttons.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/styles/styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:provider/provider.dart';
import 'package:client/core/localization/localization_helper.dart';

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
  final int titleMaxCharactersLength = 80;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: HeightConstrainedText(
            context.l10n.enterTitle,
            style: AppTextStyle.headline1,
          ),
        ),
        SizedBox(height: 15),
        CustomTextField(
          maxLines: 1,
          maxLength: titleMaxCharactersLength,
          labelText: context.l10n.title,
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
