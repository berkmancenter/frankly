import 'dart:async';
import 'dart:math';

import 'package:client/core/widgets/custom_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/events/features/live_meeting/data/providers/live_meeting_provider.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/action_button.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/services.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/data/providers/dialog_provider.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:client/features/events/presentation/widgets/periodic_builder.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/admin/plan_capability_list.dart';
import 'package:provider/provider.dart';
import 'package:client/core/localization/localization_helper.dart';

enum _BreakoutRoomsDialogState {
  start,
  searchingForAvailable,
  processingAssignment,
}

class BreakoutRoomsDialog extends StatefulWidget {
  final BuildContext outerContext;
  final bool canFetchCapabilities;

  const BreakoutRoomsDialog({
    required this.outerContext,
    this.canFetchCapabilities = false,
  });

  Future<void> show() async {
    return showCustomDialog<void>(builder: (_) => this);
  }

  @override
  __BreakoutRoomsDialogState createState() => __BreakoutRoomsDialogState();
}

class __BreakoutRoomsDialogState extends State<BreakoutRoomsDialog> {
  int get _participantCount =>
      Provider.of<LiveMeetingProvider>(widget.outerContext)
          .eventProvider
          .presentParticipantCount;

  CommunityProvider get _communityProvider =>
      Provider.of<CommunityProvider>(widget.outerContext);

  late int _numPerRoom;
  Timer? _presenceCheck;
  final _presenceCheckStopwatch = Stopwatch();
  final _presenceCheckDuration = Duration(seconds: 45);

  final _BreakoutRoomsDialogState _state = _BreakoutRoomsDialogState.start;

  @override
  void initState() {
    super.initState();

    _numPerRoom = EventProvider.read(widget.outerContext)
            .event
            .breakoutRoomDefinition
            ?.targetParticipants ??
        5;
  }

  @override
  void dispose() {
    _presenceCheck?.cancel();

    super.dispose();
  }

  Future<void> _startBreakouts(
    BreakoutAssignmentMethod assignmentMethod,
  ) async {
    await LiveMeetingProvider.read(widget.outerContext).startBreakouts(
      numPerRoom: _numPerRoom,
      assignmentMethod: assignmentMethod,
    );
    Navigator.of(context).pop();
  }

  Widget _buildNumPicker({
    required String text,
    required int value,
    required Function(int) onChanged,
    required int min,
    required int max,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        DropdownButton<int>(
          items: List.generate(
            max - min + 1,
            (i) => DropdownMenuItem<int>(
              value: i + min,
              child: Text((i + min).toString()),
            ),
          ).toList(),
          value: value,
          onChanged: (value) => onChanged(value!),
        ),
        Text(
          text,
          textAlign: TextAlign.center,
          style: DefaultTextStyle.of(context).style.copyWith(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildNumParticipants() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          _participantCount.toString(),
          style: DefaultTextStyle.of(context).style.copyWith(fontSize: 20),
        ),
        Text(
          context.l10n.currentParticipants,
          style: DefaultTextStyle.of(context).style.copyWith(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBreakoutChooser() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildNumParticipants(),
        SizedBox(width: 18),
        Icon(Icons.arrow_right_alt),
        SizedBox(width: 18),
        _buildNumPicker(
          text: context.l10n.targetParticipantsPerRoom,
          value: _numPerRoom,
          onChanged: (value) => setState(() {
            _numPerRoom = value;
          }),
          min: 1,
          max: 16,
        ),
      ],
    );
  }

  List<Widget> _buildRegularMatchingItems(
    BuildContext context,
    EventProvider eventProvider,
  ) {
    return [
      SizedBox(height: 12),
      ActionButton(
        onPressed: () => alertOnError(
          context,
          () => _startBreakouts(BreakoutAssignmentMethod.targetPerRoom),
        ),
        text: context.l10n.randomlyAssign,
        color: AppColor.brightGreen,
        textColor: Theme.of(context).primaryColor,
      ),
      SizedBox(height: 12),
      if (eventProvider.isLiveStream) ...[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            context.l10n.roomsCountMayChange,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    ];
  }

  List<Widget> _buildSmartMatchingItems(BuildContext context) {
    return [
      SizedBox(height: 12),
      ActionButton(
        onPressed: () => alertOnError(
          context,
          () => _startBreakouts(BreakoutAssignmentMethod.smartMatch),
        ),
        text: context.l10n.smartMatchParticipants,
        color: AppColor.brightGreen,
        textColor: Theme.of(context).primaryColor,
      ),
      SizedBox(height: 12),
      HeightConstrainedText(context.l10n.or),
    ];
  }

  List<Widget> _buildContent(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(widget.outerContext);
    final showSmartMatchOption = eventProvider.showSmartMatchingForBreakouts;

    return [
      if (_state == _BreakoutRoomsDialogState.start) ...[
        AnimatedBuilder(
          animation: EventProvider.watch(widget.outerContext),
          builder: (_, __) => _buildBreakoutChooser(),
        ),
        CustomStreamBuilder<PlanCapabilityList?>(
          entryFrom: '__BreakoutRoomsDialogState._buildContent',
          stream: widget.canFetchCapabilities
              ? cloudFunctionsCommunityService
                  .getCommunityCapabilities(
                    GetCommunityCapabilitiesRequest(
                      communityId: _communityProvider.communityId,
                    ),
                  )
                  .asStream()
              : Future.value(null).asStream(),
          builder: (context, caps) {
            final hasSmartMatchingCapability = caps?.hasSmartMatching ?? false;
            return Column(
              children: [
                if (hasSmartMatchingCapability && showSmartMatchOption)
                  ..._buildSmartMatchingItems(context),
                ..._buildRegularMatchingItems(context, eventProvider),
              ],
            );
          },
        ),
      ] else ...[
        PeriodicBuilder(
          period: Duration(seconds: 1),
          builder: (_) {
            final timeRemaining = max(
              (_presenceCheckDuration - _presenceCheckStopwatch.elapsed)
                  .inSeconds,
              0,
            );
            return Text(
              'Asking participants to join breakout rooms.\nBreakout rooms will start in...$timeRemaining',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColor.black,
                fontSize: 16,
              ),
            );
          },
        ),
        if (_state == _BreakoutRoomsDialogState.processingAssignment) ...[
          SizedBox(height: 24),
          Container(
            alignment: Alignment.center,
            child: CustomLoadingIndicator(),
          ),
        ],
      ],
    ];
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
        child: Stack(
          children: [
            Column(
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(
                      'Breakout Rooms',
                      style: TextStyle(color: AppColor.white, fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                ..._buildContent(context),
                SizedBox(height: 16),
              ],
            ),
            if (_state != _BreakoutRoomsDialogState.searchingForAvailable)
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
    );
  }
}
