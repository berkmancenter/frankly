import 'package:flutter/material.dart';
import 'package:client/features/events/features/live_meeting/features/video/utils/brady_bunch_layout.dart';
import 'package:client/features/events/features/live_meeting/features/video/data/providers/conference_room.dart';
import 'package:client/features/events/features/live_meeting/features/video/presentation/widgets/participant_widget.dart';
import 'package:client/features/events/features/live_meeting/features/video/presentation/views/video_flutter_meeting.dart';
import 'package:client/features/events/features/live_meeting/features/video/presentation/widgets/custom_page_view_builder.dart';

import '../../data/providers/agora_room.dart';

class BradyBunchViewWidget extends StatefulWidget {
  const BradyBunchViewWidget({Key? key}) : super(key: key);

  @override
  _BradyBunchViewWidgetState createState() => _BradyBunchViewWidgetState();
}

class _BradyBunchViewWidgetState extends State<BradyBunchViewWidget> {
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
    super.dispose();
    _pageController.dispose();
    _currentPageNotifier.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPageViewBuilder(
      pageController: _pageController,
      currentPageNotifier: _currentPageNotifier,
      pagecount: _calculateNumberOfPages(),
      child: _buildPageView(),
    );
  }

  Widget _buildPageView() {
    return LayoutBuilder(
      builder: (context, constraints) => PageView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemCount: _calculateNumberOfPages(),
        controller: _pageController,
        itemBuilder: (BuildContext context, int index) =>
            _buildParticipantPage(index),
        onPageChanged: (int index) {
          _currentPageNotifier.value = index;
        },
      ),
    );
  }

  Widget _buildParticipantPage(int pageIndex) {
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          final participantsOnThisPageStartIndex =
              pageIndex * _maxParticipantsPerPage;
          final pageParticipants = participants
              .skip(participantsOnThisPageStartIndex)
              .take(_maxParticipantsPerPage)
              .toList();

          return BradyBunchLayoutWidget(
            height: height,
            width: width,
            pageParticipants: pageParticipants,
          );
        },
      ),
    );
  }
}

class BradyBunchLayoutWidget extends StatelessWidget {
  final double height;
  final double width;
  final List<AgoraParticipant> pageParticipants;

  const BradyBunchLayoutWidget({
    required this.height,
    required this.width,
    required this.pageParticipants,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final BradyBunchLayout layout = BradyBunchLayout.calculateOptimalLayout(
      width: width,
      height: height,
      participantCount: pageParticipants.length,
    );

    AgoraParticipant participantAtIndex(int row, int column) =>
        pageParticipants[layout.columns * row + column];

    double aspectRatioAtIndex(int row, int column) {
      final lastRow = row == layout.rows - 1;
      if (lastRow && pageParticipants.length < layout.rows * layout.columns) {
        return layout.getAdjustedAspectRatio;
      } else {
        return layout.layoutParameters.aspectRatio;
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < layout.rows; i++)
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: layout.imageSize.height),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int j = 0; j < layout.layoutParameters.columns; j++)
                    if (pageParticipants.length > layout.columns * i + j)
                      Flexible(
                        child: AspectRatio(
                          aspectRatio: aspectRatioAtIndex(i, j),
                          child: ParticipantWidget(
                            borderRadius: BorderRadius.zero,
                            globalKey: CommunityGlobalKey.fromLabel(
                              participantAtIndex(i, j).userId,
                            ),
                            participant: participantAtIndex(i, j),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
