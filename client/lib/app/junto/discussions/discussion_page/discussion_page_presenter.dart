import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:junto/app/junto/community_permissions_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_page_contract.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_page_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/topic_provider.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/services/clock_service.dart';
import 'package:junto/services/cloud_functions_service.dart';
import 'package:junto/services/firestore/firestore_discussion_service.dart';
import 'package:junto/services/logging_service.dart';
import 'package:junto/services/services.dart';
import 'package:junto/services/shared_preferences_service.dart';
import 'package:junto/services/user_service.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/discussion_message.dart';
import 'package:junto_models/firestore/member_details.dart';
import 'package:junto_models/firestore/topic.dart';
import 'package:provider/provider.dart';

class DiscussionPagePresenter {
  static const String kSubCollectionDiscussionMessages = 'discussion-messages';

  final DiscussionPageView _view;
  final CloudFunctionsService _cloudFunctionsService;
  final JuntoProvider _juntoProvider;
  final TopicProvider _topicProvider;
  final DiscussionProvider _discussionProvider;
  final UserService _userService;
  final SharedPreferencesService _sharedPreferencesService;
  final ClockService _clockService;
  final FirestoreDiscussionService _firestoreDiscussionService;
  final CommunityPermissionsProvider _communityPermissionsProvider;

  bool _isEditTemplateTooltipShown = false;

  bool get isEditTemplateTooltipShown => _isEditTemplateTooltipShown;

  DiscussionPagePresenter(
    BuildContext context,
    this._view, {
    CloudFunctionsService? testCloudFunctionsService,
    JuntoProvider? juntoProvider,
    TopicProvider? topicProvider,
    DiscussionPageProvider? discussionPageProvider,
    DiscussionProvider? discussionProvider,
    UserService? userService,
    SharedPreferencesService? sharedPreferencesService,
    ClockService? clockService,
    FirestoreDiscussionService? firestoreDiscussionService,
    CommunityPermissionsProvider? communityPermissionsProvider,
  })  : _cloudFunctionsService =
            testCloudFunctionsService ?? GetIt.instance<CloudFunctionsService>(),
        _juntoProvider = juntoProvider ?? context.read<JuntoProvider>(),
        _topicProvider = topicProvider ?? context.read<TopicProvider>(),
        _discussionProvider = discussionProvider ?? context.read<DiscussionProvider>(),
        _userService = userService ?? context.read<UserService>(),
        _sharedPreferencesService =
            sharedPreferencesService ?? GetIt.instance<SharedPreferencesService>(),
        _clockService = clockService ?? GetIt.instance<ClockService>(),
        _firestoreDiscussionService =
            firestoreDiscussionService ?? GetIt.instance<FirestoreDiscussionService>(),
        _communityPermissionsProvider =
            communityPermissionsProvider ?? context.read<CommunityPermissionsProvider>();

  String get discussionPath =>
      '${_discussionProvider.discussion.collectionPath}/${_discussionProvider.discussion.id}';

  void init() async {
    final discussion = await _discussionProvider.discussionStream.first;
    _isEditTemplateTooltipShown = discussion.topicId != defaultTopicId &&
        _communityPermissionsProvider.canModerateContent &&
        _sharedPreferencesService.isEditTemplateTooltipShown();
    _view.updateView();
  }

  Future<void> sendMessage(String message) async {
    final DiscussionMessage discussionMessage = DiscussionMessage(
      creatorId: _userService.currentUserId!,
      createdAt: _clockService.now(),
      message: message,
    );

    await _cloudFunctionsService.sendDiscussionMessage(SendDiscussionMessageRequest(
      juntoId: _juntoProvider.juntoId,
      topicId: _discussionProvider.topicId,
      discussionId: _discussionProvider.discussionId,
      discussionMessage: discussionMessage,
    ));
  }

  Future<void> removeMessage(DiscussionMessage discussionMessage) async {
    final docId = discussionMessage.docId;

    if (docId == null) {
      loggingService.log(
        'DiscussionPagePresenter.removeMessage: DocID is null. DiscussionMessage: ${discussionMessage.toJson()}',
        logType: LogType.error,
      );
      return;
    }

    await _firestoreDiscussionService
        .discussionReference(
          juntoId: _juntoProvider.juntoId,
          topicId: _discussionProvider.topicId,
          discussionId: _discussionProvider.discussionId,
        )
        .collection(kSubCollectionDiscussionMessages)
        .doc(docId)
        .delete();
  }

  Future<void> refreshDiscussion() async {
    await _discussionProvider.refreshDiscussion(
      _topicProvider.topic,
      _discussionProvider.discussion,
    );
  }

  Future<GetMeetingChatsSuggestionsDataResponse> getChatsAndSuggestions() {
    return _cloudFunctionsService.getMeetingChatSuggestionData(
        request: GetMeetingChatsSuggestionsDataRequest(
      discussionPath: discussionPath,
    ));
  }

  Future<List<MemberDetails>> getMembersData(List<String> userIds) async {
    return await _userService.getMemberDetails(
      membersList: userIds,
      juntoId: _juntoProvider.juntoId,
      discussionPath: discussionPath,
    );
  }

  Topic getCombinedTopicFromDiscussion() {
    final discussion = _discussionProvider.discussion;
    final currentTopic = _topicProvider.topic;

    return currentTopic.copyWith(
      title: discussion.title,
      image: discussion.image,
      agendaItems: discussion.agendaItems,
      preEventCardData: discussion.preEventCardData,
      postEventCardData: discussion.postEventCardData,
      prerequisiteTopicId: discussion.prerequisiteTopicId,
    );
  }

  Future<void> deleteAgendaItems() async {
    final discussionDetails = _discussionProvider.discussion.copyWith(agendaItems: []);
    await _firestoreDiscussionService.updateDiscussion(
      discussion: discussionDetails,
      keys: [Discussion.kFieldAgendaItems],
    );
    _view.updateView();
    _view.showMessage('Agenda items were removed', toastType: ToastType.success);
  }

  void hideEditTooltip() {
    // Update UI state immediately without causing any loading
    _isEditTemplateTooltipShown = false;
    _view.updateView();

    // Update shared prefs afterwards
    _sharedPreferencesService.updateEditTemplateTooltipVisibility(false);
  }
}
