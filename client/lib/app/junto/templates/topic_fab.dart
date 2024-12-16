import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:junto/app/junto/community_permissions_provider.dart';
import 'package:junto/app/junto/discussions/create_discussion/create_discussion_dialog.dart';
import 'package:junto/app/junto/home/junto_page_fab.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/templates/attended_prerequisite_provider.dart';
import 'package:junto/app/junto/templates/new_conversation_card.dart';
import 'package:junto/app/junto/templates/topic_page_provider.dart';
import 'package:junto/common_widgets/create_dialog_ui_migration.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/analytics/analytics_entities.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/plan_capability_list.dart';
import 'package:junto_models/firestore/topic.dart';
import 'package:provider/provider.dart';

import '../../../routing/locations.dart';

class TopicFab extends StatefulWidget {
  const TopicFab({Key? key}) : super(key: key);

  @override
  State<TopicFab> createState() => _TopicFabState();
}

class _TopicFabState extends State<TopicFab> {
  void _defaultToHosted() => WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        Navigator.pop(context, DiscussionType.hosted);
      });

  @override
  Widget build(BuildContext context) {
    final showFab = responsiveLayoutService.isMobile(context) &&
        context.watch<CommunityPermissionsProvider>().canCreateEvent;

    if (!showFab) return SizedBox.shrink();

    return JuntoPageFloatingActionButton(
      text: 'Create an event',
      onTap: () async {
        final juntoId = Provider.of<JuntoProvider>(context, listen: false).juntoId;
        final topicId =
            (routerDelegate.currentBeamLocation.state as BeamState).pathParameters['topicId'] ?? '';

        final Topic? topic = await firestoreDatabase.getTopic(juntoId, topicId);

        if (topic == null) return;

        final isAdmin = juntoUserDataService.getMembership(juntoId).isAdmin;
        final permissions = context.read<CommunityPermissionsProvider>();

        final DiscussionType? discussionType;
        if (permissions.canModerateContent) {
          discussionType = await CreateDialogUiMigration<DiscussionType>(
              isCloseButtonVisible: false,
              builder: (_) {
                analytics.logEvent(AnalyticsPressCreateEventFromGuideEvent(
                  juntoId: topic.juntoId,
                  guideId: topic.id,
                ));

                return MultiProvider(
                  providers: [
                    ChangeNotifierProvider.value(value: context.read<JuntoProvider>()),
                    ChangeNotifierProvider(
                      create: (_) => AttendedPrerequisiteProvider(
                        topic: topic,
                        isAdmin: isAdmin,
                      )..initialize(),
                    ),
                    ChangeNotifierProvider(
                      // New conversation card below uses from the topic page provider to handle
                      // if the help tooltip is visible or not. We don't have access to that here
                      // so we create a replacement. We dont initialize it as the streams are unused.
                      create: (_) => TopicPageProvider(
                        juntoId: context.read<JuntoProvider>().juntoId,
                        topicId: topicId,
                      ),
                    ),
                  ],
                  child: _buildLoadCapabilities(topic),
                );
              }).show();
        } else {
          discussionType = DiscussionType.hosted;
        }

        if (discussionType != null) {
          await CreateDiscussionDialog.show(context, discussionType: discussionType, topic: topic);
        }
      },
    );
  }

  Widget _buildLoadCapabilities(Topic topic) {
    final juntoProvider = Provider.of<JuntoProvider>(context);

    return Builder(
      builder: (innerContext) {
        return JuntoStreamBuilder<PlanCapabilityList>(
          stream: cloudFunctionsService
              .getJuntoCapabilities(GetJuntoCapabilitiesRequest(juntoId: juntoProvider.juntoId))
              .asStream(),
          entryFrom: 'TopicFab.build',
          builder: (_, capabilities) {
            final hasLiveStream = capabilities?.hasLivestreams == true;

            // If the user doesn't have options, we will proceed to the second step automatically.
            // If the plan capabilities do not include hasLiveStream or the user is not moderator,
            // they will not have other options and we can immediately close the dialog with `hosted` option.
            if (!hasLiveStream) {
              _defaultToHosted();
              return SizedBox.shrink();
            } else {
              return _loadPrerequisite(topic);
            }
          },
        );
      },
    );
  }

  Widget _loadPrerequisite(Topic topic) {
    return Builder(builder: (innerContext) {
      return JuntoStreamBuilder<bool>(
        entryFrom: 'TopicFab._showCreateDiscussionDialog',
        stream: innerContext
            .watch<AttendedPrerequisiteProvider>()
            .hasParticipantAttendedPrerequisiteFuture
            .asStream(),
        builder: (_, hasAttendedPrerequisite) {
          return NewConversationCard(
            topic: topic,
            hasAttendedPrerequisite: hasAttendedPrerequisite ?? false,
            onCreateEventTap: (discussionType) => Navigator.pop(context, discussionType),
          );
        },
      );
    });
  }
}
