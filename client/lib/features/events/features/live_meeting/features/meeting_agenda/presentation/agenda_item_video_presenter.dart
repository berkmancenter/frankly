import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/views/agenda_item_video.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/data/services/media_helper_service.dart';
import 'package:client/services.dart';
import 'package:data_models/events/event.dart';
import 'package:provider/provider.dart';

import 'views/agenda_item_video_contract.dart';
import '../data/models/agenda_item_video_model.dart';
import '../services/video_metadata_service.dart';

class AgendaItemVideoPresenter {
  static const _durationDetectionDebounce = Duration(milliseconds: 500);

  final AgendaItemVideoView _view;
  final AgendaItemVideoModel _model;
  final AgendaItemVideoHelper _helper;
  final MediaHelperService _mediaHelperService;
  final CommunityProvider _communityProvider;
  final VideoMetadataService _videoMetadataService;
  final void Function(int durationSeconds)? _onVideoDurationDetected;

  Timer? _durationDetectionDebounceTimer;
  int _durationDetectionRequestId = 0;

  AgendaItemVideoPresenter(
    BuildContext context,
    this._view,
    this._model, {
    AgendaItemVideoHelper? agendaItemVideoHelper,
    MediaHelperService? mediaHelperService,
    CommunityProvider? communityProvider,
    VideoMetadataService? videoMetadataService,
    void Function(int durationSeconds)? onVideoDurationDetected,
  })  : _helper = agendaItemVideoHelper ?? AgendaItemVideoHelper(),
        _mediaHelperService =
            mediaHelperService ?? GetIt.instance<MediaHelperService>(),
        _communityProvider =
            communityProvider ?? context.read<CommunityProvider>(),
        _videoMetadataService =
            videoMetadataService ?? VideoMetadataService(),
        _onVideoDurationDetected = onVideoDurationDetected;

  void init() {
    if (_model.agendaItemVideoData.url.isEmpty) {
      _model.agendaItemVideoTabType = AgendaItemVideoTabType.local;
    } else {
      final AgendaItemVideoTabType agendaItemVideoTabType;

      switch (_model.agendaItemVideoData.type) {
        case AgendaItemVideoType.youtube:
          agendaItemVideoTabType = AgendaItemVideoTabType.youtube;
          break;
        case AgendaItemVideoType.vimeo:
          agendaItemVideoTabType = AgendaItemVideoTabType.vimeo;
          break;
        case AgendaItemVideoType.url:
          agendaItemVideoTabType = AgendaItemVideoTabType.url;
          break;
      }

      _model.agendaItemVideoTabType = agendaItemVideoTabType;
    }

    _view.updateView();
  }

  void updateVideoTitle(String title) {
    _model.agendaItemVideoData.title = title.trim();
    _view.updateView();

    _helper.updateParent(_model);
  }

  void updateVideoUrl(String url) {
    final trimmedUrl = url.trim();
    _model.agendaItemVideoData.url = trimmedUrl;
    _view.updateView();

    _helper.updateParent(_model);

    _scheduleDurationDetection(trimmedUrl);
  }

  void _scheduleDurationDetection(String videoUrl) {
    _durationDetectionDebounceTimer?.cancel();

    if (!_shouldDetectDurationForUrl(videoUrl)) {
      return;
    }

    final requestId = ++_durationDetectionRequestId;
    _durationDetectionDebounceTimer = Timer(_durationDetectionDebounce, () {
      unawaited(_detectAndSetVideoDuration(videoUrl, requestId));
    });
  }

  bool _shouldDetectDurationForUrl(String videoUrl) {
    if (videoUrl.isEmpty ||
        _model.agendaItemVideoData.type != AgendaItemVideoType.url) {
      return false;
    }

    // Never run metadata detection for provider pages that are not direct media files.
    if (_mediaHelperService.getYoutubeVideoId(videoUrl) != null ||
        _mediaHelperService.getVimeoVideoId(videoUrl) != null) {
      return false;
    }

    final path = Uri.tryParse(videoUrl)?.path.toLowerCase() ??
        videoUrl.toLowerCase();
    return MediaHelperService.allowedVideoFormats
        .any((format) => path.endsWith('.$format'));
  }

