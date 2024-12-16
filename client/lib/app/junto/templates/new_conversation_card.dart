import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:junto/app/junto/discussions/create_discussion/create_discussion_dialog.dart';
import 'package:junto/app/junto/templates/topic_page_provider.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/hosting_option.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/common_widgets/prerequisite_badge.dart';
import 'package:junto/services/junto_user_data_service.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto_models/analytics/analytics_entities.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/topic.dart';
import 'package:provider/provider.dart';
import 'package:simple_tooltip/simple_tooltip.dart';

class NewConversationCard extends StatefulWidget {
  final Topic topic;
  final bool hasAttendedPrerequisite;
  final void Function(DiscussionType)? onCreateEventTap;

  const NewConversationCard({
    required this.topic,
    required this.hasAttendedPrerequisite,
    this.onCreateEventTap,
    Key? key,
  }) : super(key: key);

  @override
  State<NewConversationCard> createState() => _NewConversationCardState();
}

class _NewConversationCardState extends State<NewConversationCard> {
  DiscussionType? _selectedHostingOption = DiscussionType.hosted;

  bool get isMod => Provider.of<JuntoUserDataService>(context)
      .getMembership(Provider.of<JuntoProvider>(context).juntoId)
      .isMod;

  @override
  Widget build(BuildContext context) {
    final showPrerequisiteBadge =
        !isMod && widget.topic.prerequisiteTopicId != null && !widget.hasAttendedPrerequisite;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColor.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleAndHelpIcon(),
            SizedBox(height: 10),
            if (isMod) ...[
              _buildHostingOption(),
              SizedBox(height: 10),
            ],
            if (showPrerequisiteBadge) PrerequisiteBadge() else _buildCreateEventButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleAndHelpIcon() {
    final isMobile = responsiveLayoutService.isMobile(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: JuntoText(
            'Create an event ${isMobile ? '' : '\n'}from this template',
            style: AppTextStyle.headline1.copyWith(
              fontSize: 18,
              color: AppColor.darkBlue,
            ),
          ),
        ),
        SizedBox(width: 10),
        _buildHelpTooltip(),
      ],
    );
  }

  Widget _buildHostingOption() => Center(
        child: HostingOption(
          isWhiteBackground: true,
          selectedDiscussionType: (discussionType) {
            setState(() {
              _selectedHostingOption = discussionType;
            });
          },
          isHostlessEnabled: JuntoProvider.watch(context).enableHostless,
          initialHostingOption: DiscussionType.hosted,
        ),
      );

  Widget _buildCreateEventButton() {
    final onTap = widget.onCreateEventTap;

    return Align(
      alignment: Alignment.centerRight,
      child: ActionButton(
        expand: !isMod,
        color: AppColor.darkBlue,
        onPressed: () {
          analytics.logEvent(AnalyticsPressCreateEventFromGuideEvent(
            juntoId: widget.topic.juntoId,
            guideId: widget.topic.id,
          ));
          if (onTap != null) {
            onTap(_selectedHostingOption ?? DiscussionType.hosted);
          } else {
            return CreateDiscussionDialog.show(
              context,
              discussionType: _selectedHostingOption ?? DiscussionType.hosted,
              topic: widget.topic,
            );
          }
        },
        text: 'Create event',
        textColor: AppColor.brightGreen,
      ),
    );
  }

  Widget _buildHelpTooltip() {
    final isMobile = responsiveLayoutService.isMobile(context);
    const helpDocLink =
        'https://rebootingsocialmedia.notion.site/Creating-and-Managing-Events-552a42e4a09549b788e1901536a25965';

    final topicPageProvider = context.watch<TopicPageProvider>();

    return SimpleTooltip(
      minWidth: 200,
      maxWidth: !isMobile ? 280 : null,
      arrowLength: 15,
      borderColor: AppColor.gray6,
      borderWidth: 1,
      ballonPadding: EdgeInsets.all(0),
      minimumOutSidePadding: 40,
      customShadows: const [BoxShadow(color: AppColor.gray3, blurRadius: 5, spreadRadius: 2)],
      animationDuration: Duration(milliseconds: 500),
      show: topicPageProvider.isHelpExpanded,
      tooltipDirection: isMobile ? TooltipDirection.horizontal : TooltipDirection.up,
      child: JuntoInkWell(
        onTap: () => topicPageProvider.isHelpExpanded = true,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColor.darkBlue,
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Icon(
              CupertinoIcons.question,
              size: 11,
              color: AppColor.darkBlue,
            ),
          ),
        ),
      ),
      content: Material(
        color: AppColor.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 16.0,
                  left: 20,
                  bottom: 20,
                ),
                child: RichText(
                  text: TextSpan(
                    text: 'Quickly create interactive events using templates. ',
                    style: AppTextStyle.body.copyWith(
                      color: AppColor.gray2,
                    ),
                    children: [
                      TextSpan(
                        text: 'Learn more',
                        recognizer: TapGestureRecognizer()..onTap = () => launch(helpDocLink),
                        style: AppTextStyle.body.copyWith(
                          color: AppColor.accentBlue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () => topicPageProvider.isHelpExpanded = false,
              icon: Icon(Icons.close),
            )
          ],
        ),
      ),
    );
  }
}
