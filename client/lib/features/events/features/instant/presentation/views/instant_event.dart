import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:client/features/community/data/providers/community_permissions_provider.dart';
import 'package:client/features/events/features/event_page/data/providers/event_permissions_provider.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/events/features/live_meeting/presentation/views/meeting_dialog.dart';
import 'package:client/features/events/features/event_page/data/providers/template_provider.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/core/widgets/navbar/nav_bar_provider.dart';
import 'package:client/core/routing/locations.dart';
import 'package:client/services.dart';
import 'package:client/styles/styles.dart';
import 'package:client/core/widgets/keyboard_util_widgets.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/user/public_user_info.dart';
import 'package:data_models/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:client/core/localization/localization_helper.dart';

class InstantEvent extends StatefulHookWidget {
  final String communityId;
  final String? templateId;
  final String? meetingId;
  final bool? record;
  final String? name;

  const InstantEvent({
    required this.communityId,
    required this.templateId,
    required this.meetingId,
    required this.record,
    required this.name,
  });

  @override
  _InstantEventState createState() => _InstantEventState();
}

class _InstantEventState extends State<InstantEvent> {
  String get templateId {
    final localTemplateId = widget.templateId;
    if (localTemplateId != null && localTemplateId.trim().isNotEmpty) {
      return localTemplateId;
    }

    return defaultInstantMeetingTemplateId;
  }

  Future<Event> _createEventIfNotExists(
    TemplateProvider templateProvider,
  ) async {
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

    final meetingId = 'i-${widget.communityId}-${widget.meetingId}';

    final communityId = widget.communityId;
    final community = await firestoreDatabase.getCommunity(communityId);
    final template = await templateProvider.templateFuture;
    final event = await firestoreEventService.createEventIfNotExists(
      record: widget.record ?? false,
      event: Event(
        id: meetingId,
        collectionPath: firestoreEventService
            .eventsCollection(communityId: communityId, templateId: templateId)
            .path,
        creatorId: userService.currentUserId!,
        status: EventStatus.active,
        communityId: communityId,
        templateId: templateId,
        nullableEventType: EventType.hosted,
        title: context.l10n.instantMeeting,
        scheduledTime: clockService.now(),
        isPublic: false,
        minParticipants: Event.defaultMinParticipants,
        maxParticipants: Event.defaultMaxParticipants,
        isLocked: false,
        agendaItems: template.agendaItems.toList(),
        externalCommunityId: widget.meetingId,
        eventSettings:
            template.eventSettings ?? community?.eventSettingsMigration,
      ),
    );

    await firestoreEventService.joinEvent(
      communityId: communityId,
      templateId: templateId,
      eventId: event.id,
      setAttendeeStatus: false,
    );

    return event;
  }

  Widget _buildMeeting(BuildContext context) {
    // The MeetingDialog widget expects the first event and template to
    // already be loaded so we need to wait for that to happen here.
    return CustomStreamBuilder(
      entryFrom: '_InstantEventState._buildMeeting',
      stream: Stream.fromFuture(
        Future.wait(<Future>[
          context.watch<CommunityProvider>().communityStream.first,
          context.watch<EventProvider>().eventStream.first,
          context.watch<EventProvider>().selfParticipantStream?.first ??
              Future.value(),
          context.watch<TemplateProvider>().templateFuture,
        ]),
      ),
      builder: (_, __) => MeetingDialog.create(
        isInstant: true,
        leaveLocation:
            CommunityPageRoutes(communityDisplayId: widget.communityId)
                .communityHome,
      ),
    );
  }

  Widget _buildContent() {
    final templateProvider = useMemoized(
      () => TemplateProvider(
        communityId: widget.communityId,
        templateId: templateId,
      )..initialize(),
    );
    final createEventFuture = useMemoized<Future<Event>>(
      () => _createEventIfNotExists(templateProvider),
      [],
    );

    return Center(
      child: ChangeNotifierProvider<CommunityProvider>(
        create: (context) => CommunityProvider(
          displayId: widget.communityId,
          navBarProvider: context.read<NavBarProvider>(),
        )..initialize(),
        builder: (context, _) => CustomStreamBuilder(
          entryFrom: '_InstantEventState._buildContent1',
          stream: CommunityProvider.read(context).communityStream,
          errorMessage:
              'There was an error setting up your event. Please refresh.',
          builder: (_, event) => ChangeNotifierProvider<TemplateProvider>.value(
            value: templateProvider,
            builder: (context, _) => CustomStreamBuilder<Event>(
              entryFrom: '_InstantEventState._buildContent2',
              stream: Stream.fromFuture(createEventFuture),
              errorMessage:
                  'There was an error setting up your event. Please refresh.',
              builder: (_, event) => ChangeNotifierProvider<EventProvider>(
                create: (context) => EventProvider.fromEvent(
                  event!,
                  communityProvider: CommunityProvider.read(context),
                )..initialize(),
                builder: (context, _) =>
                    ChangeNotifierProvider<CommunityPermissionsProvider>(
                  create: (context) => CommunityPermissionsProvider(
                    communityProvider: context.read<CommunityProvider>(),
                  ),
                  builder: (_, __) =>
                      ChangeNotifierProvider<EventPermissionsProvider>(
                    create: (context) => EventPermissionsProvider(
                      eventProvider: context.read<EventProvider>(),
                      communityPermissions:
                          context.read<CommunityPermissionsProvider>(),
                      communityProvider: context.read<CommunityProvider>(),
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
        color: context.theme.colorScheme.surfaceContainerLowest,
        child: _buildContent(),
      ),
    );
  }
}