  /// Detects video duration and calls the callback if duration is found
  Future<void> _detectAndSetVideoDuration(String videoUrl, int requestId) async {
    if (!_shouldDetectDurationForUrl(videoUrl)) {
      return;
    }

    if (_model.agendaItemVideoData.url != videoUrl || requestId != _durationDetectionRequestId) {
      return;
    }

    try {
      loggingService.log(
        'AgendaItemVideoPresenter._detectAndSetVideoDuration: Fetching duration for $videoUrl',
      );

      final durationSeconds =
          await _videoMetadataService.getVideoDurationInSeconds(videoUrl);

      // Ignore stale async completions from old requests/URLs.
      if (_model.agendaItemVideoData.url != videoUrl || requestId != _durationDetectionRequestId) {
        return;
      }

      if (durationSeconds != null && durationSeconds > 0) {
        loggingService.log(
          'AgendaItemVideoPresenter._detectAndSetVideoDuration: Found duration = $durationSeconds seconds',
        );
        _onVideoDurationDetected?.call(durationSeconds);
      }
    } catch (e) {
      loggingService.log(
        'AgendaItemVideoPresenter._detectAndSetVideoDuration: Error fetching duration: $e',
      );
      // Silently fail - user can manually set the time if needed
    }
  }

  void dispose() {
    _durationDetectionDebounceTimer?.cancel();
    _durationDetectionRequestId++;
  }

  String getVideoUrl() {
    return _model.agendaItemVideoData.url;
  }

  bool isValidVideo() {
    return _model.agendaItemVideoData.url.endsWith('mp4');
  }

  String? getYoutubeVideoId(String url) {
    return _mediaHelperService.getYoutubeVideoId(url);
  }

  String? getVimeoVideoId(String url) {
    return _mediaHelperService.getVimeoVideoId(url);
  }

  void updateVideoType(AgendaItemVideoTabType value) {
    final AgendaItemVideoType agendaItemVideoType;

    switch (value) {
      case AgendaItemVideoTabType.youtube:
        agendaItemVideoType = AgendaItemVideoType.youtube;
        break;
      case AgendaItemVideoTabType.vimeo:
        agendaItemVideoType = AgendaItemVideoType.vimeo;
        break;
      case AgendaItemVideoTabType.local:
      case AgendaItemVideoTabType.url:
        agendaItemVideoType = AgendaItemVideoType.url;
        break;
    }

    _model.agendaItemVideoTabType = value;
    _model.agendaItemVideoData.type = agendaItemVideoType;
    _view.updateView();

    _helper.updateParent(_model);
  }

  String getTabName(AgendaItemVideoTabType agendaItemVideoTabType) {
    switch (agendaItemVideoTabType) {
      case AgendaItemVideoTabType.local:
        return 'UPLOAD';
      case AgendaItemVideoTabType.youtube:
        return 'YOUTUBE';
      case AgendaItemVideoTabType.vimeo:
        return 'VIMEO';
      case AgendaItemVideoTabType.url:
        return 'URL';
    }
  }

  int getInitialIndex() {
    if (_model.agendaItemVideoData.url.isEmpty) {
      return AgendaItemVideoTabType.local.index;
    } else {
      // Only temporarily made solution. Once we get rid of the flag, we should get rid of `else`
      // statement here.
      if (isMultipleVideoTypesEnabled()) {
        switch (_model.agendaItemVideoData.type) {
          case AgendaItemVideoType.youtube:
            return AgendaItemVideoTabType.youtube.index;
          case AgendaItemVideoType.vimeo:
            return AgendaItemVideoTabType.vimeo.index;
          case AgendaItemVideoType.url:
            return AgendaItemVideoTabType.url.index;
        }
      } else {
        // Always go to `URL` tab. Only temporarily made solution.
        return 1;
      }
    }
  }

  bool isMultipleVideoTypesEnabled() {
    return _communityProvider.settings.multipleVideoTypes;
  }
}

@visibleForTesting
class AgendaItemVideoHelper {
  void updateParent(AgendaItemVideoModel agendaItemVideoModel) {
    agendaItemVideoModel.onChanged(agendaItemVideoModel.agendaItemVideoData);
  }
}
