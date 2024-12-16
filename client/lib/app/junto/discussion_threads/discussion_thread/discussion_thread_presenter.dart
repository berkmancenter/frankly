import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:junto/app/junto/discussion_threads/discussion_thread/discussion_thread_comment_ui.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/services/firestore/firestore_discussion_thread_comments_service.dart';
import 'package:junto/services/firestore/firestore_discussion_threads_service.dart';
import 'package:junto/services/responsive_layout_service.dart';
import 'package:junto/services/user_service.dart';
import 'package:junto/utils/models_helper.dart';
import 'package:junto_models/firestore/discussion_thread.dart';
import 'package:junto_models/firestore/discussion_thread_comment.dart';
import 'package:junto_models/firestore/emotion.dart';
import 'package:provider/provider.dart';

import 'discussion_thread_contract.dart';
import 'discussion_thread_model.dart';

class DiscussionThreadPresenter {
  final DiscussionThreadView _view;
  final DiscussionThreadModel _model;
  final ResponsiveLayoutService _responsiveLayoutService;
  final FirestoreDiscussionThreadCommentsService _firestoreDiscussionThreadCommentsService;
  final FirestoreDiscussionThreadsService _firestoreDiscussionThreadsService;
  final UserService _userService;
  final JuntoProvider _juntoProvider;
  final EmotionHelper _emotionHelper;

  DiscussionThreadPresenter(
    BuildContext context,
    this._view,
    this._model, {
    ResponsiveLayoutService? testResponsiveLayoutService,
    FirestoreDiscussionThreadCommentsService? firestoreDiscussionThreadCommentsService,
    FirestoreDiscussionThreadsService? firestoreDiscussionThreadsService,
    UserService? userService,
    JuntoProvider? juntoProvider,
    EmotionHelper? emotionHelper,
  })  : _responsiveLayoutService =
            testResponsiveLayoutService ?? GetIt.instance<ResponsiveLayoutService>(),
        _firestoreDiscussionThreadCommentsService = firestoreDiscussionThreadCommentsService ??
            GetIt.instance<FirestoreDiscussionThreadCommentsService>(),
        _firestoreDiscussionThreadsService = firestoreDiscussionThreadsService ??
            GetIt.instance<FirestoreDiscussionThreadsService>(),
        _userService = userService ?? GetIt.instance<UserService>(),
        _juntoProvider = juntoProvider ?? context.read<JuntoProvider>(),
        _emotionHelper = emotionHelper ?? EmotionHelper();

  bool isMobile(BuildContext context) {
    return _responsiveLayoutService.isMobile(context);
  }

  Future<void> toggleLikeDislike(LikeType likeType, DiscussionThread discussionThread) async {
    final userId = _userService.currentUserId!;
    final juntoId = _juntoProvider.juntoId;

    await _firestoreDiscussionThreadsService.toggleLike(
      likeType,
      userId,
      juntoId: juntoId,
      discussionThread: discussionThread,
    );
  }

  List<DiscussionThreadCommentUI> getComments(
    List<DiscussionThreadComment> discussionThreadComments,
  ) {
    // For more than 1 level nesting we will need to do recursive logic
    final List<DiscussionThreadCommentUI> discussionCommentsUI = [];
    final List<DiscussionThreadComment> topLevelComments = discussionThreadComments
        .where((topLevelComment) => topLevelComment.replyToCommentId == null)
        .toList();

    topLevelComments.forEach((topLevelComment) {
      final childrenComments = discussionThreadComments
          .where((element) => topLevelComment.id == element.replyToCommentId)
          .toList();

      discussionCommentsUI.add(DiscussionThreadCommentUI(topLevelComment, childrenComments));
    });

    return discussionCommentsUI;
  }

  Future<void> updateDiscussionEmotion(
    EmotionType emotionType,
    DiscussionThread discussionThread,
  ) async {
    final juntoId = _juntoProvider.juntoId;
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
      juntoId: juntoId,
      discussionThread: discussionThread,
      emotionHelper: _emotionHelper,
    );
  }

  Future<void> updateDiscussionCommentEmotion({
    required EmotionType emotionType,
    required DiscussionThreadComment discussionThreadComment,
    required String discussionThreadId,
  }) async {
    final juntoId = _juntoProvider.juntoId;
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
      juntoId: juntoId,
      discussionThreadId: discussionThreadId,
      discussionThreadComment: discussionThreadComment,
      emotionHelper: _emotionHelper,
    );
  }

  Stream<DiscussionThread> getDiscussionThreadStream() {
    return _firestoreDiscussionThreadsService.getDiscussionThreadStream(
      juntoId: _juntoProvider.juntoId,
      discussionThreadId: _model.discussionThreadId,
    );
  }

  bool isCreator(DiscussionThread discussionThread) {
    return discussionThread.creatorId == _userService.currentUserId;
  }

  Future<void> deleteThread() async {
    await _firestoreDiscussionThreadsService.deleteDiscussionThread(
      juntoId: _juntoProvider.juntoId,
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
    final juntoId = _juntoProvider.juntoId;
    final userId = _userService.currentUserId!;
    final id = _firestoreDiscussionThreadCommentsService.getNewDocumentId(
      juntoId: juntoId,
      discussionThreadId: discussionThreadId,
    );

    final discussionThreadComment = DiscussionThreadComment(
      id: id,
      creatorId: userId,
      comment: comment,
      replyToCommentId: replyToCommentId,
    );
    await _firestoreDiscussionThreadCommentsService.addNewDiscussionThreadComment(
      juntoId: juntoId,
      discussionThreadId: discussionThreadId,
      discussionThreadComment: discussionThreadComment,
    );
  }

  Stream<List<DiscussionThreadComment>> getDiscussionThreadCommentsStream() {
    return _firestoreDiscussionThreadCommentsService.getDiscussionThreadCommentsStream(
      juntoId: _juntoProvider.juntoId,
      discussionThreadId: _model.discussionThreadId,
    );
  }

  String getJuntoDisplayId() {
    return _juntoProvider.displayId;
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

  Future<void> deleteComment(DiscussionThreadComment discussionThreadComment) async {
    await _firestoreDiscussionThreadCommentsService.deleteDiscussionThreadComment(
      juntoId: _juntoProvider.juntoId,
      discussionThreadId: _model.discussionThreadId,
      discussionThreadComment: discussionThreadComment,
    );

    _view.showMessage('Comment was deleted', toastType: ToastType.success);
  }

  int getCommentCount(List<DiscussionThreadComment> discussionThreadComments) {
    return discussionThreadComments.where((element) => !element.isDeleted).length;
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
