import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/features/user/presentation/views/profile_tab.dart';
import 'package:flutter/material.dart';
import 'package:client/core/widgets/action_button.dart';
import 'package:client/core/widgets/profile_chip.dart';
import 'package:client/features/user/data/providers/user_info_builder.dart';
import 'package:client/services.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/utils/dialogs.dart';
import 'package:provider/provider.dart';
import 'package:client/core/localization/localization_helper.dart';

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

        String? communityId;
        try {
          communityId = Provider.of<CommunityProvider>(context).communityId;
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
                    communityId: communityId,
                    showTitle: true,
                    allowEdit: isMyUser,
                    currentUserId: userId!,
                  ),
                );
          }
        }

        final String userName;
        if (showIsYou) {
          userName = isMyUser
              ? context.l10n.you
              : name ?? snapshot.data?.displayName ?? context.l10n.anonymous;
        } else {
          userName =
              name ?? snapshot.data?.displayName ?? context.l10n.anonymous;
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
