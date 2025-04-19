import 'dart:async';

import 'package:flutter/material.dart';
import 'package:client/features/events/features/live_meeting/features/admin_panel/presentation/widgets/admin_panel.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/events/features/live_meeting/data/providers/live_meeting_provider.dart';
import 'package:client/core/widgets/action_button.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/features/user/data/providers/user_info_builder.dart';
import 'package:client/core/utils/firestore_utils.dart';
import 'package:client/services.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/data/providers/dialog_provider.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:client/core/localization/localization_helper.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';
import 'package:data_models/user/public_user_info.dart';
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
    return showCustomDialog<ReassignResult?>(
      builder: (_) => this,
    );
  }

  @override
  _ReassignBreakoutRoomDialogState createState() =>
      _ReassignBreakoutRoomDialogState();
}

class _ReassignBreakoutRoomDialogState
    extends State<ReassignBreakoutRoomDialog> {
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
        HeightConstrainedText(
          context.l10n.newRoomNumber,
          textAlign: TextAlign.center,
          style: body.copyWith(fontSize: 14),
        ),
        SizedBox(
          width: 60,
          child: CustomTextField(
            initialValue: _roomAssignment,
            hintText: context.l10n.enterRoomNumber,
            onChanged: (value) => setState(() => _roomAssignment = value),
          ),
        ),
        ActionButton(
          onPressed: () => Navigator.of(context)
              .pop(ReassignResult(reassignId: _roomAssignment)),
          text: context.l10n.reassign,
          textColor: Theme.of(context).primaryColor,
        ),
      ],
    );
  }

  Widget _buildBreakoutRoomGrid({
    required BreakoutRoomSession? sessionDetails,
  }) {
    final maxRoomNumber = sessionDetails?.maxRoomNumber;
    final expectedNewRoomNum = maxRoomNumber != null ? maxRoomNumber + 1 : null;

    final hasWaitingRoom = sessionDetails?.hasWaitingRoom ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: HeightConstrainedText(context.l10n.recentRooms),
          ),
          SizedBox(height: 6),
          CustomStreamBuilder<List<BreakoutRoom>>(
            entryFrom:
                '_ReassignBreakoutRoomDialogState._buildBreakoutRoomGrid',
            stream: _recentBreakoutRooms ??=
                firestoreLiveMeetingService.breakoutRoomsStream(
              event: EventProvider.read(widget.outerContext).event,
              breakoutRoomSessionId:
                  LiveMeetingProvider.read(widget.outerContext)
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
                value: EventProvider.read(widget.outerContext),
                child: ChangeNotifierProvider.value(
                  value: LiveMeetingProvider.read(widget.outerContext),
                  child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: rooms.length + 1,
                    itemBuilder: (context, index) {
                      if (index < rooms.length) {
                        final room = rooms[index];
                        final roomNumResult =
                            room.roomId == breakoutsWaitingRoomId
                                ? breakoutsWaitingRoomId
                                : room.roomName;
                        return BreakoutRoomButton(
                          room: room,
                          onTap: () => Navigator.of(context).pop(
                            ReassignResult(reassignId: roomNumResult),
                          ),
                        );
                      }

                      return CustomInkWell(
                        onTap: () => Navigator.of(context).pop(
                          ReassignResult(
                            reassignId: reassignNewRoomId,
                            expectedNewRoom: expectedNewRoomNum,
                          ),
                        ),
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
                              HeightConstrainedText(
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
          builder: (_, __, publicUserInfo) =>
              CustomStreamBuilder<BreakoutRoomSession>(
            entryFrom: '_ReassignBreakoutRoomDialogState.build',
            stream: _sessionDetails ??= firestoreLiveMeetingService
                .getBreakoutRoomSession(
                  event: EventProvider.read(widget.outerContext).event,
                  breakoutSessionId:
                      LiveMeetingProvider.read(widget.outerContext)
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
