import 'dart:math';

import 'package:flutter/material.dart';
import 'package:client/app/community/community_permissions_provider.dart';
import 'package:client/app/community/events/create_event/create_event_dialog.dart';
import 'package:client/app/community/home/about_section.dart';
import 'package:client/app/community/home/carousel/carousel_initializer.dart';
import 'package:client/app/community/home/event_widget.dart';
import 'package:client/app/community/home/edit_community_button.dart';
import 'package:client/app/community/home/community_home_provider.dart';
import 'package:client/app/community/community_provider.dart';
import 'package:client/app/community/utils.dart';
import 'package:client/app/community/widgets/share/app_share.dart';
import 'package:client/app/community/widgets/share/share_section.dart';
import 'package:client/common_widgets/donate_widget.dart';
import 'package:client/common_widgets/empty_page_content.dart';
import 'package:client/common_widgets/community_membership_button.dart';
import 'package:client/common_widgets/custom_stream_builder.dart';
import 'package:client/common_widgets/ui_migration.dart';
import 'package:client/common_widgets/thick_outline_button.dart';
import 'package:client/environment.dart';
import 'package:client/services/services.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/utils/extensions.dart';
import 'package:client/utils/height_constained_text.dart';
import 'package:client/utils/stream_utils.dart';
import 'package:data_models/analytics/analytics_entities.dart';
import 'package:data_models/analytics/share_type.dart';
import 'package:data_models/firestore/event.dart';
import 'package:data_models/firestore/community.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class CommunityHome extends StatefulWidget {
  const CommunityHome._();

  static Widget create() {
    return ChangeNotifierProvider(
      create: (context) => CommunityHomeProvider(
        communityProvider: context.read<CommunityProvider>(),
      ),
      child: UIMigration(
        whiteBackground: true,
        child: CommunityHome._(),
      ),
    );
  }

  @override
  _CommunityHomeState createState() => _CommunityHomeState();
}

class _CommunityHomeState extends State<CommunityHome> {
  int _eventsToShow = 20;
  final int _eventCountIncrement = 5;

  Community get community => Provider.of<CommunityProvider>(context).community;

