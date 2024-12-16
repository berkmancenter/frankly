import 'package:flutter/material.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/common_widgets/navbar/user_profile_navigation.dart';
import 'package:junto/common_widgets/sign_in_widget.dart';
import 'package:junto/routing/locations.dart';
import 'package:junto/services/user_service.dart';
import 'package:provider/provider.dart';

/// This detects whether the user is signed in or not, and shows either the user profile icon with
/// links to the profile or a 'Sign in' button.
class ProfileOrLogin extends StatelessWidget {
  final bool showMenuAboveIcon;

  const ProfileOrLogin({
    Key? key,
    this.showMenuAboveIcon = true,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (Provider.of<UserService>(context).isSignedIn) {
      return JuntoInkWell(
        child: UserProfileNavigation(showMenuAboveIcon: showMenuAboveIcon),
        onTap: () => routerDelegate.beamTo(
          UserSettingsLocation(
            initialSection: UserSettingsSection.profile,
          ),
        ),
      );
    } else {
      return SignInWidget();
    }
  }
}
