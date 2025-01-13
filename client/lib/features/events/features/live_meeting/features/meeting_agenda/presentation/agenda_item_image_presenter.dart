import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:client/features/events/features/event_page/data/providers/event_permissions_provider.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/providers/meeting_agenda_provider.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/data/services/media_helper_service.dart';

import 'views/agenda_item_image_contract.dart';
import '../data/models/agenda_item_image_model.dart';

class AgendaItemImagePresenter {
  final AgendaItemImageView _view;
  final AgendaItemImageModel _model;
  final AgendaItemImageHelper _helper;
  final MediaHelperService _mediaHelperService;

  AgendaItemImagePresenter(
    BuildContext context,
    this._view,
    this._model, {
    AgendaItemImageHelper? agendaItemImageHelper,
    MediaHelperService? mediaHelperService,
    AgendaProvider? agendaProvider,
    EventPermissionsProvider? eventPermissionsProvider,
  })  : _helper = agendaItemImageHelper ?? AgendaItemImageHelper(),
        _mediaHelperService =
            mediaHelperService ?? GetIt.instance<MediaHelperService>();

  void updateImageTitle(String title) {
    _model.agendaItemImageData.title = title.trim();
    _view.updateView();

    _helper.updateParent(_model);
  }

  void updateImageUrl(String url) {
    _model.agendaItemImageData.url = url.trim();
    _view.updateView();

    _helper.updateParent(_model);
  }

  String getImageUrl() {
    return _model.agendaItemImageData.url;
  }

  bool isValidImage() {
    return !isNullOrEmpty(_model.agendaItemImageData.url);
  }

  Future<String?> pickImage() async {
    return await _mediaHelperService.pickImageViaCloudinary();
  }
}

@visibleForTesting
class AgendaItemImageHelper {
  void updateParent(AgendaItemImageModel agendaItemImageModel) {
    agendaItemImageModel.onChanged(agendaItemImageModel.agendaItemImageData);
  }
}
