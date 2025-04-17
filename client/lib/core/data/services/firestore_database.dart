import 'dart:async';

import 'package:async/async.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/foundation.dart';
import 'package:client/features/events/features/event_page/data/providers/template_provider.dart';

import 'package:client/core/utils/visible_exception.dart';
import 'package:client/core/utils/firestore_utils.dart';
import 'package:client/services.dart';
import 'package:client/core/utils/extensions.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/templates/template.dart';
import 'package:data_models/utils/utils.dart';

class FirestoreNotFoundException implements Exception {}

/// Class for firestore interactions. This is mainly creating, reading, and
/// querying our different model types.
///
/// Functions for new model types should be placed in a file in this directory
/// specific for that model type.
///
/// See firestore_event_service.dart for an example.
class FirestoreDatabase {
  static const String communityCollectionName = 'community';
  static const String templatesCollectionName = 'templates';

  static bool usingEmulator = false;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _communityCollection =>
      firestore.collection(communityCollectionName);

  DocumentReference<Map<String, dynamic>> communityRef(String id) =>
      firestore.doc('$communityCollectionName/$id');

  CollectionReference<Map<String, dynamic>> templatesCollection(
    String communityId,
  ) =>
      firestore.collection(
        '$communityCollectionName/$communityId/$templatesCollectionName',
      );

  DocumentReference<Map<String, dynamic>> templateReference({
    required String communityId,
    required String templateId,
  }) {
    return templatesCollection(communityId).doc(templateId);
  }

  String generateNewDocId({required String collectionPath}) {
    return firestore.collection(collectionPath).doc().id;
  }

  Future<List<Community>> allPublicCommunities() async {
    final snapshot =
        await _communityCollection.where('isPublic', isEqualTo: true).get();
    return _convertCommunityListAsync(snapshot.docs);
  }

