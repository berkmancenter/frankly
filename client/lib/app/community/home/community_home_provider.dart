import 'dart:async';

import 'package:flutter/material.dart';
import 'package:client/app/community/community_provider.dart';
import 'package:client/app/community/utils.dart';
import 'package:client/services/firestore/firestore_utils.dart';
import 'package:client/services/services.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/templates/template.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class CommunityHomeProvider with ChangeNotifier {
  final CommunityProvider communityProvider;

  CommunityHomeProvider({required this.communityProvider});

  late BehaviorSubjectWrapper<List<Event>> _upcomingEvents;

  late Future<List<Event>> _featuredEventsFuture;
  late Future<List<Template>> _featuredTemplatesFuture;
  late Future<List<String>> _featuredEventsImagesFuture;
  late BehaviorSubject<List<Template>> _templatesStream;

  Future<List<Event>> get featuredEventsFuture => _featuredEventsFuture;

  Future<List<String>> get featuredEventsImagesFuture =>
      _featuredEventsImagesFuture;

  Future<List<Template>> get featuredTemplatesFuture =>
      _featuredTemplatesFuture;

  Stream<List<Event>> get eventsStream => _upcomingEvents.stream;

  Stream<List<Template>> get templatesStream => _templatesStream;

  void initialize() {
    _upcomingEvents = firestoreEventService.futurePublicEventsForCommunity(
      communityId: communityProvider.communityId,
    );

    _templatesStream = wrapInBehaviorSubject(
      firestoreDatabase
          .communityTemplatesStream(communityProvider.community.id)
          .map(
            (templates) => templates
              ..sort((a, b) {
                final aPriority = a.orderingPriority;
                final bPriority = b.orderingPriority;

                if (bPriority == null) {
                  return -1;
                } else if (aPriority == null) {
                  return 1;
                }
                return aPriority.compareTo(bPriority);
              }),
          ),
    ).stream;

    _featuredTemplatesFuture =
        _getFeaturedTemplatesFuture(allTemplatesFuture: _templatesStream.first);
    _featuredEventsFuture = _getFeaturedEventsFuture();
    _featuredEventsImagesFuture = _loadEventImages(_featuredEventsFuture);
  }

  Future<List<Event>> _getFeaturedEventsFuture() async {
    await communityProvider.featuredStream.first;

    final featuredEvents = communityProvider.featuredItems
        .where((element) => element.featuredType == FeaturedType.event)
        .toList();

    return firestoreEventService.getEventsFromPaths(
      communityProvider.communityId,
      featuredEvents.map((e) => e.documentPath!).toList(),
    );
  }

  Future<List<Template>> _getFeaturedTemplatesFuture({
    required Future<List<Template>> allTemplatesFuture,
  }) async {
    await communityProvider.featuredStream.first;

    final featuredTemplates = communityProvider.featuredItems
        .where((element) => element.featuredType == FeaturedType.template);

    final allTemplates = await allTemplatesFuture;
    final allTemplatesLookup = <String, Template>{
      for (final template in allTemplates) template.id: template,
    };

    final templates = featuredTemplates
        .map((t) => allTemplatesLookup[t.documentPath!.split('/').last])
        .toList();

    return <Template>[
      for (final template in templates)
        if (template != null) template,
    ];
  }

  Future<List<String>> _loadEventImages(
    Future<List<Event>> eventsFuture,
  ) async {
    final events = await eventsFuture;
    final images = await Future.wait(
      events.map(
        (event) async {
          final String? image;
          if (!isNullOrEmpty(event.image)) {
            image = event.image;
          } else {
            final template = await firestoreDatabase.communityTemplate(
              communityId: event.communityId,
              templateId: event.templateId,
            );
            image = template.image;
          }

          return image ?? generateRandomImageUrl(seed: event.id.hashCode);
        },
      ),
    );

    return <String>[
      for (final image in images) image,
    ];
  }

  @override
  void dispose() {
    _upcomingEvents.dispose();
    _templatesStream.close();
    super.dispose();
  }

  static CommunityHomeProvider? watch(BuildContext context) =>
      providerOrNull(() => Provider.of<CommunityHomeProvider>(context));

  static CommunityHomeProvider? read(BuildContext context) => providerOrNull(
        () => Provider.of<CommunityHomeProvider>(context, listen: false),
      );
}
