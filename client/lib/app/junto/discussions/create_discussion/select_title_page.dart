import 'package:flutter/material.dart';
import 'package:junto/app/junto/discussions/create_discussion/create_discussion_dialog_model.dart';
import 'package:junto/app/junto/discussions/create_discussion/dialog_button.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/junto_text_field.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:provider/provider.dart';

class SelectTitlePage extends StatefulWidget {
  const SelectTitlePage({Key? key}) : super(key: key);

  @override
  _SelectTitlePageState createState() => _SelectTitlePageState();
}

class _SelectTitlePageState extends State<SelectTitlePage> {
  CreateDiscussionDialogModel get editProvider => Provider.of<CreateDiscussionDialogModel>(context);
  CreateDiscussionDialogModel get editProviderRead =>
      Provider.of<CreateDiscussionDialogModel>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: JuntoText(
            'Enter a title',
            style: AppTextStyle.headline1,
          ),
        ),
        SizedBox(height: 15),
        JuntoTextField(
          maxLines: 1,
          maxLength: titleMaxCharactersLength,
          labelText: 'Title',
          initialValue: editProvider.discussion.title,
          onChanged: (value) =>
              editProviderRead.setDiscussion(editProviderRead.discussion.copyWith(title: value)),
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
