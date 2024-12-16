import 'package:flutter/material.dart';
import 'package:junto/common_widgets/junto_image.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/common_widgets/sign_in_dialog.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_asset.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';

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
                child: JuntoText(
                  'New to Frankly?',
                  style: AppTextStyle.headline4.copyWith(color: AppColor.gray1),
                ),
              ),
              SizedBox(height: 10),
              JuntoText(
                'Sign up to get started.',
                style: AppTextStyle.body.copyWith(color: AppColor.gray2),
              ),
              SizedBox(height: 30),
              _buildSignInButton(
                text: 'Sign up with email',
                image: 'media/social-email.png',
                onTap: () => SignInDialog.show(isInitializedOnEmailPassword: true),
                iconSize: 40,
                padding: 2,
              ),
              SizedBox(height: 10),
              _buildSignInButton(
                  text: 'Sign up with Google',
                  image: 'media/googleLogo.png',
                  onTap: () => userService.signInWithGoogle(),
                  leftPadding: 16,
                  padding: 12),
              SizedBox(height: 100),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignInButton(
      {String? image,
      required String text,
      required onTap,
      double iconSize = 20,
      double padding = 8.0,
      double leftPadding = 0.0}) {
    return JuntoInkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        height: 48,
        width: 311,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColor.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: leftPadding),
            if (image != null)
              JuntoImage(
                null,
                asset: AppAsset(image),
                width: iconSize,
              ),
            SizedBox(width: padding),
            JuntoText(
              text,
              style: AppTextStyle.body.copyWith(color: AppColor.darkBlue),
            )
          ],
        ),
      ),
    );
  }
}
