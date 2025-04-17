import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:client/features/community/data/providers/community_permissions_provider.dart';
import 'package:client/features/events/features/create_event/data/providers/create_event_dialog_model.dart';
import 'package:client/features/events/features/create_event/presentation/widgets/event_dialog_buttons.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:provider/provider.dart';

class SelectParticipantsNumber extends StatefulWidget {
  const SelectParticipantsNumber();

  @override
  State<SelectParticipantsNumber> createState() =>
      _SelectParticipantsNumberState();
}

class _SelectParticipantsNumberState extends State<SelectParticipantsNumber> {
  CreateEventDialogModel get editProvider =>
      Provider.of<CreateEventDialogModel>(context);

  CreateEventDialogModel get editProviderRead =>
      Provider.of<CreateEventDialogModel>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    final maxParticipants =
        Provider.of<CommunityPermissionsProvider>(context).canCreateLargeEvents
            ? 50
            : 20;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: HeightConstrainedText(
            'How many people',
            style: AppTextStyle.headline1,
          ),
        ),
        SizedBox(height: 10),
        FormBuilderSlider(
          activeColor: AppColor.brightGreen,
          inactiveColor: context.theme.colorScheme.onPrimaryContainer,
          decoration: InputDecoration(
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent, width: 0),
            ),
            border: const OutlineInputBorder(),
            labelStyle: TextStyle(color: context.theme.colorScheme.primary),
          ),
          initialValue: editProvider.event.maxParticipants?.toDouble() ?? 8,
          min: 2,
          numberFormat: NumberFormat('##'),
          max: maxParticipants.toDouble(),
          divisions: maxParticipants - 2,
          onChanged: (value) => editProviderRead.setEvent(
            editProviderRead.event
                .copyWith(maxParticipants: value?.round() ?? 0),
          ),
          name: 'num_participants',
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
