@JS()
library google_cloud.firestore;

import 'package:js/js.dart';
import 'package:node_interop/node.dart';
import 'package:node_interop/util.dart';

FirestoreModule get firestoreModule =>
    _firestoreModule ??= require('@google-cloud/firestore') as FirestoreModule;
FirestoreModule? _firestoreModule;


/// Interface to FirestoreAdminClient within @google-cloud/firestore module.
@JS()
@anonymous
abstract class FirestoreAdminClient {
  /// Exports documents to another storage system
  /// https://firebase.google.com/docs/firestore/reference/rest/v1beta1/projects.databases/exportDocuments
  external Promise exportDocuments(ExportSettings settings);
}

@JS()
@anonymous
abstract class ExportSettings {
  /// Database to export
  external String? get name;
  /// The output URI. Currently only supports Google Cloud Storage URIs
  external String? get outputUriPrefix;
  /// Which collection ids to export. Empty list means all collections.
  external List<String>? get collectionIds;

  external factory ExportSettings({
    String name,
    String outputUriPrefix,
    List<String>? collectionIds,
  });
}


@JS()
@anonymous
abstract class FirestoreModule {
  V1 get v1;
}

@JS()
@anonymous
abstract class V1 {
  //ignore: non_constant_identifier_names
  dynamic get FirestoreAdminClient;
}

FirestoreAdminClient createFirestoreAdminClient() {
  return callConstructor(firestoreModule.v1.FirestoreAdminClient, []) as FirestoreAdminClient;
}
