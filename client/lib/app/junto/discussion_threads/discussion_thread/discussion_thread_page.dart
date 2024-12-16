import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:junto/app/junto/discussion_threads/discussion_thread/discussion_thread_card.dart';
import 'package:junto/app/junto/discussion_threads/discussion_thread/discussion_thread_comment_card.dart';
import 'package:junto/app/junto/discussion_threads/discussion_thread/discussion_thread_comment_ui.dart';
import 'package:junto/app/junto/discussion_threads/manipulate_discussion_thread/manipulate_discussion_thread_page.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/app_clickable_widget.dart';
import 'package:junto/common_widgets/app_generic_state_widget.dart';
import 'package:junto/common_widgets/confirm_dialog.dart';
import 'package:junto/common_widgets/junto_image.dart';
import 'package:junto/routing/locations.dart';
import 'package:junto/services/services.dart';
import 'package:junto/services/user_service.dart';
import 'package:junto/styles/app_asset.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/dialogs.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto/utils/stream_utils.dart';
import 'package:junto_models/firestore/discussion_thread.dart';
import 'package:junto_models/firestore/discussion_thread_comment.dart';
import 'package:provider/provider.dart';

import 'discussion_thread_contract.dart';
import 'discussion_thread_model.dart';
import 'discussion_thread_presenter.dart';

enum DiscussionThreadOptionType {
  update,
  delete,
}

class DiscussionThreadPage extends StatefulWidget {
  final String discussionThreadId;
  final bool scrollToComments;

  const DiscussionThreadPage({
    Key? key,
    required this.discussionThreadId,
    required this.scrollToComments,
  }) : super(key: key);

  @override
  _DiscussionThreadPageState createState() => _DiscussionThreadPageState();
}

