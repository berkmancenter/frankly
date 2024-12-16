import 'package:flutter/material.dart';
import 'package:junto/app/junto/announcements/announcements_provider.dart';
import 'package:junto/app/junto/announcements/announcments.dart';
import 'package:junto/app/junto/community_permissions_provider.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/common_widgets/junto_ui_migration.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/dialog_provider.dart';
import 'package:junto_models/firestore/announcement.dart';
import 'package:provider/provider.dart';

class AnnouncementsIcon extends StatelessWidget {
  final String juntoId;

  const AnnouncementsIcon({
    required this.juntoId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => AnnouncementsProvider(juntoId: juntoId)..initialize(),
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
    final RenderBox button = _buttonGlobalKey.currentContext?.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay?.context.findRenderObject() as RenderBox;

    final juntoProvider = Provider.of<JuntoProvider>(context, listen: false);
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
    await showJuntoDialog(
      context: context,
      barrierColor: AppColor.black.withOpacity(0.3),
      builder: (context) => ChangeNotifierProvider<CommunityPermissionsProvider>.value(
        value: communityPermissionsProvider,
        child: ChangeNotifierProvider<JuntoProvider>.value(
          value: juntoProvider,
          child: Stack(
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
                width: 260.0,
                right: position.right - 90,
                top: position.top + position.toSize(overlay.size).height,
                child: MouseRegion(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxHeight: halfSize ? 200 : 400),
                    color: AppColor.white,
                    child: JuntoUiMigration(
                      whiteBackground: true,
                      child: Announcements.create(),
                    ),
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
      label: 'Show Announcements Button',
      child: JuntoInkWell(
        onHover: (hover) async {
          if (hover && !_isShowing) {
            return _profileActivated(halfSize);
          }
        },
        // Register on tap events in case of touchscreens
        onTap: () => _profileActivated(halfSize),
        child: Container(
          key: _buttonGlobalKey,
          alignment: Alignment.center,
          width: 50,
          height: AppSize.kNavBarHeight,
          child: Icon(
            Icons.notifications_none,
            size: 30,
            color: AppColor.gray3,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return JuntoStreamBuilder<List<Announcement>>(
      stream: Provider.of<AnnouncementsProvider>(context)?.announcements,
      entryFrom: '_AnnouncementsState._buildAnnouncementsLoading',
      errorMessage: 'There was an error loading announcements.',
      showLoading: false,
      builder: (_, announcements) {
        return _buildNotificationButton((announcements ?? []).isEmpty);
      },
    );
  }
}
