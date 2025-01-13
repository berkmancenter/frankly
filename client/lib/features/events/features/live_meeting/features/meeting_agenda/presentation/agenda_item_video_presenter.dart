import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/views/agenda_item_video.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/data/services/media_helper_service.dart';
import 'package:data_models/events/event.dart';
import 'package:provider/provider.dart';

import 'views/agenda_item_video_contract.dart';
import '../data/models/agenda_item_video_model.dart';

class AgendaItemVideoPresenter {
  final AgendaItemVideoView _view;
  final AgendaItemVideoModel _model;
  final AgendaItemVideoHelper _helper;
  final MediaHelperService _mediaHelperService;
  final CommunityProvider _communityProvider;

  AgendaItemVideoPresenter(
    BuildContext context,
    this._view,
    this._model, {
    AgendaItemVideoHelper? agendaItemVideoHelper,
    MediaHelperService? mediaHelperService,
    CommunityProvider? communityProvider,
  })  : _helper = agendaItemVideoHelper ?? AgendaItemVideoHelper(),
        _mediaHelperService =
            mediaHelperService ?? GetIt.instance<MediaHelperService>(),
        _communityProvider =
            communityProvider ?? context.read<CommunityProvider>();

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
    _model.agendaItemVideoData.url = url.trim();
    _view.updateView();

    _helper.updateParent(_model);
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
