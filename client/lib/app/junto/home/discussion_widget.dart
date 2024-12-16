import 'package:flutter/material.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/discussion_picture.dart';
import 'package:junto/app/junto/home/carousel/time_indicator.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/common_widgets/discussion_participants_list.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/routing/locations.dart';
import 'package:junto/services/junto_user_data_service.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:provider/provider.dart';

/// This is the card for the upcoming discussions shown on the Frankly Home page.
///
/// Tapping on it navigates to the discussion page.
class DiscussionWidget extends StatelessWidget {
  final Discussion discussion;

  const DiscussionWidget(
    this.discussion, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ChangeNotifierProvider(
        create: (context) => DiscussionProvider(
          juntoProvider: context.read<JuntoProvider>(),
          topicId: discussion.topicId,
          discussionId: discussion.id,
        )..initialize(),
        child: Builder(
          builder: (context) {
            final discussionProvider = DiscussionProvider.watch(context);
            return JuntoStreamBuilder<bool>(
                entryFrom: 'discussion_widget.build_discussion',
                stream: discussionProvider.hasParticipantAttendedPrerequisiteFuture.asStream(),
                builder: (_, __) {
                  return JuntoStreamBuilder<Discussion>(
                    entryFrom: 'discussion_widget.build_discussion',
                    stream: discussionProvider.discussionStream,
                    builder: (context, _) {
                      final isAdmin = Provider.of<JuntoUserDataService>(context)
                          .getMembership(Provider.of<JuntoProvider>(context).juntoId)
                          .isAdmin;

                      final hasPrerequisiteTopic =
                          discussionProvider.discussion.prerequisiteTopicId != null;

                      final isDisabled = hasPrerequisiteTopic &&
                          !discussionProvider.hasAttendedPrerequisite &&
                          !isAdmin;
                      return MergeSemantics(
                        child: JuntoInkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: isDisabled
                              ? null
                              : () => routerDelegate.beamTo(
                                    JuntoPageRoutes(
                                      juntoDisplayId:
                                          JuntoProvider.readOrNull(context)?.displayId ??
                                              discussion.juntoId,
                                    ).discussionPage(
                                      topicId: discussion.topicId,
                                      discussionId: discussion.id,
                                    ),
                                  ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: isDisabled ? AppColor.white.withOpacity(0.8) : AppColor.white,
                              boxShadow: [
                                if (!isDisabled) AppDecoration.lightBoxShadow,
                              ],
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: _buildCardContent(context: context, isDisabled: isDisabled),
                          ),
                        ),
                      );
                    },
                  );
                });
          },
        ),
      ),
    );
  }

  Widget _buildCardContent({required BuildContext context, required bool isDisabled}) => Row(
        children: [
          if (discussion.scheduledTime != null)
            VerticalTimeAndDateIndicator(
              shadow: false,
              isDisabled: isDisabled,
              time: DateTime.fromMillisecondsSinceEpoch(
                  (discussion.scheduledTime?.millisecondsSinceEpoch ?? 0)),
            )
          else
            SizedBox(width: 100),
          Stack(
            children: [
              Container(
                width: 90,
                height: 90,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                child: DiscussionOrTopicPicture(
                  key: Key(discussion.id),
                  discussion: discussion,
                  height: 100,
                ),
              ),
              if (isDisabled)
                Container(
                  width: 90,
                  height: 90,
                  color: Colors.white.withOpacity(0.5),
                ),
            ],
          ),
          Expanded(
            child: _buildCardText(isDisabled),
          )
        ],
      );

  Widget _buildCardText(bool disabled) => Padding(
        padding: const EdgeInsets.all(12),
        child: _buildCardTextContent(disabled),
      );

  Widget _buildCardTextContent(bool isDisabled) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          JuntoText(
            discussion.title ?? 'Scheduled event',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.headline4.copyWith(
              color: isDisabled ? AppColor.darkBlue.withOpacity(0.5) : AppColor.darkBlue,
            ),
          ),
          SizedBox(height: 20.0),
          if (isDisabled)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: AppColor.pink,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColor.redLightMode,
                    child: Icon(Icons.school_outlined, size: 20, color: AppColor.white),
                  ),
                  SizedBox(width: 10),
                  JuntoText(
                    'Prerequisite',
                    style: AppTextStyle.eyebrowSmall.copyWith(color: AppColor.redLightMode),
                  ),
                ],
              ),
            )
          else ...[
            if (discussion.isLiveStream)
              JuntoText(
                'Livestream',
                style: AppTextStyle.bodySmall.copyWith(
                  color: AppColor.gray3,
                ),
              ),
            DiscussionPageParticipantsList(
              discussion,
              iconSize: 30,
              showFullParticipantCount: true,
            ),
          ]
        ],
      );
}