  Future<Community?> getCommunity(String id) async {
    final snapshot = await _communityCollection.doc(id).get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null || data.isEmpty) {
      return null;
    }
    return _convertCommunity(snapshot.data()!);
  }

  Future<List<Community?>> getCommunityDocuments(
    List<String> communityIds,
  ) async {
    final communityFutures = <Future<Community?>>[];
    for (final id in communityIds) {
      final communityDoc = await communityRef(id).snapshots().firstOrNull;
      if (communityDoc != null) {
        communityFutures.add(_convertCommunityAsync(communityDoc));
      }
    }
    return Future.wait(communityFutures);
  }

  Stream<List<Community>> communitiesUserIsOwnerOf(String userId) {
    return _communityCollection
        .where('creatorId', isEqualTo: userId)
        .snapshots()
        .asyncMap(
          (s) => Future.wait(s.docs.map((e) => _convertCommunityAsync(e))),
        )
        .map((e) => e.withoutNulls.toList());
  }

  String generateNewCommunityId() => _communityCollection.doc().id;

  BehaviorSubjectWrapper<Community> communityStream(String displayId) =>
      wrapInBehaviorSubject(
        firestore
            .collection(communityCollectionName)
            .where('displayIds', arrayContains: displayId)
            .snapshots()
            .map((s) => s.docs)
            .asyncMap((docs) async {
          if (docs.isEmpty) throw FirestoreNotFoundException();

          final community = await _convertCommunityAsync(docs.first);
          if (community == null) throw FirestoreNotFoundException();

          return community;
        }),
      );

  Future<List<Template>> allCommunityTemplates(
    String communityId, {
    bool includeRemovedTemplates = true,
  }) async {
    final collection = templatesCollection(communityId);

    final QuerySnapshot<Map<String, dynamic>> querySnapshot;

    if (includeRemovedTemplates) {
      querySnapshot = await collection.get();
    } else {
      querySnapshot = await collection
          .where(
            'status',
            isNotEqualTo: EnumToString.convertToString(TemplateStatus.removed),
          )
          .get();
    }

    return _convertTemplateListAsync(collection.path, querySnapshot.docs);
  }

  Stream<bool> communityHasTemplatesStream(String communityId) {
    final collection = templatesCollection(communityId);

    return collection
        .where(
          'status',
          isNotEqualTo: EnumToString.convertToString(TemplateStatus.removed),
        )
        .limit(1)
        .snapshots()
        .map((event) => event.docs.isEmpty ? false : true);
  }

  Stream<List<Template>> communityTemplatesStream(String communityId) {
    final collection = templatesCollection(communityId);

    return collection
        .snapshots()
        .asyncMap(
          (snapshot) =>
              _convertTemplateListAsync(collection.path, snapshot.docs),
        )
        // Some legacy templates have status == null so we use notEqualsTo
        .map(
          (t) => t.where((t) => t.status != TemplateStatus.removed).toList(),
        );
  }

  Future<Template?> getTemplate(String communityId, String templateId) async {
    final collection = templatesCollection(communityId);

    final snapshot = await collection.doc(templateId).get();
    final data = snapshot.data();

    if (!snapshot.exists || data == null || data.isEmpty) {
      return null;
    }

    return _convertTemplate(snapshot.data()!);
  }

  Future<Template> communityTemplate({
    required String communityId,
    required String templateId,
  }) async {
    // Bit of a hack to fix situations where events are in template collections that don't
    // actually exist. This can happen for instant meetings or if the user "skips" template selection
    // when creating a meeting.
    if (templateId == defaultInstantMeetingTemplateId) {
      return defaultInstantMeetingTemplate;
    } else if (templateId == defaultTemplateId) {
      return defaultTemplate;
    }

    final documentReference = templateReference(
      communityId: communityId,
      templateId: templateId,
    );

    final snapshot = await documentReference.get();
    if (!snapshot.exists) {
      throw Exception('Template $templateId not found.');
    }

    return _convertTemplateAsync(documentReference.parent.path, snapshot);
  }

  Stream<Template?> templateStream({
    required String communityId,
    required String templateId,
  }) {
    if (templateId == defaultInstantMeetingTemplateId) {
      return Stream.value(defaultInstantMeetingTemplate);
    } else if (templateId == defaultTemplateId) {
      return Stream.value(defaultTemplate);
    }

    final documentReference = templateReference(
      communityId: communityId,
      templateId: templateId,
    );

    final snapshot = documentReference.snapshots();

    return snapshot.map((e) {
      final data = e.data();
      if (data == null) {
        return null;
      } else {
        return _convertTemplate(data);
      }
    });
  }

  BehaviorSubjectWrapper<List<Featured>> getCommunityFeaturedItems(
    String communityId,
  ) {
    return wrapInBehaviorSubject(
      firestore
          .collection(communityCollectionName)
          .doc(communityId)
          .collection('featured')
          .snapshots()
          .map((s) => s.docs)
          .asyncMap((docs) => _convertFeaturedListAsync(docs)),
    );
  }

  Future<void> updateFeaturedItem({
    required String communityId,
    required String documentId,
    required Featured featured,
    required bool isFeatured,
  }) async {
    final doc = firestore
        .collection(communityCollectionName)
        .doc(communityId)
        .collection('featured')
        .doc(documentId);

    if (!isFeatured) {
      await doc.delete();
    } else {
      await doc.set(toFirestoreJson(featured.toJson()));
    }
  }

  Future<Template> createTemplate({
    required String communityId,
    required Template template,
  }) async {
    if ((template.title?.trim() ?? '').isEmpty) {
      throw VisibleException('Template title is required.');
    }

    final docRef = templatesCollection(communityId).doc(template.id);

    final newTemplate = template.copyWith(
      id: docRef.id,
      status: TemplateStatus.active,
      collectionPath: docRef.parent.path,
      creatorId: userService.currentUserId!,
      image: template.image ?? defaultTemplateImage(docRef.id),
    );

    await docRef.set(toFirestoreJson(newTemplate.toJson()));

    return newTemplate;
  }

  Future<void> updateTemplate({
    required String communityId,
    required Template template,
    required Iterable<String> keys,
  }) async {
    final docRef =
        templateReference(communityId: communityId, templateId: template.id);

    await docRef.update(jsonSubset(keys, toFirestoreJson(template.toJson())));
  }

  Future<void> upsertTemplateAgendaItem({
    required String communityId,
    required String templateId,
    required AgendaItem updatedItem,
  }) {
    return firestore.runTransaction((transaction) async {
      try {
        final ref = templateReference(
          communityId: communityId,
          templateId: templateId,
        );
        final snapshot = await transaction.get(ref);

        var template = await _convertTemplateAsync(ref.parent.path, snapshot);

        final agendaItems = template.agendaItems.toList();
        final index =
            agendaItems.indexWhere((item) => item.id == updatedItem.id);
        if (index < 0) {
          agendaItems.add(updatedItem);
        } else {
          agendaItems[index] = updatedItem;
        }

        template = template.copyWith(agendaItems: agendaItems);
        transaction.update(
          snapshot.reference,
          jsonSubset(
            [Template.kFieldAgendaItems],
            toFirestoreJson(template.toJson()),
          ),
        );
      } catch (e) {
        print('Erorr udring transaction');
        print(e);
        rethrow;
      }
    });
  }

  Future<void> deleteTemplateAgendaItem({
    required String communityId,
    required String templateId,
    required String itemId,
  }) {
    return firestore.runTransaction((transaction) async {
      final ref = templateReference(
        communityId: communityId,
        templateId: templateId,
      );
      final snapshot = await transaction.get(ref);

      var template = await _convertTemplateAsync(ref.parent.path, snapshot);

      final agendaItems = template.agendaItems;
      agendaItems.removeWhere((item) => item.id == itemId);

      template = template.copyWith(agendaItems: agendaItems);
      transaction.update(
        snapshot.reference,
        jsonSubset(
          [Template.kFieldAgendaItems],
          toFirestoreJson(template.toJson()),
        ),
      );
    });
  }

  Future<void> updateTemplateAgendaOrdering({
    required String communityId,
    required String templateId,
    required List<String> ordering,
  }) {
    return firestoreDatabase.firestore.runTransaction((transaction) async {
      final ref = templateReference(
        communityId: communityId,
        templateId: templateId,
      );
      final snapshot = await transaction.get(ref);

      var template = await _convertTemplateAsync(ref.parent.path, snapshot);

      final List<AgendaItem> agendaItems = template.agendaItems;
      final agendaItemMap = Map<String, AgendaItem>.fromIterable(
        agendaItems,
        key: (item) => (item as AgendaItem).id,
      );

      if (!setEquals(ordering.toSet(), agendaItemMap.keys.toSet())) {
        throw VisibleException(
          'Error in updating agenda ordering. Please refresh.',
        );
      }

      final List<AgendaItem> newAgenda =
          ordering.map((itemId) => agendaItemMap[itemId]!).toList();

      template = template.copyWith(agendaItems: newAgenda);
      transaction.update(
        snapshot.reference,
        jsonSubset(
          [Template.kFieldAgendaItems],
          toFirestoreJson(template.toJson()),
        ),
      );
    });
  }

  Future<List<Template>> getActiveTemplatesFromCommunities(
    List<String> communityIds,
  ) async {
    final templates = await Future.wait(
      [for (final id in communityIds) templatesCollection(id).get()],
    );
    final groupedTemplates = await Future.wait([
      for (int i = 0; i < communityIds.length; i++)
        _convertTemplateListAsync(
          templatesCollection(communityIds[i]).path,
          templates[i].docs,
        ),
    ]);

    return groupedTemplates
        .expand((t) => t)
        .where((t) => t.status == TemplateStatus.active)
        .toList();
  }

  static Future<List<Community>> _convertCommunityListAsync(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    final communities = await compute(
      _convertCommunityList,
      docs.map((doc) => doc.data()).toList(),
    );

    for (var i = 0; i < communities.length; i++) {
      communities[i] = communities[i].copyWith(
        id: docs[i].id,
      );
    }

    return communities;
  }

  static Future<Community?> _convertCommunityAsync(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final docData = doc.data();
    if (docData == null) return null;

    final community = await compute<Map<String, dynamic>, Community>(
      _convertCommunity,
      docData,
    );
    return community.copyWith(id: doc.id);
  }

  static Community _convertCommunity(Map<String, dynamic> data) {
    return Community.fromJson(fromFirestoreJson(data));
  }

  static List<Community> _convertCommunityList(
    List<Map<String, dynamic>> data,
  ) {
    return data.map((d) => Community.fromJson(fromFirestoreJson(d))).toList();
  }

  static Future<List<Template>> _convertTemplateListAsync(
    String collectionPath,
    List<DocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    final templates = await compute<List<Map<String, dynamic>>, List<Template>>(
      _convertTemplateList,
      docs.map((doc) {
        // Create a new Map from the document data and add 'collectionPath'
        var data =
            Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);
        data['collectionPath'] = collectionPath;
        return data;
      }).toList(),
    );

    for (var i = 0; i < templates.length; i++) {
      templates[i] = templates[i].copyWith(
        id: docs[i].id,
        collectionPath: collectionPath,
      );
    }

    return templates;
  }

  static Future<Template> _convertTemplateAsync(
    String collectionPath,
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final template = await compute<Map<String, dynamic>, Template>(
      _convertTemplate,
      doc.data()!,
    );
    return template.copyWith(
      id: doc.id,
      collectionPath: collectionPath,
    );
  }

  static Template _convertTemplate(Map<String, dynamic> data) {
    return Template.fromJson(fromFirestoreJson(data));
  }

  static List<Template> _convertTemplateList(List<Map<String, dynamic>> data) {
    return data.map((d) => _convertTemplate(d)).toList();
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
