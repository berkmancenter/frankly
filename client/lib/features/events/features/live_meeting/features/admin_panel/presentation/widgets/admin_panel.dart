import 'package:client/core/widgets/custom_loading_indicator.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:client/features/community/data/providers/community_permissions_provider.dart';
import 'package:client/features/events/features/live_meeting/features/admin_panel/presentation/views/breakout_rooms_dialog.dart';
import 'package:client/features/events/features/live_meeting/features/admin_panel/presentation/views/jump_to_room_dialog.dart';
import 'package:client/features/events/features/live_meeting/features/admin_panel/presentation/views/kick_dialog.dart';
import 'package:client/features/events/features/live_meeting/features/admin_panel/presentation/views/reassign_breakout_room_dialog.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/events/features/live_meeting/data/providers/live_meeting_provider.dart';
import 'package:client/features/events/features/live_meeting/features/video/presentation/views/fake_participants_dialog.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/providers/meeting_agenda_provider.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/confirm_dialog.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/core/widgets/buttons/thick_outline_button.dart';
import 'package:client/features/user/data/providers/user_info_builder.dart';
import 'package:client/features/user/presentation/widgets/user_profile_chip.dart';
import 'package:client/core/utils/visible_exception.dart';
import 'package:client/config/environment.dart';
import 'package:client/core/utils/firestore_utils.dart';
import 'package:client/services.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:client/styles/styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';
import 'package:provider/provider.dart';

final fakeWaitingRoomObject = BreakoutRoom(
  roomId: breakoutsWaitingRoomId,
  roomName: 'Waiting Room',
  orderingPriority: -1,
  flagStatus: BreakoutRoomFlagStatus.unflagged,
  creatorId: 'fake',
);

class AdminPanel extends StatefulWidget {
  final EdgeInsets padding;

  const AdminPanel({this.padding = EdgeInsets.zero});

  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  LiveMeetingProvider get _provider =>
      Provider.of<LiveMeetingProvider>(context);
  LiveMeetingProvider get _providerRead =>
      Provider.of<LiveMeetingProvider>(context, listen: false);

  EventProvider get _eventProvider => EventProvider.watch(context);

