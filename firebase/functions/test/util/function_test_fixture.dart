import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:functions/utils/infra/firestore_utils.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'subscription_test_utils.dart';

void setupTestFixture() {
  final subscriptionTestUtils = SubscriptionTestUtils();

  setUpAll(() async {
    setFirebaseAppFactory(() => FirebaseAdmin.instance.initializeApp()!);
    // App currently uses these unrestricted capabilities for all communities, which are preloaded into the DB
    await subscriptionTestUtils.addUnrestrictedPlanCapabilities(
      planCapabilities: SubscriptionTestUtils.unrestrictedPlan,
    );
  });

  setUp(() async {
    // clean up test database between test runs
    await deleteAllCollections();
  });
  tearDown(() async {
    resetMocktailState();
  });
}

Future<void> deleteAllCollections() async {
  final collections = await firestore.listCollections();
  for (final collection in collections) {
    // Delete all data except for preloaded unrestricted plan capabilities
    if (collection.path != 'plan-capability-lists') {
      final documents = await collection.get();

      await Future.wait(
        documents.documents.map((doc) async {
          await doc.reference.delete();
        }),
      );
    }
  }
}
