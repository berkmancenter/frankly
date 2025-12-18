import 'package:flutter/material.dart';
import 'package:client/features/events/features/live_meeting/features/video/data/providers/conference_room.dart';
import 'package:client/features/events/features/live_meeting/features/video/presentation/widgets/participant_widget.dart';
import 'package:client/features/events/features/live_meeting/features/video/presentation/views/video_flutter_meeting.dart';
import 'package:client/features/events/features/live_meeting/features/video/presentation/widgets/custom_page_view_builder.dart';

import '../../data/providers/agora_room.dart';

class ParticipantGridLayout extends StatefulWidget {
  const ParticipantGridLayout({Key? key, required this.keyPrefix})
      : super(key: key);

  final String keyPrefix;

  @override
  ParticipantGridLayoutState createState() => ParticipantGridLayoutState();
}

class ParticipantGridLayoutState extends State<ParticipantGridLayout> {
  final _pageController = PageController();
  final _currentPageNotifier = ValueNotifier<int>(0);
  static const int _maxParticipantsPerPage = 10;

  List<AgoraParticipant> get participants =>
      ConferenceRoom.watch(context).participants;

  int _calculateNumberOfPages() {
    return (participants.length / _maxParticipantsPerPage).ceil();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentPageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPageViewBuilder(
      pageController: _pageController,
      currentPageNotifier: _currentPageNotifier,
      pagecount: _calculateNumberOfPages(),
      child: PageView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _calculateNumberOfPages(),
        controller: _pageController,
        itemBuilder: (context, index) => _ParticipantGridPage(
          keyPrefix: widget.keyPrefix,
          pageIndex: index,
          participants: participants
              .skip(index * _maxParticipantsPerPage)
              .take(_maxParticipantsPerPage)
              .toList(),
        ),
        onPageChanged: (index) => _currentPageNotifier.value = index,
      ),
    );
  }
}

class _ParticipantGridPage extends StatelessWidget {
  const _ParticipantGridPage({
    required this.keyPrefix,
    required this.pageIndex,
    required this.participants,
  });

  final String keyPrefix;
  final int pageIndex;
  final List<AgoraParticipant> participants;

  @override
  Widget build(BuildContext context) {
    if (participants.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.center,
          spacing: 8.0, // horizontal spacing between items
          runSpacing: 8.0, // vertical spacing between rows
          children: participants.map((participant) {
            return SizedBox(
              width: _calculateItemWidth(context, participants.length),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: ParticipantWidget(
                  borderRadius: BorderRadius.zero,
                  globalKey: CommunityGlobalKey.fromLabel(participant.userId),
                  participant: participant,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Calculate appropriate width for each participant based on screen size and participant count
  double _calculateItemWidth(BuildContext context, int participantCount) {
    final screenWidth =
        MediaQuery.of(context).size.width - 32; // Account for padding

    if (participantCount == 1) return screenWidth * 0.8;
    if (participantCount == 2) return screenWidth * 0.45;
    if (participantCount <= 4) return screenWidth * 0.45;
    if (participantCount <= 6) return screenWidth * 0.3;
    if (participantCount <= 9) return screenWidth * 0.3;

    // For 10+ participants, make them smaller
    return screenWidth * 0.22;
  }
}
