import 'package:client/common_widgets/sign_in_options_content.dart';
import 'package:flutter/material.dart';
import 'package:client/common_widgets/proxied_image.dart';
import 'package:client/common_widgets/custom_ink_well.dart';
import 'package:client/common_widgets/sign_in_dialog.dart';
import 'package:client/environment.dart';
import 'package:client/services/services.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/utils/height_constained_text.dart';

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
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 45),
              Align(
                alignment: Alignment.centerLeft,
                child: HeightConstrainedText(
                  'New to ${Environment.appName}?',
                  style: AppTextStyle.headline4.copyWith(color: AppColor.gray1),
                ),
              ),
              SizedBox(height: 10),
              HeightConstrainedText(
                'Sign up to get started.',
                style: AppTextStyle.body.copyWith(color: AppColor.gray2),
              ),
              SizedBox(
                width: 300,
                child: SignInOptionsContent(
                  isNewUser: true,
                  showHeader: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
