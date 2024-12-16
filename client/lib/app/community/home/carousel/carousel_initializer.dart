import 'package:flutter/material.dart';
import 'package:client/app/community/home/carousel/community_carousel.dart';
import 'package:client/app/community/home/community_home_provider.dart';
import 'package:client/app/community/community_provider.dart';
import 'package:client/common_widgets/custom_stream_builder.dart';
import 'package:data_models/firestore/event.dart';
import 'package:data_models/firestore/community.dart';
import 'package:data_models/firestore/template.dart';

/// Loads data required for the community carousel, including featured items and the urls to the images
/// for those items.
class CarouselInitializer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomStreamBuilder<Community>(
        entryFrom: 'carousel_creation.build_community',
        stream: CommunityProvider.watch(context).communityStream,
        builder: (context, community) {
          return CustomStreamBuilder<List<Template>>(
            entryFrom: 'carousel_creation.build_templates',
            stream: CommunityHomeProvider.watch(context)!
                .featuredTemplatesFuture
                .asStream(),
            builder: (context, templates) {
              return CustomStreamBuilder<List<Event>>(
                entryFrom: 'carousel_creation.build_events',
                stream: CommunityHomeProvider.watch(context)!
                    .featuredEventsFuture
                    .asStream(),
                builder: (context, events) {
                  return CustomStreamBuilder<List<String>>(
                    entryFrom: 'carousel_creation.build_imageurls',
                    stream: CommunityHomeProvider.watch(context)!
                        .featuredEventsImagesFuture
                        .asStream(),
                    builder: (context, images) {
                      if (community == null) {
                        return Icon(Icons.error);
                      }
                      return CommunityCarousel(
                        featuredTemplates: templates ?? [],
                        featuredEvents: events ?? [],
                        featuredEventImages: images ?? [],
                        community: community,
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
