import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:client/features/chat/data/providers/chat_model.dart';
import 'package:client/features/events/features/event_page/presentation/widgets/event_tabs.dart';
import 'package:client/features/events/features/event_page/presentation/event_tabs_model.dart';
import 'package:client/features/events/features/live_meeting/data/providers/live_meeting_provider.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/providers/user_submitted_agenda_provider.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/services.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:provider/provider.dart';

final _hostlessGlobalKey = GlobalKey();

class HostlessMeetingInfo extends StatefulWidget {
  HostlessMeetingInfo() : super(key: _hostlessGlobalKey);

  @override
  _HostlessMeetingInfoState createState() => _HostlessMeetingInfoState();
}

class _HostlessMeetingInfoState extends State<HostlessMeetingInfo> {
  double get _iconWidth =>
      responsiveLayoutService.isMobile(context) ? 88.0 : 115.0;

  Widget _buildCommunityProfilePic() {
    return AspectRatio(
      aspectRatio: 1.0,
      child: ProxiedImage(
        Provider.of<CommunityProvider>(context).community.profileImageUrl,
      ),
    );
  }

  Widget _buildTab({
    required TabType tabType,
    int unreadMessages = 0,
    required AppAsset asset,
    required String text,
  }) {
    final isMobile = responsiveLayoutService.isMobile(context);

    return SizedBox(
      height: _iconWidth,
      width: _iconWidth,
      child: CustomInkWell(
        onTap: () {
          final tabController = Provider.of<EventTabsControllerState>(
            context,
            listen: false,
          );
          final isCurrentTabOpen = tabController.isTabOpen(tabType);
          if (isCurrentTabOpen) {
            tabController.expanded = false;
          } else {
            tabController.openTab(tabType);
          }
        },
        hoverColor: AppColor.white.withOpacity(0.3),
        child: Container(
          color:
              Provider.of<EventTabsControllerState>(context).isTabOpen(tabType)
                  ? AppColor.white.withOpacity(0.3)
                  : null,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: ProxiedImage(
                      null,
                      asset: asset,
                      height: isMobile ? 30 : 40,
                      loadingColor: Colors.transparent,
                    ),
                  ),
                  if (unreadMessages > 0)
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: AppColor.brightGreen,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadMessages.toString(),
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 4),
              HeightConstrainedText(
                text,
                style: body.copyWith(
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParticipantCountText() {
    final liveMeetingProvider = Provider.of<LiveMeetingProvider>(context);
    final participants = max(
      liveMeetingProvider.conferenceRoom?.participants.length ??
          liveMeetingProvider.eventProvider.presentParticipantCount,
      1,
    );

    return Padding(
      padding: const EdgeInsets.all(6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.account_circle,
            color: AppColor.brightGreen,
          ),
          SizedBox(width: 6),
          Flexible(
            child: HeightConstrainedText(
              NumberFormat.decimalPattern().format(participants),
              style: body.copyWith(
                fontWeight: FontWeight.w300,
                color: AppColor.brightGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final provider = Provider.of<EventTabsControllerState>(context).widget;
    final isMobile = responsiveLayoutService.isMobile(context);

    final tabs = <Widget>[
      if (provider.enableGuide)
        _buildTab(
          tabType: TabType.guide,
          asset: AppAsset('media/guide_icon.png'),
          text: 'Agenda',
        ),
      if (provider.enableChat)
        _buildTab(
          tabType: TabType.chat,
          unreadMessages: Provider.of<ChatModel>(context).numUnreadMessages,
          asset: AppAsset('media/chat_icon.png'),
          text: 'Chat',
        ),
      if (provider.enableUserSubmittedAgenda)
        _buildTab(
          tabType: TabType.suggestions,
          unreadMessages: Provider.of<UserSubmittedAgendaProvider>(context)
              .numUnreadSuggestions,
          asset: AppAsset('media/guide_icon.png'),
          text: 'Suggest',
        ),
      if (provider.enableAdminPanel)
        _buildTab(
          tabType: TabType.admin,
          asset: AppAsset('media/admin_icon.png'),
          text: 'Admin',
        ),
    ];

    final separator = Container(
      width: isMobile ? 1 : null,
      height: isMobile ? null : 1,
      color: AppColor.white.withOpacity(0.5),
    );
    final children = [
      _buildCommunityProfilePic(),
      for (final tab in tabs) ...[
        tab,
        separator,
      ],
    ];
    if (children.length > 1) {
      children.removeLast();
    }

    final outerChildren = [
      Expanded(
        child: ListView(
          scrollDirection: isMobile ? Axis.horizontal : Axis.vertical,
          children: children,
        ),
      ),
      Align(
        alignment: isMobile ? Alignment.bottomRight : Alignment.bottomLeft,
        child: _buildParticipantCountText(),
      ),
    ];
    return Container(
      color: context.theme.colorScheme.primary,
      width: isMobile ? null : _iconWidth,
      height: isMobile ? _iconWidth : null,
      child: isMobile
          ? Row(children: outerChildren)
          : Column(children: outerChildren),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildContent();
  }
}
