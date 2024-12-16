import 'package:flutter/material.dart';
import 'package:junto/app/home/creation_dialog/create_junto_dialog.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/stream_utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/plan_capability_list.dart';
import 'package:provider/provider.dart';

class EditCommunityButton extends StatefulWidget {
  const EditCommunityButton({Key? key}) : super(key: key);

  @override
  State<EditCommunityButton> createState() => _EditCommunityButtonState();
}

class _EditCommunityButtonState extends State<EditCommunityButton> {
  void _editTapped({bool canSetDisplayId = false}) => CreateJuntoDialog.updateJunto(
        junto: context.read<JuntoProvider>().junto,
        showChooseCustomDisplayId: canSetDisplayId,
      ).show();

  @override
  Widget build(BuildContext context) {
    return JuntoStreamGetterBuilder<PlanCapabilityList>(
      entryFrom: 'EditCommunityButton._buildEditButton',
      showLoading: false,
      streamGetter: () => cloudFunctionsService
          .getJuntoCapabilities(
            GetJuntoCapabilitiesRequest(juntoId: Provider.of<JuntoProvider>(context).juntoId),
          )
          .asStream(),
      builder: (context, caps) {
        return JuntoInkWell(
          onTap: () => _editTapped(canSetDisplayId: caps?.hasCustomUrls ?? false),
          borderRadius: BorderRadius.circular(15),
          child: Container(
            alignment: Alignment.center,
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.edit,
              color: AppColor.gray1,
              size: 20,
            ),
          ),
        );
      },
    );
  }
}
