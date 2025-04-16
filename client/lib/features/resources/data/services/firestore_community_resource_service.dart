import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:client/services.dart';
import 'package:data_models/resources/community_resource.dart';

import '../../../../core/utils/firestore_utils.dart';

class FirestoreCommunityResourceService {
  static const community = 'community';
  static const resources = 'community-resources';

  CollectionReference<Map<String, dynamic>> communityResourcesCollection({
    required String communityId,
  }) {
    return firestoreDatabase.firestore
        .collection(community)
        .doc(communityId)
        .collection(resources);
  }

  Future<void> createCommunityResource({
    required String communityId,
    required CommunityResource resource,
  }) async {
    final doc =
        communityResourcesCollection(communityId: communityId).doc(resource.id);
    await doc.set(toFirestoreJson(resource.copyWith(id: doc.id).toJson()));
  }

  Future<void> updateCommunityResource({
    required String communityId,
    required CommunityResource resource,
  }) async {
    final doc =
        communityResourcesCollection(communityId: communityId).doc(resource.id);
    await doc.update(toFirestoreJson(resource.copyWith(id: doc.id).toJson()));
  }

  Stream<List<CommunityResource>> getCommunityResources({
    required String communityId,
  }) {
    return communityResourcesCollection(communityId: communityId)
        .snapshots(includeMetadataChanges: true)
        .map((s) => s.docs)
        .asyncMap((docs) => _convertCommunityResourceListAsync(docs));
  }

  Stream<bool> communityHasResources({required String communityId}) =>
      communityResourcesCollection(communityId: communityId)
          .limit(1)
          .snapshots()
          .map((event) => event.docs.isNotEmpty);

  Future<void> deleteCommunityResource({
    required String communityId,
    required String resourceId,
  }) {
    return communityResourcesCollection(communityId: communityId)
        .doc(resourceId)
        .delete();
  }

  static Future<List<CommunityResource>> _convertCommunityResourceListAsync(
    List<DocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    final resource =
        await compute<List<Map<String, dynamic>>, List<CommunityResource>>(
      _convertCommunityResourceList,
      docs.map((doc) => doc.data()!).toList(),
    );
    return resource;
  }

  static List<CommunityResource> _convertCommunityResourceList(
    List<Map<String, dynamic>> data,
  ) {
    return data
        .map((d) => CommunityResource.fromJson(fromFirestoreJson(d)))
        .toList();
  }
}
