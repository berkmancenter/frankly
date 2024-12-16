import 'package:flutter/material.dart';
import 'package:junto/app/junto/discussions/create_discussion/create_discussion_dialog_model.dart';
import 'package:junto/app/junto/discussions/create_discussion/dialog_button.dart';
import 'package:junto/common_widgets/hosting_option.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:provider/provider.dart';

class SelectHostingOptionPage extends StatelessWidget {
  const SelectHostingOptionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: JuntoText(
            'Hosting option',
            style: AppTextStyle.headline1,
          ),
        ),
        SizedBox(height: 15),
        Center(
          child: HostingOption(
            selectedDiscussionType: (option) {
              context.read<CreateDiscussionDialogModel>().updateDiscussionType(option!);
            },
            isHostlessEnabled:
                context.watch<CreateDiscussionDialogModel>().juntoProvider.enableHostless,
            initialHostingOption:
                context.read<CreateDiscussionDialogModel>().discussion.discussionType,
            isWhiteBackground: true,
          ),
        ),
        SizedBox(height: 20),
        NextOrSubmitButton(),
      ],
    );
  }
}
