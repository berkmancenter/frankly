import 'package:flutter/material.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/self/profile_tab.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/profile_chip.dart';
import 'package:junto/common_widgets/user_info_builder.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/dialogs.dart';
import 'package:provider/provider.dart';

class UserProfileChip extends StatelessWidget {
  final String? userId;
  final String? name;
  final TextStyle? textStyle;
  final ActionButton? button;
  final double? imageHeight;
  final bool showBorder;
  final bool showName;

  /// Shows `You` instead of your full name if it's you.
  final bool showIsYou;
  final bool enableOnTap;
  final Alignment alignment;
  final Function()? customAction;

  const UserProfileChip({
    Key? key,
    this.userId,
    this.name,
    this.button,
    this.imageHeight,
    this.showBorder = true,
    this.textStyle,
    this.showName = true,
    this.showIsYou = false,
    this.enableOnTap = true,
    this.alignment = Alignment.centerLeft,
    this.customAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMyUser = userId == userService.currentUserId;

    return UserInfoBuilder(
      userId: userId,
      builder: (context, isLoading, snapshot) {
        if (isLoading) {
          return Align(
            alignment: alignment,
            child: Container(
              height: imageHeight ?? 42,
              width: imageHeight ?? 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColor.gray5,
              ),
            ),
          );
        }

        String? juntoId;
        try {
          juntoId = Provider.of<JuntoProvider>(context).juntoId;
        } on ProviderNotFoundException {
          // Do nothing
        }

        void Function()? onTap() {
          final localCustomAction = customAction;

          if (userId == null || !enableOnTap) {
            return null;
          } else if (localCustomAction != null) {
            return localCustomAction;
          } else {
            return () => Dialogs.showAppDrawer(
                  context,
                  AppDrawerSide.right,
                  ProfileTab(
                    juntoId: juntoId,
                    showTitle: true,
                    allowEdit: isMyUser,
                    currentUserId: userId!,
                  ),
                );
          }
        }

        final String userName;
        if (showIsYou) {
          userName = isMyUser ? 'You' : name ?? snapshot.data?.displayName ?? 'Anonymous';
        } else {
          userName = name ?? snapshot.data?.displayName ?? 'Anonymous';
        }

        return ProfileChip(
          key: Key('profile-chip-$userId'),
          name: userName,
          imageUrl: snapshot.data?.imageUrl,
          textStyle: textStyle,
          imageHeight: imageHeight,
          showBorder: showBorder,
          showName: showName,
          onTap: onTap(),
        );
      },
    );
  }
}
