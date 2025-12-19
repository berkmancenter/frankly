import 'package:flutter/material.dart';
import 'package:client/features/events/features/live_meeting/features/video/data/providers/conference_room.dart';
import 'package:client/features/events/features/live_meeting/features/video/presentation/widgets/participant_widget.dart';
import 'package:client/features/events/features/live_meeting/features/video/presentation/views/video_flutter_meeting.dart';
import 'package:provider/provider.dart';
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

  int _calculateNumberOfPages() {
    return (participants.length / _maxParticipantsPerPage).ceil();
  }
      Provider.of<ConferenceRoom>(context, listen: false).participants;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final numberOfPages =
        (participants.length / _maxParticipantsPerPage).ceil();

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            itemCount: numberOfPages,
            controller: _pageController,
            itemBuilder: (context, index) => _ParticipantGridPage(
              pageIndex: index,
              participants: participants
                  .skip(index * _maxParticipantsPerPage)
                  .take(_maxParticipantsPerPage)
                  .toList(),
            ),
            onPageChanged: (i) => _pageController.jumpToPage(i),
          ),
        ),
        // Buttons to navigate between pages
        if (numberOfPages > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  final previousPage = _pageController.page!.toInt() - 1;
                  if (previousPage >= 0) {
                    _pageController.jumpToPage(
                      previousPage,
                    );
                  }
                },
              ),
              ...List.generate(
                numberOfPages,
                (pageIndex) => Icon(
                  Icons.circle,
                  size: 12,
                  color: _pageController.page!.toInt() == pageIndex
                      ? context.theme.colorScheme.primary
                      : context.theme.colorScheme.surfaceContainerHigh,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {
                  final nextPage = _pageController.page!.toInt() + 1;
                  if (nextPage < numberOfPages) {
                    _pageController.jumpToPage(
                      nextPage,
                    );
                  }
                },
              ),
            ],
          ),
      ],
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
