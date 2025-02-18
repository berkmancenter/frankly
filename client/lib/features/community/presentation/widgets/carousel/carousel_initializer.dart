import 'package:flutter/material.dart';
import 'package:client/features/community/presentation/widgets/carousel/community_carousel.dart';
import 'package:client/features/community/data/providers/community_home_provider.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/templates/template.dart';

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