  Widget _buildParticipantEntry(Participant participant) {
    return Container(
      key: Key('participant-entry-${participant.id}'),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: UserProfileChip(
              userId: participant.id,
              imageHeight: 26,
            ),
          ),
          if (participant.id != Provider.of<UserService>(context).currentUserId)
            _ParticipantMenu(kickedUserId: participant.id),
        ],
      ),
    );
  }

  Widget _buildMeetingProviderParticipantEntry(
    MeetingProviderParticipant participant,
  ) {
    final id = participant.userId;
    final sessionId = participant.sessionId;
    final local = participant.local;

    return Padding(
      key: Key('participant-entry-${participant.userId}'),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: UserProfileChip(
              userId: id,
              imageHeight: 32,
            ),
          ),
          Spacer(),
          if (!local)
            _ParticipantMenu(
              kickedUserId: participant.userId,
              providerParticipant: participant,
            ),
        ],
      ),
    );
  }

  List<Widget> _buildBreakoutList() {
    return [
      Container(
        color: context.theme.colorScheme.scrim.withScrimOpacity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: HeightConstrainedText(
                'Breakouts',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ),
            if (_eventProvider.event.eventType != EventType.hostless) ...[
              SizedBox(width: 4),
              ActionButton(
                color: context.theme.colorScheme.onPrimary,
                onPressed: () => _providerRead.endBreakoutRooms(),
                text: 'End Breakouts',
              ),
            ],
            SizedBox(width: 6),
            _MeetingControlsMenu(),
          ],
        ),
      ),
      SizedBox(height: 6),
      Expanded(child: BreakoutRoomGrid()),
    ];
  }

  Widget _buildPaginatedParticipants() {
    return FirestoreListView(
      itemBuilder: (context, documentSnapshot) {
        final participant = Participant.fromJson(
          fromFirestoreJson(documentSnapshot.data() as Map<String, dynamic>),
        );
        return _buildParticipantEntry(participant);
      },
      query: firestoreEventService.eventParticipantsQuery(
        event: EventProvider.watch(context).event,
      ),
      pageSize: 40,
      emptyBuilder: (_) => HeightConstrainedText('No one is here yet.'),
      errorBuilder: (_, __, ___) => HeightConstrainedText(
        'Something went wrong loading participants. Please refreh.',
      ),
    );
  }

  List<Widget> _buildDefaultParticipantList() {
    var participantSuffix = '';
    final useMeetingProviderParticipants = _eventProvider.event.isHosted;
    final participantCount = (useMeetingProviderParticipants
            ? _provider.meetingProviderParticipants?.length
            : _eventProvider.participantCount) ??
        0;
    if (participantCount > 0 && useMeetingProviderParticipants) {
      participantSuffix = ' ($participantCount)';
    }
    return [
      Row(
        children: [
          Expanded(
            child: HeightConstrainedText(
              'Participants$participantSuffix',
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          SizedBox(width: 6),
          ActionButton(
            onPressed: participantCount == 0
                ? null
                : () => BreakoutRoomsDialog(
                      outerContext: context,
                      canFetchCapabilities: context
                          .read<CommunityPermissionsProvider>()
                          .canModerateContent,
                    ).show(),
            text: 'Breakouts',
            color: context.theme.colorScheme.onPrimary,
          ),
          SizedBox(width: 6),
          _MeetingControlsMenu(),
        ],
      ),
      SizedBox(height: 8),
      if (!useMeetingProviderParticipants)
        Expanded(child: _buildPaginatedParticipants())
      else if (participantCount == 0)
        Text('No one is here yet')
      else ...[
        ActionButton(
          expand: true,
          text: 'Mute All',
          onPressed: () => _providerRead.muteAllParticipants(),
          color: context.theme.colorScheme.onPrimary,
        ),
        Expanded(
          child: ListView(
            children: _provider.meetingProviderParticipants
                    ?.map(_buildMeetingProviderParticipantEntry)
                    .toList() ??
                [],
          ),
        ),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Column(
        children: [
          if (_provider.breakoutsActive)
            ..._buildBreakoutList()
          else
            ..._buildDefaultParticipantList(),
        ],
      ),
    );
  }
}

class BreakoutRoomGrid extends StatefulWidget {
  @override
  _BreakoutRoomGridState createState() => _BreakoutRoomGridState();
}

class _BreakoutRoomGridState extends State<BreakoutRoomGrid> {
  String? _selectedRoom;
  bool _showOnlyAlertedRooms = false;

  BehaviorSubjectWrapper<List<BreakoutRoom>>? _needHelpRooms;
  BehaviorSubjectWrapper<BreakoutRoom?>? _waitingRoomStream;
  BehaviorSubjectWrapper<List<Participant>>? _waitingRoomParticipants;

  @override
  void dispose() {
    _waitingRoomStream?.dispose();
    _waitingRoomParticipants?.dispose();
    _needHelpRooms?.dispose();
    super.dispose();
  }

  Widget _buildSelectedRoom() {
    return BreakoutRoomDetails(
      roomId: _selectedRoom!,
      goBack: () => setState(() => _selectedRoom = null),
    );
  }

  Widget _buildBreakoutRoomFilterToggle() {
    const borderRadius = 20.0;
    return CustomInkWell(
      borderRadius: BorderRadius.circular(borderRadius),
      onTap: () =>
          setState(() => _showOnlyAlertedRooms = !_showOnlyAlertedRooms),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(borderRadius),
                ),
                color: _showOnlyAlertedRooms
                    ? context.theme.colorScheme.scrim.withScrimOpacity
                    : context.theme.colorScheme.onPrimary,
              ),
              alignment: Alignment.center,
              child: HeightConstrainedText(
                'All rooms',
                style: TextStyle(
                  color: _showOnlyAlertedRooms
                      ? context.theme.colorScheme.onPrimary
                      : Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(borderRadius),
                ),
                color: !_showOnlyAlertedRooms
                    ? context.theme.colorScheme.scrim.withScrimOpacity
                    : context.theme.colorScheme.onPrimary,
              ),
              alignment: Alignment.center,
              child: HeightConstrainedText(
                'Alerts only',
                style: TextStyle(
                  color: !_showOnlyAlertedRooms
                      ? context.theme.colorScheme.onPrimary
                      : Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllBreakoutsPaginated(
    BoxConstraints constraints,
    Set<String> needsHelpRoomIds,
  ) {
    return FirestoreQueryBuilder(
      key: Key('paginate-breakouts-needHelp-$_showOnlyAlertedRooms'),
      query: firestoreLiveMeetingService.getBreakoutRoomsQuery(
        event: EventProvider.watch(context).event,
        breakoutRoomSessionId: LiveMeetingProvider.watch(context)
            .liveMeeting!
            .currentBreakoutSession!
            .breakoutRoomSessionId,
        filterNeedsHelp: _showOnlyAlertedRooms,
      ),
      pageSize: 20,
      builder: (_, snapshot, widget) {
        return GridView.builder(
          itemCount: snapshot.docs.length,
          itemBuilder: (_, index) {
            if (snapshot.hasError) {
              return HeightConstrainedText(
                'Something went wrong loading breakout rooms. Please refresh',
              );
            } else if (snapshot.docs.isEmpty) {
              return HeightConstrainedText('No rooms found.');
            }

            // if we reached the end of the currently obtained items, we try to
            // obtain more items
            if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
              // Tell FirestoreQueryBuilder to try to obtain more items.
              // It is safe to call this function from within the build method.
              snapshot.fetchMore();
            }

            final room = BreakoutRoom.fromJson(
              fromFirestoreJson(
                snapshot.docs[index].data() as Map<String, dynamic>,
              ),
            );
            return BreakoutRoomButton(
              needsHelpOverride: needsHelpRoomIds.contains(room.roomId),
              room: room,
              onTap: () => setState(() => _selectedRoom = room.roomId),
            );
          },
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: constraints.maxWidth > 430 ? 3 : 2,
            childAspectRatio: 140.0 / 80,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
        );
      },
    );
  }

  Widget _buildNeedsHelpGrid(
    BoxConstraints constraints,
    List<BreakoutRoom> rooms,
  ) {
    if (rooms.isEmpty) {
      return HeightConstrainedText('No rooms need help.');
    }
    return GridView.builder(
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final room = rooms[index];
        return BreakoutRoomButton(
          room: room,
          onTap: () => setState(() => _selectedRoom = room.roomId),
        );
      },
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: constraints.maxWidth > 430 ? 3 : 2,
        childAspectRatio: 140.0 / 80,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isNullOrEmpty(_selectedRoom)) {
      return _buildSelectedRoom();
    }

    final liveMeetingProvider = LiveMeetingProvider.read(context);

    final breakoutSessionId = liveMeetingProvider
        .liveMeeting!.currentBreakoutSession!.breakoutRoomSessionId;
    return CustomStreamBuilder<BreakoutRoom?>(
      entryFrom: '_BreakoutRoomGridState.build',
      stream: _waitingRoomStream ??=
          firestoreLiveMeetingService.breakoutRoomStream(
        event: EventProvider.read(context).event,
        breakoutRoomSessionId: breakoutSessionId,
        breakoutRoomId: breakoutsWaitingRoomId,
      ),
      builder: (_, waitingRoom) => CustomStreamBuilder<List<Participant>>(
        entryFrom: '_BreakoutRoomGridState.build',
        stream: _waitingRoomParticipants ??=
            firestoreLiveMeetingService.breakoutRoomParticipantsStream(
          event: EventProvider.watch(context).event,
          breakoutRoomSessionId: breakoutSessionId,
          breakoutRoomId: breakoutsWaitingRoomId,
        ),
        builder: (context, waitingRoomParticipants) =>
            CustomStreamBuilder<List<BreakoutRoom>>(
          entryFrom: '_BreakoutRoomGridState.build',
          stream: _needHelpRooms ??=
              firestoreLiveMeetingService.breakoutRoomsStream(
            event: EventProvider.watch(context).event,
            breakoutRoomSessionId: breakoutSessionId,
            filterNeedsHelp: true,
          ),
          builder: (context, needHelpRooms) {
            // If the waiting room has participants who are present there, that are also assigned
            // there we want to show the waiting room in this list of rooms that need help so that
            // an admin can reassign them.
            //
            // If someone in the waiting room flagged the room as needing help it will already
            // be in the list of rooms that need help so we don't want to add it twice.
            final usersAssignedToWaitingRoom =
                waitingRoom?.participantIds.toSet() ?? {};
            final waitingRoomIsActive = waitingRoomParticipants
                    ?.any((p) => usersAssignedToWaitingRoom.contains(p.id)) ??
                false;
            final waitingRoomAlreadyFlaggedAsNeedHelp =
                needHelpRooms?.any((r) => r.roomId == breakoutsWaitingRoomId) ??
                    false;
            final List<BreakoutRoom> allNeedHelpRooms = [
              if (waitingRoomIsActive && !waitingRoomAlreadyFlaggedAsNeedHelp)
                waitingRoom!,
              ...needHelpRooms!,
            ];
            return Column(
              children: [
                SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _buildBreakoutRoomFilterToggle(),
                    ),
                    SizedBox(width: 4),
                    ActionButton(
                      onPressed: () => alertOnError(context, () async {
                        final roomNumber = await JumpToRoomDialog().show();
                        if (!isNullOrEmpty(roomNumber)) {
                          final room = await firestoreLiveMeetingService
                              .getBreakoutRoomFromRoomNumber(
                            event: EventProvider.read(context).event,
                            breakoutRoomSessionId: liveMeetingProvider
                                    .liveMeeting
                                    ?.currentBreakoutSession
                                    ?.breakoutRoomSessionId ??
                                '',
                            roomNumber: roomNumber!,
                          );
                          if (room == null) {
                            throw VisibleException(
                              'Room $roomNumber not found.',
                            );
                          }
                          setState(() => _selectedRoom = room.roomId);
                        }
                      }),
                      text: 'Jump To',
                      textColor: context.theme.colorScheme.onPrimary,
                      color: context.theme.colorScheme.scrim.withScrimOpacity,
                    ),
                  ],
                ),
                SizedBox(height: 16),
                if (!isNullOrEmpty(
                  liveMeetingProvider.currentBreakoutRoomId,
                )) ...[
                  ActionButton(
                    onPressed: () => setState(
                      () => _selectedRoom =
                          liveMeetingProvider.currentBreakoutRoomId,
                    ),
                    text: 'View Current Room',
                    expand: true,
                    color: context.theme.colorScheme.onPrimary,
                  ),
                  SizedBox(height: 16),
                ],
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) => _showOnlyAlertedRooms
                        ? _buildNeedsHelpGrid(constraints, allNeedHelpRooms)
                        : _buildAllBreakoutsPaginated(
                            constraints,
                            allNeedHelpRooms.map((r) => r.roomId).toSet(),
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MeetingControlsMenu extends StatefulWidget {
  @override
  _MeetingControlsMenuState createState() => _MeetingControlsMenuState();
}

class _MeetingControlsMenuState extends State<_MeetingControlsMenu> {
  final _menuKey = GlobalKey();

  bool get canModerateContent =>
      Provider.of<CommunityPermissionsProvider>(context).canModerateContent;

  List<PopupMenuEntry<Function()>> _getMoreMenuItems() {
    final provider = context.read<EventProvider>();
    final liveMeetingProvider = LiveMeetingProvider.read(context);
    final agendaProvider = Provider.of<AgendaProvider>(context, listen: false);
    final isLocked = provider.event.isLocked;
    return [
      if (liveMeetingProvider.isHost == true || canModerateContent)
        PopupMenuItem<Function()>(
          value: () async {
            await alertOnError(
              context,
              () => firestoreEventService.updateEvent(
                event: provider.event.copyWith(isLocked: !isLocked),
                keys: [Event.kFieldIsLocked],
              ),
            );
          },
          child: HeightConstrainedText(
            isLocked ? 'Unlock Meeting' : 'Lock Meeting',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      if ((liveMeetingProvider.isHost == true || canModerateContent) &&
          agendaProvider.isMeetingStarted)
        PopupMenuItem<Function()>(
          value: () => alertOnError(context, () async {
            final confirmed = await ConfirmDialog(
              mainText:
                  'This will delete all existing meeting data. Are you sure you want to reset?',
            ).show(context: context);
            if (!confirmed) return;
            await agendaProvider.resetMeeting();
          }),
          child: HeightConstrainedText(
            'Reset Guide',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      if (Environment.enableFakeParticipants)
        PopupMenuItem<Function()>(
          value: () => alertOnError(context, () async {
            final numParticipants = await FakeParticipantsDialog(
              fakeParticipantCount: LiveMeetingProvider.read(context)
                      .conferenceRoom
                      ?.numFakeParticipants ??
                  0,
            ).show();
            if (numParticipants == null) return;
            final countValue = int.tryParse(numParticipants);
            if (countValue == null) return;

            LiveMeetingProvider.read(context)
                .conferenceRoom
                ?.numFakeParticipants = countValue;
          }),
          child: HeightConstrainedText(
            'Add Fake Participants',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
    ];
  }

  Future<void> _showMoreMenu(List<PopupMenuEntry<Function()>> items) async {
    final button = _menuKey.currentContext?.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay?.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );
    final resultFunction = await showMenu<Function()>(
      context: context,
      position: position,
      items: items,
    );

    if (resultFunction != null) {
      resultFunction();
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = _getMoreMenuItems();

    if (menuItems.isEmpty) return SizedBox.shrink();

    return CustomInkWell(
      hoverColor: context.theme.colorScheme.scrim.withScrimOpacity,
      onTap: () => _showMoreMenu(menuItems),
      child: Icon(
        Icons.more_vert,
        key: _menuKey,
      ),
    );
  }
}

class _ParticipantMenu extends StatefulWidget {
  final String kickedUserId;
  final MeetingProviderParticipant? providerParticipant;
  final String? breakoutRoomId;

  const _ParticipantMenu({
    required this.kickedUserId,
    this.providerParticipant,
    this.breakoutRoomId,
  });

  @override
  __ParticipantMenuState createState() => __ParticipantMenuState();
}

class __ParticipantMenuState extends State<_ParticipantMenu> {
  final _menuKey = GlobalKey();

  List<PopupMenuEntry<Function()>> _getMenuItems() {
    return [
      if (widget.providerParticipant?.audioOn ?? false)
        PopupMenuItem<Function()>(
          value: () => widget.providerParticipant?.mute(),
          child: HeightConstrainedText(
            'Mute',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      PopupMenuItem<Function()>(
        value: () => alertOnError(context, () async {
          KickDialogResult? confirmResult = await KickDialog(
            userName:
                UserInfoProvider.forUser(widget.kickedUserId).info?.displayName,
          ).show();
          if (!(confirmResult?.kickParticipant ?? false)) return;

          final event = EventProvider.read(context).event;
          if (event.creatorId == widget.kickedUserId) {
            throw VisibleException('Can\'t kick the event creator.');
          }
          final breakoutRoomId = widget.breakoutRoomId;

          await swallowErrors(
            () => cloudFunctionsLiveMeetingService.kickParticipant(
              request: KickParticipantRequest(
                userToKickId: widget.kickedUserId,
                breakoutRoomId: breakoutRoomId,
                eventPath: event.fullPath,
              ),
            ),
          );
          await firestoreEventService.kickParticipant(
            event: event,
            kickedUserId: widget.kickedUserId,
            lockRoom: confirmResult?.lockRoom ?? false,
          );
        }),
        child: HeightConstrainedText(
          'Kick',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    ];
  }

  Future<void> _showMoreMenu(List<PopupMenuEntry<Function()>> items) async {
    final button = _menuKey.currentContext?.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay?.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );
    final resultFunction = await showMenu<Function()>(
      context: context,
      position: position,
      items: items,
    );

    if (resultFunction != null) {
      resultFunction();
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = _getMenuItems();
    return Semantics(
      label:
          'Participant Actions for user with ID ${widget.providerParticipant?.userId}',
      child: CustomInkWell(
        hoverColor: context.theme.colorScheme.scrim.withScrimOpacity,
        onTap: () => _showMoreMenu(menuItems),
        child: Icon(
          Icons.more_vert,
          key: _menuKey,
        ),
      ),
    );
  }
}

class BreakoutRoomButton extends StatefulWidget {
  final BreakoutRoom room;
  final Function()? onTap;
  final bool needsHelpOverride;

  BreakoutRoomButton({
    required this.room,
    this.onTap,
    this.needsHelpOverride = false,
  }) : super(key: Key('breakout-room-button-${room.roomId}'));

  @override
  _BreakoutRoomButtonState createState() => _BreakoutRoomButtonState();
}

class _BreakoutRoomButtonState extends State<BreakoutRoomButton> {
  late BehaviorSubjectWrapper<List<Participant>> _breakoutParticipantsStream;

  bool get isWaitingRoom => widget.room.roomId == breakoutsWaitingRoomId;

  @override
  void initState() {
    super.initState();
    _breakoutParticipantsStream =
        firestoreLiveMeetingService.breakoutRoomParticipantsStream(
      event: EventProvider.read(context).event,
      breakoutRoomSessionId: LiveMeetingProvider.read(context)
          .liveMeeting!
          .currentBreakoutSession!
          .breakoutRoomSessionId,
      breakoutRoomId: widget.room.roomId,
    );
  }

  @override
  void dispose() {
    _breakoutParticipantsStream.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Participant>>(
      stream: _breakoutParticipantsStream,
      builder: (context, participantsSnapshot) {
        var participants =
            participantsSnapshot.data?.map((p) => p.id).toList() ?? [];
        if (isWaitingRoom) {
          final assignedHere = widget.room.participantIds.toSet();
          participants =
              participants.where((id) => assignedHere.contains(id)).toList();
        }
        final participantCount = participants.length;

        final room = widget.room;
        final roomDisplayName = room.roomId == breakoutsWaitingRoomId
            ? room.roomName
            : 'Room ${room.roomName}';

        final needsHelp = widget.needsHelpOverride ||
            room.flagStatus == BreakoutRoomFlagStatus.needsHelp ||
            (room.roomId == breakoutsWaitingRoomId && participantCount > 0);

        final liveMeetingProvider = LiveMeetingProvider.watch(context);
        final isCurrentRoom =
            liveMeetingProvider.currentBreakoutRoomId == room.roomId &&
                liveMeetingProvider.userLeftBreakouts == false;

        Color backgroundColor =
            context.theme.colorScheme.scrim.withScrimOpacity;
        if (isCurrentRoom) {
          backgroundColor = context.theme.colorScheme.onPrimary;
        } else if (needsHelp) {
          backgroundColor = context.theme.colorScheme.error;
        }

        return CustomInkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                HeightConstrainedText(
                  roomDisplayName.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: isCurrentRoom
                        ? Theme.of(context).primaryColor
                        : context.theme.colorScheme.onPrimary,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: needsHelp
                        ? context.theme.colorScheme.errorContainer
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (needsHelp) ...[
                        Icon(
                          Icons.notifications,
                          color: context.theme.colorScheme.error,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                      ],
                      if (participantsSnapshot.connectionState ==
                          ConnectionState.waiting)
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: CustomLoadingIndicator(),
                        )
                      else if (participantsSnapshot.hasError)
                        HeightConstrainedText('Error')
                      else
                        HeightConstrainedText(
                          '$participantCount people',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: needsHelp
                                ? context.theme.colorScheme.error
                                : (isCurrentRoom
                                    ? Theme.of(context).primaryColor
                                    : context.theme.colorScheme.onPrimary),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class BreakoutRoomDetails extends StatefulWidget {
  final String roomId;
  final Function() goBack;

  BreakoutRoomDetails({
    required this.roomId,
    required this.goBack,
  }) : super(key: Key(roomId));

  @override
  _BreakoutRoomDetailsState createState() => _BreakoutRoomDetailsState();
}

class _BreakoutRoomDetailsState extends State<BreakoutRoomDetails> {
  late BehaviorSubjectWrapper<BreakoutRoom?> _breakoutRoomStream;
  late BehaviorSubjectWrapper<List<Participant>> _breakoutParticipantsStream;

  @override
  void initState() {
    super.initState();
    final breakoutSessionId = LiveMeetingProvider.read(context)
        .liveMeeting!
        .currentBreakoutSession!
        .breakoutRoomSessionId;
    _breakoutRoomStream = firestoreLiveMeetingService.breakoutRoomStream(
      event: EventProvider.read(context).event,
      breakoutRoomSessionId: breakoutSessionId,
      breakoutRoomId: widget.roomId,
    );
    _breakoutParticipantsStream =
        firestoreLiveMeetingService.breakoutRoomParticipantsStream(
      event: EventProvider.read(context).event,
      breakoutRoomSessionId: breakoutSessionId,
      breakoutRoomId: widget.roomId,
    );
  }

  @override
  void dispose() {
    _breakoutRoomStream.dispose();
    _breakoutParticipantsStream.dispose();
    super.dispose();
  }

  Widget _buildBreakoutRoomParticipant(
    String participantId,
    BreakoutRoom breakoutRoom,
    BuildContext context,
  ) {
    final id = participantId;
    final providerParticipant = LiveMeetingProvider.watch(context)
        .meetingProviderParticipants
        ?.firstWhereOrNull((p) => p.userId == id);

    final local = id == Provider.of<UserService>(context).currentUserId;

    return Padding(
      key: Key('breakout-room-participant-$id'),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: UserProfileChip(
                userId: id,
                imageHeight: 28,
              ),
            ),
          ),
          SizedBox(width: 6),
          ActionButton(
            color: Colors.transparent,
            textColor: context.theme.colorScheme.onPrimary,
            overlayColor: context.theme.colorScheme.surfaceContainer,
            sendingIndicatorAlign: ActionButtonSendingIndicatorAlign.none,
            onPressed: () => alertOnError(context, () async {
              final ReassignResult? newRoomAssignment =
                  await ReassignBreakoutRoomDialog(
                outerContext: context,
                userId: id,
                currentRoomNumber: [
                  breakoutsWaitingRoomId,
                  reassignNewRoomId,
                ].contains(breakoutRoom.roomId)
                    ? null
                    : breakoutRoom.roomName,
              ).show();
              final reassignId = newRoomAssignment?.reassignId;
              if (reassignId == null || reassignId.trim().isEmpty) return;

              final newBreakoutRoom =
                  await Provider.of<LiveMeetingProvider>(context, listen: false)
                      .reassignBreakoutRoom(
                userId: id,
                newRoomNumber: reassignId,
              );

              // If multiple people are reassigning at the same time its possible for the
              // new room number to be higher than expected. We show a dialog to
              // make sure the user knows the room the user was assigned to.
              if (reassignId == reassignNewRoomId &&
                  newRoomAssignment?.expectedNewRoom?.toString() !=
                      newBreakoutRoom.roomName) {
                await ConfirmDialog(
                  title: 'Participant Reassigned',
                  mainText: 'Reassigned to Room ${newBreakoutRoom.roomName}',
                  confirmText: 'Ok',
                ).show(context: context);
              }
            }),
            text: 'Reassign',
          ),
          if (!local)
            _ParticipantMenu(
              kickedUserId: participantId,
              providerParticipant: providerParticipant,
              breakoutRoomId: breakoutRoom.roomId,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomStreamBuilder<BreakoutRoom?>(
      entryFrom: '_BreakoutRoomDetailsState.build',
      stream: _breakoutRoomStream.stream,
      builder: (context, room) => CustomStreamBuilder<List<Participant>>(
        entryFrom: '_BreakoutRoomDetailsState.build',
        stream: _breakoutParticipantsStream,
        builder: (context, liveBreakoutParticipants) {
          final localRoom = room!;
          final localLiveBreakoutParticipants = liveBreakoutParticipants!;
          final isWaitingRoom = localRoom.roomId == breakoutsWaitingRoomId;
          var participantIds =
              localLiveBreakoutParticipants.map((p) => p.id).toList();
          if (isWaitingRoom) {
            final assignedHere = room.participantIds.toSet();
            participantIds = participantIds
                .where((id) => assignedHere.contains(id))
                .toList();
          }
          final participantCount = participantIds.length;

          final roomDisplayName = localRoom.roomId == breakoutsWaitingRoomId
              ? localRoom.roomName
              : 'Room ${localRoom.roomName}';

          final needsHelp =
              localRoom.flagStatus == BreakoutRoomFlagStatus.needsHelp ||
                  (localRoom.roomId == breakoutsWaitingRoomId &&
                      participantCount > 0);
          final provider = LiveMeetingProvider.watch(context);

          return Column(
            children: [
              CustomInkWell(
                onTap: widget.goBack,
                child: Container(
                  color: needsHelp
                      ? context.theme.colorScheme.error
                      : context.theme.colorScheme.scrim.withScrimOpacity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      Icon(Icons.chevron_left, size: 36),
                      SizedBox(width: 12),
                      Expanded(
                        child: HeightConstrainedText(
                          roomDisplayName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      SizedBox(width: 4),
                      if (provider.currentBreakoutRoomId == localRoom.roomId &&
                          (!provider.userLeftBreakouts))
                        ActionButton(
                          color: Colors.transparent,
                          textColor: context.theme.colorScheme.onPrimary,
                          overlayColor:
                              context.theme.colorScheme.surfaceContainer,
                          onPressed: () async {
                            final reassignUser =
                                provider.currentBreakoutRoomId ==
                                    provider.assignedBreakoutRoomId;

                            provider.leaveBreakoutRoom();

                            if (reassignUser) {
                              await provider.reassignBreakoutRoom(
                                userId: userService.currentUserId!,
                                newRoomNumber: null,
                              );
                            }
                          },
                          text: 'Leave Room',
                        )
                      else
                        ActionButton(
                          onPressed: () {
                            provider.enterBreakoutRoom(
                              roomId: localRoom.roomId,
                            );
                          },
                          color: needsHelp
                              ? context.theme.colorScheme.errorContainer
                              : Colors.transparent,
                          textColor: needsHelp
                              ? context.theme.colorScheme.onPrimary
                              : context.theme.colorScheme.onPrimary,
                          overlayColor:
                              context.theme.colorScheme.surfaceContainer,
                          text: 'Enter Room',
                        ),
                    ],
                  ),
                ),
              ),
              if (localRoom.flagStatus == BreakoutRoomFlagStatus.needsHelp) ...[
                SizedBox(height: 6),
                ThickOutlineButton(
                  onPressed: () async {
                    final roomId = localRoom.roomId;

                    await alertOnError(
                      context,
                      () => cloudFunctionsLiveMeetingService
                          .updateBreakoutRoomFlagStatus(
                        request: UpdateBreakoutRoomFlagStatusRequest(
                          eventPath: provider.eventPath,
                          breakoutSessionId: provider
                                  .liveMeeting
                                  ?.currentBreakoutSession
                                  ?.breakoutRoomSessionId ??
                              '',
                          roomId: roomId,
                          flagStatus: BreakoutRoomFlagStatus.unflagged,
                        ),
                      ),
                    );
                  },
                  expand: true,
                  text: 'Cancel Help Needed',
                ),
              ],
              SizedBox(height: 8),
              if (participantCount == 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: HeightConstrainedText('No one is here yet'),
                )
              else
                Expanded(
                  child: ListView(
                    children: [
                      for (final participantId in participantIds)
                        _buildBreakoutRoomParticipant(
                          participantId,
                          room,
                          context,
                        ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
