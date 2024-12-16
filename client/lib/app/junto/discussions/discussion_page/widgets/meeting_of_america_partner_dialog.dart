import 'package:flutter/material.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/create_dialog_ui_migration.dart';
import 'package:junto/common_widgets/junto_ui_migration.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto/utils/stream_utils.dart';
import 'package:junto_models/firestore/external_partners.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class MeetingOfAmericaPartnerDialog extends StatefulWidget {
  const MeetingOfAmericaPartnerDialog({Key? key}) : super(key: key);

  static Future<String?> show() => CreateDialogUiMigration<String?>(
        builder: (context) => PointerInterceptor(child: MeetingOfAmericaPartnerDialog()),
      ).show();

  @override
  State<MeetingOfAmericaPartnerDialog> createState() => _MeetingOfAmericaPartnerDialogState();
}

class _MeetingOfAmericaPartnerDialogState extends State<MeetingOfAmericaPartnerDialog> {
  String? _selectedPartner;

  @override
  Widget build(BuildContext context) {
    const spacerHeight = 20.0;

    return JuntoUiMigration(
      whiteBackground: true,
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 40),
            JuntoText(
              'How did you first hear about Meeting of America?',
              style: AppTextStyle.headline3,
            ),
            SizedBox(height: spacerHeight),
            Center(
              child: _buildPartnerDropdown(),
            ),
            SizedBox(height: spacerHeight),
            Align(
              alignment: Alignment.centerRight,
              child: ActionButton(
                color: _selectedPartner != null ? AppColor.brightGreen : AppColor.gray4,
                onPressed: _selectedPartner != null
                    ? () => Navigator.of(context).pop(_selectedPartner)
                    : null,
                text: 'Submit',
              ),
            ),
            SizedBox(height: spacerHeight),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerDropdown() {
    return JuntoStreamGetterBuilder<MeetingOfAmerica>(
      streamGetter: () => firestoreExternalPartnersService.getMeetingOfAmerica().asStream(),
      builder: (_, moaInfo) => DropdownButton<String>(
        value: _selectedPartner,
        icon: Icon(Icons.arrow_drop_down),
        iconSize: 24,
        elevation: 16,
        style: TextStyle(color: AppColor.darkBlue),
        underline: Container(height: 2, color: AppColor.darkBlue),
        iconEnabledColor: AppColor.darkBlue,
        onChanged: (value) => setState(() => _selectedPartner = value),
        hint: DropdownMenuItem<String>(
          child: Text(
            'Select an option',
            style: AppTextStyle.body,
          ),
        ),
        selectedItemBuilder: (_) => [
          for (final partner in moaInfo!.pilotPartners)
            DropdownMenuItem<String>(
              value: partner,
              child: Text(
                partner,
                style: AppTextStyle.body,
              ),
            ),
        ],
        items: [
          for (final partner in moaInfo!.pilotPartners)
            DropdownMenuItem<String>(
              value: partner,
              child: Text(
                partner,
                style: AppTextStyle.body.copyWith(
                  color: AppColor.darkBlue,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
