import 'package:flutter/material.dart';
import 'package:client/features/announcements/data/providers/announcements_provider.dart';
import 'package:client/features/announcements/presentation/views/announcments.dart';
import 'package:client/features/community/data/providers/community_permissions_provider.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/styles/styles.dart';
import 'package:client/core/data/providers/dialog_provider.dart';
import 'package:data_models/announcements/announcement.dart';
import 'package:provider/provider.dart';
import 'package:client/core/localization/localization_helper.dart';

class AnnouncementsIcon extends StatelessWidget {
  final String communityId;

  const AnnouncementsIcon({
    required this.communityId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) =>
          AnnouncementsProvider(communityId: communityId)..initialize(),
      child: _AnnouncementsIcon(),
    );
  }
}

class _AnnouncementsIcon extends StatefulWidget {
  @override
  _AnnouncementsIconState createState() => _AnnouncementsIconState();
}

class _AnnouncementsIconState extends State<_AnnouncementsIcon> {
  final _buttonGlobalKey = GlobalKey();
  bool _isExiting = false;
  bool _isShowing = false;

  Future<void> _showOptionsFloating(bool halfSize) async {
    final RenderBox button =
        _buttonGlobalKey.currentContext?.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay?.context.findRenderObject() as RenderBox;

    final communityProvider =
        Provider.of<CommunityProvider>(context, listen: false);
    final communityPermissionsProvider =
        Provider.of<CommunityPermissionsProvider>(context, listen: false);

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
      builder: (context) =>
          ChangeNotifierProvider<CommunityPermissionsProvider>.value(
        value: communityPermissionsProvider,
        child: ChangeNotifierProvider<CommunityProvider>.value(
          value: communityProvider,
          child: Stack(
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
                width: 260.0,
                right: position.right - 90,
                top: position.top + position.toSize(overlay.size).height,
                child: MouseRegion(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: context.theme.colorScheme.surfaceContainerLowest,
                    ),
                    padding: const EdgeInsets.all(12),
                    constraints:
                        BoxConstraints(maxHeight: halfSize ? 200 : 400),
                    child: Announcements.create(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _profileActivated(bool empty) async {
    _isShowing = true;
    await _showOptionsFloating(empty);
    _isShowing = false;
  }

  Widget _buildNotificationButton(bool halfSize) {
    return Semantics(
      button: true,
      label: context.l10n.showAnnouncementsButton,
      child: CustomInkWell(
        onHover: (hover) async {
          if (hover && !_isShowing) {
            return _profileActivated(halfSize);
          }
        },
        hoverColor: Colors.transparent,
        // Register on tap events in case of touchscreens
        onTap: () => _profileActivated(halfSize),
        child: Container(
          key: _buttonGlobalKey,
          width: 50,
          alignment: Alignment.center,
          child: Icon(
            Icons.notifications_none_rounded,
            size: 30,
            color: _isShowing
                ? context.theme.colorScheme.onSurface
                : context.theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomStreamBuilder<List<Announcement>>(
      stream: Provider.of<AnnouncementsProvider>(context).announcements,
      entryFrom: '_AnnouncementsState._buildAnnouncementsLoading',
      errorMessage: 'There was an error loading announcements.',
      showLoading: false,
      builder: (_, announcements) {
        return _buildNotificationButton((announcements ?? []).isEmpty);
      },
    );
  }
}
