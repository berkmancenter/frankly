import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:client/app/community/utils.dart';
import 'package:client/common_widgets/user_info_builder.dart';
import 'package:client/common_widgets/visible_exception.dart';
import 'package:client/services/services.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/community/community_user_settings.dart';
import 'package:data_models/community/member_details.dart';
import 'package:data_models/user/public_user_info.dart';
import 'package:data_models/utils/utils.dart';
import 'package:pedantic/pedantic.dart';
import 'package:quiver/iterables.dart';
import 'package:rxdart/rxdart.dart';
import 'package:universal_html/html.dart' as html;

enum SignInState {
  loading,
  signedIn,
  signedOut,
}

class UserService with ChangeNotifier {
  static bool usingEmulator = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // ignore: close_sinks
  final BehaviorSubject<String> _currentUserChanges = BehaviorSubject();

  Timer? _returningUserTimer;
  User? _currentUser;

  bool _signingInAnonymously = false;
  bool _redirectResultHandled = false;

  String? _redirectErrorMessage;

  /// Holds the display name to use with email registration.
  ///
  /// This display name is used by the authStateChanges callback to know what name to store for
  /// this user.
  String? _emailRegistrationDisplayName;

  SignInState _signInState = SignInState.loading;

  void verifyEmail() {
    _currentUser?.sendEmailVerification();
  }

  /// If there was an error signing in during redirect this flag indicates that.
  String? get redirectErrorMessage => _redirectErrorMessage;

  String? get currentUserId => _currentUser?.uid;

  Stream<String> get currentUserChanges => _currentUserChanges;

  FirebaseAuth get firebaseAuth => _firebaseAuth;

  bool get isSignedIn {
    final localCurrentUser = _currentUser;
    return localCurrentUser != null && !localCurrentUser.isAnonymous;
  }

  SignInState get signInState => _signInState;

  void _setCurrentUser(User user) {
    if (_currentUser?.uid != user.uid) {
      _currentUserChanges.add(user.uid);
    }
    _currentUser = user;
  }

