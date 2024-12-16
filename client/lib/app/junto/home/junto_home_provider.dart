import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/services/firestore/firestore_utils.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:junto_models/firestore/topic.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

const lrcJuntoIds = ['living-room-convos-dev', '53FXvTKVnJlUPInVgDzd'];

class JuntoHomeProvider with ChangeNotifier {
  final JuntoProvider juntoProvider;

  JuntoHomeProvider({required this.juntoProvider});

  late BehaviorSubjectWrapper<List<Discussion>> _upcomingDiscussions;

  late Future<List<Discussion>> _featuredDiscussionsFuture;
  late Future<List<Topic>> _featuredTopicsFuture;
  late Future<List<String>> _featuredDiscussionsImagesFuture;
  late BehaviorSubject<List<Topic>> _topicsStream;

  Future<List<Discussion>> get featuredDiscussionsFuture => _featuredDiscussionsFuture;

  Future<List<String>> get featuredDiscussionsImagesFuture => _featuredDiscussionsImagesFuture;

  Future<List<Topic>> get featuredTopicsFuture => _featuredTopicsFuture;

  Stream<List<Discussion>> get discussionsStream => _upcomingDiscussions.stream;

  Stream<List<Topic>> get topicsStream => _topicsStream;

  void initialize() {
    _upcomingDiscussions = firestoreDiscussionService.futurePublicDiscussionsForJunto(
      juntoId: juntoProvider.juntoId,
    );

    _topicsStream = wrapInBehaviorSubject(
        firestoreDatabase.juntoTopicsStream(juntoProvider.junto.id).map((topics) => topics
          ..sort((a, b) {
            final aPriority = a.orderingPriority;
            final bPriority = b.orderingPriority;

            if (bPriority == null) {
              return -1;
            } else if (aPriority == null) {
              return 1;
            }
            return aPriority.compareTo(bPriority);
          }))).stream;

    _featuredTopicsFuture = _getFeaturedTopicsFuture(allTopicsFuture: _topicsStream.first);
    _featuredDiscussionsFuture = _getFeaturedDiscussionsFuture();
    _featuredDiscussionsImagesFuture = _loadDiscussionImages(_featuredDiscussionsFuture);
  }

  Future<List<Discussion>> _getFeaturedDiscussionsFuture() async {
    await juntoProvider.featuredStream.first;

    final featuredDiscussions = juntoProvider.featuredItems
        .where((element) => element.featuredType == FeaturedType.conversation)
        .toList();

    return firestoreDiscussionService.getDiscussionsFromPaths(
        juntoProvider.juntoId, featuredDiscussions.map((e) => e.documentPath!).toList());
  }

  Future<List<Topic>> _getFeaturedTopicsFuture({
    required Future<List<Topic>> allTopicsFuture,
  }) async {
    await juntoProvider.featuredStream.first;

    final featuredTopics =
        juntoProvider.featuredItems.where((element) => element.featuredType == FeaturedType.topic);

    final allTopics = await allTopicsFuture;
    final allTopicsLookup = <String, Topic>{
      for (final topic in allTopics) topic.id: topic
    };

    final topics =
        featuredTopics.map((t) => allTopicsLookup[t.documentPath!.split('/').last]).toList();

    return <Topic>[
      for (final topic in topics)
        if (topic != null) topic
    ];
  }

  Future<List<String>> _loadDiscussionImages(Future<List<Discussion>> discussionsFuture) async {
    final discussions = await discussionsFuture;
    final images = await Future.wait(
      discussions.map(
        (discussion) async {
          final String? image;
          if (!isNullOrEmpty(discussion.image)) {
            image = discussion.image;
          } else {
            final topic = await firestoreDatabase.juntoTopic(
              juntoId: discussion.juntoId,
              topicId: discussion.topicId,
            );
            image = topic.image;
          }

          return image ?? generateRandomImageUrl(seed: discussion.id.hashCode);
        },
      ),
    );

    return <String>[
      for (final image in images) image,
    ];
  }

  @override
  void dispose() {
    _upcomingDiscussions.dispose();
    _topicsStream.close();
    super.dispose();
  }

  static JuntoHomeProvider? watch(BuildContext context) =>
      providerOrNull(() => Provider.of<JuntoHomeProvider>(context));

  static JuntoHomeProvider? read(BuildContext context) =>
      providerOrNull(() => Provider.of<JuntoHomeProvider>(context, listen: false));
}
