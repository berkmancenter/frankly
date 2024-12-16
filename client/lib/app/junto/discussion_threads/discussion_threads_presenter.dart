import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/services/firestore/firestore_discussion_thread_comments_service.dart';
import 'package:junto/services/firestore/firestore_discussion_threads_service.dart';
import 'package:junto/services/responsive_layout_service.dart';
import 'package:junto/services/user_service.dart';
import 'package:junto/utils/models_helper.dart';
import 'package:junto_models/firestore/discussion_thread.dart';
import 'package:junto_models/firestore/discussion_thread_comment.dart';
import 'package:junto_models/firestore/emotion.dart';
import 'package:provider/provider.dart';

import 'discussion_threads_contract.dart';
import 'discussion_threads_model.dart';

class DiscussionThreadsPresenter {
  //ignore: unused_field
  final DiscussionThreadsView _view;
  //ignore: unused_field
  final DiscussionThreadsModel _model;
  final ResponsiveLayoutService _responsiveLayoutService;
  final FirestoreDiscussionThreadCommentsService _firestoreDiscussionThreadCommentsService;
  final FirestoreDiscussionThreadsService _firestoreDiscussionThreadsService;
  final UserService _userService;
  final JuntoProvider _juntoProvider;
  final EmotionHelper _emotionHelper;

  DiscussionThreadsPresenter(
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

  Future<void> toggleLikeDislike(LikeType likeType, DiscussionThread discussionThread) async {
    final userId = _userService.currentUserId!;

    await _firestoreDiscussionThreadsService.toggleLike(
      likeType,
      userId,
      juntoId: _juntoProvider.juntoId,
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

  String getJuntoDisplayId() {
    return _juntoProvider.displayId;
  }

  String getJuntoId() {
    return _juntoProvider.juntoId;
  }

  Stream<List<DiscussionThread>> getDiscussionThreadsStream(String juntoId) {
    return _firestoreDiscussionThreadsService.getDiscussionThreadsStream(juntoId: juntoId);
  }

  Future<void> addNewComment(String comment, String discussionThreadId) async {
    final juntoId = _juntoProvider.juntoId;
    final userId = _userService.currentUserId!;
    final id = _firestoreDiscussionThreadsService.getNewDocumentId(juntoId);

    final discussionThreadComment = DiscussionThreadComment(
      id: id,
      creatorId: userId,
      comment: comment,
    );
    await _firestoreDiscussionThreadCommentsService.addNewDiscussionThreadComment(
      juntoId: juntoId,
      discussionThreadId: discussionThreadId,
      discussionThreadComment: discussionThreadComment,
    );
  }

  Stream<DiscussionThreadComment?> getMostRecentDiscussionThreadCommentStream(
    String discussionThreadId,
  ) {
    return _firestoreDiscussionThreadCommentsService.getMostRecentDiscussionThreadCommentsStream(
      juntoId: _juntoProvider.juntoId,
      discussionThreadId: discussionThreadId,
    );
  }

  Emotion? getCurrentlySelectedDiscussionThreadEmotion(DiscussionThread discussionThread) {
    final emotion = _emotionHelper.getMyEmotion(
      discussionThread.emotions,
      _userService.isSignedIn,
      _userService.currentUserId,
    );

    return emotion;
  }
}
