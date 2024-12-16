import 'dart:async';

import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/foundation.dart';
import 'package:junto/app/junto/discussions/discussion_page/topic_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/visible_exception.dart';
import 'package:junto/services/firestore/firestore_utils.dart';
import 'package:junto/services/services.dart';
import 'package:junto/utils/extensions.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:junto_models/firestore/topic.dart';
import 'package:junto_models/utils.dart';

class FirestoreNotFoundException implements Exception {}

/// Class for firestore interactions. This is mainly creating, reading, and
/// querying our different model types.
///
/// Functions for new model types should be placed in a file in this directory
/// specific for that model type.
///
/// See firestore_discussion_service.dart for an example.
class FirestoreDatabase {
  static const String juntoCollectionName = 'junto';
  static const String topicsCollectionName = 'topics';

  static bool usingEmulator = false;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _juntoCollection =>
      firestore.collection(juntoCollectionName);

  DocumentReference<Map<String, dynamic>> juntoRef(String id) =>
      firestore.doc('$juntoCollectionName/$id');

  CollectionReference<Map<String, dynamic>> topicsCollection(String juntoId) =>
      firestore.collection('$juntoCollectionName/$juntoId/$topicsCollectionName');

  DocumentReference<Map<String, dynamic>> topicReference({
    required String juntoId,
    required String topicId,
  }) {
    return topicsCollection(juntoId).doc(topicId);
  }

  String generateNewDocId({required String collectionPath}) {
    return firestore.collection(collectionPath).doc().id;
  }

  Future<List<Junto>> allPublicJuntos() async {
    final snapshot = await _juntoCollection.where('isPublic', isEqualTo: true).get();
    return _convertJuntoListAsync(snapshot.docs);
  }

  Stream<List<Junto>> featuredCommunities() {
    return _juntoCollection
        .where('${Junto.kFieldCommunitySettings}.${CommunitySettings.kFieldFeatureOnKazmHome}',
            isEqualTo: true)
        .snapshots()
        .asyncMap((event) => _convertJuntoListAsync(event.docs));
  }

