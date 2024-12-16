import 'package:flutter/material.dart';
import 'package:junto/app/home/creation_dialog/freemium_dialog_flow.dart';
import 'package:junto/common_widgets/junto_ui_migration.dart';
import 'package:junto/common_widgets/navbar/junto_scaffold.dart';
import 'package:junto/common_widgets/sign_in_dialog.dart';
import 'package:junto/common_widgets/sign_in_widget.dart';
import 'package:junto/services/services.dart';
import 'package:junto/services/user_service.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:provider/src/provider.dart';

class NewSpacePage extends StatefulWidget {
  const NewSpacePage({Key? key}) : super(key: key);

  @override
  State<NewSpacePage> createState() => _NewSpacePageState();
}

class _NewSpacePageState extends State<NewSpacePage> {
  @override
  void initState() {
    if (!userService.isSignedIn) {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        SignInDialog.show(isDismissable: false);
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!context.watch<UserService>().isSignedIn) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            JuntoText('Please log in or sign up'),
            SizedBox(height: 20),
            SignInWidget(),
          ],
        ),
      );
    }
    return JuntoUiMigration(
      whiteBackground: true,
      child: JuntoScaffold(
        child: FreemiumDialogFlow(showAppNameOnMobile: false),
      ),
    );
  }
}
