import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/src/iterable_extensions.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/foundation.dart';
import 'package:client/core/utils/firestore_utils.dart';
import 'package:client/services.dart';
import 'package:data_models/community/community_tag.dart';
import 'package:data_models/community/community_tag_definition.dart';

class FirestoreTagService {
  static const String communityTagDefinitions = 'community-tag-definitions';
  static const String communityTags = 'community-tags';
  static const String resource = 'resource';
  static const String resources = 'community-resources';

  CollectionReference<Map<String, dynamic>>
      get _communityTagDefinitionsCollection =>
          firestoreDatabase.firestore.collection(communityTagDefinitions);

  CollectionReference<Map<String, dynamic>> _communityResourcesTagCollection({
    required String communityId,
    String? resourceId,
  }) =>
      firestoreCommunityResourceService
          .communityResourcesCollection(communityId: communityId)
          .doc(resourceId)
          .collection(communityTags);

  DocumentReference<Map<String, dynamic>> _communityTagDefinitionRef(
    String id,
  ) =>
      _communityTagDefinitionsCollection.doc(id);

  CollectionReference<Map<String, dynamic>> _communityTagsCollection(
    String communityId,
  ) =>
      firestoreDatabase.communityRef(communityId).collection(communityTags);

  CollectionReference<Map<String, dynamic>> _templateTagsCollection({
    required String communityId,
    required String templateId,
  }) {
    return firestoreDatabase
        .templateReference(communityId: communityId, templateId: templateId)
        .collection(communityTags);
  }

  CollectionReference<Map<String, dynamic>> _profileTagsCollection({
    required String taggedItemId,
  }) {
    return firestoreUserService
        .publicUserReference(userId: taggedItemId)
        .collection(communityTags);
  }

  Stream<List<CommunityTag>> getResourceTagsStream({
    required String communityId,
  }) {
    return firestoreDatabase.firestore
        .collectionGroup(communityTags)
        .where('communityId', isEqualTo: communityId)
        .where(
          'taggedItemType',
          isEqualTo: EnumToString.convertToString(TaggedItemType.resource),
        )
        .snapshots()
        .asyncMap((s) => _convertCommunityTagListAsync(s.docs));
  }

  Stream<List<CommunityTag>> getAllTagsForCommunityStream() {
    return firestoreDatabase.firestore
        .collectionGroup(communityTags)
        .where(
          'taggedItemType',
          isEqualTo: EnumToString.convertToString(TaggedItemType.community),
        )
        .snapshots()
        .asyncMap((s) => _convertCommunityTagListAsync(s.docs));
  }

  Stream<List<CommunityTag>> getTemplateTagsStream({
    required String communityId,
  }) {
    return firestoreDatabase.firestore
        .collectionGroup(communityTags)
        .where('communityId', isEqualTo: communityId)
        .where(
          'taggedItemType',
          isEqualTo: EnumToString.convertToString(TaggedItemType.template),
        )
        .snapshots()
        .asyncMap((s) => _convertCommunityTagListAsync(s.docs));
  }