  /// If we determine they are a returning user we expect firebase to sign them in automatically.
  ///
  /// We wait for a period and if we don't see them get signed in, we sign in anonymously.
  void _handleReturningUser() {
    _returningUserTimer = Timer(Duration(seconds: 8), () {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        // This path happens during hot reload mostly.
        loggingService.log(
          'Returning user timer has expired, but there is a current user so not signing in anonymously',
        );
        _handleUserSignedIn(user);
        return;
      }
      loggingService
          .log('Returning user timer has expired, signing in anonymously');
      _firebaseAuth.signInAnonymously();
    });
  }

  /// Handle redirect sign in failures by showing a dialog.
  ///
  /// After a user signs in using google they are redirected back to our site.
  /// If they signed in successfully firebase auth signs them in. However, if they failed for some
  /// reason we have to check the redirectResult which will throw an error.
  Future<void> _handleRedirectResult() async {
    if (!_redirectResultHandled) {
      _redirectResultHandled = true;

      try {
        await _firebaseAuth.getRedirectResult();
      } catch (e) {
        // If the error is a FirebaseAuthException that contains TypeError then it can be ignored.
        // It shows up due to an apparent bug in firebase auth that throws an exception if there
        // is no redirect result pending.
        if (!e.toString().contains('An unknown error occurred')) {
          _redirectErrorMessage = e.toString();
          notifyListeners();
        }
      }
    }
  }

  Future<void> initialize() async {
    if (usingEmulator) {
      await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    }
    await sharedPreferencesService.initialize();
    if (sharedPreferencesService.isReturningUser()) {
      _handleReturningUser();
    }

    _firebaseAuth.authStateChanges().listen((user) async {
      loggingService.log(
        'Firebase user updated ${user?.uid}: Email - ${user?.email} Anonymous: ${user?.isAnonymous}',
      );

      // Notify listeners immediately in order to update any firestore streams that are listening
      // to the old user.
      notifyListeners();

      // On macos it throws un-implemented error, thus wrap in control flow
      if (kIsWeb) {
        unawaited(_handleRedirectResult());
      }

      if (!sharedPreferencesService.isReturningUser() &&
          user == null &&
          !_signingInAnonymously) {
        await signInAnonymously();
      } else if (user == null && _signInState == SignInState.signedIn) {
        _signInState = SignInState.signedOut;
        notifyListeners();
      } else if (user != null) {
        await _handleUserSignedIn(user);
      }
    });
  }

  Future<void> _handleUserSignedIn(User user) async {
    unawaited(sharedPreferencesService.setIsReturningUser(true));
    _returningUserTimer?.cancel();

    _setCurrentUser(user);
    if (!user.isAnonymous) {
      await createCurrentUserInfoIfNotExists(
        displayName: _emailRegistrationDisplayName,
      );
    }

    _signInState = SignInState.signedIn;

    notifyListeners();
  }

  PublicUserInfo getDefaultPublicUserInfo({String? displayName}) {
    final currentUser = _currentUser!;
    return PublicUserInfo(
      id: currentUser.uid,
      agoraId: uidToInt(currentUser.uid),
      displayName:
          firstAndLastInitial(displayName ?? currentUser.displayName) ??
              'User-${currentUser.uid.substring(0, 4)}',
      imageUrl: isNullOrEmpty(currentUser.photoURL)
          ? 'https://picsum.photos/seed/${currentUser.uid}/80'
          : currentUser.photoURL,
    );
  }

  CommunityUserSettings getDefaultCommunityUserSettings({
    required String communityId,
  }) {
    return CommunityUserSettings(
      userId: _currentUser!.uid,
      communityId: communityId,
      notifyAnnouncements: NotificationEmailType.immediate,
      notifyEvents: NotificationEmailType.immediate,
    );
  }

  Future<void> updateCommunityUserSettings(
    CommunityUserSettings settings,
  ) async {
    await firestorePrivateUserDataService.updateCommunityUserSettings(
      communityUserSettings: settings,
    );
  }

  Future<void> createCurrentUserInfoIfNotExists({String? displayName}) async {
    loggingService.log(
      'UserService.createCurrentUserInfoIfNotExists: updating current user info to $displayName',
    );
    final userInfo = await firestoreUserService.getOrCreatePublicUserInfo(
      defaultUserInfo: getDefaultPublicUserInfo(displayName: displayName),
    );

    // Update the agora ID for anyone who logs in
    unawaited(updateCurrentUserInfo(userInfo, [PublicUserInfo.kFieldAgoraId]));

    UserInfoProvider.reloadUser(currentUserId!);
  }

  Future<void> updateCurrentUserInfo(
    PublicUserInfo newUserInfo,
    Iterable<String> keys,
  ) async {
    await firestoreUserService.updatePublicUser(
      userInfo: newUserInfo,
      keys: keys,
    );
    UserInfoProvider.reloadUser(currentUserId!);
  }

  Future<UserCredential> signInAnonymously() async {
    _signingInAnonymously = true;
    loggingService.log('signing in anonymously');
    final result = await _firebaseAuth.signInAnonymously();
    _signingInAnonymously = false;
    return result;
  }

  Future<void> signOut() async {
    await sharedPreferencesService.setIsReturningUser(false);
    await _firebaseAuth.signOut();

    html.window.location.reload();
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCredential.user;
    if (user != null) {
      await _handleUserSignedIn(user);
    }
  }

  Future<void> signInWithGoogle() async {
    await _firebaseAuth.signInWithRedirect(
      GoogleAuthProvider()..setCustomParameters({'prompt': 'select_account'}),
    );
  }

  Future<void> registerWithEmail({
    required String displayName,
    required String email,
    required String password,
  }) async {
    if (displayName.trim().isEmpty) {
      throw VisibleException('Your name is required.');
    }
    // Store the display name in this variable so that the authStateChanges callback will know what
    // to set the users name as.
    _emailRegistrationDisplayName = displayName;
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user != null) {
        await _handleUserSignedIn(user);
      }
    } catch (e) {
      _emailRegistrationDisplayName = null;
      rethrow;
    }
  }

  Future<void> resetPassword({required String email}) {
    if (email.trim().isEmpty) {
      throw VisibleException('Email must be entered to reset password.');
    }

    return firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<List<MemberDetails>> getMemberDetails({
    required List<String> membersList,
    required String communityId,
    String? eventPath,
  }) async {
    final responseFutures = <Future<GetMembersDataResponse>>[];
    for (final membersListBatch in partition(membersList, 1000)) {
      responseFutures.add(
        cloudFunctionsService.getMembersData(
          request: GetMembersDataRequest(
            communityId: communityId,
            userIds: membersListBatch,
            eventPath: eventPath,
          ),
        ),
      );
    }
    final responses = await Future.wait(responseFutures);
    final membersDetailsLists =
        responses.map((response) => response.membersDetailsList ?? []);
    final members = <MemberDetails>[];
    for (final list in membersDetailsLists) {
      members.addAll(list);
    }
    return members;
  }
}
