import 'package:flutter/material.dart';
import 'package:client/features/events/features/live_meeting/features/video/data/providers/conference_room.dart';
import 'package:client/features/events/features/live_meeting/features/video/presentation/widgets/participant_widget.dart';
import 'package:client/features/events/features/live_meeting/features/video/presentation/views/video_flutter_meeting.dart';
import '../../data/providers/agora_room.dart';

class ParticipantGridLayout extends StatefulWidget {
  const ParticipantGridLayout({Key? key}) : super(key: key);

  @override
  ParticipantGridLayoutState createState() => ParticipantGridLayoutState();
}

class ParticipantGridLayoutState extends State<ParticipantGridLayout> {
  final _pageController = PageController();
  static const int _maxParticipantsPerPage = 10;

  List<AgoraParticipant> get participants =>
      ConferenceRoom.watch(context).participants;

  int _calculateNumberOfPages() {
    return (participants.length / _maxParticipantsPerPage).ceil();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      itemCount: _calculateNumberOfPages(),
      controller: _pageController,
      itemBuilder: (context, index) => _ParticipantGridPage(
        pageIndex: index,
        participants: participants
            .skip(index * _maxParticipantsPerPage)
            .take(_maxParticipantsPerPage)
            .toList(),
      ),
      onPageChanged: (i) => _pageController.jumpToPage(i),
    );
  }
}

class _ParticipantGridPage extends StatelessWidget {
  const _ParticipantGridPage({
    required this.pageIndex,
    required this.participants,
  });

  final int pageIndex;
  final List<AgoraParticipant> participants;

  @override
  Widget build(BuildContext context) {
    if (participants.isEmpty) {
      return const SizedBox.shrink();
    }
    print(
      'GRID DEBUG: Building page $pageIndex with ${participants.length} participants. ',
    );

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 4 / 3,
      ),
      itemCount: participants.length,
      itemBuilder: (context, index) {
        final participant = participants[index];
        return SizedBox(
          width: kParticipantVideoWidgetDimensions.width / 2,
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: ParticipantWidget(
              borderRadius: BorderRadius.zero,
              globalKey: CommunityGlobalKey.fromLabel(participant.userId),
              participant: participant,
            ),
          ),
        );
      },
    );
  }
}
