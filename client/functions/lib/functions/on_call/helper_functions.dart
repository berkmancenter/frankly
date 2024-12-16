import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart' as functions_interop;
import 'package:junto_functions/functions/on_call_function.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';

/// Helper class which provides various methods to manipulate bulk data in firestore.
class FirestoreUtilsHelper {
  static bool isAllowed(String uid) {
    // Hardcoded UID of `admin@junto.dev`
    const String adminUid = '0hE42z28CXRhDRI72KP1hs2LJFA2';

    // Only allowed if it's in emulator (thus juntochat-test) or user authenticated as an admin.
    return firebaseApp.options.projectId == 'juntochat-test' || uid == adminUid;
  }
}

/// Finds all documents from [AddNewFieldRequest.collectionName] and adds
/// [AddNewFieldRequest.fieldWithValue] to document if [AddNewFieldRequest.fieldWithValue] does not
/// exist.
class AddNewField extends OnCallMethod<AddNewFieldRequest> {
  static const String kAddNewFieldApi = 'addNewField';
  AddNewField() : super(kAddNewFieldApi, (jsonMap) => AddNewFieldRequest.fromJson(jsonMap));

  @override
  Future<void> action(AddNewFieldRequest request, functions_interop.CallableContext context) async {
    if (!FirestoreUtilsHelper.isAllowed(context!.authUid!)) {
      throw functions_interop.HttpsError(functions_interop.HttpsError.failedPrecondition, 'unauthorized', null);
    }

    final collectionName = request.collectionName;
    final fieldWithValue = request.fieldWithValue;

    final docs = await firestore.collectionGroup(collectionName).get();
    final docsToUpdate = <DocumentSnapshot>[];
    // CF does not seem to support more advance array operations (retainWhere) - use old school way.
    for (var doc in docs.documents) {
      if (!doc.data.has(fieldWithValue.keys.first)) {
        docsToUpdate.add(doc);
      }
    }

    final List<Future> futures = docsToUpdate
        .map((doc) => doc.reference.setData(
              DocumentData.fromMap(fieldWithValue),
              SetOptions(merge: true),
            ))
        .toList();
    await Future.wait(futures);

    print({'docs updated: ${docsToUpdate.length}'});
  }
}

/// Finds all documents from [RemoveExistingFieldRequest.collectionName] and removes
/// [RemoveExistingFieldRequest.field] from document if field exists.
class RemoveExistingField extends OnCallMethod<RemoveExistingFieldRequest> {
  static const String kRemoveExistingFieldApi = 'removeExistingField';
  RemoveExistingField()
      : super(kRemoveExistingFieldApi, (jsonMap) => RemoveExistingFieldRequest.fromJson(jsonMap));

  @override
  Future<void> action(RemoveExistingFieldRequest request, functions_interop.CallableContext context) async {
    if (!FirestoreUtilsHelper.isAllowed(context!.authUid!)) {
      throw functions_interop.HttpsError(functions_interop.HttpsError.failedPrecondition, 'unauthorized', null);
    }

    final collectionName = request.collectionName;
    final field = request.field;

    final docs = await firestore.collectionGroup(collectionName).get();
    final docsToUpdate = List.of(docs.documents)..retainWhere((doc) => doc.data.has(field));

    final List<Future> futures = docsToUpdate
        .map((doc) =>
            doc.reference.updateData(UpdateData.fromMap({field: Firestore.fieldValues.delete()})))
        .toList();
    await Future.wait(futures);

    print({'docs updated: ${docsToUpdate.length}'});
  }
}
