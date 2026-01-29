import 'package:client/core/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:client/features/events/features/event_page/data/providers/event_permissions_provider.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_template/data/providers/meeting_template_card_store.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/providers/meeting_agenda_provider.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_template/data/services/firestore_meeting_template_service.dart';
import 'package:client/core/data/services/responsive_layout_service.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:client/styles/app_asset.dart';
import 'package:data_models/discussion_threads/discussion_thread.dart';
import 'package:data_models/events/live_meetings/meeting_template.dart';
import 'package:provider/provider.dart';

import 'views/meeting_template_card_item_user_suggestions_contract.dart';
import '../data/models/meeting_template_card_item_user_suggestions_model.dart';

class MeetingTemplateCardItemUserSuggestionsPresenter {
  final MeetingTemplateCardItemUserSuggestionsView _view;

  //ignore:unused_field
  final MeetingTemplateCardItemUserSuggestionsModel _model;
  final AgendaProvider _agendaProvider;
  final FirestoreMeetingTemplateService _firestoreMeetingTemplateService;
  final MeetingTemplateCardStore _meetingTemplateCardStore;
  final ResponsiveLayoutService _responsiveLayoutService;
  final EventPermissionsProvider _eventPermissions;
  final UserService _userService;

  MeetingTemplateCardItemUserSuggestionsPresenter(
    BuildContext context,
    this._view,
    this._model, {
    AgendaProvider? agendaProvider,
    FirestoreMeetingTemplateService? testFirestoreMeetingTemplateService,
    MeetingTemplateCardStore? meetingTemplateCardStore,
    ResponsiveLayoutService? testResponsiveLayoutService,
    UserService? userService,
    EventPermissionsProvider? eventPermissions,
  })  : _agendaProvider = agendaProvider ?? context.read<AgendaProvider>(),
        _firestoreMeetingTemplateService = testFirestoreMeetingTemplateService ??
            GetIt.instance<FirestoreMeetingTemplateService>(),
        _meetingTemplateCardStore =
            meetingTemplateCardStore ?? context.read<MeetingTemplateCardStore>(),
        _responsiveLayoutService = testResponsiveLayoutService ??
            GetIt.instance<ResponsiveLayoutService>(),
        _eventPermissions =
            eventPermissions ?? context.read<EventPermissionsProvider>(),
        _userService = userService ?? context.read<UserService>();

  bool isMobile(BuildContext context) {
    return _responsiveLayoutService.isMobile(context);
  }

  bool inLiveMeeting() {
    return _agendaProvider.inLiveMeeting;
  }

  bool get canModerateSuggestions => _eventPermissions.canModerateSuggestions;

  Stream<List<ParticipantAgendaItemDetails>>?
      getParticipantAgendaItemDetailsStream() {
    return _meetingTemplateCardStore.participantAgendaItemDetailsStream;
  }

  Future<void> addSuggestion(String suggestion) async {
    if (suggestion.isEmpty) {
      _view.showMessage(
        'Suggestion cannot be empty',
        toastType: ToastType.failed,
      );
      return;
    }

    await _firestoreMeetingTemplateService.addUserSuggestion(
      agendaItemId: _meetingTemplateCardStore.meetingTemplateCardAgendaItem?.id ?? '',
      userId: _userService.currentUserId ?? '',
      liveMeetingPath: _agendaProvider.liveMeetingPath,
      suggestion: suggestion,
    );
  }

  Future<void> removeSuggestion(
    MeetingUserSuggestion meetingUserSuggestion,
    String userId,
  ) async {
    await _firestoreMeetingTemplateService.removeUserSuggestion(
      agendaItemId: _meetingTemplateCardStore.meetingTemplateCardAgendaItem?.id ?? '',
      userId: userId,
      liveMeetingPath: _agendaProvider.liveMeetingPath,
      meetingUserSuggestion: meetingUserSuggestion,
    );
  }

  // Originally each item holds list of suggestions. Here we split the list so that
  // each item holds only one suggestion. This way we are able to access `parent` information
  // while having `suggestion` itself.
  List<ParticipantAgendaItemDetails> getFormattedDetails(
    List<ParticipantAgendaItemDetails>? participantAgendaItemDetails,
  ) {
    if (participantAgendaItemDetails == null ||
        participantAgendaItemDetails.isEmpty) {
      return [];
    }

    final formattedDetails = <ParticipantAgendaItemDetails>[];
    for (var participantAgendaItemDetail in participantAgendaItemDetails) {
      for (var userSuggestion in participantAgendaItemDetail.suggestions) {
        formattedDetails.add(
          ParticipantAgendaItemDetails(
            userId: participantAgendaItemDetail.userId,
            suggestions: [userSuggestion],
          ),
        );
      }
    }

    // Sort items based on `likedByIds` count. Highest `like` count - on top.
    formattedDetails.sort(
      (a, b) => b.suggestions.first
          .getLikeDislikeCount()
          .compareTo(a.suggestions.first.getLikeDislikeCount()),
    );

    return formattedDetails;
  }

  bool isMySuggestion(
    ParticipantAgendaItemDetails participantAgendaItemDetails,
  ) {
    return _userService.currentUserId == participantAgendaItemDetails.userId;
  }

  AppAsset getLikeImagePath(MeetingUserSuggestion meetingUserSuggestion) {
    final isLiked = meetingUserSuggestion.isLiked(_userService.currentUserId!);
    return isLiked ? AppAsset.kLikeSelectedPng : AppAsset.kLikeNotSelectedPng;
  }

  AppAsset getDislikeImagePath(MeetingUserSuggestion meetingUserSuggestion) {
    final isDisliked =
        meetingUserSuggestion.isDisliked(_userService.currentUserId);
    return isDisliked
        ? AppAsset.kDislikeSelectedPng
        : AppAsset.kDislikeNotSelectedPng;
  }

  String getLikeDislikeCount(MeetingUserSuggestion meetingUserSuggestion) {
    final count = meetingUserSuggestion.getLikeDislikeCount();
    final numberFormat = NumberFormat.compact();

    return numberFormat.format(count);
  }

  Future<void> toggleLikeDislike(
    LikeType likeType,
    ParticipantAgendaItemDetails participantAgendaItemDetails,
    MeetingUserSuggestion meetingUserSuggestion,
  ) async {
    final userId = _userService.currentUserId;
    final LikeType finalisedLikeType;
    switch (likeType) {
      case LikeType.like:
        final isLiked = meetingUserSuggestion.isLiked(userId);
        finalisedLikeType = isLiked ? LikeType.neutral : LikeType.like;
        break;
      case LikeType.neutral:
        finalisedLikeType = LikeType.neutral;
        break;
      case LikeType.dislike:
        final isDisliked = meetingUserSuggestion.isDisliked(userId);
        finalisedLikeType = isDisliked ? LikeType.neutral : LikeType.dislike;
        break;
    }

    await _firestoreMeetingTemplateService.toggleLikeInMeetingSuggestion(
      finalisedLikeType,
      agendaItemId: _meetingTemplateCardStore.meetingTemplateCardAgendaItem?.id ?? '',
      voterId: _userService.currentUserId ?? '',
      creatorId: participantAgendaItemDetails.userId ?? '',
      liveMeetingPath: _agendaProvider.liveMeetingPath,
      meetingUserSuggestionId: meetingUserSuggestion.id,
    );
  }
}
