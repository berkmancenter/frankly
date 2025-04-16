import 'package:client/core/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:client/features/discussion_threads/data/services/discussion_threads_helper.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/features/discussion_threads/data/services/firestore_discussion_threads_service.dart';
import 'package:client/core/data/services/media_helper_service.dart';
import 'package:client/core/data/services/responsive_layout_service.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:client/core/utils/extensions.dart';

import 'views/manipulate_discussion_thread_contract.dart';
import '../data/models/manipulate_discussion_thread_model.dart';

class ManipulateDiscussionThreadPresenter {
  final ManipulateDiscussionThreadView _view;
  final ManipulateDiscussionThreadModel _model;
  final DiscussionThreadsHelper _discussionThreadsHelper;
  final FirestoreDiscussionThreadsService _firestoreDiscussionThreadsService;
  final MediaHelperService _mediaHelperService;
  final ResponsiveLayoutService _responsiveLayoutService;
  final UserService _userService;

  ManipulateDiscussionThreadPresenter(
    BuildContext context,
    this._view,
    this._model, {
    DiscussionThreadsHelper? discussionThreadsHelper,
    FirestoreDiscussionThreadsService? firestoreDiscussionThreadsService,
    MediaHelperService? mediaHelperService,
    ResponsiveLayoutService? responsiveLayoutService,
    UserService? userService,
  })  : _discussionThreadsHelper =
            discussionThreadsHelper ?? DiscussionThreadsHelper(),
        _firestoreDiscussionThreadsService =
            firestoreDiscussionThreadsService ??
                GetIt.instance<FirestoreDiscussionThreadsService>(),
        _mediaHelperService =
            mediaHelperService ?? GetIt.instance<MediaHelperService>(),
        _responsiveLayoutService = responsiveLayoutService ??
            GetIt.instance<ResponsiveLayoutService>(),
        _userService = userService ?? GetIt.instance<UserService>();

  void init() {
    final localDiscussionThread = _model.existingDiscussionThread;

    if (localDiscussionThread != null) {
      _model.content = localDiscussionThread.content;
    }
  }

  String? getUserId() {
    return _userService.currentUserId;
  }

  String getPositiveButtonText() {
    if (_model.existingDiscussionThread != null) {
      return 'Update';
    } else {
      return 'Post';
    }
  }

  Future<bool> addNewDiscussionThread() async {
    final communityId = _model.communityProvider.communityId;
    final documentId =
        _firestoreDiscussionThreadsService.getNewDocumentId(communityId);
    final discussionThread =
        await _discussionThreadsHelper.addNewDiscussionThread(
      discussionThreadContent: _model.content,
      userId: _userService.currentUserId,
      pickedImageUrl: _model.pickedImageUrl,
      documentId: documentId,
      mediaHelperService: _mediaHelperService,
      onError: (error) => _view.showMessage(error, toastType: ToastType.failed),
    );

    if (discussionThread == null) {
      return false;
    }

    await _firestoreDiscussionThreadsService.addNewDiscussionThread(
      communityId,
      discussionThread,
    );

    _view.showMessage('Post has been created', toastType: ToastType.success);
    return true;
  }

  Future<bool> updateDiscussionThread() async {
    final discussionThread =
        await _discussionThreadsHelper.updateDiscussionThread(
      existingDiscussionThread: _model.existingDiscussionThread,
      discussionThreadContent: _model.content,
      pickedImageUrl: _model.pickedImageUrl,
      generalHelperService: _mediaHelperService,
      onError: (message) =>
          _view.showMessage(message, toastType: ToastType.failed),
    );

    if (discussionThread == null) {
      return false;
    }

    final communityId = _model.communityProvider.communityId;

    await _firestoreDiscussionThreadsService.updateDiscussionThread(
      communityId,
      discussionThread,
    );
    _view.showMessage('Post has been updated', toastType: ToastType.success);

    return true;
  }

  void updateContent(String input) {
    _model.content = input;
  }

  Future<void> pickImage() async {
    _model.pickedImageUrl = await _mediaHelperService.pickImageViaCloudinary();
    _view.requestTextFocus();
    _view.updateView();
  }

  String getCommunityDisplayId() {
    return _model.communityProvider.displayId;
  }

  void addEmojiToContent(EmotionType emotionType, int offset) {
    final emoji = emotionType.stringEmoji;

    // It shouldn't happen, but if it does, add emoji as very first character
    if (offset < 0) {
      _model.content = emoji + _model.content;
      return;
    }

    // It shouldn't happen, but if it does, add emoji as very last character
    if (offset > _model.content.length + 1) {
      _model.content += emoji;
      return;
    }

    final textStartPart = _model.content.substring(0, offset);
    final textEndPart = _model.content.substring(offset, _model.content.length);

    // Inserting emoji to exact position where the cursor currently is
    final finalisedText = textStartPart + emoji + textEndPart;
    _model.content = finalisedText;
    _view.updateTextEditingController();
  }

  bool isMobile(BuildContext context) {
    return _responsiveLayoutService.isMobile(context);
  }
}
