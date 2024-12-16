import 'package:flutter/material.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/common_widgets/junto_image.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/routing/locations.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto_models/firestore/topic.dart';
import 'package:provider/provider.dart';

class AdditionalTopicsCard extends StatelessWidget {
  const AdditionalTopicsCard({
    Key? key,
    required this.context,
    required this.topics,
    required this.numShown,
  }) : super(key: key);

  final BuildContext context;
  final List<Topic> topics;
  final int numShown;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: JuntoInkWell(
        onTap: () => routerDelegate.beamTo(
          JuntoPageRoutes(
            juntoDisplayId: Provider.of<JuntoProvider>(context, listen: false).displayId,
          ).browseTopicsPage,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
              child: JuntoImage(topics[numShown].image),
              clipBehavior: Clip.hardEdge,
            ),
            Container(
              width: 90,
              height: 90,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color(0x44000000),
              ),
            ),
            JuntoText(
              '+${topics.length - numShown}',
              style: AppTextStyle.body.copyWith(color: AppColor.white, fontSize: 22),
            )
          ],
        ),
      ),
    );
  }
}

class TopicCard extends StatelessWidget {
  const TopicCard({
    Key? key,
    required this.context,
    required this.topic,
  }) : super(key: key);

  final BuildContext context;
  final Topic topic;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          JuntoInkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => routerDelegate.beamTo(
              JuntoPageRoutes(
                juntoDisplayId: Provider.of<JuntoProvider>(context, listen: false).displayId,
              ).topicPage(topicId: topic.id),
            ),
            child: Tooltip(
              message: topic.title ?? 'Event Template',
              child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                clipBehavior: Clip.hardEdge,
                child: JuntoImage(topic.image, height: 90, width: 90),
              ),
            ),
          ),
          SizedBox(
            width: 90,
            child: JuntoText(
              topic.title ?? '',
              style: AppTextStyle.body.copyWith(fontSize: 14, color: AppColor.gray1),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
