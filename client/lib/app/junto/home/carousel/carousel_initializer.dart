import 'package:flutter/material.dart';
import 'package:junto/app/junto/home/carousel/junto_carousel.dart';
import 'package:junto/app/junto/home/junto_home_provider.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:junto_models/firestore/topic.dart';

/// Loads data required for the junto carousel, including featured items and the urls to the images
/// for those items.
class CarouselInitializer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: JuntoStreamBuilder<Junto>(
        entryFrom: 'carousel_creation.build_junto',
        stream: JuntoProvider.watch(context).juntoStream,
        builder: (context, junto) {
          return JuntoStreamBuilder<List<Topic>>(
            entryFrom: 'carousel_creation.build_topics',
            stream: JuntoHomeProvider.watch(context)!.featuredTopicsFuture.asStream(),
            builder: (context, topics) {
              return JuntoStreamBuilder<List<Discussion>>(
                entryFrom: 'carousel_creation.build_discussions',
                stream: JuntoHomeProvider.watch(context)!.featuredDiscussionsFuture.asStream(),
                builder: (context, discussions) {
                  return JuntoStreamBuilder<List<String>>(
                    entryFrom: 'carousel_creation.build_imageurls',
                    stream: JuntoHomeProvider.watch(context)!
                        .featuredDiscussionsImagesFuture
                        .asStream(),
                    builder: (context, images) {
                      if (junto == null) {
                        return Icon(Icons.error);
                      }
                      return JuntoCarousel(
                        featuredTopics: topics ?? [],
                        featuredDiscussions: discussions ?? [],
                        featuredDiscussionImages: images ?? [],
                        junto: junto,
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