  Stream<List<CommunityTag>> getCommunityTags({
    String? communityId,
    required String taggedItemId,
    required TaggedItemType taggedItemType,
  }) {
    return _getTagCollection(
      communityId: communityId,
      taggedItemId: taggedItemId,
      taggedItemType: taggedItemType,
    )
        .snapshots(includeMetadataChanges: true)
        .map((s) => s.docs)
        .asyncMap((docs) => _convertCommunityTagListAsync(docs));
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
  Future<List<CommunityTagDefinition>> getSuggestions({
    required String input,
  }) async {
    QuerySnapshot<Map<String, dynamic>> snapshots =
        await _communityTagDefinitionsCollection
            .where(
              'searchKey',
              isGreaterThanOrEqualTo: normalizeSuggestionKey(input),
            )
            .where(
              'searchKey',
              isLessThan:
                  getFirestoreStartsWithLimit(normalizeSuggestionKey(input)),
            )
            .limit(20)
            .get();

    // Use title search as fallback for tag definitions without searchKey
    if (snapshots.docs.isEmpty) {
      snapshots = await _communityTagDefinitionsCollection
          .where('title', isGreaterThanOrEqualTo: input.toLowerCase())
          .where(
            'title',
            isLessThan: getFirestoreStartsWithLimit(input.toLowerCase()),
          )
          .limit(20)
          .get();
    }
    return _convertCommunityTagDefinitionListAsync(snapshots.docs);
  }

  static Future<List<CommunityTagDefinition>>
      _convertCommunityTagDefinitionListAsync(
    List<DocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    final communityTagDefinitions =
        await compute<List<Map<String, dynamic>>, List<CommunityTagDefinition>>(
      _convertCommunityTagDefinitionList,
      docs.map((doc) => doc.data() ?? {}).toList(),
    );

    return communityTagDefinitions;
  }

  static List<CommunityTagDefinition> _convertCommunityTagDefinitionList(
    List<Map<String, dynamic>> data,
  ) {
    return data
        .map((d) => CommunityTagDefinition.fromJson(fromFirestoreJson(d)))
        .toList();
  }

  Future<CommunityTagDefinition?> getTagDefinition(tagId) async {
    final snapshot = await _communityTagDefinitionRef(tagId).get();
    return _convertTagDefinitionAsync(snapshot);
  }

  Future<CommunityTag> addCommunityTag({
    String? communityId,
    required TaggedItemType taggedItemType,
    required String taggedItemId,
    String? title,
    String? definitionId,
  }) async {
    assert(
      title != null || definitionId != null,
      'Title or definitionId must not be null.',
    );

    final tagDefinitionId =
        definitionId ?? (await lookupOrCreateTagDefinition(title!)).id;
    final tagReference = _getTagCollection(
      communityId: communityId,
      taggedItemId: taggedItemId,
      taggedItemType: taggedItemType,
    ).doc(tagDefinitionId);
    final tagDoc = await tagReference.get();

    if (tagDoc.exists) {
      return await _convertCommunityTagAsync(tagDoc.data()!);
    } else {
      final newTag = CommunityTag(
        communityId: communityId,
        taggedItemId: taggedItemId,
        taggedItemType: taggedItemType,
        definitionId: tagDefinitionId,
      );

      await tagReference.set(toFirestoreJson(newTag.toJson()));

      return newTag;
    }
  }

  Future<CommunityTagDefinition> lookupOrCreateTagDefinition(
    String title,
  ) async {
    CommunityTagDefinition? definition = await _lookupDefinitionByTitle(title);
    if (definition == null) {
      final collection = _communityTagDefinitionsCollection;
      definition = CommunityTagDefinition(
        id: firestoreDatabase.generateNewDocId(collectionPath: collection.path),
        title: title,
        searchKey: normalizeSuggestionKey(title),
      );
      await collection
          .doc(definition.id)
          .set(toFirestoreJson(definition.toJson()));
    }
    return definition;
  }

  Future<CommunityTagDefinition?> _lookupDefinitionByTitle(
    String? tagTitle,
  ) async {
    final result = await _communityTagDefinitionsCollection
        .where('title', isEqualTo: tagTitle)
        .get();

    final definitionDoc = result.docs.firstOrNull;
    if (definitionDoc != null) {
      return await _convertTagDefinitionAsync(definitionDoc);
    }

    return null;
  }

  Future<void> deleteCommunityTag(CommunityTag tag) {
    return _getTagCollection(
      communityId: tag.communityId,
      taggedItemId: tag.taggedItemId,
      taggedItemType: tag.taggedItemType!,
    ).doc(tag.definitionId).delete();
  }

  CollectionReference<Map<String, dynamic>> _getTagCollection({
    String? communityId,
    required TaggedItemType taggedItemType,
    required String taggedItemId,
  }) {
    switch (taggedItemType) {
      case TaggedItemType.template:
        return _templateTagsCollection(
          communityId: communityId ?? '',
          templateId: taggedItemId,
        );
      case TaggedItemType.resource:
        return _communityResourcesTagCollection(
          communityId: communityId ?? '',
          resourceId: taggedItemId,
        );
      case TaggedItemType.community:
        return _communityTagsCollection(communityId ?? '');
      case TaggedItemType.profile:
        return _profileTagsCollection(taggedItemId: taggedItemId);
    }
  }

  static Future<CommunityTagDefinition?> _convertTagDefinitionAsync(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final docData = doc.data();
    if (docData == null) return null;

    final communityTagDefinition =
        await compute<Map<String, dynamic>, CommunityTagDefinition>(
      _convertTagDefinition,
      docData,
    );
    return communityTagDefinition.copyWith(id: doc.id);
  }

  static CommunityTagDefinition _convertTagDefinition(
    Map<String, dynamic> data,
  ) {
    return CommunityTagDefinition.fromJson(fromFirestoreJson(data));
  }

  static Future<CommunityTag> _convertCommunityTagAsync(
    Map<String, dynamic> doc,
  ) async {
    final tag = await compute<Map<String, dynamic>, CommunityTag>(
      _convertCommunityTag,
      doc,
    );
    return tag;
  }

  static CommunityTag _convertCommunityTag(Map<String, dynamic> data) {
    return CommunityTag.fromJson(fromFirestoreJson(data));
  }

  static Future<List<CommunityTag>> _convertCommunityTagListAsync(
    List<DocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    final resource =
        await compute<List<Map<String, dynamic>>, List<CommunityTag>>(
      _convertCommunityTagList,
      docs.map((doc) => doc.data()!).toList(),
    );
    return resource;
  }

  static List<CommunityTag> _convertCommunityTagList(
    List<Map<String, dynamic>> data,
  ) {
    return data
        .map((d) => CommunityTag.fromJson(fromFirestoreJson(d)))
        .toList();
  }
}
