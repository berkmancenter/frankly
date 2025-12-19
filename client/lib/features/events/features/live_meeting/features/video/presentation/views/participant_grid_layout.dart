import 'dart:math';

import 'package:client/styles/styles.dart';
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
  int _currentPage = 0;

  List<AgoraParticipant> get participants =>
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
            physics: const NeverScrollableScrollPhysics(),
            itemCount: numberOfPages,
            controller: _pageController,
            itemBuilder: (context, index) => _ParticipantGridPage(
              pageIndex: index,
              participants: participants
                  .skip(index * _maxParticipantsPerPage)
                  .take(_maxParticipantsPerPage)
                  .toList(),
            ),
            onPageChanged: (i) {
              setState(() => _currentPage = i);
              _pageController.jumpToPage(i);
            },
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
                  final previousPage = _currentPage - 1;
                  if (previousPage >= 0) {
                    setState(() => _currentPage = previousPage);
                    _pageController.jumpToPage(previousPage);
                  }
                },
              ),
              ...List.generate(
                numberOfPages,
                (pageIndex) => Icon(
                  Icons.circle,
                  size: 12,
                  color: _currentPage == pageIndex
                      ? context.theme.colorScheme.primary
                      : context.theme.colorScheme.surfaceContainerHigh,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {
                  final nextPage = _currentPage + 1;
                  if (nextPage < numberOfPages) {
                    setState(() => _currentPage = nextPage);
                    _pageController.jumpToPage(nextPage);
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxVideosPerRow = constraints.maxWidth > 750 ? 3 : 2;
        final rowCount = (participants.length / maxVideosPerRow).ceil();

        // Calculate the height each row should take to fill the screen.
        // Constrain the height.
        final itemHeight = min(
          constraints.maxHeight / rowCount,
          kParticipantVideoWidgetDimensions.height,
        );
        // Calculate width needed to maintain 4:3 aspect ratio
        final idealItemWidth = itemHeight * (4 / 3);

        // Check if two videos would fit side by side, if not, constrain the width
        final maxItemWidth = constraints.maxWidth / maxVideosPerRow;
        final itemWidth =
            idealItemWidth <= maxItemWidth ? idealItemWidth : maxItemWidth;

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int row = 0; row < rowCount; row++)
                SizedBox(
                  height: itemHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int col = 0; col < maxVideosPerRow; col++)
                        Builder(
                          builder: (context) {
                            final participantIndex =
                                row * maxVideosPerRow + col;
                            if (participantIndex >= participants.length) {
                              return const SizedBox.shrink();
                            }

                            final participant = participants[participantIndex];
                            return SizedBox(
                              width: itemWidth,
                              height: itemHeight,
                              child: ParticipantWidget(
                                borderRadius: BorderRadius.zero,
                                globalKey: CommunityGlobalKey.fromLabel(
                                  participant.userId,
                                ),
                                participant: participant,
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
