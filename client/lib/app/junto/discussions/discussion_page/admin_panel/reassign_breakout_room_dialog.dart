import 'dart:async';

import 'package:flutter/material.dart';
import 'package:junto/app/junto/discussions/discussion_page/admin_panel/admin_panel.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/live_meeting_provider.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/common_widgets/junto_text_field.dart';
import 'package:junto/common_widgets/user_info_builder.dart';
import 'package:junto/services/firestore/firestore_utils.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/dialog_provider.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto_models/firestore/live_meeting.dart';
import 'package:junto_models/firestore/public_user_info.dart';
import 'package:provider/provider.dart';

class ReassignResult {
  final String? reassignId;
  final int? expectedNewRoom;

  ReassignResult({required this.reassignId, this.expectedNewRoom});
}

class ReassignBreakoutRoomDialog extends StatefulWidget {
  final BuildContext outerContext;
  final String userId;
  final String? currentRoomNumber;

  const ReassignBreakoutRoomDialog({
    required this.outerContext,
    required this.userId,
    this.currentRoomNumber,
  });

  Future<ReassignResult?> show() async {
    return showJuntoDialog<ReassignResult?>(
      builder: (_) => this,
    );
  }

  @override
  _ReassignBreakoutRoomDialogState createState() => _ReassignBreakoutRoomDialogState();
}

class _ReassignBreakoutRoomDialogState extends State<ReassignBreakoutRoomDialog> {
  String? _roomAssignment;

  Stream<BreakoutRoomSession>? _sessionDetails;

  BehaviorSubjectWrapper<List<BreakoutRoom>>? _recentBreakoutRooms;

  @override
  void initState() {
    super.initState();
    _roomAssignment = widget.currentRoomNumber;
  }

  @override
  void dispose() {
    _recentBreakoutRooms?.dispose();
    super.dispose();
  }

  Widget _buildBreakoutRoomChooser() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        JuntoText(
          'New Room Number:',
          textAlign: TextAlign.center,
          style: body.copyWith(fontSize: 14),
        ),
        SizedBox(
          width: 60,
          child: JuntoTextField(
            initialValue: _roomAssignment,
            hintText: 'Ex: 2',
            onChanged: (value) => setState(() => _roomAssignment = value),
          ),
        ),
        ActionButton(
          onPressed: () => Navigator.of(context).pop(ReassignResult(reassignId: _roomAssignment)),
          text: 'Reassign',
          textColor: Theme.of(context).primaryColor,
        ),
      ],
    );
  }

  Widget _buildBreakoutRoomGrid({required BreakoutRoomSession? sessionDetails}) {
    final maxRoomNumber = sessionDetails?.maxRoomNumber;
    final expectedNewRoomNum = maxRoomNumber != null ? maxRoomNumber + 1 : null;

    final hasWaitingRoom = sessionDetails?.hasWaitingRoom ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: JuntoText('Recent Rooms'),
          ),
          SizedBox(height: 6),
          JuntoStreamBuilder<List<BreakoutRoom>>(
            entryFrom: '_ReassignBreakoutRoomDialogState._buildBreakoutRoomGrid',
            stream: _recentBreakoutRooms ??= firestoreLiveMeetingService.breakoutRoomsStream(
              discussion: DiscussionProvider.read(widget.outerContext).discussion,
              breakoutRoomSessionId: LiveMeetingProvider.read(widget.outerContext)
                      .liveMeeting
                      ?.currentBreakoutSession
                      ?.breakoutRoomSessionId ??
                  '',
              descending: true,
              limit: hasWaitingRoom ? 4 : 5,
            ),
            height: 100,
            builder: (context, breakoutRooms) {
              final rooms = [
                if (hasWaitingRoom) fakeWaitingRoomObject,
                ...(breakoutRooms ?? [])
                    .reversed
                    .where((r) => r.roomId != breakoutsWaitingRoomId)
                    .toList(),
              ];

              return ChangeNotifierProvider.value(
                value: DiscussionProvider.read(widget.outerContext),
                child: ChangeNotifierProvider.value(
                  value: LiveMeetingProvider.read(widget.outerContext),
                  child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: rooms.length + 1,
                    itemBuilder: (context, index) {
                      if (index < rooms.length) {
                        final room = rooms[index];
                        final roomNumResult = room.roomId == breakoutsWaitingRoomId
                            ? breakoutsWaitingRoomId
                            : room.roomName;
                        return BreakoutRoomButton(
                          room: room,
                          onTap: () => Navigator.of(context).pop(
                            ReassignResult(reassignId: roomNumResult),
                          ),
                        );
                      }

                      return JuntoInkWell(
                        onTap: () => Navigator.of(context).pop(ReassignResult(
                          reassignId: reassignNewRoomId,
                          expectedNewRoom: expectedNewRoomNum,
                        )),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColor.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.add, size: 36, color: AppColor.white),
                              SizedBox(height: 6),
                              JuntoText(
                                'Add Room $expectedNewRoomNum',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColor.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 140.0 / 80,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent({
    PublicUserInfo? publicUserInfo,
    BreakoutRoomSession? sessionDetails,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          alignment: Alignment.topLeft,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(4),
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            child: Text(
              'Reassign ${publicUserInfo?.displayName ?? 'User'}',
              style: TextStyle(
                color: AppColor.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
        SizedBox(height: 24),
        _buildBreakoutRoomChooser(),
        SizedBox(height: 24),
        if (!responsiveLayoutService.isMobile(context))
          _buildBreakoutRoomGrid(
            sessionDetails: sessionDetails,
          ),
        SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColor.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Color(0xFF5568FF),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 500),
        child: UserInfoBuilder(
          userId: widget.userId,
          builder: (_, __, publicUserInfo) => JuntoStreamBuilder<BreakoutRoomSession>(
            entryFrom: '_ReassignBreakoutRoomDialogState.build',
            stream: _sessionDetails ??= firestoreLiveMeetingService
                .getBreakoutRoomSession(
                  discussion: DiscussionProvider.read(widget.outerContext).discussion,
                  breakoutSessionId: LiveMeetingProvider.read(widget.outerContext)
                          .liveMeeting
                          ?.currentBreakoutSession
                          ?.breakoutRoomSessionId ??
                      '',
                )
                .asStream(),
            builder: (context, sessionDetails) => Stack(
              children: [
                _buildMainContent(
                  publicUserInfo: publicUserInfo.data,
                  sessionDetails: sessionDetails,
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
