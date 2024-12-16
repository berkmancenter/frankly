import 'dart:math';

import 'package:flutter/material.dart';
import 'package:junto/app/junto/community_permissions_provider.dart';
import 'package:junto/app/junto/discussions/create_discussion/create_discussion_dialog.dart';
import 'package:junto/app/junto/home/about_section.dart';
import 'package:junto/app/junto/home/carousel/carousel_initializer.dart';
import 'package:junto/app/junto/home/discussion_widget.dart';
import 'package:junto/app/junto/home/edit_community_button.dart';
import 'package:junto/app/junto/home/junto_home_provider.dart';
import 'package:junto/app/junto/home/super_admin_controls.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/app/junto/widgets/share/app_share.dart';
import 'package:junto/app/junto/widgets/share/share_section.dart';
import 'package:junto/common_widgets/donate_widget.dart';
import 'package:junto/common_widgets/empty_page_content.dart';
import 'package:junto/common_widgets/junto_membership_button.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/common_widgets/junto_ui_migration.dart';
import 'package:junto/common_widgets/thick_outline_button.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/extensions.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto/utils/stream_utils.dart';
import 'package:junto_models/analytics/analytics_entities.dart';
import 'package:junto_models/analytics/share_type.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class JuntoHome extends StatefulWidget {
  const JuntoHome._();

  static Widget create() {
    return ChangeNotifierProvider(
      create: (context) => JuntoHomeProvider(
        juntoProvider: context.read<JuntoProvider>(),
      ),
      child: JuntoUiMigration(
        whiteBackground: true,
        child: JuntoHome._(),
      ),
    );
  }

  @override
  _JuntoHomeState createState() => _JuntoHomeState();
}

class _JuntoHomeState extends State<JuntoHome> {
  int _discussionsToShow = 20;
  final int _discussionCountIncrement = 5;

  Junto get junto => Provider.of<JuntoProvider>(context).junto;

