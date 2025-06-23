import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:flutter/material.dart';
import 'package:client/features/user/presentation/widgets/user_profile_chip.dart';
import 'package:client/core/routing/locations.dart';
import 'package:client/services.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:client/styles/styles.dart';
import 'package:client/core/data/providers/dialog_provider.dart';
import 'package:provider/provider.dart';
import 'package:client/core/localization/localization_helper.dart';

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
  UserProfileNavigationState createState() => UserProfileNavigationState();
}

class UserProfileNavigationState extends State<UserProfileNavigation> {
  final _buttonGlobalKey = GlobalKey();
  bool _isExiting = false;
  bool _isShowing = false;

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
    _isExiting = false;

    await showCustomDialog(
      context: context,
      barrierColor: context.theme.colorScheme.scrim.withScrimOpacity,
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: CustomInkWell(
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
    _isShowing = true;
    await _showOptionsFloating();
    _isShowing = false;
  }

  Widget _buildProfileButton() {
    return Semantics(
      button: true,
      label: context.l10n.profileButton,
      child: CustomInkWell(
        onHover: (hover) async {
          if (hover && !_isShowing) {
            return _profileActivated();
          }
        },
        child: IconButton(
          key: _buttonGlobalKey,
          onPressed: _profileActivated,
          icon: UserProfileChip(
            userId: Provider.of<UserService>(context).currentUserId,
            customAction: _profileActivated,
            alignment: Alignment.center,
            showName: false,
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
  @override
  Widget build(BuildContext context) {
    final userId = userService.currentUserId;

    return ListView(
      shrinkWrap: true,
      children: [
        if (userId != null)
           ActionButton(
            type: ActionButtonType.text,
            text: context.l10n.myProfile,
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
          text: context.l10n.myEvents,
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
          text: context.l10n.signOut,
          onPressed: () => userService.signOut(),
          expand: true,
          textStyle: context.theme.textTheme.bodyMedium,
          contentAlign: ActionButtonContentAlignment.start,
        ),
      ],
    );
  }
}
