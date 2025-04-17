import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:client/features/events/features/live_meeting/data/providers/live_meeting_provider.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/data/providers/meeting_guide_card_store.dart';
import 'package:client/features/events/features/live_meeting/features/live_stream/presentation/widgets/url_video_widget.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/providers/meeting_agenda_provider.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/data/services/firestore_meeting_guide_service.dart';
import 'package:client/core/data/services/media_helper_service.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/meeting_guide.dart';
import 'package:provider/provider.dart';
import 'package:quiver/iterables.dart';

import 'views/meeting_guide_card_item_video_contract.dart';
import '../data/models/meeting_guide_card_item_video_model.dart';

class MeetingGuideCardItemVideoPresenter {
  //ignore: unused_field
  final MeetingGuideCardItemVideoView _view;
  //ignore: unused_field
  final MeetingGuideCardItemVideoModel _model;
  final AgendaProvider _agendaProvider;
  final MeetingGuideCardStore _meetingGuideCardStore;
  final FirestoreMeetingGuideService _firestoreMeetingGuideService;
  final UserService _userService;
  final LiveMeetingProvider _liveMeetingProvider;
  final CommunityProvider _communityProvider;
  final MediaHelperService _mediaHelperService;

  MeetingGuideCardItemVideoPresenter(
    BuildContext context,
    this._view,
    this._model, {
    AgendaProvider? agendaProvider,
    FirestoreMeetingGuideService? testFirestoreMeetingGuideService,
    MeetingGuideCardStore? meetingGuideCardStore,
    UserService? userService,
    LiveMeetingProvider? liveMeetingProvider,
    CommunityProvider? communityProvider,
    MediaHelperService? mediaHelperService,
  })  : _agendaProvider = agendaProvider ?? context.read<AgendaProvider>(),
        _meetingGuideCardStore =
            meetingGuideCardStore ?? context.read<MeetingGuideCardStore>(),
        _userService = userService ?? GetIt.instance<UserService>(),
        _firestoreMeetingGuideService = testFirestoreMeetingGuideService ??
            GetIt.instance<FirestoreMeetingGuideService>(),
        _liveMeetingProvider =
            liveMeetingProvider ?? context.read<LiveMeetingProvider>(),
        _communityProvider =
            communityProvider ?? context.read<CommunityProvider>(),
        _mediaHelperService =
            mediaHelperService ?? GetIt.instance<MediaHelperService>();

  Stream<List<ParticipantAgendaItemDetails>>
      getParticipantAgendaItemDetailsStream(
    String agendaItemId,
    String liveMeetingPath,
  ) {
    return _firestoreMeetingGuideService.participantAgendaItemDetailsStream(
      agendaItemId: agendaItemId,
      liveMeetingPath: liveMeetingPath,
    );
  }

  String getLiveMeetingPath() {
    return _agendaProvider.liveMeetingPath;
  }

  AgendaItem getCurrentAgendaItem() {
    return _meetingGuideCardStore.meetingGuideCardAgendaItem!;
  }

  Future<void> checkReadyToAdvance() async {
    await _agendaProvider.checkReadyToAdvance(
      agendaItemId: _meetingGuideCardStore.meetingGuideCardAgendaItem!.id,
    );
  }

  bool canShowPostVideoInfo(
    ValueNotifier<bool> initialWatchingState,
    ValueNotifier<bool> rewatchingState,
  ) {
    return !initialWatchingState.value && !rewatchingState.value;
  }

  void updateVideoPosition(
    String currentAgendaItemId,
    String liveMeetingPath,
    UrlVideoPlayheadInfo status,
  ) {
    final userId = _userService.currentUserId;

    if (userId != null) {
      _firestoreMeetingGuideService.updateVideoPosition(
        agendaItemId: currentAgendaItemId,
        userId: userId,
        liveMeetingPath: liveMeetingPath,
        currentTime: _fixNan(status.currentTime),
        duration: _fixNan(status.videoDuration),
      );
    }
  }

  double _fixNan(double val) {
    return val.isNaN ? 0 : val;
  }

  bool areAllReady(
    List<ParticipantAgendaItemDetails> participantAgendaItemDetails,
  ) {
    final presentParticipantIds =
        _liveMeetingProvider.presentParticipantIds.toSet();
    final readyToMoveOnCount = participantAgendaItemDetails
        .where(
          (p) =>
              (p.readyToAdvance ?? false) &&
              presentParticipantIds.contains(p.userId),
        )
        .length;
    final areAllReady = readyToMoveOnCount == presentParticipantIds.length;

    return areAllReady;
  }

  int getTotalTimeLeft(
    List<ParticipantAgendaItemDetails> participantAgendaItemDetails,
  ) {
    final remainingTimes = participantAgendaItemDetails
        .where((details) => !(details.readyToAdvance ?? false))
        .map((e) => (e.videoDuration ?? 0) - (e.videoCurrentTime ?? 0));
    // Calculate time left as maximum time remaining across all participants
    final totalTimeLeft = (max(remainingTimes) ?? 0).floor();

    return totalTimeLeft;
  }

  bool isMultipleVideoTypesEnabled() {
    return _communityProvider.settings.multipleVideoTypes;
  }

  String? getYoutubeVideoId(String url) {
    return _mediaHelperService.getYoutubeVideoId(url);
  }

  String? getVimeoVideoId(String url) {
    return _mediaHelperService.getVimeoVideoId(url);
  }
}
