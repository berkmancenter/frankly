import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/firestore/junto_resource.dart';

import 'firestore_utils.dart';

class FirestoreJuntoResourceService {
  static const junto = 'junto';
  static const resources = 'junto-resources';

  CollectionReference<Map<String, dynamic>> juntoResourcesCollection({
    required String juntoId,
  }) {
    return firestoreDatabase.firestore.collection(junto).doc(juntoId).collection(resources);
  }

  Future<void> createJuntoResource({
    required String juntoId,
    required JuntoResource resource,
  }) async {
    final doc = juntoResourcesCollection(juntoId: juntoId).doc(resource.id);
    await doc.set(toFirestoreJson(resource.copyWith(id: doc.id).toJson()));
  }

  Future<void> updateJuntoResource({
    required String juntoId,
    required JuntoResource resource,
  }) async {
    final doc = juntoResourcesCollection(juntoId: juntoId).doc(resource.id);
    await doc.update(toFirestoreJson(resource.copyWith(id: doc.id).toJson()));
  }

  Stream<List<JuntoResource>> getJuntoResources({required String juntoId}) {
    return juntoResourcesCollection(juntoId: juntoId)
        .snapshots(includeMetadataChanges: true)
        .map((s) => s.docs)
        .asyncMap((docs) => _convertJuntoResourceListAsync(docs));
  }

  Stream<bool> juntoHasResources({required String juntoId}) =>
      juntoResourcesCollection(juntoId: juntoId)
          .limit(1)
          .snapshots()
          .map((event) => event.docs.isNotEmpty);

  Future<void> deleteJuntoResource({
    required String juntoId,
    required String resourceId,
  }) {
    return juntoResourcesCollection(juntoId: juntoId).doc(resourceId).delete();
  }

  static Future<List<JuntoResource>> _convertJuntoResourceListAsync(
    List<DocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    final resource = await compute<List<Map<String, dynamic>>, List<JuntoResource>>(
      _convertJuntoResourceList,
      docs.map((doc) => doc.data()!).toList(),
    );
    return resource;
  }

  static List<JuntoResource> _convertJuntoResourceList(List<Map<String, dynamic>> data) {
    return data.map((d) => JuntoResource.fromJson(fromFirestoreJson(d))).toList();
  }
}
