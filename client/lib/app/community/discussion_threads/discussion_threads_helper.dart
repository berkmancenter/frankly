import 'package:client/common_widgets/visible_exception.dart';
import 'package:client/services/media_helper_service.dart';
import 'package:data_models/discussion_threads/discussion_thread.dart';

class DiscussionThreadsHelper {
  Future<DiscussionThread?> addNewDiscussionThread({
    required String discussionThreadContent,
    required String? userId,
    String? pickedImageUrl,
    required String documentId,
    required MediaHelperService mediaHelperService,
    required void Function(String) onError,
  }) async {
    final content = discussionThreadContent.trim();

    if (content.isEmpty) {
      onError('Content cannot be empty');
      return null;
    }

    if (userId == null) {
      throw VisibleException('UserId is null, please contact support');
    }

    final String? uploadedImageURL = pickedImageUrl;

    final discussionThread = DiscussionThread(
      id: documentId,
      creatorId: userId,
      content: content,
      imageUrl: uploadedImageURL,
    );

    return discussionThread;
  }

  Future<DiscussionThread?> updateDiscussionThread({
    required DiscussionThread? existingDiscussionThread,
    required String discussionThreadContent,
    String? pickedImageUrl,
    required MediaHelperService generalHelperService,
    required void Function(String) onError,
  }) async {
    final localDiscussionThread = existingDiscussionThread;
    // This should never happen, because when we are in `update` mode, this model must be
    // always provided
    if (localDiscussionThread == null) {
      return null;
    }

    final content = discussionThreadContent.trim();

    if (content.isEmpty) {
      onError('Content cannot be empty');
      return null;
    }

    final String? uploadedImageUrl =
        pickedImageUrl ?? localDiscussionThread.imageUrl;

    final discussionThread = localDiscussionThread.copyWith(
      content: content,
      imageUrl: uploadedImageUrl,
    );

    return discussionThread;
  }
}
