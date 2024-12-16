import 'package:flutter/material.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/common_widgets/junto_ui_migration.dart';
import 'package:junto/common_widgets/user_profile_chip.dart';
import 'package:junto/routing/locations.dart';
import 'package:junto/services/services.dart';
import 'package:junto/services/user_service.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/dialog_provider.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:provider/provider.dart';

/// This is the user profile icon. If hovered over (or tapped on mobile / touchscreen) a menu will
/// appear above or below it with options to select from.
class UserProfileNavigation extends StatefulWidget {
  /// If true, the profile menu will appear above the user icon instead of below it when activated
  final bool showMenuAboveIcon;

  const UserProfileNavigation({
    Key? key,
    this.showMenuAboveIcon = false,
  }) : super(key: key);

  @override
  _UserProfileNavigationState createState() => _UserProfileNavigationState();
}

class _UserProfileNavigationState extends State<UserProfileNavigation> {
  final _buttonGlobalKey = GlobalKey();
  bool _isExiting = false;
  bool _isShowing = false;

  Future<void> _showOptionsFloating() async {
    final RenderBox button = _buttonGlobalKey.currentContext?.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay?.context.findRenderObject() as RenderBox;

    final RelativeRect position;

    position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    _isExiting = false;
    await showJuntoDialog(
      context: context,
      barrierColor: AppColor.black.withOpacity(0.3),
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: JuntoInkWell(
              hoverColor: Colors.transparent,
              onTap: () {
                Navigator.of(context).pop();
              },
              onHover: (hover) {
                if (hover && !_isExiting) {
                  _isExiting = true;
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
          // Absorb mouse region over the button
          Positioned.fromRelativeRect(
            rect: position,
            child: MouseRegion(),
          ),
          Positioned(
            width: 200.0,
            right: position.right - 60,
            bottom: widget.showMenuAboveIcon
                ? position.bottom + position.toSize(overlay.size).height
                : null,
            top: widget.showMenuAboveIcon
                ? null
                : position.top + position.toSize(overlay.size).height,
            child: MouseRegion(
              child: Container(
                constraints: BoxConstraints(maxHeight: 400),
                color: AppColor.white,
                child: JuntoUiMigration(
                  whiteBackground: true,
                  child: ProfileNavigationList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _profileActivated() async {
    _isShowing = true;
    await _showOptionsFloating();
    _isShowing = false;
  }

  Widget _buildProfileButton() {
    return JuntoInkWell(
      onHover: (hover) async {
        if (hover && !_isShowing) {
          return _profileActivated();
        }
      },
      // Register on tap events in case of touchscreens
      onTap: _profileActivated,
      child: Center(
        child: Semantics(
          button: true,
          label: 'Profile Button',
          child: Container(
            key: _buttonGlobalKey,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: UserProfileChip(
                userId: Provider.of<UserService>(context).currentUserId,
                customAction: _profileActivated,
                showName: false,
                imageHeight: 38,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildProfileButton();
  }
}

class ProfileNavigationList extends StatelessWidget {
  Widget _buildNavButton(
    BuildContext context,
    String text,
    void Function()? onTap, {
    Color? color,
  }) {
    return JuntoInkWell(
      onTap: () {
        Navigator.of(context).pop();

        if (onTap != null) onTap();
      },
      hoverColor: Theme.of(context).primaryColor.withOpacity(0.3),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        color: color,
        alignment: Alignment.centerLeft,
        child: JuntoText(
          text,
          textAlign: TextAlign.start,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = userService.currentUserId;

    return ListView(
      shrinkWrap: true,
      children: [
        if (userId != null)
          _buildNavButton(
              context,
              'My Profile',
              () => routerDelegate.beamTo(UserSettingsLocation(
                    initialSection: UserSettingsSection.profile,
                  ))),
        _buildNavButton(
          context,
          'My Events',
          () => routerDelegate.beamTo(
            UserSettingsLocation(initialSection: UserSettingsSection.conversations),
          ),
        ),
        _buildNavButton(
          context,
          'Sign Out',
          () => userService.signOut(),
        ),
      ],
    );
  }
}
