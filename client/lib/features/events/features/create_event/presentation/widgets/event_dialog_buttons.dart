import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:client/features/events/features/create_event/data/providers/create_event_dialog_model.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:provider/provider.dart';
import 'package:client/core/localization/localization_helper.dart';

class DialogBackButton extends StatelessWidget {
  const DialogBackButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final allowBack = context.watch<CreateEventDialogModel>().allowBack;

    return allowBack
        ? TextButton(
            onPressed: () => context.read<CreateEventDialogModel>().goBack(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chevron_left,
                    color: context.theme.colorScheme.primary,
                  ),
                  SizedBox(width: 10),
                  Text(
                    context.l10n.back,
                    style: AppTextStyle.body
                        .copyWith(color: context.theme.colorScheme.primary),
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
    final dialogModel = context.watch<CreateEventDialogModel>();
    return Align(
      alignment: Alignment.centerRight,
      child: ActionButton(
        onPressed: () => dialogModel.isFinalPage
            ? alertOnError(context, () async {
                final event = await dialogModel.submit(context);
                Navigator.of(context).pop(event);
              })
            : dialogModel.goNext(),
        text: dialogModel.isFinalPage
            ? (dialogModel.isEdit ? context.l10n.updateEvent : context.l10n.createEvent)
            : context.l10n.next,
      ),
    );
  }
}
