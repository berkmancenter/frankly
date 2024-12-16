import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/src/iterable_extensions.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/foundation.dart';
import 'package:junto/services/firestore/firestore_utils.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/firestore/junto_tag.dart';
import 'package:junto_models/firestore/junto_tag_definition.dart';

class FirestoreTagService {
  static const String juntoTagDefinitions = 'junto-tag-definitions';
  static const String juntoTags = 'junto-tags';
  static const String resource = 'resource';
  static const String resources = 'junto-resources';

  CollectionReference<Map<String, dynamic>> get _juntoTagDefinitionsCollection =>
      firestoreDatabase.firestore.collection(juntoTagDefinitions);

  CollectionReference<Map<String, dynamic>> _juntoResourcesTagCollection(
          {required String juntoId, String? resourceId}) =>
      firestoreJuntoResourceService
          .juntoResourcesCollection(juntoId: juntoId)
          .doc(resourceId)
          .collection(juntoTags);

  DocumentReference<Map<String, dynamic>> _juntoTagDefinitionRef(String id) =>
      _juntoTagDefinitionsCollection.doc(id);

  CollectionReference<Map<String, dynamic>> _juntoTagsCollection(String juntoId) =>
      firestoreDatabase.juntoRef(juntoId).collection(juntoTags);

  CollectionReference<Map<String, dynamic>> _topicTagsCollection({
    required String juntoId,
    required String topicId,
  }) {
    return firestoreDatabase
        .topicReference(juntoId: juntoId, topicId: topicId)
        .collection(juntoTags);
  }

  CollectionReference<Map<String, dynamic>> _profileTagsCollection({
    required String taggedItemId,
  }) {
    return firestoreUserService.publicUserReference(userId: taggedItemId).collection(juntoTags);
  }

  Stream<List<JuntoTag>> getResourceTagsStream({required String juntoId}) {
    return firestoreDatabase.firestore
        .collectionGroup(juntoTags)
        .where('juntoId', isEqualTo: juntoId)
        .where('taggedItemType', isEqualTo: EnumToString.convertToString(TaggedItemType.resource))
        .snapshots()
        .asyncMap((s) => _convertJuntoTagListAsync(s.docs));
  }

  Stream<List<JuntoTag>> getAllTagsForJuntoStream() {
    return firestoreDatabase.firestore
        .collectionGroup(juntoTags)
        .where('taggedItemType', isEqualTo: EnumToString.convertToString(TaggedItemType.junto))
        .snapshots()
        .asyncMap((s) => _convertJuntoTagListAsync(s.docs));
  }

  Stream<List<JuntoTag>> getTopicTagsStream({required String juntoId}) {
    return firestoreDatabase.firestore
        .collectionGroup(juntoTags)
        .where('juntoId', isEqualTo: juntoId)
        .where('taggedItemType', isEqualTo: EnumToString.convertToString(TaggedItemType.topic))
        .snapshots()
        .asyncMap((s) => _convertJuntoTagListAsync(s.docs));
  }

  Stream<List<JuntoTag>> getJuntoTags({
    String? juntoId,
    required String taggedItemId,
    required TaggedItemType taggedItemType,
  }) {
    return _getTagCollection(
      juntoId: juntoId,
      taggedItemId: taggedItemId,
      taggedItemType: taggedItemType,
    )
        .snapshots(includeMetadataChanges: true)
        .map((s) => s.docs)
        .asyncMap((docs) => _convertJuntoTagListAsync(docs));
  }

  /// Removes any non-word, non-white-space characters for searching.
  String normalizeSuggestionKey(String input) {
    return input.replaceAll(RegExp(r'[^\w\s]+'), '').toLowerCase();
  }

  String getFirestoreStartsWithLimit(String text) {
    if (text.isEmpty) return '';

    final strFrontCode = text.substring(0, text.length - 1);
    final strEndCode = text.runes.last;
    final limit = strFrontCode + String.fromCharCode(strEndCode + 1);

    return limit;
  }

  /// Return a list of suggested tags based on input text.
  Future<List<JuntoTagDefinition>> getSuggestions({required String input}) async {
    QuerySnapshot<Map<String, dynamic>> snapshots = await _juntoTagDefinitionsCollection
        .where('searchKey', isGreaterThanOrEqualTo: normalizeSuggestionKey(input))
        .where('searchKey', isLessThan: getFirestoreStartsWithLimit(normalizeSuggestionKey(input)))
        .limit(20)
        .get();

    // Use title search as fallback for tag definitions without searchKey
    if (snapshots.docs.isEmpty) {
      snapshots = await _juntoTagDefinitionsCollection
          .where('title', isGreaterThanOrEqualTo: input.toLowerCase())
          .where('title', isLessThan: getFirestoreStartsWithLimit(input.toLowerCase()))
          .limit(20)
          .get();
    }
    return _convertJuntoTagDefinitionListAsync(snapshots.docs);
  }

  static Future<List<JuntoTagDefinition>> _convertJuntoTagDefinitionListAsync(
    List<DocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    final juntoTagDefinitions = await compute<List<Map<String, dynamic>>, List<JuntoTagDefinition>>(
      _convertJuntoTagDefinitionList,
      docs.map((doc) => doc.data() ?? {}).toList(),
    );

    return juntoTagDefinitions;
  }

