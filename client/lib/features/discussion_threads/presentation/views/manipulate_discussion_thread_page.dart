import 'package:client/core/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/action_button.dart';
import 'package:client/core/widgets/app_clickable_widget.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/features/user/presentation/widgets/user_profile_chip.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/utils/extensions.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/discussion_threads/discussion_thread.dart';
import 'package:client/core/localization/localization_helper.dart';

import 'manipulate_discussion_thread_contract.dart';
import '../../data/models/manipulate_discussion_thread_model.dart';
import '../manipulate_discussion_thread_presenter.dart';

/// Manipulates (Adds new OR Updates) [DiscussionThread] while user is using `mobile` device page.
class ManipulateDiscussionThreadPage extends StatefulWidget {
  final CommunityProvider communityProvider;
  final DiscussionThread? discussionThread;

  const ManipulateDiscussionThreadPage({
    Key? key,
    required this.communityProvider,
    this.discussionThread,
  }) : super(key: key);

  @override
  _ManipulateDiscussionThreadPageState createState() =>
      _ManipulateDiscussionThreadPageState();
}

class _ManipulateDiscussionThreadPageState
    extends State<ManipulateDiscussionThreadPage>
    implements ManipulateDiscussionThreadView {
  final FocusNode _focusNode = FocusNode();
  late final TextEditingController _textEditingController;
  late final ManipulateDiscussionThreadModel _model;
  late final ManipulateDiscussionThreadPresenter _presenter;

  @override
  void initState() {
    super.initState();
    _model = ManipulateDiscussionThreadModel(
      widget.communityProvider,
      widget.discussionThread,
    );
    _presenter = ManipulateDiscussionThreadPresenter(context, this, _model);
    _presenter.init();

    _textEditingController = TextEditingController(text: _model.content);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = _presenter.isMobile(context);

    return Scaffold(
      backgroundColor: isMobile ? AppColor.white : AppColor.gray6,
      body: _buildBody(isMobile),
    );
  }

  @override
  void showMessage(String message, {ToastType toastType = ToastType.neutral}) {
    showRegularToast(context, message, toastType: toastType);
  }

  @override
  void updateView() {
    setState(() {});
  }

  Widget _buildBody(bool isMobile) {
    if (isMobile) {
      return _buildChild(isMobile);
    } else {
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: 20,
          horizontal: MediaQuery.of(context).size.width / 4,
        ),
        child: _buildChild(isMobile),
      );
    }
  }

  Widget _buildChild(bool isMobile) {
    const horizontalPadding = 20.0;
    final userId = _presenter.getUserId();
    final positiveButtonText = _presenter.getPositiveButtonText();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColor.white,
      ),
      child: Column(
        children: [
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Row(
              children: [
                UserProfileChip(userId: userId, showName: false),
                Spacer(),
                AppClickableWidget(
                  child: ProxiedImage(
                    null,
                    asset: AppAsset.kXPng,
                    width: 30,
                    height: 30,
                  ),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                SizedBox(height: 20),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 400),
                  child: _buildImage(),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: CustomTextField(
                          autofocus: true,
                          focusNode: _focusNode,
                          controller: _textEditingController,
                          hintText: context.l10n.typeSomething,
                          onChanged: (input) => _presenter.updateContent(input),
                          maxLines: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: AppClickableWidget(
                    onTap: () => _presenter.pickImage(),
                    isIcon: false,
                    child: Row(
                      children: [
                        Icon(Icons.attach_file_rounded),
                        SizedBox(width: 10),
                        HeightConstrainedText(
                          'Image',
                          style: AppTextStyle.bodyMedium
                              .copyWith(color: AppColor.darkBlue),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 10,
              horizontal: horizontalPadding,
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: EmotionType.values.length,
                      itemBuilder: (context, index) {
                        final emotionType = EmotionType.values[index];

                        return AppClickableWidget(
                          child: ProxiedImage(
                            null,
                            asset: emotionType.imageAssetPath,
                            width: 24,
                            height: 24,
                          ),
                          onTap: () => _presenter.addEmojiToContent(
                            emotionType,
                            _textEditingController.selection.baseOffset,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ActionButton(
                  text: positiveButtonText,
                  onPressed: () async {
                    await alertOnError(context, () async {
                      final bool isSuccess;
                      if (_model.existingDiscussionThread != null) {
                        isSuccess = await _presenter.updateDiscussionThread();
                      } else {
                        isSuccess = await _presenter.addNewDiscussionThread();
                      }

                      if (isSuccess) {
                        Navigator.pop(context);
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void updateTextEditingController() {
    _textEditingController.value = _textEditingController.value.copyWith(
      text: _model.content,
      selection: TextSelection.collapsed(offset: _model.content.length),
    );
  }

  Widget _buildImage() {
    final uploadedImageUrl = _model.existingDiscussionThread?.imageUrl;
    final pickedImageUrl = _model.pickedImageUrl;

    final imageUrl = pickedImageUrl ?? uploadedImageUrl;
    if (imageUrl == null) {
      return SizedBox.shrink();
    }

    return ProxiedImage(imageUrl, width: double.maxFinite, fit: BoxFit.cover);
  }

  @override
  void requestTextFocus() {
    _focusNode.requestFocus();
  }
}