  @override
  void initState() {
    context.read<CommunityHomeProvider>().initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomStreamGetterBuilder<bool>(
        streamGetter: () =>
            context.read<CommunityProvider>().donationsEnabled().asStream(),
        keys: [community.id],
        builder: (context, showDonations) => Column(
          children: [
            if (responsiveLayoutService.isMobile(context))
              ..._mobileLayout(showDonations!)
            else
              ..._desktopLayout(showDonations!),
          ],
        ),
      ),
    );
  }

  List<Widget> _mobileLayout(bool showDonations) => [
        if (MediaQuery.of(context).size.width > AppSize.kMaxCarouselSize)
          SizedBox(height: 30),
        Stack(
          children: [
            Center(
              child: Container(
                clipBehavior:
                    MediaQuery.of(context).size.width > AppSize.kMaxCarouselSize
                        ? Clip.hardEdge
                        : Clip.none,
                decoration:
                    MediaQuery.of(context).size.width > AppSize.kMaxCarouselSize
                        ? BoxDecoration(borderRadius: BorderRadius.circular(10))
                        : null,
                constraints: BoxConstraints(maxWidth: AppSize.kMaxCarouselSize),
                child: CarouselInitializer(),
              ),
            ),
            if (Provider.of<CommunityPermissionsProvider>(context)
                .canEditCommunity)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: EditCommunityButton(),
                ),
              ),
          ],
        ),
        ConstrainedBody(
          maxWidth: 524,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 30),
              _buildEvents(),
              SizedBox(height: 30),
              CommunityHomeAboutSection(community: community),
              SizedBox(height: 30),
              _buildContactUsSection(showDonations),
              SizedBox(height: 30),
            ],
          ),
        ),
      ];

  List<Widget> _desktopLayout(bool showDonations) => [
        ConstrainedBody(
          child: Column(
            children: [
              SizedBox(
                height: 48,
                child: Provider.of<CommunityPermissionsProvider>(context)
                        .canEditCommunity
                    ? Align(
                        alignment: Alignment.centerRight,
                        child: EditCommunityButton(),
                      )
                    : null,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildLeftSideOfDesktop(showDonations),
                  ),
                  SizedBox(width: 52),
                  Expanded(
                    child: _buildRightSideOfDesktop(),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 100),
      ];

  Widget _buildLeftSideOfDesktop(bool showDonations) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          clipBehavior: Clip.hardEdge,
          child: CarouselInitializer(),
        ),
        SizedBox(height: 30),
        CommunityHomeAboutSection(community: community),
        SizedBox(height: 20),
        _buildContactUsSection(showDonations),
        SizedBox(height: 30),
      ],
    );
  }

  Widget _buildRightSideOfDesktop() => Column(
        children: [
          _buildEvents(),
        ],
      );

  Widget _buildEngagementButtons(bool showDonation) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        children: [
          if (!userDataService.isMember(communityId: community.id)) ...[
            CommunityMembershipButton(
              community,
              bgColor: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(width: 12),
          ],
          if (showDonation)
            ThickOutlineButton(
              text: 'Donate',
              eventName: 'donate_pressed',
              backgroundColor: Colors.white,
              onPressed: () => guardSignedIn(
                () => DonateWidget(
                  community: CommunityProvider.read(context).community,
                  headline: 'Donate to keep the conversation going!',
                  subHeader:
                      'Support ${CommunityProvider.read(context).community.name}!',
                ).show(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShare() {
    final title = Provider.of<CommunityProvider>(context).community.name;
    final subject = 'Join $title on ${Environment.appName}';
    final body = 'Hey, check out $title on ${Environment.appName}!';
    final shareData = AppShareData(subject: subject, body: body);

    return ShareSection(
      iconColor: Theme.of(context).colorScheme.primary,
      iconBackgroundColor: null,
      url: shareData.pathToPage,
      body: body,
      subject: subject,
      wrapIcons: false,
      buttonPadding: 0,
      size: 39,
      iconSize: 16,
      shareCallback: (ShareType type) {
        analytics.logEvent(
          AnalyticsPressShareCommunityLinkEvent(
            communityId: community.id,
            shareType: type,
          ),
        );
      },
    );
  }

  Widget _buildEvents() {
    return CustomStreamBuilder<List<Event>>(
      entryFrom: '_CommunityHomeState._buildEvents',
      stream: Provider.of<CommunityHomeProvider>(context).eventsStream,
      errorMessage: 'Error loading events. Please refresh!',
      builder: (_, events) {
        if (events == null || events.isEmpty) {
          if (Provider.of<CommunityPermissionsProvider>(context)
              .canEditCommunity) {
            return _buildEmptyEventAdminButton();
          } else if (Provider.of<CommunityPermissionsProvider>(context)
              .canCreateEvent) {
            return EmptyPageContent(
              type: EmptyPageType.events,
              onButtonPress: () => CreateEventDialog.show(context),
            );
          } else {
            return EmptyPageContent(type: EmptyPageType.events);
          }
        } else {
          return Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: HeightConstrainedText(
                  'Upcoming Events',
                  style: AppTextStyle.headline4.copyWith(
                    color: AppColor.gray1,
                  ),
                ),
              ),
              SizedBox(height: 10),
              for (var i = 0; i < min(events.length, _eventsToShow); i++) ...[
                EventWidget(events[i]),
                SizedBox(height: 20),
              ],
              if (events.length > _eventsToShow)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(
                          () => _eventsToShow += _eventCountIncrement,
                        );
                      },
                      child: Container(
                        width: 150,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(),
                        ),
                        alignment: Alignment.center,
                        child: HeightConstrainedText(
                          'See More Events',
                          style: AppTextStyle.eyebrowSmall,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          );
        }
      },
    );
  }

  Widget _buildEmptyEventAdminButton() => CustomStreamGetterBuilder<bool>(
        keys: [community.id],
        streamGetter: () => firestoreEventService.communityHasEvents(
          communityId: community.id,
        ),
        builder: (context, communityHasEvents) {
          return EmptyPageContent(
            type: EmptyPageType.events,
            subtitleText: (communityHasEvents ?? true)
                ? 'No events'
                : 'Create your first event!',
            onButtonPress: () => CreateEventDialog.show(context),
          );
        },
      );

  Widget _buildContactUsSection(bool showDonations) {
    final email = community.contactEmail;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (email != null && email.isNotEmpty) ...[
          Text(
            'Contact',
            style: AppTextStyle.headline4.copyWith(color: AppColor.gray1),
          ),
          SizedBox(height: 10),
          GestureDetector(
            onTap: () => url_launcher.launch('mailto:$email'),
            child: Text(
              email,
              style: AppTextStyle.bodyMedium.copyWith(color: AppColor.gray1),
            ),
          ),
          SizedBox(height: 10),
        ],
        Row(
          children: [
            _buildShare(),
            Spacer(),
          ],
        ),
        SizedBox(height: 30),
        _buildEngagementButtons(showDonations),
      ],
    );
  }
}
