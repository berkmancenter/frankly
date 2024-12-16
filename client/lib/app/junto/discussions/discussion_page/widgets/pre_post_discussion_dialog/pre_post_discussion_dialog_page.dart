import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/common_widgets/user_admin_details_builder.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/dialog_provider.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/pre_post_card.dart';
import 'package:junto_models/firestore/pre_post_url_params.dart';

import 'pre_post_discussion_dialog_contract.dart';
import 'pre_post_discussion_dialog_model.dart';
import 'pre_post_discussion_dialog_presenter.dart';

class PrePostDiscussionDialogPage extends StatefulWidget {
  final PrePostCard prePostCard;
  final Discussion discussion;
  final bool isMeetingOfAmerica;

  const PrePostDiscussionDialogPage._({
    Key? key,
    required this.prePostCard,
    required this.discussion,
    required this.isMeetingOfAmerica,
  }) : super(key: key);

  static Future<void> show({
    required PrePostCard prePostCardData,
    required Discussion discussion,
    bool isMeetingOfAmerica = false,
  }) async {
    await showJuntoDialog(builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColor.darkBlue,
        child: PrePostDiscussionDialogPage._(
          prePostCard: prePostCardData,
          discussion: discussion,
          isMeetingOfAmerica: isMeetingOfAmerica,
        ),
      );
    });
  }

  @override
  _PrePostDiscussionDialogPageState createState() => _PrePostDiscussionDialogPageState();
}

class _PrePostDiscussionDialogPageState extends State<PrePostDiscussionDialogPage>
    implements PrePostDiscussionDialogView {
  late final PrePostDiscussionDialogModel _model;
  late final PrePostDiscussionDialogPresenter _presenter;

  @override
  void initState() {
    super.initState();
    _model = PrePostDiscussionDialogModel(widget.prePostCard, widget.discussion);
    _presenter = PrePostDiscussionDialogPresenter(_model,
        userAdminDetailsProvider: UserAdminDetailsProvider.forUser(userService.currentUserId!))
      ..initialize();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = _presenter.isMobile(context);
    final overallPaddingSize = _presenter.getSize(context, 40, scale: 0.5);
    final iconPaddingSize = _presenter.getSize(context, 0);
    final iconSize = _presenter.getSize(context, 32);
    final maxWidth = _presenter.getSize(context, 700);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Padding(
        padding: EdgeInsets.all(overallPaddingSize),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                JuntoInkWell(
                  onTap: () => Navigator.pop(context),
                  boxShape: BoxShape.circle,
                  child: Padding(
                    padding: EdgeInsets.all(iconPaddingSize),
                    child: Icon(
                      Icons.close,
                      size: iconSize,
                      color: AppColor.white,
                    ),
                  ),
                )
              ],
            ),
            JuntoText(
              _model.prePostCard.headline,
              style: AppTextStyle.headline1.copyWith(color: AppColor.white),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 10),
            JuntoText(
              _model.prePostCard.message,
              style: AppTextStyle.subhead.copyWith(color: AppColor.white),
              maxLines: 8,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 10),
            _buildBottomSection(isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection(bool isMobile) {
    final hasUrls = _model.prePostCard.prePostUrls.isNotEmpty;
    if (isMobile) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (hasUrls) ...[
              for (int i = 0; i < _model.prePostCard.prePostUrls.length; i++) ...[
                SizedBox(height: 8),
                _buildSurveyButtonWidget(_model.prePostCard.prePostUrls[i]),
              ],
              SizedBox(height: 8),
              _buildNotNowWidget(),
            ] else
              _buildNextButton(),
          ],
        ),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (hasUrls) ...[
            _buildNotNowWidget(),
            SizedBox(width: 30),
            Wrap(
              runSpacing: 8,
              spacing: 8,
              children: [
                for (final url in _model.prePostCard.prePostUrls) _buildSurveyButtonWidget(url),
              ],
            ),
          ] else ...[
            SizedBox.shrink(),
            _buildNextButton(),
          ],
        ],
      );
    }
  }

  Widget _buildNotNowWidget() {
    return ActionButton(
      type: ActionButtonType.outline,
      text: widget.isMeetingOfAmerica ? 'No' : 'Next',
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildSurveyButtonWidget(PrePostUrlParams urlParams) {
    final buttonText = urlParams.buttonText;
    final buttonTextNotEmpty = buttonText != null && buttonText.isNotEmpty;
    return ActionButton(
      color: AppColor.darkerBlue,
      type: ActionButtonType.outline,
      borderSide: BorderSide(color: AppColor.brightGreen, width: 1),
      textColor: AppColor.brightGreen,
      text: buttonTextNotEmpty ? buttonText : 'Open Link',
      onPressed: () => alertOnError(context, () => _presenter.launchSurvey(urlParams)),
    );
  }

  Widget _buildNextButton() {
    return ActionButton(
      onPressed: () => Navigator.pop(context),
      text: 'Next',
    );
  }
}
