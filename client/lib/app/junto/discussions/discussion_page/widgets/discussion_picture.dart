import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:junto/app/junto/discussions/discussion_page/topic_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/editable_image.dart';
import 'package:junto/common_widgets/junto_image.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/topic.dart';

class DiscussionOrTopicPicture extends HookWidget {
  final Discussion? discussion;
  final Topic? topic;
  final Function(String)? onEdit;
  final double? height;

  const DiscussionOrTopicPicture({
    Key? key,
    this.discussion,
    this.topic,
    this.onEdit,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localDiscussion = discussion;
    final localTopic = topic;
    final discussionImage = localDiscussion?.image;
    final topicImage = localTopic?.image;

    final Future<String?> imageFuture = useMemoized(() async {
      if (discussionImage != null && discussionImage.isNotEmpty) {
        return discussionImage;
      } else if (topicImage != null && topicImage.isNotEmpty) {
        return topicImage;
      } else if (localDiscussion?.topicId == defaultInstantMeetingTopicId) {
        return defaultInstantMeetingTopic.image!;
      } else if (localDiscussion != null) {
        final topicData = await firestoreDatabase.juntoTopic(
          juntoId: localDiscussion.juntoId,
          topicId: localDiscussion.topicId,
        );
        return topicData.image;
      }
    });

    return SizedBox(
      width: height,
      height: height,
      child: Container(
        alignment: Alignment.center,
        child: FutureBuilder<String?>(
          future: imageFuture,
          builder: (_, snapshot) => snapshot.connectionState == ConnectionState.waiting
              ? JuntoLoadingIndicator(
                  color: Theme.of(context).colorScheme.secondary,
                )
              : EditableImage(
                  initialUrl: snapshot.data ?? '',
                  allowEdit: onEdit != null,
                  onImageSelect: onEdit,
                  borderRadius: BorderRadius.circular(20),
                  child: JuntoImage(
                    snapshot.data ?? '',
                    height: height,
                    borderRadius: BorderRadius.circular(20),
                    width: height,
                  ),
                ),
        ),
      ),
    );
  }
}
