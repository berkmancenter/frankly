import 'dart:async';

import 'package:flutter/material.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_tabs/discussion_tabs_model.dart';
import 'package:junto/junto_app.dart';
import 'package:junto/services/firestore/firestore_utils.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/firestore/discussion.dart';

/*
-Rank should be upvotes, then oldest first
-Turn on "participant suggestions" by default
-Don't show the green button during agenda creation
Newlines should be reflected in agenda content
-Add a "Finish" button when creating an agenda during the topic creation flow
-Agenda creation should be part of topic creation flow, like it is for event creation

In agenda creation - last word disappears if the title is too long.  Try this one "Another template agenda item before being modified also it's really long"
 */
class UserSubmittedAgendaProvider with ChangeNotifier {
  /// Path to the parent document for these user submitted agenda items.
  final String parentPath;
  final DiscussionTabsControllerState discussionTabsControllerState;

  final newSubmissionController = TextEditingController();

  UserSubmittedAgendaProvider({
    required this.parentPath,
    required this.discussionTabsControllerState,
  });

  String get newSubmissionContent => newSubmissionController.text;

  List<SuggestedAgendaItem>? _previousSuggestedAgendaItems;
  BehaviorSubjectWrapper<List<SuggestedAgendaItem>>? _suggestedAgendaItems;
  StreamSubscription? _suggestedAgendaItemsStreamSubscription;

  Stream<List<SuggestedAgendaItem>>? get suggestedAgendaItemsStream =>
      _suggestedAgendaItems?.stream;
  List<SuggestedAgendaItem>? get suggestedAgendaItems => _suggestedAgendaItems?.stream.valueOrNull;

  int get numUnreadSuggestions {
    final previousSuggestedAgendaItems = _previousSuggestedAgendaItems;
    final localSuggestedAgendaItems = suggestedAgendaItems;

    if (previousSuggestedAgendaItems == null || localSuggestedAgendaItems == null) {
      return 0;
    }

    return localSuggestedAgendaItems.length - previousSuggestedAgendaItems.length;
  }

  void initialize() {
    if (_suggestedAgendaItems == null || _suggestedAgendaItems?.stream.hasError == true) {
      _suggestedAgendaItems?.dispose();
      _suggestedAgendaItems = firestoreUserAgendaService.suggestedAgendaItemsStream(
        parentDoc: parentPath,
      );
      _suggestedAgendaItemsStreamSubscription?.cancel();
      _suggestedAgendaItemsStreamSubscription =
          _suggestedAgendaItems!.stream.listen(_onSuggestedAgendaItemsUpdate);
    }

    discussionTabsControllerState.selectedTabController.addListener(_checkClearUnread);
  }

  void _checkClearUnread() {
    if (discussionTabsControllerState.isSuggestedAgendaItemsTab()) {
      _markAllSuggestionsRead();
    }
  }

  @override
  void dispose() {
    discussionTabsControllerState.selectedTabController.removeListener(_checkClearUnread);
    _suggestedAgendaItemsStreamSubscription?.cancel();
    _suggestedAgendaItems?.dispose();
    super.dispose();
  }

  void _markAllSuggestionsRead() {
    _previousSuggestedAgendaItems = suggestedAgendaItems;
    notifyListeners();
  }

  void _onSuggestedAgendaItemsUpdate(List<SuggestedAgendaItem> suggestedAgendaItems) {
    if (_previousSuggestedAgendaItems == null ||
        (discussionTabsControllerState.isSuggestedAgendaItemsTab())) {
      _markAllSuggestionsRead();
    }

    notifyListeners();
  }

  Future<void> vote({required bool upvote, required String itemId}) async {
    await firestoreUserAgendaService.voteOnSuggestedAgendaItem(
      parentDoc: parentPath,
      itemId: itemId,
      upvote: upvote,
    );
  }

  Future<void> submit() async {
    final content = newSubmissionContent;

    newSubmissionController.clear();
    if (content.isNotEmpty) {
      await firestoreUserAgendaService.addSuggestedAgendaItem(
        parentDoc: parentPath,
        item: SuggestedAgendaItem(
          id: uuid.v4(),
          creatorId: userService.currentUserId,
          content: content,
          upvotedUserIds: [userService.currentUserId!],
          downvotedUserIds: [],
        ),
      );
      notifyListeners();
    }
  }

  Future<void> delete(String agendaItemId) async {
    await firestoreUserAgendaService.deleteSuggestedAgendaItem(
      parentDoc: parentPath,
      id: agendaItemId,
    );
  }
}
