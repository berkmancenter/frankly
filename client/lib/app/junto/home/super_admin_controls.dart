import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/services/junto_user_data_service.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/extensions.dart';
import 'package:junto_models/firestore/membership.dart';
import 'package:provider/provider.dart';
import 'package:enum_to_string/enum_to_string.dart';

class SuperAdminControls extends StatefulWidget {
  const SuperAdminControls({Key? key}) : super(key: key);

  @override
  State<SuperAdminControls> createState() => _SuperAdminRowState();
}

class _SuperAdminRowState extends State<SuperAdminControls> {
  bool _expanded = false;

  void _setMembership(MembershipStatus status) async {
    await alertOnError(
        context,
        () => juntoUserDataService.changeJuntoMembership(
              juntoId: Provider.of<JuntoProvider>(context, listen: false).juntoId,
              userId: userService.currentUserId!,
              newStatus: status,
            ));
  }

  @override
  Widget build(BuildContext context) {
    final juntoId = context.watch<JuntoProvider>().juntoId;
    final currentStatus = context.watch<JuntoUserDataService>().getMembership(juntoId);

    if (!_expanded) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: _buildOpenButton(),
        ),
      );
    }
    return Row(
      children: [
        SizedBox(width: 20),
        for (final status in MembershipStatus.values.take(MembershipStatus.values.length - 1)) ...[
          JuntoInkWell(
            onTap: () => _setMembership(status),
            child: Container(
              padding: EdgeInsets.only(bottom: 5),
              decoration: currentStatus.status == status
                  ? BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppColor.black, width: 2)),
                    )
                  : null,
              child: Tooltip(
                message: EnumToString.convertToString(status),
                child: status.icon,
              ),
            ),
          ),
          SizedBox(width: 10),
        ],
        _buildCloseButton(),
      ],
    );
  }

  Widget _buildOpenButton() => GestureDetector(
        onTap: () => setState(() => _expanded = true),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColor.white,
          ),
          width: 30,
          height: 30,
          alignment: Alignment.center,
          child: Icon(Icons.arrow_forward_ios),
        ),
      );

  Widget _buildCloseButton() => GestureDetector(
        child: Icon(
          Icons.arrow_back_ios,
          color: AppColor.black,
        ),
        onTap: () => setState(() => _expanded = false),
      );
}
