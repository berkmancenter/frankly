import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:junto/app/junto/discussion_threads/discussion_thread_preview_card.dart';
import 'package:junto/app/junto/discussion_threads/manipulate_discussion_thread/manipulate_discussion_thread_page.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/empty_page_content.dart';
import 'package:junto/common_widgets/junto_ui_migration.dart';
import 'package:junto/routing/locations.dart';
import 'package:junto/services/user_service.dart';
import 'package:junto/utils/stream_utils.dart';
import 'package:junto_models/firestore/discussion_thread.dart';
import 'package:junto_models/firestore/discussion_thread_comment.dart';
import 'package:provider/provider.dart';

import 'discussion_threads_contract.dart';
import 'discussion_threads_model.dart';
import 'discussion_threads_presenter.dart';

class DiscussionThreadsPage extends StatefulWidget {
  const DiscussionThreadsPage({Key? key}) : super(key: key);

  @override
  _DiscussionThreadsPageState createState() => _DiscussionThreadsPageState();
}

class _DiscussionThreadsPageState extends State<DiscussionThreadsPage>
    implements DiscussionThreadsView {
  late final DiscussionThreadsModel _model;
  late final DiscussionThreadsPresenter _presenter;

  @override
  void initState() {
    super.initState();

    _model = DiscussionThreadsModel();
    _presenter = DiscussionThreadsPresenter(context, this, _model);
  }

  Future<void> _goToNewDiscussionThreadPage() async {
    await guardSignedIn(
      () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ManipulateDiscussionThreadPage(
            juntoProvider: context.read<JuntoProvider>(),
            discussionThread: null,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<JuntoProvider>();
    final juntoId = _presenter.getJuntoId();

    return JuntoStreamGetterBuilder<List<DiscussionThread>>(
      streamGetter: () => _presenter.getDiscussionThreadsStream(juntoId),
      keys: [juntoId],
      builder: (context, discussionThreads) {
        final localDiscussionThreads = discussionThreads ?? [];

        return _buildBody(localDiscussionThreads);
      },
    );
  }

  Widget _buildBody(List<DiscussionThread> discussionThreads) {
    final isMobile = _presenter.isMobile(context);
    final totalWidth = MediaQuery.of(context).size.width;

    if (discussionThreads.isEmpty) {
      return Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: EmptyPageContent(
            type: EmptyPageType.posts,
            onButtonPress: () => _goToNewDiscussionThreadPage(),
            isBackgroundPrimaryColor: true,
            showContainer: false,
          ),
        ),
      );
    } else {
      return JuntoUiMigration(
        whiteBackground: true,
        child: isMobile
            ? _buildMobileUI(discussionThreads)
            : _buildDesktopUI(discussionThreads, totalWidth),
      );
    }
  }

  Widget _buildMobileUI(List<DiscussionThread> discussionThreads) {
    return ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: discussionThreads.length,
        itemBuilder: (context, index) {
          final discussionThread = discussionThreads[index];
          final juntoDisplayId = _presenter.getJuntoDisplayId();

          return JuntoStreamGetterBuilder<DiscussionThreadComment?>(
            streamGetter: () {
              return _presenter.getMostRecentDiscussionThreadCommentStream(discussionThread.id);
            },
            keys: [discussionThread.id],
            builder: (context, discussionThreadComment) {
              final currentlySelectedEmotion =
                  _presenter.getCurrentlySelectedDiscussionThreadEmotion(discussionThread);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: DiscussionThreadPreviewCard(
                  discussionThread: discussionThread,
                  userService: context.watch<UserService>(),
                  mostRecentDiscussionThreadComment: discussionThreadComment,
                  onLikeDislikeToggle: (likeType) async {
                    await alertOnError(
                      context,
                      () async => await _presenter.toggleLikeDislike(likeType, discussionThread),
                    );
                  },
                  onSeeMoreTap: () => routerDelegate
                      .beamTo(JuntoPageRoutes(juntoDisplayId: juntoDisplayId).discussionThreadPage(
                    discussionThreadId: discussionThread.id,
                    scrollToComments: true,
                  )),
                  onCardTap: () => routerDelegate.beamTo(
                    JuntoPageRoutes(juntoDisplayId: juntoDisplayId).discussionThreadPage(
                      discussionThreadId: discussionThread.id,
                      scrollToComments: false,
                    ),
                  ),
                  onEmotionTypeSelect: (emotion) async {
                    await alertOnError(
                      context,
                      () => _presenter.updateDiscussionEmotion(emotion, discussionThread),
                    );
                  },
                  onAddNewComment: (comment) async {
                    await alertOnError(
                        context, () => _presenter.addNewComment(comment, discussionThread.id));
                  },
                  isMobile: true,
                  currentlySelectedDiscussionThreadEmotion: currentlySelectedEmotion,
                ),
              );
            },
          );
        });
  }

  Widget _buildDesktopUI(List<DiscussionThread> discussionThreads, double totalWidth) {
    return ConstrainedBody(
      child:
        MasonryGridView.count(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 30),
        crossAxisCount: 2,
        itemCount: discussionThreads.length,
        itemBuilder: (BuildContext context, int index) {
          final discussionThread = discussionThreads[index];
          final juntoDisplayId = _presenter.getJuntoDisplayId();

          return JuntoStreamGetterBuilder<DiscussionThreadComment?>(
            streamGetter: () {
              return _presenter.getMostRecentDiscussionThreadCommentStream(discussionThread.id);
            },
            keys: [discussionThread.id],
            builder: (context, discussionThreadComment) {
              final currentlySelectedDiscussionThreadEmotion =
                  _presenter.getCurrentlySelectedDiscussionThreadEmotion(discussionThread);

              return DiscussionThreadPreviewCard(
                discussionThread: discussionThread,
                userService: context.watch<UserService>(),
                mostRecentDiscussionThreadComment: discussionThreadComment,
                onLikeDislikeToggle: (likeType) async {
                  await alertOnError(
                    context,
                    () => _presenter.toggleLikeDislike(likeType, discussionThread),
                  );
                },
                onSeeMoreTap: () => routerDelegate
                    .beamTo(JuntoPageRoutes(juntoDisplayId: juntoDisplayId).discussionThreadPage(
                  discussionThreadId: discussionThread.id,
                  scrollToComments: true,
                )),
                onCardTap: () => routerDelegate.beamTo(
                  JuntoPageRoutes(juntoDisplayId: juntoDisplayId).discussionThreadPage(
                    discussionThreadId: discussionThread.id,
                    scrollToComments: false,
                  ),
                ),
                onEmotionTypeSelect: (emotion) async {
                  await alertOnError(
                    context,
                    () => _presenter.updateDiscussionEmotion(emotion, discussionThread),
                  );
                },
                onAddNewComment: (message) async {
                  await alertOnError(
                      context, () => _presenter.addNewComment(message, discussionThread.id));
                },
                isMobile: false,
                currentlySelectedDiscussionThreadEmotion: currentlySelectedDiscussionThreadEmotion,
              );
            },
          );
        },
        mainAxisSpacing: 40,
        crossAxisSpacing: 40,
      ),
    );
  }

  @override
  void showMessage(String message, {ToastType toastType = ToastType.neutral}) {
    showRegularToast(context, message, toastType: toastType);
  }

  @override
  void updateView() {
    if (mounted) setState(() {});
  }
}