  Future<Junto?> getJunto(String id) async {
    final snapshot = await _juntoCollection.doc(id).get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null || data.isEmpty) {
      return null;
    }
    return _convertJunto(snapshot.data()!);
  }

  Future<List<Junto?>> getJuntoDocuments(List<String> juntoIds) async {
    final juntoFutures = <Future<Junto?>>[];
    for (final id in juntoIds) {
      final juntoDoc = await juntoRef(id).snapshots().firstOrNull;
      if (juntoDoc != null) {
        juntoFutures.add(_convertJuntoAsync(juntoDoc));
      }
    }
    return Future.wait(juntoFutures);
  }

  Stream<List<Junto>> juntosUserIsOwnerOf(String userId) {
    return _juntoCollection
        .where('creatorId', isEqualTo: userId)
        .snapshots()
        .asyncMap((s) => Future.wait(s.docs.map((e) => _convertJuntoAsync(e))))
        .map((e) => e.withoutNulls.toList());
  }

  String generateNewJuntoId() => _juntoCollection.doc().id;

  BehaviorSubjectWrapper<Junto> juntoStream(String displayId) => wrapInBehaviorSubject(firestore
          .collection(juntoCollectionName)
          .where('displayIds', arrayContains: displayId)
          .snapshots()
          .map((s) => s.docs)
          .asyncMap((docs) async {
        if (docs.isEmpty) throw FirestoreNotFoundException();

        final junto = await _convertJuntoAsync(docs.first);
        if (junto == null) throw FirestoreNotFoundException();

        return junto;
      }));

  Future<List<Topic>> allJuntoTopics(String juntoId, {bool includeRemovedTopics = true}) async {
    final collection = topicsCollection(juntoId);

    final QuerySnapshot<Map<String, dynamic>> querySnapshot;

    if (includeRemovedTopics) {
      querySnapshot = await collection.get();
    } else {
      querySnapshot = await collection
          .where('status', isNotEqualTo: EnumToString.convertToString(TopicStatus.removed))
          .get();
    }

    return _convertTopicListAsync(collection.path, querySnapshot.docs);
  }

  Stream<bool> juntoHasTopicsStream(String juntoId) {
    final collection = topicsCollection(juntoId);

    return collection
        .where('status', isNotEqualTo: EnumToString.convertToString(TopicStatus.removed))
        .limit(1)
        .snapshots()
        .map((event) => event.docs.isEmpty ? false : true);
  }

  Stream<List<Topic>> juntoTopicsStream(String juntoId) {
    final collection = topicsCollection(juntoId);

    return collection
        .snapshots()
        .asyncMap((snapshot) => _convertTopicListAsync(collection.path, snapshot.docs))
        // Some legacy topics have status == null so we use notEqualsTo
        .map((t) => t.where((t) => t.status != TopicStatus.removed).toList());
  }

  Future<Topic?> getTopic(String juntoId, String topicId) async {
    final collection = topicsCollection(juntoId);

    final snapshot = await collection.doc(topicId).get();
    final data = snapshot.data();

    if (!snapshot.exists || data == null || data.isEmpty) {
      return null;
    }

    return _convertTopic(snapshot.data()!);
  }

  Future<Topic> juntoTopic({
    required String juntoId,
    required String topicId,
  }) async {
    // Bit of a hack to fix situations where discussions are in topic collections that don't
    // actually exist. This can happen for instant meetings or if the user "skips" topic selection
    // when creating a meeting.
    if (topicId == defaultInstantMeetingTopicId) {
      return defaultInstantMeetingTopic;
    } else if (topicId == defaultTopicId) {
      return defaultTopic;
    }

    final documentReference = topicReference(
      juntoId: juntoId,
      topicId: topicId,
    );

    final snapshot = await documentReference.get();
    if (!snapshot.exists) {
      throw Exception('Topic $topicId not found.');
    }

    return _convertTopicAsync(documentReference.parent.path, snapshot);
  }

  Stream<Topic?> topicStream({
    required String juntoId,
    required String topicId,
  }) {
    if (topicId == defaultInstantMeetingTopicId) {
      return Stream.value(defaultInstantMeetingTopic);
    } else if (topicId == defaultTopicId) {
      return Stream.value(defaultTopic);
    }

    final documentReference = topicReference(
      juntoId: juntoId,
      topicId: topicId,
    );

    final snapshot = documentReference.snapshots();

    return snapshot.map((e) {
      final data = e.data();
      if (data == null) {
        return null;
      } else {
        return _convertTopic(data);
      }
    });
  }

  BehaviorSubjectWrapper<List<Featured>> getJuntoFeaturedItems(String juntoId) {
    return wrapInBehaviorSubject(firestore
        .collection(juntoCollectionName)
        .doc(juntoId)
        .collection('featured')
        .snapshots()
        .map((s) => s.docs)
        .asyncMap((docs) => _convertFeaturedListAsync(docs)));
  }

  Future<void> updateFeaturedItem({
    required String juntoId,
    required String documentId,
    required Featured featured,
    required bool isFeatured,
  }) async {
    final doc = firestore
        .collection(juntoCollectionName)
        .doc(juntoId)
        .collection('featured')
        .doc(documentId);

    if (!isFeatured) {
      await doc.delete();
    } else {
      await doc.set(toFirestoreJson(featured.toJson()));
    }
  }

  Future<Topic> createTopic({
    required String juntoId,
    required Topic topic,
  }) async {
    if ((topic.title?.trim() ?? '').isEmpty) {
      throw VisibleException('Template title is required.');
    }

    final docRef = topicsCollection(juntoId).doc(topic.id);

    final newTopic = topic.copyWith(
      id: docRef.id,
      status: TopicStatus.active,
      collectionPath: docRef.parent.path,
      creatorId: userService.currentUserId!,
      image: topic.image ?? defaultTopicImage(docRef.id),
    );

    await docRef.set(toFirestoreJson(newTopic.toJson()));

    return newTopic;
  }

  Future<void> updateTopic({
    required String juntoId,
    required Topic topic,
    required Iterable<String> keys,
  }) async {
    final docRef = topicReference(juntoId: juntoId, topicId: topic.id);

    await docRef.update(jsonSubset(keys, toFirestoreJson(topic.toJson())));
  }

  Future<void> upsertTopicAgendaItem({
    required String juntoId,
    required String topicId,
    required AgendaItem updatedItem,
  }) {
    return firestore.runTransaction((transaction) async {
      try {
        final ref = topicReference(
          juntoId: juntoId,
          topicId: topicId,
        );
        final snapshot = await transaction.get(ref);

        var topic = await _convertTopicAsync(ref.parent.path, snapshot);

        final agendaItems = topic.agendaItems.toList();
        final index = agendaItems.indexWhere((item) => item.id == updatedItem.id);
        if (index < 0) {
          agendaItems.add(updatedItem);
        } else {
          agendaItems[index] = updatedItem;
        }

        topic = topic.copyWith(agendaItems: agendaItems);
        transaction.update(snapshot.reference,
            jsonSubset([Topic.kFieldAgendaItems], toFirestoreJson(topic.toJson())));
      } catch (e) {
        print("Erorr udring transaction");
        print(e);
        rethrow;
      }
    });
  }

  Future<void> deleteTopicAgendaItem({
    required String juntoId,
    required String topicId,
    required String itemId,
  }) {
    return firestore.runTransaction((transaction) async {
      final ref = topicReference(
        juntoId: juntoId,
        topicId: topicId,
      );
      final snapshot = await transaction.get(ref);

      var topic = await _convertTopicAsync(ref.parent.path, snapshot);

      final agendaItems = topic.agendaItems;
      agendaItems.removeWhere((item) => item.id == itemId);

      topic = topic.copyWith(agendaItems: agendaItems);
      transaction.update(snapshot.reference,
          jsonSubset([Topic.kFieldAgendaItems], toFirestoreJson(topic.toJson())));
    });
  }

  Future<void> updateTopicAgendaOrdering({
    required String juntoId,
    required String topicId,
    required List<String> ordering,
  }) {
    return firestoreDatabase.firestore.runTransaction((transaction) async {
      final ref = topicReference(
        juntoId: juntoId,
        topicId: topicId,
      );
      final snapshot = await transaction.get(ref);

      var topic = await _convertTopicAsync(ref.parent.path, snapshot);

      final List<AgendaItem> agendaItems = topic.agendaItems;
      final agendaItemMap = Map<String, AgendaItem>.fromIterable(
        agendaItems,
        key: (item) => (item as AgendaItem).id,
      );

      if (!setEquals(ordering.toSet(), agendaItemMap.keys.toSet())) {
        throw VisibleException('Error in updating agenda ordering. Please refresh.');
      }

      final List<AgendaItem> newAgenda = ordering.map((itemId) => agendaItemMap[itemId]!).toList();

      topic = topic.copyWith(agendaItems: newAgenda);
      transaction.update(snapshot.reference,
          jsonSubset([Topic.kFieldAgendaItems], toFirestoreJson(topic.toJson())));
    });
  }

  Future<List<Topic>> getActiveTopicsFromJuntos(List<String> juntoIds) async {
    final topics = await Future.wait([for (final id in juntoIds) topicsCollection(id).get()]);
    final groupedTopics = await Future.wait([
      for (int i = 0; i < juntoIds.length; i++)
        _convertTopicListAsync(topicsCollection(juntoIds[i]).path, topics[i].docs),
    ]);

    return groupedTopics.expand((t) => t).where((t) => t.status == TopicStatus.active).toList();
  }

  static Future<List<Junto>> _convertJuntoListAsync(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    final juntos = await compute(_convertJuntoList, docs.map((doc) => doc.data()).toList());

    for (var i = 0; i < juntos.length; i++) {
      juntos[i] = juntos[i].copyWith(
        id: docs[i].id,
      );
    }

    return juntos;
  }

  static Future<Junto?> _convertJuntoAsync(DocumentSnapshot<Map<String, dynamic>> doc) async {
    final docData = doc.data();
    if (docData == null) return null;

    final junto = await compute<Map<String, dynamic>, Junto>(_convertJunto, docData);
    return junto.copyWith(id: doc.id);
  }

  static Junto _convertJunto(Map<String, dynamic> data) {
    return Junto.fromJson(fromFirestoreJson(data));
  }

  static List<Junto> _convertJuntoList(List<Map<String, dynamic>> data) {
    return data.map((d) => Junto.fromJson(fromFirestoreJson(d))).toList();
  }

  static Future<List<Topic>> _convertTopicListAsync(
    String collectionPath,
    List<DocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    final topics = await compute<List<Map<String, dynamic>>, List<Topic>>(
      _convertTopicList,
      docs.map((doc) {
        // Create a new Map from the document data and add 'collectionPath'
        var data = Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);
        data['collectionPath'] = collectionPath;
        return data;
      }).toList(),
    );

    for (var i = 0; i < topics.length; i++) {
      topics[i] = topics[i].copyWith(
        id: docs[i].id,
        collectionPath: collectionPath,
      );
    }

    return topics;
  }

  static Future<Topic> _convertTopicAsync(
    String collectionPath,
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final topic = await compute<Map<String, dynamic>, Topic>(_convertTopic, doc.data()!);
    return topic.copyWith(
      id: doc.id,
      collectionPath: collectionPath,
    );
  }

  static Topic _convertTopic(Map<String, dynamic> data) {
    return Topic.fromJson(fromFirestoreJson(data));
  }

  static List<Topic> _convertTopicList(List<Map<String, dynamic>> data) {
    return data.map((d) => _convertTopic(d)).toList();
  }

  static Future<List<Featured>> _convertFeaturedListAsync(
    List<DocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    final featured = await compute<List<Map<String, dynamic>>, List<Featured>>(
      _convertFeaturedList,
      docs.map((doc) => doc.data()!).toList(),
    );

    return featured;
  }

  static List<Featured> _convertFeaturedList(List<Map<String, dynamic>> data) {
    return data.map((d) => Featured.fromJson(fromFirestoreJson(d))).toList();
  }

  Future<void> initialize() async {
    if (usingEmulator) {
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    }
  }
}
