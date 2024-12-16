import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/live_meeting_provider.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/dialog_provider.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto/utils/periodic_builder.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/plan_capability_list.dart';
import 'package:provider/provider.dart';

enum _BreakoutRoomsDialogState {
  start,
  searchingForAvailable,
  processingAssignment,
}

class BreakoutRoomsDialog extends StatefulWidget {
  final BuildContext outerContext;
  final bool canFetchCapabilities;

  const BreakoutRoomsDialog({required this.outerContext, this.canFetchCapabilities = false});

  Future<void> show() async {
    return showJuntoDialog<void>(builder: (_) => this);
  }

  @override
  __BreakoutRoomsDialogState createState() => __BreakoutRoomsDialogState();
}

class __BreakoutRoomsDialogState extends State<BreakoutRoomsDialog> {
  int get _participantCount => Provider.of<LiveMeetingProvider>(widget.outerContext)
      .discussionProvider
      .presentParticipantCount;

  JuntoProvider get _juntoProvider => Provider.of<JuntoProvider>(widget.outerContext);

  late int _numPerRoom;
  Timer? _presenceCheck;
  final _presenceCheckStopwatch = Stopwatch();
  final _presenceCheckDuration = Duration(seconds: 45);

  _BreakoutRoomsDialogState _state = _BreakoutRoomsDialogState.start;

  @override
  void initState() {
    super.initState();

    _numPerRoom = DiscussionProvider.read(widget.outerContext)
            .discussion
            .breakoutRoomDefinition
            ?.targetParticipants ??
        5;
  }

  @override
  void dispose() {
    _presenceCheck?.cancel();

    super.dispose();
  }

  Future<void> _startBreakouts(BreakoutAssignmentMethod assignmentMethod) async {
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
          'Current\nParticipants',
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
          text: 'Target Participants\nPer Room',
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
    DiscussionProvider discussionProvider,
  ) {
    return [
      SizedBox(height: 12),
      ActionButton(
        onPressed: () =>
            alertOnError(context, () => _startBreakouts(BreakoutAssignmentMethod.targetPerRoom)),
        text: 'Randomly Assign',
        color: AppColor.brightGreen,
        textColor: Theme.of(context).primaryColor,
      ),
      SizedBox(height: 12),
      if (discussionProvider.isLiveStream) ...[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Number of rooms may change if participants drop off.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ]
    ];
  }

  List<Widget> _buildSmartMatchingItems(BuildContext context) {
    return [
      SizedBox(height: 12),
      ActionButton(
        onPressed: () =>
            alertOnError(context, () => _startBreakouts(BreakoutAssignmentMethod.smartMatch)),
        text: 'Smart Match Participants',
        color: AppColor.brightGreen,
        textColor: Theme.of(context).primaryColor,
      ),
      SizedBox(height: 12),
      JuntoText('Or'),
    ];
  }

  List<Widget> _buildContent(BuildContext context) {
    final discussionProvider = Provider.of<DiscussionProvider>(widget.outerContext);
    final showSmartMatchOption = discussionProvider.showSmartMatchingForBreakouts;

    return [
      if (_state == _BreakoutRoomsDialogState.start) ...[
        AnimatedBuilder(
          animation: DiscussionProvider.watch(widget.outerContext),
          builder: (_, __) => _buildBreakoutChooser(),
        ),
        JuntoStreamBuilder<PlanCapabilityList?>(
          entryFrom: '__BreakoutRoomsDialogState._buildContent',
          stream: widget.canFetchCapabilities
              ? cloudFunctionsService
                  .getJuntoCapabilities(
                      GetJuntoCapabilitiesRequest(juntoId: _juntoProvider.juntoId))
                  .asStream()
              : Future.value(null).asStream(),
          builder: (context, caps) {
            final hasSmartMatchingCapability = caps?.hasSmartMatching ?? false;
            return Column(
              children: [
                if (hasSmartMatchingCapability && showSmartMatchOption)
                  ..._buildSmartMatchingItems(context),
                ..._buildRegularMatchingItems(context, discussionProvider),
              ],
            );
          },
        ),
      ] else ...[
        PeriodicBuilder(
          period: Duration(seconds: 1),
          builder: (_) {
            final timeRemaining =
                max((_presenceCheckDuration - _presenceCheckStopwatch.elapsed).inSeconds, 0);
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
            child: JuntoLoadingIndicator(),
          ),
        ],
      ]
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
