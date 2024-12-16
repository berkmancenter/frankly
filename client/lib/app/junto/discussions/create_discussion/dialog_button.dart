import 'package:flutter/material.dart';
import 'package:junto/app/junto/discussions/create_discussion/create_discussion_dialog_model.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:provider/provider.dart';

class DialogBackButton extends StatelessWidget {
  const DialogBackButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final allowBack = context.watch<CreateDiscussionDialogModel>().allowBack;

    return allowBack
        ? TextButton(
            onPressed: () => context.read<CreateDiscussionDialogModel>().goBack(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chevron_left,
                    color: AppColor.darkBlue,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Back',
                    style: AppTextStyle.body.copyWith(color: AppColor.darkBlue),
                  ),
                ],
              ),
            ),
          )
        : SizedBox.shrink();
  }
}

class NextOrSubmitButton extends StatelessWidget {
  const NextOrSubmitButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dialogModel = context.watch<CreateDiscussionDialogModel>();
    return Align(
      alignment: Alignment.centerRight,
      child: ActionButton(
        onPressed: () => dialogModel.isFinalPage
            ? alertOnError(context, () async {
                final discussion = await dialogModel.submit(context);
                Navigator.of(context).pop(discussion);
              })
            : dialogModel.goNext(),
        text: dialogModel.isFinalPage
            ? (dialogModel.isEdit ? 'Update Event' : 'Create Event')
            : 'Next',
      ),
    );
  }
}
