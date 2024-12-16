import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:junto/app/junto/community_permissions_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_permissions_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/meeting_dialog.dart';
import 'package:junto/app/junto/discussions/discussion_page/topic_provider.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/common_widgets/navbar/nav_bar_provider.dart';
import 'package:junto/junto_app.dart';
import 'package:junto/routing/locations.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/keyboard_utils.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/public_user_info.dart';
import 'package:junto_models/utils.dart';
import 'package:provider/provider.dart';

class InstantDiscussion extends StatefulHookWidget {
  final String juntoId;
  final String? topicId;
  final String? meetingId;
  final bool? record;
  final String? name;

  const InstantDiscussion({
    required this.juntoId,
    required this.topicId,
    required this.meetingId,
    required this.record,
    required this.name,
  });

  @override
  _InstantDiscussionState createState() => _InstantDiscussionState();
}

class _InstantDiscussionState extends State<InstantDiscussion> {
  static final String _defaultAllSidesTopic =
      isDev ? 'MBRiMvQyFcVe6d8hsPFI' : 'NVwyIgtNhz6frXWrlTrC';

  String get topicId {
    final localTopicId = widget.topicId;
    if (localTopicId != null && localTopicId.trim().isNotEmpty) return localTopicId;

    if (widget.juntoId == 'allsides-talks') {
      return _defaultAllSidesTopic;
    }

    return defaultInstantMeetingTopicId;
  }

  Future<Discussion> _createDiscussionIfNotExists(TopicProvider topicProvider) async {
    if (!userService.isSignedIn) {
      await userService.updateCurrentUserInfo(
        PublicUserInfo(
          id: userService.currentUserId!,
          agoraId: uidToInt(userService.currentUserId!),
          displayName: widget.name ?? 'Participant',
        ),
        ['displayName'],
      );
    }

    final meetingId = 'i-${widget.juntoId}-${widget.meetingId}';

    final juntoId = widget.juntoId;
    final junto = await firestoreDatabase.getJunto(juntoId);
    final topic = await topicProvider.topicFuture;
    final discussion = await firestoreDiscussionService.createDiscussionIfNotExists(
      record: widget.record ?? false,
      discussion: Discussion(
        id: meetingId,
        collectionPath: firestoreDiscussionService
            .discussionsCollection(juntoId: juntoId, topicId: topicId)
            .path,
        creatorId: userService.currentUserId!,
        status: DiscussionStatus.active,
        juntoId: juntoId,
        topicId: topicId,
        nullableDiscussionType: DiscussionType.hosted,
        title: 'Instant Meeting',
        scheduledTime: clockService.now(),
        isPublic: false,
        minParticipants: Discussion.defaultMinParticipants,
        maxParticipants: Discussion.defaultMaxParticipants,
        isLocked: false,
        agendaItems: topic.agendaItems.toList(),
        externalCommunityId: widget.meetingId,
        discussionSettings: topic.discussionSettings ?? junto?.discussionSettingsMigration,
      ),
    );

    await firestoreDiscussionService.joinDiscussion(
      juntoId: juntoId,
      topicId: topicId,
      discussionId: discussion.id,
      setAttendeeStatus: false,
    );

    return discussion;
  }

  Widget _buildMeeting(BuildContext context) {
    // The MeetingDialog widget expects the first discussion and topic to
    // already be loaded so we need to wait for that to happen here.
    return JuntoStreamBuilder(
      entryFrom: '_InstantDiscussionState._buildMeeting',
      stream: Stream.fromFuture(Future.wait(<Future>[
        context.watch<JuntoProvider>().juntoStream.first,
        context.watch<DiscussionProvider>().discussionStream.first,
        context.watch<DiscussionProvider>().selfParticipantStream?.first ?? Future.value(),
        context.watch<TopicProvider>().topicFuture,
      ])),
      builder: (_, __) => MeetingDialog.create(
        isInstant: true,
        leaveLocation: JuntoPageRoutes(juntoDisplayId: widget.juntoId).juntoHome,
      ),
    );
  }

  Widget _buildContent() {
    final topicProvider = useMemoized(() => TopicProvider(
          juntoId: widget.juntoId,
          topicId: topicId,
        )..initialize());
    final createDiscussionFuture =
        useMemoized<Future<Discussion>>(() => _createDiscussionIfNotExists(topicProvider), []);

    return Center(
      child: ChangeNotifierProvider<JuntoProvider>(
        create: (context) =>
            JuntoProvider(displayId: widget.juntoId, navBarProvider: context.read<NavBarProvider>())
              ..initialize(),
        builder: (context, _) => JuntoStreamBuilder(
          entryFrom: '_InstantDiscussionState._buildContent1',
          stream: JuntoProvider.read(context).juntoStream,
          errorMessage: 'There was an error setting up your event. Please refresh.',
          builder: (_, discussion) => ChangeNotifierProvider<TopicProvider>.value(
            value: topicProvider,
            builder: (context, _) => JuntoStreamBuilder<Discussion>(
              entryFrom: '_InstantDiscussionState._buildContent2',
              stream: Stream.fromFuture(createDiscussionFuture),
              errorMessage: 'There was an error setting up your event. Please refresh.',
              builder: (_, discussion) => ChangeNotifierProvider<DiscussionProvider>(
                create: (context) => DiscussionProvider.fromDiscussion(
                  discussion!,
                  juntoProvider: JuntoProvider.read(context),
                )..initialize(),
                builder: (context, _) => ChangeNotifierProvider<CommunityPermissionsProvider>(
                  create: (context) => CommunityPermissionsProvider(
                    juntoProvider: context.read<JuntoProvider>(),
                  ),
                  builder: (_, __) => ChangeNotifierProvider<DiscussionPermissionsProvider>(
                    create: (context) => DiscussionPermissionsProvider(
                      discussionProvider: context.read<DiscussionProvider>(),
                      communityPermissions: context.read<CommunityPermissionsProvider>(),
                      juntoProvider: context.read<JuntoProvider>(),
                    ),
                    builder: (_, __) => _buildMeeting(context),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FocusFixer(
      resizeForKeyboard: true,
      child: Material(
        color: AppColor.white,
        child: _buildContent(),
      ),
    );
  }
}
