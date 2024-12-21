import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:client/app/community/community_provider.dart';
import 'package:client/services/firestore/firestore_discussion_thread_comments_service.dart';
import 'package:client/services/firestore/firestore_discussion_threads_service.dart';
import 'package:client/services/responsive_layout_service.dart';
import 'package:client/services/user_service.dart';
import 'package:client/utils/models_helper.dart';
import 'package:data_models/discussion_threads/discussion_thread.dart';
import 'package:data_models/discussion_threads/discussion_thread_comment.dart';
import 'package:data_models/chat/emotion.dart';
import 'package:provider/provider.dart';

import 'discussion_threads_contract.dart';
import 'discussion_threads_model.dart';

class DiscussionThreadsPresenter {
  //ignore: unused_field
  final DiscussionThreadsView _view;
  //ignore: unused_field
  final DiscussionThreadsModel _model;
  final ResponsiveLayoutService _responsiveLayoutService;
  final FirestoreDiscussionThreadCommentsService
      _firestoreDiscussionThreadCommentsService;
  final FirestoreDiscussionThreadsService _firestoreDiscussionThreadsService;
  final UserService _userService;
  final CommunityProvider _communityProvider;
  final EmotionHelper _emotionHelper;

  DiscussionThreadsPresenter(
    BuildContext context,
    this._view,
    this._model, {
    ResponsiveLayoutService? testResponsiveLayoutService,
    FirestoreDiscussionThreadCommentsService?
        firestoreDiscussionThreadCommentsService,
    FirestoreDiscussionThreadsService? firestoreDiscussionThreadsService,
    UserService? userService,
    CommunityProvider? communityProvider,
    EmotionHelper? emotionHelper,
  })  : _responsiveLayoutService = testResponsiveLayoutService ??
            GetIt.instance<ResponsiveLayoutService>(),
        _firestoreDiscussionThreadCommentsService =
            firestoreDiscussionThreadCommentsService ??
                GetIt.instance<FirestoreDiscussionThreadCommentsService>(),
        _firestoreDiscussionThreadsService =
            firestoreDiscussionThreadsService ??
                GetIt.instance<FirestoreDiscussionThreadsService>(),
        _userService = userService ?? GetIt.instance<UserService>(),
        _communityProvider =
            communityProvider ?? context.read<CommunityProvider>(),
        _emotionHelper = emotionHelper ?? EmotionHelper();

  Future<void> toggleLikeDislike(
    LikeType likeType,
    DiscussionThread discussionThread,
  ) async {
    final userId = _userService.currentUserId!;

    await _firestoreDiscussionThreadsService.toggleLike(
      likeType,
      userId,
      communityId: _communityProvider.communityId,
      discussionThread: discussionThread,
    );
  }

  bool isMobile(BuildContext context) {
    return _responsiveLayoutService.isMobile(context);
  }

  Future<void> updateDiscussionEmotion(
    EmotionType emotionType,
    DiscussionThread discussionThread,
  ) async {
    final communityId = _communityProvider.communityId;
    final userId = _userService.currentUserId!;
    final emotion = Emotion(
      creatorId: userId,
      emotionType: emotionType,
    );
    // Find if emotion was already toggled by user.
    final existingEmotion = _emotionHelper.getMyEmotion(
      discussionThread.emotions,
      _userService.isSignedIn,
      emotion.creatorId,
    );

    await _firestoreDiscussionThreadsService.updateEmotion(
      emotion,
      existingEmotion: existingEmotion,
      communityId: communityId,
      discussionThread: discussionThread,
      emotionHelper: _emotionHelper,
    );
  }

  String getCommunityDisplayId() {
    return _communityProvider.displayId;
  }

  String getCommunityId() {
    return _communityProvider.communityId;
  }

  Stream<List<DiscussionThread>> getDiscussionThreadsStream(
    String communityId,
  ) {
    return _firestoreDiscussionThreadsService.getDiscussionThreadsStream(
      communityId: communityId,
    );
  }

  Future<void> addNewComment(String comment, String discussionThreadId) async {
    final communityId = _communityProvider.communityId;
    final userId = _userService.currentUserId!;
    final id = _firestoreDiscussionThreadsService.getNewDocumentId(communityId);

    final discussionThreadComment = DiscussionThreadComment(
      id: id,
      creatorId: userId,
      comment: comment,
    );
    await _firestoreDiscussionThreadCommentsService
        .addNewDiscussionThreadComment(
      communityId: communityId,
      discussionThreadId: discussionThreadId,
      discussionThreadComment: discussionThreadComment,
    );
  }

  Stream<DiscussionThreadComment?> getMostRecentDiscussionThreadCommentStream(
    String discussionThreadId,
  ) {
    return _firestoreDiscussionThreadCommentsService
        .getMostRecentDiscussionThreadCommentsStream(
      communityId: _communityProvider.communityId,
      discussionThreadId: discussionThreadId,
    );
  }

  Emotion? getCurrentlySelectedDiscussionThreadEmotion(
    DiscussionThread discussionThread,
  ) {
    final emotion = _emotionHelper.getMyEmotion(
      discussionThread.emotions,
      _userService.isSignedIn,
      _userService.currentUserId,
    );

    return emotion;
  }
}