class _DiscussionThreadPageState extends State<DiscussionThreadPage>
    implements DiscussionThreadView {
  static const _kBackgroundColor = AppColor.gray6;

  /// Key for `comments` section start. It is used for auto-scrolling if [widget.scrollToComments]
  /// is true.
  final _commentsSectionKey = GlobalKey();

  late final DiscussionThreadModel _model;
  late final DiscussionThreadPresenter _presenter;

  @override
  void initState() {
    super.initState();

    _model = DiscussionThreadModel(widget.discussionThreadId, widget.scrollToComments);
    _presenter = DiscussionThreadPresenter(context, this, _model);
  }

  Future<void> _showDeleteThreadDialog() async {
    await ConfirmDialog(
      title: 'Delete post',
      mainText: 'Are you sure want to delete this post?',
      cancelText: 'No',
      onCancel: (context) => Navigator.pop(context),
      confirmText: 'Yes',
      onConfirm: (context) async {
        await alertOnError(context, () => _presenter.deleteThread());
        _goToThreadsPage();
      },
    ).show();
  }

  Future<void> _showAddCommentDialog(DiscussionThread discussionThread) async {
    final isMobile = _presenter.isMobile(context);

    await guardSignedIn(() async {
      final comment = await Dialogs.showComposeMessageDialog(
        context,
        title: 'Add comment',
        isMobile: isMobile,
        labelText: 'Comment',
        validator: (text) => text == null || text.isEmpty ? 'Comment cannot be empty' : null,
        positiveButtonText: 'Add Comment',
      );

      if (comment != null) {
        await alertOnError(
          context,
          () => _presenter.addNewComment(comment: comment, discussionThreadId: discussionThread.id),
        );
      }
    });
  }

  void _goToThreadsPage() {
    final juntoDisplayId = _presenter.getJuntoDisplayId();

    routerDelegate.beamTo(
      JuntoPageRoutes(juntoDisplayId: juntoDisplayId).discussionThreadsPage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: JuntoStreamGetterBuilder<DiscussionThread>(
        streamGetter: () => _presenter.getDiscussionThreadStream(),
        keys: [_model.discussionThreadId],
        builder: (context, discussionThread) {
          if (discussionThread == null) {
            return SizedBox.shrink();
          }

          if (discussionThread.isDeleted) {
            return Center(
              child: AppGenericStateWidget(
                title: 'Post was deleted.',
                imagePath: AppAsset.kEmptyStateStatusPng,
                responsiveLayoutService: responsiveLayoutService,
                appGenericStateData: AppGenericStateData(
                  'Show all posts',
                  () => _goToThreadsPage(),
                ),
              ),
            );
          }

          return JuntoStreamGetterBuilder<List<DiscussionThreadComment>>(
            streamGetter: () => _presenter.getDiscussionThreadCommentsStream(),
            keys: [],
            builder: (context, discussionThreadComments) {
              final localDiscussionThreadComments = discussionThreadComments ?? [];
              _presenter.scrollToComments();

              return Scaffold(
                backgroundColor: _kBackgroundColor,
                floatingActionButton: _buildFAB(discussionThread),
                body: _buildBody(discussionThread, localDiscussionThreadComments),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFAB(DiscussionThread discussionThread) {
    final isMobile = _presenter.isMobile(context);

    if (isMobile) {
      return FloatingActionButton(
        isExtended: isMobile,
        backgroundColor: AppColor.darkBlue,
        onPressed: () => _showAddCommentDialog(discussionThread),
        child: Icon(Icons.add, color: AppColor.brightGreen, size: 30),
      );
    } else {
      return FloatingActionButton.extended(
        backgroundColor: AppColor.darkBlue,
        onPressed: () => _showAddCommentDialog(discussionThread),
        label: Row(
          children: [
            Icon(Icons.add, color: AppColor.brightGreen, size: 30),
            SizedBox(width: 10),
            Text(
              'Add a comment',
              style: AppTextStyle.subhead.copyWith(color: AppColor.brightGreen),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildBody(
    DiscussionThread discussionThread,
    List<DiscussionThreadComment> discussionThreadComments,
  ) {
    final commentCount = _presenter.getCommentCount(discussionThreadComments);
    final discussionThreadCommentsUI = _presenter.getComments(discussionThreadComments);
    final isMobile = _presenter.isMobile(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          // Strict width defined by Rich
          width: isMobile ? MediaQuery.of(context).size.width : 712,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: isMobile ? AppColor.white : _kBackgroundColor,
                automaticallyImplyLeading: false,
                expandedHeight: 50,
                floating: true,
                snap: true,
                flexibleSpace: _buildSliverAppBarContent(discussionThread),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Column(
                      children: [
                        _buildDiscussionThreadCard(discussionThread),
                        SizedBox(height: 20),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 0),
                          child: Row(
                            key: _commentsSectionKey,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              JuntoText(
                                '$commentCount ${commentCount == 1 ? 'comment' : 'comments'}',
                                style: AppTextStyle.bodyMedium.copyWith(color: AppColor.gray2),
                              ),
                              if (commentCount != 0)
                                JuntoText(
                                  'Newest First', // Forced (mock) sorting
                                  style: AppTextStyle.bodyMedium.copyWith(color: AppColor.gray2),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        if (discussionThreadComments.isNotEmpty)
                          _buildCommentsSection(
                            discussionThread,
                            discussionThreadCommentsUI,
                          ),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBarContent(DiscussionThread discussionThread) {
    final isCreator = _presenter.isCreator(discussionThread);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            AppClickableWidget(
              child: JuntoImage(
                null,
                asset: AppAsset.kArrowBackPng,
                width: 30,
                height: 30,
              ),
              onTap: () => _goToThreadsPage(),
              tooltipMessage: 'Back',
            ),
            Spacer(),
            if (isCreator)
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Material(
                  color: Colors.transparent,
                  child: PopupMenuButton<DiscussionThreadOptionType>(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      onSelected: (value) {
                        switch (value) {
                          case DiscussionThreadOptionType.update:
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ManipulateDiscussionThreadPage(
                                  juntoProvider: context.read<JuntoProvider>(),
                                  discussionThread: discussionThread,
                                ),
                              ),
                            );
                            break;
                          case DiscussionThreadOptionType.delete:
                            _showDeleteThreadDialog();
                            break;
                        }
                      },
                      tooltip: 'Show Options',
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: JuntoImage(
                          null,
                          asset: AppAsset.kMorePng,
                          width: 30,
                          height: 30,
                        ),
                      ),
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                              value: DiscussionThreadOptionType.update,
                              child: Text(
                                'Update Post',
                                style: AppTextStyle.bodyMedium.copyWith(color: AppColor.darkBlue),
                              )),
                          PopupMenuItem(
                              value: DiscussionThreadOptionType.delete,
                              child: Text(
                                'Delete Post',
                                style: AppTextStyle.bodyMedium.copyWith(color: AppColor.darkBlue),
                              )),
                        ];
                      }),
                ),
              ),
          ],
        ),
      ],
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

  Widget _buildDiscussionThreadCard(DiscussionThread discussionThread) {
    final isMobile = _presenter.isMobile(context);
    final emotion = _presenter.getCurrentlySelectedEmotion(discussionThread.emotions);

    return DiscussionThreadCard(
      discussionThread: discussionThread,
      userService: context.watch<UserService>(),
      onLikeDislikeToggle: (likeType) async {
        await alertOnError(
          context,
          () => _presenter.toggleLikeDislike(likeType, discussionThread),
        );
      },
      onEmotionTypeSelect: (emotionType) async {
        await alertOnError(
          context,
          () => _presenter.updateDiscussionEmotion(emotionType, discussionThread),
        );
      },
      isMobile: isMobile,
      currentlySelectedDiscussionThreadEmotion: emotion,
    );
  }

  Widget _buildCommentsSection(
    DiscussionThread discussionThread,
    List<DiscussionThreadCommentUI> discussionThreadCommentsUI,
  ) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: discussionThreadCommentsUI.length,
      itemBuilder: (context, index) {
        final discussionThreadCommentUI = discussionThreadCommentsUI[index];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Container(
            color: AppColor.white,
            child: Column(
              children: [
                SizedBox(height: 20),
                DiscussionThreadCommentCard(
                  discussionThreadCommentUI: discussionThreadCommentUI,
                  userService: context.watch<UserService>(),
                  currentlySelectedEmotion: (discussionThreadComment) {
                    return _presenter.getCurrentlySelectedEmotion(discussionThreadComment.emotions);
                  },
                  onDeleteComment: (discussionThreadComment) async {
                    await alertOnError(
                      context,
                      () => _presenter.deleteComment(discussionThreadComment),
                    );
                  },
                  onEmotionTypeSelect: (emotionType, discussionThreadComment) async {
                    await guardSignedIn(
                      () => alertOnError(
                        context,
                        () => _presenter.updateDiscussionCommentEmotion(
                          emotionType: emotionType,
                          discussionThreadComment: discussionThreadComment,
                          discussionThreadId: discussionThread.id,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),
                _buildReplySection(
                  discussionThread.id,
                  discussionThreadCommentUI.parentComment.id,
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReplySection(String discussionThreadId, String parentCommentId) {
    final isMobile = _presenter.isMobile(context);

    return Container(
      padding: const EdgeInsets.only(left: 20),
      alignment: Alignment.centerLeft,
      child: AppClickableWidget(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            JuntoImage(
              null,
              asset: AppAsset.kChatBubble2Png,
              width: 20,
              height: 20,
            ),
            SizedBox(width: 10),
            Text(
              'Reply',
              style: AppTextStyle.bodyMedium.copyWith(color: AppColor.darkBlue),
            )
          ],
        ),
        onTap: () async {
          await guardSignedIn(() async {
            final comment = await Dialogs.showComposeMessageDialog(
              context,
              title: 'Add comment',
              isMobile: isMobile,
              labelText: 'Comment',
              validator: (text) => text == null || text.isEmpty ? 'Comment cannot be empty' : null,
              positiveButtonText: 'Add Comment',
            );

            if (comment != null) {
              await alertOnError(
                context,
                () => _presenter.addNewComment(
                  comment: comment,
                  discussionThreadId: discussionThreadId,
                  replyToCommentId: parentCommentId,
                ),
              );
            }
          });
        },
        isIcon: false,
      ),
    );
  }

  @override
  void scrollToComments() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      Scrollable.ensureVisible(
        _commentsSectionKey.currentContext!,
        duration: kTabScrollDuration,
      );
    });
  }
}
