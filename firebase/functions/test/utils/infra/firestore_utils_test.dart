import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:functions/utils/infra/firestore_utils.dart';
import 'package:test/test.dart';

void main() {
  test('fromFirestoreJson serializes Timestamps with a UTC marker', () {
    final result = FirestoreUtils().fromFirestoreJson({
      'createdDate': Timestamp.fromDateTime(DateTime.utc(2026, 8, 20, 17, 5)),
    });

    // Clients call DateTime.parse on the serialized string. Without the "Z"
    // they read it as local time and show it shifted by their UTC offset.
    final createdDate = result['createdDate'] as DateTime;
    expect(createdDate.toIso8601String(), endsWith('Z'));
  });
}
