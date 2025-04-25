import 'package:flutter/material.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/features/user/presentation/widgets/user_profile_chip.dart';
import 'package:client/core/routing/locations.dart';
import 'package:client/services.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:client/styles/styles.dart';
import 'package:client/core/data/providers/dialog_provider.dart';
import 'package:client/core/widgets/height_constained_text.dart';
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

  Future<void> _showOptionsFloating() async {
    final RenderBox button =
        _buttonGlobalKey.currentContext?.findRenderObject() as RenderBox;
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

    await showCustomDialog(
      context: context,
      barrierColor: context.theme.colorScheme.scrim.withScrimOpacity,
      builder: (context) => Stack(
        children: [
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
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: context.theme.colorScheme.surfaceContainerLowest,
                ),
                constraints: BoxConstraints(maxHeight: 400),
                child: ProfileNavigationList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _profileActivated() async {
    await _showOptionsFloating();
  }

  Widget _buildProfileButton() {
    return Semantics(
      button: true,
      label: 'Profile Button',
      child: IconButton(
        key: _buttonGlobalKey,
        onPressed: _profileActivated,
        padding: EdgeInsets.all(4.0),
        icon: SizedBox(
          height: 40,
          width: 40,
          child: UserProfileChip(
            userId: Provider.of<UserService>(context).currentUserId,
            customAction: _profileActivated,
            alignment: Alignment.center,
            showName: false,
            imageHeight: 40,
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
    return CustomInkWell(
      onTap: () {
        Navigator.of(context).pop();

        if (onTap != null) onTap();
      },
      hoverColor: Theme.of(context).primaryColor.withOpacity(0.3),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        color: color,
        alignment: Alignment.centerLeft,
        child: HeightConstrainedText(
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
          ActionButton(
            type: ActionButtonType.text,
            text: 'My Profile',
            onPressed: () => routerDelegate.beamTo(
              UserSettingsLocation(
                initialSection: UserSettingsSection.profile,
              ),
            ),
            expand: true,
            textStyle: context.theme.textTheme.bodyMedium,
            contentAlign: ActionButtonContentAlignment.start,
          ),
        ActionButton(
          type: ActionButtonType.text,
          text: 'My Events',
          onPressed: () => routerDelegate.beamTo(
            UserSettingsLocation(
              initialSection: UserSettingsSection.events,
            ),
          ),
          expand: true,
          textStyle: context.theme.textTheme.bodyMedium,
          contentAlign: ActionButtonContentAlignment.start,
        ),
        ActionButton(
          type: ActionButtonType.text,
          text: 'Sign Out',
          onPressed: () => userService.signOut(),
          expand: true,
          textStyle: context.theme.textTheme.bodyMedium,
          contentAlign: ActionButtonContentAlignment.start,
        ),
      ],
    );
  }
}
