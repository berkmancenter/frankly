import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:junto/app/junto/community_permissions_provider.dart';
import 'package:junto/app/junto/discussions/create_discussion/create_discussion_dialog_model.dart';
import 'package:junto/app/junto/discussions/create_discussion/dialog_button.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:provider/provider.dart';

class SelectParticipantsNumber extends StatefulWidget {
  const SelectParticipantsNumber();

  @override
  State<SelectParticipantsNumber> createState() => _SelectParticipantsNumberState();
}

class _SelectParticipantsNumberState extends State<SelectParticipantsNumber> {
  CreateDiscussionDialogModel get editProvider => Provider.of<CreateDiscussionDialogModel>(context);

  CreateDiscussionDialogModel get editProviderRead =>
      Provider.of<CreateDiscussionDialogModel>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    final maxParticipants =
        Provider.of<CommunityPermissionsProvider>(context).canCreateLargeEvents ? 50 : 20;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: JuntoText(
            'How many people',
            style: AppTextStyle.headline1,
          ),
        ),
        SizedBox(height: 10),
        FormBuilderSlider(
          activeColor: AppColor.brightGreen,
          inactiveColor: AppColor.gray4,
          decoration: InputDecoration(
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent, width: 0),
            ),
            border: const OutlineInputBorder(),
            labelStyle: TextStyle(color: AppColor.darkBlue),
          ),
          initialValue: editProvider.discussion.maxParticipants?.toDouble() ?? 8,
          min: 2,
          numberFormat: NumberFormat('##'),
          max: maxParticipants.toDouble(),
          divisions: maxParticipants - 2,
          onChanged: (value) => editProviderRead.setDiscussion(
            editProviderRead.discussion.copyWith(maxParticipants: value?.round() ?? 0),
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