  @override
  void initState() {
    context.read<JuntoHomeProvider>().initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: JuntoStreamGetterBuilder<bool>(
        streamGetter: () => context.read<JuntoProvider>().donationsEnabled().asStream(),
        keys: [junto.id],
        builder: (context, showDonations) => Column(
          children: [
            if (responsiveLayoutService.isMobile(context))
              ..._mobileLayout(showDonations!)
            else
              ..._desktopLayout(showDonations!),
            if (userService.userIsSuperAdmin) ...[
              SuperAdminControls(),
              SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _mobileLayout(bool showDonations) => [
        if (MediaQuery.of(context).size.width > AppSize.kMaxCarouselSize) SizedBox(height: 30),
        Stack(
          children: [
            Center(
              child: Container(
                clipBehavior: MediaQuery.of(context).size.width > AppSize.kMaxCarouselSize
                    ? Clip.hardEdge
                    : Clip.none,
                decoration: MediaQuery.of(context).size.width > AppSize.kMaxCarouselSize
                    ? BoxDecoration(borderRadius: BorderRadius.circular(10))
                    : null,
                constraints: BoxConstraints(maxWidth: AppSize.kMaxCarouselSize),
                child: CarouselInitializer(),
              ),
            ),
            if (Provider.of<CommunityPermissionsProvider>(context).canEditCommunity)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: EditCommunityButton(),
                ),
              )
          ],
        ),
        ConstrainedBody(
          maxWidth: 524,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 30),
              _buildDiscussions(),
              SizedBox(height: 30),
              JuntoHomeAboutSection(junto: junto),
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
                child: Provider.of<CommunityPermissionsProvider>(context).canEditCommunity
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
        JuntoHomeAboutSection(junto: junto),
        SizedBox(height: 20),
        _buildContactUsSection(showDonations),
        SizedBox(height: 30),
      ],
    );
  }

  Widget _buildRightSideOfDesktop() => Column(
        children: [
          _buildDiscussions(),
        ],
      );

  Widget _buildEngagementButtons(bool showDonation) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        children: [
          if (!juntoUserDataService.isMember(juntoId: junto.id)) ...[
            JuntoMembershipButton(
              junto,
              bgColor: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(width: 12),
          ],
          if (showDonation)
            ThickOutlineButton(
              text: 'Donate',
              eventName: 'donate_pressed',
              whiteBackground: false,
              onPressed: () => guardSignedIn(() => DonateWidget(
                    junto: JuntoProvider.read(context).junto,
                    headline: 'Donate to keep the conversation going!',
                    subHeader: 'Support ${JuntoProvider.read(context).junto.name}!',
                  ).show()),
            ),
        ],
      ),
    );
  }

  Widget _buildShare() {
    final title = Provider.of<JuntoProvider>(context).junto.name;
    final subject = 'Join $title on Frankly';
    final body = 'Hey, check out $title on Frankly!';
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
        analytics.logEvent(AnalyticsPressShareJuntoLinkEvent(
          juntoId: junto.id,
          shareType: type,
        ));
      },
    );
  }

  Widget _buildDiscussions() {
    final isMeetingOfAmerica = JuntoProvider.watch(context).isMeetingOfAmerica;
    return JuntoStreamBuilder<List<Discussion>>(
      entryFrom: '_JuntoHomeState._buildDiscussions',
      stream: Provider.of<JuntoHomeProvider>(context).discussionsStream,
      errorMessage: 'Error loading events. Please refresh!',
      builder: (_, discussions) {
        if (discussions == null || discussions.isEmpty) {
          if (Provider.of<CommunityPermissionsProvider>(context).canEditCommunity) {
            return _buildEmptyDiscussionAdminButton();
          } else if (Provider.of<CommunityPermissionsProvider>(context).canCreateEvent) {
            return EmptyPageContent(
              type: EmptyPageType.events,
              onButtonPress: () => CreateDiscussionDialog.show(context),
            );
          } else {
            return EmptyPageContent(type: EmptyPageType.events);
          }
        } else {
          return Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: JuntoText(
                  isMeetingOfAmerica ? 'Sign up for one of the below!' : 'Upcoming Events',
                  style: AppTextStyle.headline4.copyWith(
                    color: AppColor.gray1,
                  ),
                ),
              ),
              SizedBox(height: 10),
              for (var i = 0; i < min(discussions.length, _discussionsToShow); i++) ...[
                DiscussionWidget(discussions[i]),
                SizedBox(height: 20),
              ],
              if (discussions.length > _discussionsToShow)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() => _discussionsToShow += _discussionCountIncrement);
                      },
                      child: Container(
                        width: 150,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(),
                        ),
                        alignment: Alignment.center,
                        child: JuntoText(
                          'See More Events',
                          style: AppTextStyle.eyebrowSmall,
                        ),
                      ),
                    ),
                  ],
                )
            ],
          );
        }
      },
    );
  }

  Widget _buildEmptyDiscussionAdminButton() => JuntoStreamGetterBuilder<bool>(
        keys: [junto.id],
        streamGetter: () => firestoreDiscussionService.juntoHasDiscussions(juntoId: junto.id),
        builder: (context, juntoHasDiscussions) {
          return EmptyPageContent(
            type: EmptyPageType.events,
            subtitleText: (juntoHasDiscussions ?? true) ? 'No events' : 'Create your first event!',
            onButtonPress: () => CreateDiscussionDialog.show(context),
          );
        },
      );

  Widget _buildContactUsSection(bool showDonations) {
    final email = junto.contactEmail;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (email != null && email.isNotEmpty) ...[
          Text('Contact', style: AppTextStyle.headline4.copyWith(color: AppColor.gray1)),
          SizedBox(height: 10),
          GestureDetector(
            onTap: () => url_launcher.launch('mailto:$email'),
            child: Text(email, style: AppTextStyle.bodyMedium.copyWith(color: AppColor.gray1)),
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
