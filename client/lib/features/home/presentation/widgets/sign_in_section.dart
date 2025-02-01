import 'package:client/features/auth/presentation/widgets/sign_in_options_content.dart';
import 'package:flutter/material.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/features/auth/presentation/views/sign_in_dialog.dart';
import 'package:client/config/environment.dart';
import 'package:client/services.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';

class HomePageSignInSection extends StatefulWidget {
  const HomePageSignInSection({Key? key}) : super(key: key);

  @override
  _HomePageSignInSectionState createState() => _HomePageSignInSectionState();
}

class _HomePageSignInSectionState extends State<HomePageSignInSection> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 45),
              SizedBox(
                width: 300,
                child: SignInOptionsContent(
                  isNewUser: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
