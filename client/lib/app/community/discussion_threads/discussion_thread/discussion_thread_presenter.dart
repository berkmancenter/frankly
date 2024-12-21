import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:client/app/community/discussion_threads/discussion_thread/discussion_thread_comment_ui.dart';
import 'package:client/app/community/community_provider.dart';
import 'package:client/app/community/utils.dart';
import 'package:client/services/firestore/firestore_discussion_thread_comments_service.dart';
import 'package:client/services/firestore/firestore_discussion_threads_service.dart';
import 'package:client/services/responsive_layout_service.dart';
import 'package:client/services/user_service.dart';
import 'package:client/utils/models_helper.dart';
import 'package:data_models/discussion_threads/discussion_thread.dart';
import 'package:data_models/discussion_threads/discussion_thread_comment.dart';
import 'package:data_models/chat/emotion.dart';
import 'package:provider/provider.dart';

import 'discussion_thread_contract.dart';
import 'discussion_thread_model.dart';

class DiscussionThreadPresenter {
  final DiscussionThreadView _view;
  final DiscussionThreadModel _model;
  final ResponsiveLayoutService _responsiveLayoutService;
  final FirestoreDiscussionThreadCommentsService
      _firestoreDiscussionThreadCommentsService;
  final FirestoreDiscussionThreadsService _firestoreDiscussionThreadsService;
  final UserService _userService;
  final CommunityProvider _communityProvider;
  final EmotionHelper _emotionHelper;

  DiscussionThreadPresenter(
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

  bool isMobile(BuildContext context) {
    return _responsiveLayoutService.isMobile(context);
  }

  Future<void> toggleLikeDislike(
    LikeType likeType,
    DiscussionThread discussionThread,
  ) async {
    final userId = _userService.currentUserId!;
    final communityId = _communityProvider.communityId;

    await _firestoreDiscussionThreadsService.toggleLike(
      likeType,
      userId,
      communityId: communityId,
      discussionThread: discussionThread,
    );
  }

  List<DiscussionThreadCommentUI> getComments(
    List<DiscussionThreadComment> discussionThreadComments,
  ) {
    // For more than 1 level nesting we will need to do recursive logic
    final List<DiscussionThreadCommentUI> discussionCommentsUI = [];
    final List<DiscussionThreadComment> topLevelComments =
        discussionThreadComments
            .where(
              (topLevelComment) => topLevelComment.replyToCommentId == null,
            )
            .toList();

    for (var topLevelComment in topLevelComments) {
      final childrenComments = discussionThreadComments
          .where((element) => topLevelComment.id == element.replyToCommentId)
          .toList();

      discussionCommentsUI
          .add(DiscussionThreadCommentUI(topLevelComment, childrenComments));
    }

    return discussionCommentsUI;
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

  Future<void> updateDiscussionCommentEmotion({
    required EmotionType emotionType,
    required DiscussionThreadComment discussionThreadComment,
    required String discussionThreadId,
  }) async {
    final communityId = _communityProvider.communityId;
    final userId = _userService.currentUserId!;
    final emotion = Emotion(
      creatorId: userId,
      emotionType: emotionType,
    );

    // Find if emotion was already toggled by user.
    final existingEmotion = _emotionHelper.getMyEmotion(
      discussionThreadComment.emotions,
      _userService.isSignedIn,
      emotion.creatorId,
    );

    await _firestoreDiscussionThreadCommentsService.updateEmotion(
      emotion,
      existingEmotion: existingEmotion,
      communityId: communityId,
      discussionThreadId: discussionThreadId,
      discussionThreadComment: discussionThreadComment,
      emotionHelper: _emotionHelper,
    );
  }

  Stream<DiscussionThread> getDiscussionThreadStream() {
    return _firestoreDiscussionThreadsService.getDiscussionThreadStream(
      communityId: _communityProvider.communityId,
      discussionThreadId: _model.discussionThreadId,
    );
  }

  bool isCreator(DiscussionThread discussionThread) {
    return discussionThread.creatorId == _userService.currentUserId;
  }

  Future<void> deleteThread() async {
    await _firestoreDiscussionThreadsService.deleteDiscussionThread(
      communityId: _communityProvider.communityId,
      discussionThreadId: _model.discussionThreadId,
    );
    _view.showMessage('Post was deleted', toastType: ToastType.success);
  }

  String? getUserId() {
    return _userService.currentUserId;
  }

  /// Adds new comment.
  ///
  /// If [replyToCommentId] is provided, comment is a `reply` comment.
  Future<void> addNewComment({
    required String comment,
    required String discussionThreadId,
    String? replyToCommentId,
  }) async {
    final communityId = _communityProvider.communityId;
    final userId = _userService.currentUserId!;
    final id = _firestoreDiscussionThreadCommentsService.getNewDocumentId(
      communityId: communityId,
      discussionThreadId: discussionThreadId,
    );

    final discussionThreadComment = DiscussionThreadComment(
      id: id,
      creatorId: userId,
      comment: comment,
      replyToCommentId: replyToCommentId,
    );
    await _firestoreDiscussionThreadCommentsService
        .addNewDiscussionThreadComment(
      communityId: communityId,
      discussionThreadId: discussionThreadId,
      discussionThreadComment: discussionThreadComment,
    );
  }

  Stream<List<DiscussionThreadComment>> getDiscussionThreadCommentsStream() {
    return _firestoreDiscussionThreadCommentsService
        .getDiscussionThreadCommentsStream(
      communityId: _communityProvider.communityId,
      discussionThreadId: _model.discussionThreadId,
    );
  }

  String getCommunityDisplayId() {
    return _communityProvider.displayId;
  }

  void scrollToComments() {
    if (_model.scrollToComments && !_model.wasScrolledToComments) {
      _model.wasScrolledToComments = true;
      _view.scrollToComments();
    }
  }

  bool isSignedIn() {
    return _userService.isSignedIn;
  }

  Future<void> deleteComment(
    DiscussionThreadComment discussionThreadComment,
  ) async {
    await _firestoreDiscussionThreadCommentsService
        .deleteDiscussionThreadComment(
      communityId: _communityProvider.communityId,
      discussionThreadId: _model.discussionThreadId,
      discussionThreadComment: discussionThreadComment,
    );

    _view.showMessage('Comment was deleted', toastType: ToastType.success);
  }

  int getCommentCount(List<DiscussionThreadComment> discussionThreadComments) {
    return discussionThreadComments
        .where((element) => !element.isDeleted)
        .length;
  }

  Emotion? getCurrentlySelectedEmotion(List<Emotion> emotions) {
    final emotion = _emotionHelper.getMyEmotion(
      emotions,
      _userService.isSignedIn,
      _userService.currentUserId,
    );

    return emotion;
  }
}
