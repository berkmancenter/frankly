import 'package:flutter/material.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/core/widgets/navbar/user_profile_navigation.dart';
import 'package:client/features/auth/presentation/widgets/sign_in_widget.dart';
import 'package:client/core/routing/locations.dart';
import 'package:client/features/user/data/services/user_service.dart';
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
      return CustomInkWell(
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