  static List<JuntoTagDefinition> _convertJuntoTagDefinitionList(List<Map<String, dynamic>> data) {
    return data.map((d) => JuntoTagDefinition.fromJson(fromFirestoreJson(d))).toList();
  }

  Future<JuntoTagDefinition?> getTagDefinition(tagId) async {
    final snapshot = await _juntoTagDefinitionRef(tagId).get();
    return _convertTagDefinitionAsync(snapshot);
  }

  Future<JuntoTag> addJuntoTag({
    String? juntoId,
    required TaggedItemType taggedItemType,
    required String taggedItemId,
    String? title,
    String? definitionId,
  }) async {
    assert(title != null || definitionId != null, 'Title or definitionId must not be null.');

    final tagDefinitionId = definitionId ?? (await lookupOrCreateTagDefinition(title!)).id;
    final tagReference = _getTagCollection(
      juntoId: juntoId,
      taggedItemId: taggedItemId,
      taggedItemType: taggedItemType,
    ).doc(tagDefinitionId);
    final tagDoc = await tagReference.get();

    if (tagDoc.exists) {
      return await _convertJuntoTagAsync(tagDoc.data()!);
    } else {
      final newTag = JuntoTag(
        juntoId: juntoId,
        taggedItemId: taggedItemId,
        taggedItemType: taggedItemType,
        definitionId: tagDefinitionId,
      );

      await tagReference.set(toFirestoreJson(newTag.toJson()));

      return newTag;
    }
  }

  Future<JuntoTagDefinition> lookupOrCreateTagDefinition(String title) async {
    JuntoTagDefinition? definition = await _lookupDefinitionByTitle(title);
    if (definition == null) {
      final collection = _juntoTagDefinitionsCollection;
      definition = JuntoTagDefinition(
        id: firestoreDatabase.generateNewDocId(collectionPath: collection.path),
        title: title,
        searchKey: normalizeSuggestionKey(title),
      );
      await collection.doc(definition.id).set(toFirestoreJson(definition.toJson()));
    }
    return definition;
  }

  Future<JuntoTagDefinition?> _lookupDefinitionByTitle(String? tagTitle) async {
    final result = await _juntoTagDefinitionsCollection.where('title', isEqualTo: tagTitle).get();

    final definitionDoc = result.docs.firstOrNull;
    if (definitionDoc != null) {
      return await _convertTagDefinitionAsync(definitionDoc);
    }

    return null;
  }

  Future<void> deleteJuntoTag(JuntoTag tag) {
    return _getTagCollection(
      juntoId: tag.juntoId,
      taggedItemId: tag.taggedItemId,
      taggedItemType: tag.taggedItemType!,
    ).doc(tag.definitionId).delete();
  }

  CollectionReference<Map<String, dynamic>> _getTagCollection({
    String? juntoId,
    required TaggedItemType taggedItemType,
    required String taggedItemId,
  }) {
    switch (taggedItemType) {
      case TaggedItemType.topic:
        return _topicTagsCollection(juntoId: juntoId ?? '', topicId: taggedItemId);
      case TaggedItemType.resource:
        return _juntoResourcesTagCollection(
          juntoId: juntoId ?? '',
          resourceId: taggedItemId,
        );
      case TaggedItemType.junto:
        return _juntoTagsCollection(juntoId ?? '');
      case TaggedItemType.profile:
        return _profileTagsCollection(taggedItemId: taggedItemId);
    }
  }

  static Future<JuntoTagDefinition?> _convertTagDefinitionAsync(
      DocumentSnapshot<Map<String, dynamic>> doc) async {
    final docData = doc.data();
    if (docData == null) return null;

    final juntoTagDefinition =
        await compute<Map<String, dynamic>, JuntoTagDefinition>(_convertTagDefinition, docData);
    return juntoTagDefinition.copyWith(id: doc.id);
  }

  static JuntoTagDefinition _convertTagDefinition(Map<String, dynamic> data) {
    return JuntoTagDefinition.fromJson(fromFirestoreJson(data));
  }

  static Future<JuntoTag> _convertJuntoTagAsync(
    Map<String, dynamic> doc,
  ) async {
    final tag = await compute<Map<String, dynamic>, JuntoTag>(
      _convertJuntoTag,
      doc,
    );
    return tag;
  }

  static JuntoTag _convertJuntoTag(Map<String, dynamic> data) {
    return JuntoTag.fromJson(fromFirestoreJson(data));
  }

  static Future<List<JuntoTag>> _convertJuntoTagListAsync(
    List<DocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    final resource = await compute<List<Map<String, dynamic>>, List<JuntoTag>>(
      _convertJuntoTagList,
      docs.map((doc) => doc.data()!).toList(),
    );
    return resource;
  }

  static List<JuntoTag> _convertJuntoTagList(List<Map<String, dynamic>> data) {
    return data.map((d) => JuntoTag.fromJson(fromFirestoreJson(d))).toList();
  }
}
