import 'dart:async';

import 'package:client/features/auth/utils/auth_utils.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

// Complete the Firebase operation without delivering an authStateChanges event.
class _DeferredAuth extends Fake implements FirebaseAuth {
  final result = Completer<UserCredential>();

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      result.future;

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      result.future;
}

class _User extends Fake implements User {
  @override
  final String uid;
  bool verificationSent = false;

  _User(this.uid);

  @override
  bool get isAnonymous => false;

  @override
  Future<void> sendEmailVerification([ActionCodeSettings? settings]) async {
    verificationSent = true;
  }
}

class _Credential extends Fake implements UserCredential {
  @override
  final User? user;

  _Credential(this.user);
}

void main() {
  for (final signup in [true, false]) {
    final operation = signup ? 'signup' : 'login';
    late _DeferredAuth auth;
    late UserService service;

    Future<void> authenticate() => signup
        ? service.registerWithEmail(
            displayName: 'New Member',
            email: 'member@example.test',
            password: 'ExamplePassword123!',
          )
        : service.signInWithEmail(
            email: 'member@example.test',
            password: 'ExamplePassword123!',
          );

    group(operation, () {
      setUp(() {
        auth = _DeferredAuth();
        service = UserService(firebaseAuth: auth);
        GetIt.instance.registerSingleton<UserService>(service);
      });

      tearDown(() async {
        service.dispose();
        await GetIt.instance.reset();
      });

      test('allows a guarded action before an auth-state event arrives',
          () async {
        final notifiedIds = <String?>[];
        service.addListener(() => notifiedIds.add(service.currentUserId));
        final pending = authenticate();
        expect(service.isSignedIn, isFalse);
        expect(notifiedIds, isEmpty);

        auth.result.complete(_Credential(_User('new-member')));
        await pending;

        expect(service.isSignedIn, isTrue);
        expect(service.currentUserId, 'new-member');
        expect(notifiedIds, ['new-member']);
        var followCalls = 0;
        final result = await guardSignedIn(() async {
          followCalls++;
          return service.currentUserId;
        });
        expect(followCalls, 1);
        expect(result, 'new-member');
      });

      test('verification targets the user returned by Firebase', () async {
        final user = _User('new-member');
        final pending = authenticate();
        auth.result.complete(_Credential(user));
        await pending;
        await service.verifyEmail();
        expect(user.verificationSent, isTrue);
      });

      test('a failed operation does not sign in or notify listeners', () async {
        var notifications = 0;
        service.addListener(() => notifications++);
        final pending = authenticate();
        final expectation =
            expectLater(pending, throwsA(isA<FirebaseAuthException>()));
        auth.result.completeError(
          FirebaseAuthException(code: 'network-request-failed'),
        );
        await expectation;
        expect(service.isSignedIn, isFalse);
        expect(service.currentUserId, isNull);
        expect(notifications, 0);
      });
    });
  }
}
