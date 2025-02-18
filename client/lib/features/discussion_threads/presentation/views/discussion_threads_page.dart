import 'package:client/core/utils/toast_utils.dart';
import 'package:client/core/widgets/constrained_body.dart';
import 'package:client/features/auth/utils/auth_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:client/features/discussion_threads/presentation/views/discussion_thread_preview_card.dart';
import 'package:client/features/discussion_threads/presentation/views/manipulate_discussion_thread_page.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/empty_page_content.dart';
import 'package:client/core/widgets/ui_migration.dart';
import 'package:client/core/routing/locations.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:client/core/widgets/stream_utils.dart';
import 'package:data_models/discussion_threads/discussion_thread.dart';
import 'package:data_models/discussion_threads/discussion_thread_comment.dart';
import 'package:provider/provider.dart';

import 'discussion_threads_contract.dart';
import '../../data/models/discussion_threads_model.dart';
import '../discussion_threads_presenter.dart';

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
            communityProvider: context.read<CommunityProvider>(),
            discussionThread: null,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<CommunityProvider>();
    final communityId = _presenter.getCommunityId();

    return MemoizedStreamBuilder<List<DiscussionThread>>(
      streamGetter: () => _presenter.getDiscussionThreadsStream(communityId),
      keys: [communityId],
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
      return UIMigration(
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
        final communityDisplayId = _presenter.getCommunityDisplayId();

        return MemoizedStreamBuilder<DiscussionThreadComment?>(
          streamGetter: () {
            return _presenter.getMostRecentDiscussionThreadCommentStream(
              discussionThread.id,
            );
          },
          keys: [discussionThread.id],
          builder: (context, discussionThreadComment) {
            final currentlySelectedEmotion =
                _presenter.getCurrentlySelectedDiscussionThreadEmotion(
              discussionThread,
            );

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: DiscussionThreadPreviewCard(
                discussionThread: discussionThread,
                userService: context.watch<UserService>(),
                mostRecentDiscussionThreadComment: discussionThreadComment,
                onLikeDislikeToggle: (likeType) async {
                  await alertOnError(
                    context,
                    () async => await _presenter.toggleLikeDislike(
                      likeType,
                      discussionThread,
                    ),
                  );
                },
                onSeeMoreTap: () => routerDelegate.beamTo(
                  CommunityPageRoutes(
                    communityDisplayId: communityDisplayId,
                  ).discussionThreadPage(
                    discussionThreadId: discussionThread.id,
                    scrollToComments: true,
                  ),
                ),
                onCardTap: () => routerDelegate.beamTo(
                  CommunityPageRoutes(communityDisplayId: communityDisplayId)
                      .discussionThreadPage(
                    discussionThreadId: discussionThread.id,
                    scrollToComments: false,
                  ),
                ),
                onEmotionTypeSelect: (emotion) async {
                  await alertOnError(
                    context,
                    () => _presenter.updateDiscussionEmotion(
                      emotion,
                      discussionThread,
                    ),
                  );
                },
                onAddNewComment: (comment) async {
                  await alertOnError(
                    context,
                    () => _presenter.addNewComment(
                      comment,
                      discussionThread.id,
                    ),
                  );
                },
                isMobile: true,
                currentlySelectedDiscussionThreadEmotion:
                    currentlySelectedEmotion,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDesktopUI(
    List<DiscussionThread> discussionThreads,
    double totalWidth,
  ) {
    return ConstrainedBody(
      child: MasonryGridView.count(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 30),
        crossAxisCount: 2,
        itemCount: discussionThreads.length,
        itemBuilder: (BuildContext context, int index) {
          final discussionThread = discussionThreads[index];
          final communityDisplayId = _presenter.getCommunityDisplayId();

          return MemoizedStreamBuilder<DiscussionThreadComment?>(
            streamGetter: () {
              return _presenter.getMostRecentDiscussionThreadCommentStream(
                discussionThread.id,
              );
            },
            keys: [discussionThread.id],
            builder: (context, discussionThreadComment) {
              final currentlySelectedDiscussionThreadEmotion =
                  _presenter.getCurrentlySelectedDiscussionThreadEmotion(
                discussionThread,
              );

              return DiscussionThreadPreviewCard(
                discussionThread: discussionThread,
                userService: context.watch<UserService>(),
                mostRecentDiscussionThreadComment: discussionThreadComment,
                onLikeDislikeToggle: (likeType) async {
                  await alertOnError(
                    context,
                    () => _presenter.toggleLikeDislike(
                      likeType,
                      discussionThread,
                    ),
                  );
                },
                onSeeMoreTap: () => routerDelegate.beamTo(
                  CommunityPageRoutes(communityDisplayId: communityDisplayId)
                      .discussionThreadPage(
                    discussionThreadId: discussionThread.id,
                    scrollToComments: true,
                  ),
                ),
                onCardTap: () => routerDelegate.beamTo(
                  CommunityPageRoutes(communityDisplayId: communityDisplayId)
                      .discussionThreadPage(
                    discussionThreadId: discussionThread.id,
                    scrollToComments: false,
                  ),
                ),
                onEmotionTypeSelect: (emotion) async {
                  await alertOnError(
                    context,
                    () => _presenter.updateDiscussionEmotion(
                      emotion,
                      discussionThread,
                    ),
                  );
                },
                onAddNewComment: (message) async {
                  await alertOnError(
                    context,
                    () => _presenter.addNewComment(
                      message,
                      discussionThread.id,
                    ),
                  );
                },
                isMobile: false,
                currentlySelectedDiscussionThreadEmotion:
                    currentlySelectedDiscussionThreadEmotion,
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
