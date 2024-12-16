import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/live_meeting_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/meeting_guide/meeting_guide_card_store.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_stream/url_video_widget.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/agenda_item_card/items/video/vimeo_video_widget.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/meeting_agenda_provider.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto/utils/stream_utils.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/meeting_guide.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'meeting_guide_card_item_video_contract.dart';
import 'meeting_guide_card_item_video_model.dart';
import 'meeting_guide_card_item_video_presenter.dart';

class MeetingGuideCardItemVideo extends StatefulWidget {
  @override
  _MeetingGuideCardItemVideoState createState() => _MeetingGuideCardItemVideoState();
}

class _MeetingGuideCardItemVideoState extends State<MeetingGuideCardItemVideo>
    implements MeetingGuideCardItemVideoView {
  late YoutubePlayerController _youtubePlayerController;
  late final MeetingGuideCardItemVideoModel _model;
  late final MeetingGuideCardItemVideoPresenter _presenter;

  @override
  void initState() {
    super.initState();

    _model = MeetingGuideCardItemVideoModel();
    _presenter = MeetingGuideCardItemVideoPresenter(context, this, _model);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AgendaProvider>();
    context.watch<MeetingGuideCardStore>();
    context.watch<LiveMeetingProvider>();

    final liveMeetingPath = _presenter.getLiveMeetingPath();
    final currentAgendaItem = _presenter.getCurrentAgendaItem();
    final videoUrl = currentAgendaItem.videoUrl ?? '';
    final isMultipleVideoTypesEnabled = _presenter.isMultipleVideoTypesEnabled();

    if (isMultipleVideoTypesEnabled) {
      switch (currentAgendaItem.videoType) {
        case AgendaItemVideoType.youtube:
          final youtubeVideoId = _presenter.getYoutubeVideoId(videoUrl);

          if (youtubeVideoId != null) {
            return Builder(builder: (context) {
              _youtubePlayerController = YoutubePlayerController.fromVideoId(
                videoId: youtubeVideoId,
                params: YoutubePlayerParams(showControls: true),
              );

              return Center(
                child: YoutubePlayer(
                  controller: _youtubePlayerController,
                  aspectRatio: 16 / 9,
                ),
              );
            });
          } else {
            return Center(child: Text('Cannot play YouTube video'));
          }
        case AgendaItemVideoType.vimeo:
          final vimeoVideoId = _presenter.getVimeoVideoId(videoUrl);

          if (vimeoVideoId != null) {
            return AspectRatio(
              aspectRatio: 16 / 9,
              child: VimeoVideoWidget(vimeoId: vimeoVideoId),
            );
          } else {
            return Center(child: Text('Cannot play Vimeo video'));
          }
        case AgendaItemVideoType.url:
          return UrlVideoWidget(
            key: Key('${currentAgendaItem.id}:${currentAgendaItem.videoUrl}'),
            playbackUrl: currentAgendaItem.videoUrl ?? '',
            autoplay: false,
          );
      }
    } else {
      final currentAgendaItemId = currentAgendaItem.id;

      return Center(
        child: JuntoStreamGetterBuilder<List<ParticipantAgendaItemDetails>>(
          streamGetter: () => _presenter.getParticipantAgendaItemDetailsStream(
            currentAgendaItemId,
            liveMeetingPath,
          ),
          keys: [currentAgendaItemId, liveMeetingPath],
          builder: (context, detailsList) {
            return HookBuilder(builder: (context) {
              // Store whether user has indicated intent to rewatch; state is bound to this HookBuilder
              final rewatchingState = useState(false);
              final initialWatchingState = useState(true);
              final canShowPostVideoInfo =
                  _presenter.canShowPostVideoInfo(initialWatchingState, rewatchingState);

              if (canShowPostVideoInfo && detailsList != null) {
                final allReady = _presenter.areAllReady(detailsList);
                final totalTimeLeft = _presenter.getTotalTimeLeft(detailsList);

                return _buildPostVideoInfo(
                  allReady: allReady,
                  totalTimeLeft: totalTimeLeft,
                  onRewatch: () => rewatchingState.value = true,
                );
              } else {
                return _buildActiveWatching(
                  currentAgendaItem: currentAgendaItem,
                  liveMeetingPath: liveMeetingPath,
                  onEnded: () {
                    rewatchingState.value = false;
                    initialWatchingState.value = false;
                    _presenter.checkReadyToAdvance();
                  },
                );
              }
            });
          },
        ),
      );
    }
  }

  Widget _buildActiveWatching({
    required AgendaItem currentAgendaItem,
    required String liveMeetingPath,
    required void Function() onEnded,
  }) {
    return UrlVideoWidget(
      key: Key('${currentAgendaItem.id}:${currentAgendaItem.videoUrl}'),
      playbackUrl: currentAgendaItem.videoUrl ?? '',
      onEnded: onEnded,
      onPlayheadUpdate: (status) {
        _presenter.updateVideoPosition(currentAgendaItem.id, liveMeetingPath, status);
      },
    );
  }

  Widget _buildPostVideoInfo({
    required bool allReady,
    required int totalTimeLeft,
    required void Function() onRewatch,
  }) {
    final minutes = totalTimeLeft ~/ 60;
    final seconds = totalTimeLeft % 60;
    final secondsFormatted = seconds.toString().padLeft(2, '0');

    return Container(
      color: AppColor.darkBlue,
      padding: EdgeInsets.all(5),
      child: Stack(
        children: [
          ActionButton(
            text: 'Rewatch',
            icon: Icons.refresh,
            onPressed: onRewatch,
            color: Colors.transparent,
            textColor: AppColor.white,
          ),
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (allReady)
                    JuntoText(
                      'Everyone is ready to move on.',
                      style: AppTextStyle.subhead.copyWith(color: AppColor.white),
                    )
                  else ...[
                    JuntoText(
                      'Some people are still finishing the video.',
                      style: AppTextStyle.subhead.copyWith(color: AppColor.white),
                    ),
                    if (totalTimeLeft > 0) ...[
                      JuntoText(
                        'We\'ll be ready in:',
                        style: AppTextStyle.subhead.copyWith(color: AppColor.white),
                      ),
                      JuntoText(
                        '$minutes:$secondsFormatted',
                        style: AppTextStyle.timeLarge.copyWith(color: AppColor.white),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void updateView() {
    setState(() {});
  }
}
