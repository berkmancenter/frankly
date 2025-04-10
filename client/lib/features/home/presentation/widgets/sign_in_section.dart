import 'package:client/features/auth/presentation/widgets/sign_in_options_content.dart';
import 'package:flutter/material.dart';

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
                  openDialogOnEmailProviderSelected: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
