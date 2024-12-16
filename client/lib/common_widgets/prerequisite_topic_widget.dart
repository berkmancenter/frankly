import 'package:flutter/material.dart';
import 'package:junto/app/junto/discussions/discussion_page/topic_provider.dart';
import 'package:junto/common_widgets/junto_image.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/routing/locations.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto_models/firestore/topic.dart';
import 'package:provider/provider.dart';

/// This is a Widget that displays event Prerequisite topic
class PrerequisiteTopicWidget extends StatelessWidget {
  final String prerequisiteTopicId;
  final String juntoId;

  const PrerequisiteTopicWidget({
    Key? key,
    required this.prerequisiteTopicId,
    required this.juntoId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        JuntoText(
          'Attend this first:',
          style: AppTextStyle.headline4.copyWith(
            color: AppColor.darkBlue,
          ),
        ),
        SizedBox(height: 10),
        ChangeNotifierProvider<TopicProvider>(
          key: Key(prerequisiteTopicId),
          create: (_) => TopicProvider(
            juntoId: juntoId,
            topicId: prerequisiteTopicId,
          )..initialize(),
          builder: (context, __) {
            return JuntoStreamBuilder<Topic>(
              entryFrom: '_PrerequisiteTopicWidget.build',
              stream: Provider.of<TopicProvider>(context).topicFuture.asStream(),
              builder: (_, topic) => JuntoInkWell(
                onTap: () => routerDelegate.beamTo(
                  JuntoPageRoutes(
                    juntoDisplayId: juntoId,
                  ).topicPage(topicId: prerequisiteTopicId),
                ),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      border: Border.all(color: AppColor.gray3),
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      JuntoImage(
                        topic?.image,
                        width: 70,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            JuntoText(
                              topic?.title ?? '',
                              style: AppTextStyle.headline4.copyWith(
                                color: AppColor.gray1,
                              ),
                            ),
                            JuntoText('Find an event with this template.')
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
