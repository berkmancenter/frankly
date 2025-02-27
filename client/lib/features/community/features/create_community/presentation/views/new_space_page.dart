import 'package:flutter/material.dart';
import 'package:client/features/community/features/create_community/presentation/widgets/freemium_dialog_flow.dart';
import 'package:client/core/widgets/ui_migration.dart';
import 'package:client/core/widgets/navbar/custom_scaffold.dart';
import 'package:client/features/auth/presentation/views/sign_in_dialog.dart';
import 'package:client/features/auth/presentation/widgets/sign_in_widget.dart';
import 'package:client/services.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:client/core/widgets/height_constained_text.dart';
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
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
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
            HeightConstrainedText('Please log in or sign up'),
            SizedBox(height: 20),
            SignInWidget(),
          ],
        ),
      );
    }
    return UIMigration(
      child: CustomScaffold(
        child: FreemiumDialogFlow(showAppNameOnMobile: false),
      ),
    );
  }
}
