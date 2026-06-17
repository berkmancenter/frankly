import 'dart:async';

import 'package:client/core/utils/error_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:client/features/user/data/providers/user_info_builder.dart';
import 'package:client/core/utils/visible_exception.dart';
import 'package:client/services.dart';
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
  String? _emailActionCodeError;

  /// Holds the display name to use with email registration.
  ///
  /// This display name is used by the authStateChanges callback to know what name to store for
  /// this user.
  String? _emailRegistrationDisplayName;

  SignInState _signInState = SignInState.loading;

  String _emailActionContinueUrl() => '${html.window.location.origin}/';

  Future<void> verifyEmail() async {
    await _currentUser?.sendEmailVerification(
      ActionCodeSettings(
        url: _emailActionContinueUrl(),
        handleCodeInApp: true,
      ),
    );
  }

  Future<void> refreshEmailVerificationStatus() async {
    await _firebaseAuth.currentUser?.reload();
    notifyListeners();
  }

  Future<void> updateEmailAndResendVerification(String newEmail) async {
    final methods = await _firebaseAuth.fetchSignInMethodsForEmail(newEmail);
    if (methods.isNotEmpty) {
      throw FirebaseAuthException(code: 'email-already-in-use');
    }
    await _currentUser?.verifyBeforeUpdateEmail(
      newEmail,
      ActionCodeSettings(
        url: _emailActionContinueUrl(),
        handleCodeInApp: true,
      ),
    );
  }

  /// If there was an error signing in during redirect this flag indicates that.
  String? get redirectErrorMessage => _redirectErrorMessage;

  /// Non-null when an email action code (verify link) was found in the URL but failed.
  String? get emailActionCodeError => _emailActionCodeError;

  String? get currentUserId => _currentUser?.uid;

  Stream<String> get currentUserChanges => _currentUserChanges;

  FirebaseAuth get firebaseAuth => _firebaseAuth;

  bool get isCurrentUserEmailVerified =>
      _firebaseAuth.currentUser?.emailVerified ?? false;

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

  Future<void> _handleEmailActionCode() async {
    final uri = Uri.tryParse(html.window.location.href);
    if (uri == null) return;
    final mode = uri.queryParameters['mode'];
    final oobCode = uri.queryParameters['oobCode'];
    if (mode != 'verifyEmail' || oobCode == null) return;

    // Strip action-code params so they don't persist on refresh.
    html.window.history.replaceState(
      null,
      '',
      html.window.location.pathname ?? '/',
    );

    try {
      await _firebaseAuth.applyActionCode(oobCode);
      await _firebaseAuth.currentUser?.reload();
    } on FirebaseAuthException catch (e) {
      _emailActionCodeError = e.message;
    }
  }

  Future<void> initialize() async {
    if (usingEmulator) {
      await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
      // Set persistence to session for emulator to avoid logout across hard reloads
      await _firebaseAuth.setPersistence(Persistence.SESSION);
    }

    // Must run after emulator setup so applyActionCode targets the right endpoint.
    await _handleEmailActionCode();

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

    // If the user is unverified, reload before gating on emailVerified so that
    // a verification completed on Firebase's hosted action page (which processes
    // the code itself, then redirects to continueUrl without the oobCode) is
    // detected immediately rather than requiring the polling timer to catch it.
    if (!user.isAnonymous && !user.emailVerified) {
      try {
        await _firebaseAuth.currentUser?.reload();
      } catch (_) {}
    }

    // Set signedIn immediately so the UI (email verification gate, etc.) is
    // not blocked waiting for the Firestore call below. Brave's shields block
    // Firestore's WebChannel, which can cause createCurrentUserInfoIfNotExists
    // to hang indefinitely if we await it before notifying.
    _signInState = SignInState.signedIn;
    notifyListeners();

    if (!user.isAnonymous) {
      await createCurrentUserInfoIfNotExists(
        displayName: _emailRegistrationDisplayName,
      );
      notifyListeners();
    }
  }

  PublicUserInfo getDefaultPublicUserInfo({String? displayName}) {
    final currentUser = _currentUser!;
    // Auth emulator users rarely have displayName set. Prefer the explicitly
    // passed displayName (from registration), fall back to the auth displayName,
    // and finally derive initials from the email address before giving up and
    // using the uid prefix. This ensures existing-user login and page refresh
    // produce the same non-null value as new account creation.
    final resolvedName = firstAndLastInitial(displayName) ??
        firstAndLastInitial(currentUser.displayName) ??
        firstAndLastInitial(currentUser.email) ??
        'User-${currentUser.uid.substring(0, 4)}';
    if (kDebugMode) {
      loggingService.log(
        'getDefaultPublicUserInfo: name source = '
        'passed="$displayName" '
        'auth="${currentUser.displayName}" '
        'email="${currentUser.email}" '
        '-> resolved="$resolvedName"',
      );
    }
    return PublicUserInfo(
      id: currentUser.uid,
      agoraId: uidToInt(currentUser.uid),
      displayName: resolvedName,
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

    UserInfoProvider.reloadUser(userInfo.id);
  }

  Future<void> updateCurrentUserInfo(
    PublicUserInfo newUserInfo,
    Iterable<String> keys,
  ) async {
    await firestoreUserService.updatePublicUser(
      userInfo: newUserInfo,
      keys: keys,
    );
    UserInfoProvider.reloadUser(newUserInfo.id);
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
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    // authStateChanges listener handles _handleUserSignedIn, same as registerWithEmail
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
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
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
        cloudFunctionsCommunityService.getMembersData(
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