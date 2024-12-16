import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:junto_models/firestore/membership.dart';
import 'package:test/test.dart';
import 'package:junto_functions/functions/on_call/create_junto.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart';

void main() {
  setUp(() async {
    setFirebaseAppFactory(() => FirebaseAdmin.instance.initializeApp()!);
  });

  test('Junto should be created without partner agreement', () async {
    const userId = 'fakeAuthId';
    final juntoCreator = CreateJunto();
    final testJunto = Junto(
        id: '1234',
        name: 'Testing Community',
        isPublic: true,
        profileImageUrl: 'http://someimage.com',
        bannerImageUrl: 'http://mybanner.com');
    final req = CreateJuntoRequest(junto: testJunto);
    final result = await juntoCreator.action(req, CallableContext(userId, null, 'fakeInstanceId'));
    expect(result, contains('juntoId'));
    final juntoId = result['juntoId'];
    final juntoSnapshot = await firestore.document('junto/$juntoId').get();
    final createdJunto =
        Junto.fromJson(firestoreUtils.fromFirestoreJson(juntoSnapshot.data.toMap()));

    final expectedJunto = testJunto.copyWith(
        id: juntoId,
        creatorId: userId,
        communitySettings: const CommunitySettings(),
        discussionSettings: DiscussionSettings.defaultSettings,
        createdDate: createdJunto.createdDate,
        displayIds: [juntoId]);

    expect(createdJunto, equals(expectedJunto));
    final membershipSnapshot =
        await firestore.document('memberships/fakeAuthId/junto-membership/$juntoId').get();
    final createdMembership =
        Membership.fromJson(firestoreUtils.fromFirestoreJson(membershipSnapshot.data.toMap()));
    expect(
        createdMembership,
        equals(Membership(
            juntoId: juntoId,
            userId: userId,
            status: MembershipStatus.owner,
            firstJoined: createdMembership.firstJoined)));
    // add verification of partner agreement when default partner agreement info added to firestore
  });

  test('Junto should be created under existing partner agreement', () async {
    // Implement this when default partner agreement info added to firestore
  });

  test('Junto should be created with default image URLs', () async {
    const userId = 'fakeAuthId';
    final juntoCreator = CreateJunto();
    final testJunto = Junto(id: '1234', name: 'Testing Community', isPublic: true);
    final req = CreateJuntoRequest(junto: testJunto);
    final result = await juntoCreator.action(req, CallableContext(userId, null, 'fakeInstanceId'));
    expect(result, contains('juntoId'));
    final juntoId = result['juntoId'];
    final juntoSnapshot = await firestore.document('junto/$juntoId').get();
    final createdJunto =
        Junto.fromJson(firestoreUtils.fromFirestoreJson(juntoSnapshot.data.toMap()));

    final expectedJunto = testJunto.copyWith(
        id: juntoId,
        creatorId: userId,
        communitySettings: const CommunitySettings(),
        discussionSettings: DiscussionSettings.defaultSettings,
        createdDate: createdJunto.createdDate,
        profileImageUrl: 'https://picsum.photos/seed/$juntoId-profile/512',
        bannerImageUrl: '',
        displayIds: [juntoId]);

    expect(createdJunto, equals(expectedJunto));
    final membershipSnapshot =
        await firestore.document('memberships/fakeAuthId/junto-membership/$juntoId').get();
    final createdMembership =
        Membership.fromJson(firestoreUtils.fromFirestoreJson(membershipSnapshot.data.toMap()));
    expect(
        createdMembership,
        equals(Membership(
            juntoId: juntoId,
            userId: userId,
            status: MembershipStatus.owner,
            firstJoined: createdMembership.firstJoined)));
  });

  test('Exception should be thrown if specified partner agreement not found', () async {
    const userId = 'fakeAuthId';
    final juntoCreator = CreateJunto();
    final testJunto = Junto(id: '1234', name: 'Testing Community', isPublic: true);
    final req = CreateJuntoRequest(junto: testJunto, agreementId: 'fakeagreement');
    expect(() async {
      await juntoCreator.action(req, CallableContext(userId, null, 'fakeInstanceId'));
    },
        throwsA(predicate((e) =>
            e is HttpsError &&
            e.code == HttpsError.failedPrecondition &&
            e.message == 'unauthorized')));
  });

  test('Exception should be thrown if no junto specified', () async {
    const userId = 'fakeAuthId';
    final juntoCreator = CreateJunto();
    final req = CreateJuntoRequest(junto: null);
    expect(() async {
      await juntoCreator.action(req, CallableContext(userId, null, 'fakeInstanceId'));
    },
        throwsA(predicate((e) =>
            e is HttpsError &&
            e.code == HttpsError.failedPrecondition &&
            e.message == 'Must provide junto information.')));
  });

  test('Exception should be thrown if junto name not specified', () async {
    const userId = 'fakeAuthId';
    final juntoCreator = CreateJunto();
    final testJunto = Junto(id: '1234', isPublic: true);
    final req = CreateJuntoRequest(junto: testJunto);
    expect(() async {
      await juntoCreator.action(req, CallableContext(userId, null, 'fakeInstanceId'));
    },
        throwsA(predicate((e) =>
            e is HttpsError &&
            e.code == HttpsError.failedPrecondition &&
            e.message == 'Name is required.')));
  });

  test('Exception should be thrown if request unauthorized', () async {
    final juntoCreator = CreateJunto();
    final testJunto = Junto(id: '1234', isPublic: true);
    final req = CreateJuntoRequest(junto: testJunto);
    expect(() async {
      await juntoCreator.action(req, CallableContext(null, null, 'fakeInstanceId'));
    },
        throwsA(predicate((e) =>
            e is HttpsError &&
            e.code == HttpsError.failedPrecondition &&
            e.message == 'unauthorized')));
  });
}
