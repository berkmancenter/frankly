import 'dart:async';
import 'package:flutter/material.dart';
import 'package:junto/app/junto/community_permissions_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_permissions_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/meeting_dialog.dart';
import 'package:junto/app/junto/discussions/discussion_page/topic_provider.dart';
import 'package:junto/app/junto/discussions/instant_unify/unify_america_controller.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/common_widgets/navbar/nav_bar_provider.dart';
import 'package:junto/services/services.dart';
import 'package:junto/utils/keyboard_utils.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/live_meeting.dart';
import 'package:junto_models/firestore/public_user_info.dart';
import 'package:junto_models/utils.dart';
import 'package:provider/provider.dart';

const unifyBlue = Color(0xFF087acf);

class InstantUnifyDiscussion extends StatefulWidget {
  final String juntoId;

  // We currently assume that the below parameters will be present but technically this URL can be
  // visited without these query parameters.
  final String? userId;
  final String? userDisplay;
  final String? meetingId;
  final String? typeformLink;
  final String? redirectUrl;
  final bool record;

  const InstantUnifyDiscussion({
    required this.juntoId,
    required this.userId,
    required this.userDisplay,
    required this.meetingId,
    required this.typeformLink,
    required this.redirectUrl,
    required this.record,
  });

  @override
  _InstantUnifyDiscussionState createState() => _InstantUnifyDiscussionState();
}

class _InstantUnifyDiscussionState extends State<InstantUnifyDiscussion> {
  static const _topicId = 'unify-default-topic';

  late Future<Discussion> _createAndJoinDiscussionFuture;

  bool _leaveMeeting = false;

  @override
  void initState() {
    super.initState();

    dialogProvider.isOnIframePage = true;

    _createAndJoinDiscussionFuture = _createDiscussionIfNotExists();
  }

  Future<Discussion> _createDiscussionIfNotExists() async {
    if (!userService.isSignedIn) {
      await userService.updateCurrentUserInfo(
        PublicUserInfo(
          id: userService.currentUserId!,
          agoraId: uidToInt(userService.currentUserId!),
          displayName: widget.userDisplay ?? 'Participant',
        ),
        ['displayName'],
      );
    }

    final meetingId = 'i-${widget.juntoId}-${widget.meetingId}';

    final juntoId = widget.juntoId;
    final junto = await firestoreDatabase.getJunto(juntoId);
    final discussion = await firestoreDiscussionService.createDiscussionIfNotExists(
      discussion: Discussion(
        id: meetingId,
        collectionPath: firestoreDiscussionService
            .discussionsCollection(juntoId: juntoId, topicId: _topicId)
            .path,
        creatorId: userService.currentUserId!,
        status: DiscussionStatus.active,
        nullableDiscussionType: DiscussionType.hosted,
        title: widget.meetingId,
        juntoId: juntoId,
        topicId: _topicId,
        scheduledTime: clockService.now(),
        isPublic: false,
        minParticipants: 0,
        maxParticipants: 10,
        isLocked: false,
        agendaItems: [],
        externalCommunityId: widget.meetingId,
        discussionSettings: junto?.discussionSettingsMigration,
      ),
    );

    if (widget.record) {
      await firestoreLiveMeetingService.update(
        liveMeetingPath: firestoreLiveMeetingService.getLiveMeetingPath(discussion),
        liveMeeting: LiveMeeting(record: true),
        keys: [LiveMeeting.kFieldRecord],
      );
    }

    await firestoreDiscussionService.joinDiscussion(
      juntoId: juntoId,
      topicId: _topicId,
      discussionId: discussion.id,
      externalCommunityId: widget.userId,
      setAttendeeStatus: false,
    );

    await firestoreLiveMeetingService.updateMeetingPresence(
      discussion: discussion,
      isPresent: true,
    );

    return discussion;
  }

  Future<void> _onLeaveMeeting(String redirectUrl) async {
    if (isNullOrEmpty(redirectUrl)) {
      setState(() => _leaveMeeting = true);
    } else {
      await launch(
        redirectUrl,
        targetIsSelf: true,
      );
    }
  }

  Widget _buildMeeting(BuildContext context) {
    // The MeetingDialog widget expects the first discussion and topic to
    // already be loaded so we need to wait for that to happen here.
    return JuntoStreamBuilder(
      entryFrom: '_InstantUnifyDiscussionState._buildMeeting',
      stream: Stream.fromFuture(Future.wait(<Future>[
        context.watch<JuntoProvider>().juntoStream.first,
        context.watch<DiscussionProvider>().discussionStream.first,
        context.watch<DiscussionProvider>().selfParticipantStream?.first ?? Future.value(),
      ])),
      builder: (_, __) => MeetingDialog.create(
        isInstant: true,
        onLeave: () => _onLeaveMeeting(widget.redirectUrl!),
      ),
    );
  }

  Widget _buildContent() {
    return ChangeNotifierProvider<JuntoProvider>(
      create: (context) => JuntoProvider(
        displayId: widget.juntoId,
        navBarProvider: context.read<NavBarProvider>(),
      )..initialize(),
      builder: (context, _) => JuntoStreamBuilder(
        stream: JuntoProvider.read(context).juntoStream,
        entryFrom: '_InstantUnifyDiscussionState._buildContent',
        errorMessage: 'There was an error setting up your event. Please refresh.',
        builder: (_, __) => ChangeNotifierProvider<TopicProvider>(
          create: (_) => TopicProvider(
            juntoId: widget.juntoId,
            topicId: _topicId,
          )..initialize(),
          builder: (context, _) => JuntoStreamBuilder<Discussion>(
            stream: Stream.fromFuture(_createAndJoinDiscussionFuture),
            entryFrom: '_InstantUnifyDiscussionState._buildContent',
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
    );
  }

  Widget _buildLeftMeeting() {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'media/UA-Horizontal-Logo-1024x392.png',
            width: 350,
          ),
          SizedBox(height: 16),
          Text(
            'Thank you for participating!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_leaveMeeting) return _buildLeftMeeting();

    return FocusFixer(
      child: Scaffold(
        body: Center(
          child: ChangeNotifierProvider(
            create: (_) => UnifyAmericaController(
              typeformLink: widget.typeformLink!,
              externalCommunityId: widget.userId!,
            ),
            child: _buildContent(),
          ),
        ),
      ),
    );
  }
}
