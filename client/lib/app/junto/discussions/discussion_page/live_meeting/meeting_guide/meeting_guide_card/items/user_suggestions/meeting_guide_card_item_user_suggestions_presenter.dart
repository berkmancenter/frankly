import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_permissions_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/meeting_guide/meeting_guide_card_store.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/meeting_agenda_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/services/firestore/firestore_meeting_guide_service.dart';
import 'package:junto/services/responsive_layout_service.dart';
import 'package:junto/services/user_service.dart';
import 'package:junto/styles/app_asset.dart';
import 'package:junto_models/firestore/discussion_thread.dart';
import 'package:junto_models/firestore/meeting_guide.dart';
import 'package:provider/provider.dart';

import 'meeting_guide_card_item_user_suggestions_contract.dart';
import 'meeting_guide_card_item_user_suggestions_model.dart';

class MeetingGuideCardItemUserSuggestionsPresenter {
  final MeetingGuideCardItemUserSuggestionsView _view;

  //ignore:unused_field
  final MeetingGuideCardItemUserSuggestionsModel _model;
  final AgendaProvider _agendaProvider;
  final FirestoreMeetingGuideService _firestoreMeetingGuideService;
  final MeetingGuideCardStore _meetingGuideCardStore;
  final ResponsiveLayoutService _responsiveLayoutService;
  final DiscussionPermissionsProvider _discussionPermissions;
  final UserService _userService;

  MeetingGuideCardItemUserSuggestionsPresenter(
    BuildContext context,
    this._view,
    this._model, {
    AgendaProvider? agendaProvider,
    FirestoreMeetingGuideService? testFirestoreMeetingGuideService,
    MeetingGuideCardStore? meetingGuideCardStore,
    ResponsiveLayoutService? testResponsiveLayoutService,
    UserService? userService,
    DiscussionPermissionsProvider? discussionPermissions,
  })  : _agendaProvider = agendaProvider ?? context.read<AgendaProvider>(),
        _firestoreMeetingGuideService =
            testFirestoreMeetingGuideService ?? GetIt.instance<FirestoreMeetingGuideService>(),
        _meetingGuideCardStore = meetingGuideCardStore ?? context.read<MeetingGuideCardStore>(),
        _responsiveLayoutService =
            testResponsiveLayoutService ?? GetIt.instance<ResponsiveLayoutService>(),
        _discussionPermissions = discussionPermissions ?? context.read<DiscussionPermissionsProvider>(),
        _userService = userService ?? context.read<UserService>();

  bool isMobile(BuildContext context) {
    return _responsiveLayoutService.isMobile(context);
  }

  bool inLiveMeeting() {
    return _agendaProvider.inLiveMeeting;
  }

  bool get canModerateSuggestions => _discussionPermissions.canModerateSuggestions;

  Stream<List<ParticipantAgendaItemDetails>>? getParticipantAgendaItemDetailsStream() {
    return _meetingGuideCardStore.participantAgendaItemDetailsStream;
  }

  Future<void> addSuggestion(String suggestion) async {
    if (suggestion.isEmpty) {
      _view.showMessage('Suggestion cannot be empty', toastType: ToastType.failed);
      return;
    }

    await _firestoreMeetingGuideService.addUserSuggestion(
      agendaItemId: _meetingGuideCardStore.meetingGuideCardAgendaItem?.id ?? '',
      userId: _userService.currentUserId ?? '',
      liveMeetingPath: _agendaProvider.liveMeetingPath,
      suggestion: suggestion,
    );
  }

  Future<void> removeSuggestion(MeetingUserSuggestion meetingUserSuggestion, String userId) async {
    await _firestoreMeetingGuideService.removeUserSuggestion(
      agendaItemId: _meetingGuideCardStore.meetingGuideCardAgendaItem?.id ?? '',
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
    if (participantAgendaItemDetails == null || participantAgendaItemDetails.isEmpty) {
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

  bool isMySuggestion(ParticipantAgendaItemDetails participantAgendaItemDetails) {
    return _userService.currentUserId == participantAgendaItemDetails.userId;
  }

  AppAsset getLikeImagePath(MeetingUserSuggestion meetingUserSuggestion) {
    final isLiked = meetingUserSuggestion.isLiked(_userService.currentUserId!);
    return isLiked ? AppAsset.kLikeSelectedPng : AppAsset.kLikeNotSelectedPng;
  }

  AppAsset getDislikeImagePath(MeetingUserSuggestion meetingUserSuggestion) {
    final isDisliked = meetingUserSuggestion.isDisliked(_userService.currentUserId);
    return isDisliked ? AppAsset.kDislikeSelectedPng : AppAsset.kDislikeNotSelectedPng;
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

    await _firestoreMeetingGuideService.toggleLikeInMeetingSuggestion(
      finalisedLikeType,
      agendaItemId: _meetingGuideCardStore.meetingGuideCardAgendaItem?.id ?? '',
      voterId: _userService.currentUserId ?? '',
      creatorId: participantAgendaItemDetails.userId ?? '',
      liveMeetingPath: _agendaProvider.liveMeetingPath,
      meetingUserSuggestionId: meetingUserSuggestion.id,
    );
  }
}
