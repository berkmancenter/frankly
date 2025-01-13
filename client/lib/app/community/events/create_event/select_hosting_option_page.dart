import 'package:flutter/material.dart';
import 'package:client/app/community/events/create_event/create_event_dialog_model.dart';
import 'package:client/app/community/events/create_event/event_dialog_buttons.dart';
import 'package:client/common_widgets/hosting_option.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/utils/height_constained_text.dart';
import 'package:provider/provider.dart';

class SelectHostingOptionPage extends StatelessWidget {
  const SelectHostingOptionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: HeightConstrainedText(
            'Hosting option',
            style: AppTextStyle.headline1,
          ),
        ),
        SizedBox(height: 15),
        Center(
          child: HostingOption(
            selectedEventType: (option) {
              context.read<CreateEventDialogModel>().updateEventType(option!);
            },
            isHostlessEnabled: context
                .watch<CreateEventDialogModel>()
                .communityProvider
                .enableHostless,
            initialHostingOption:
                context.read<CreateEventDialogModel>().event.eventType,
            isWhiteBackground: true,
          ),
        ),
        SizedBox(height: 20),
        NextOrSubmitButton(),
      ],
    );
  }
}
