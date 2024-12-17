import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:client/app/community/utils.dart';
import 'package:client/common_widgets/confirm_dialog.dart';
import 'package:client/common_widgets/visible_exception.dart';
import 'package:client/services/firestore/firestore_utils.dart';
import 'package:client/services/services.dart';
import 'package:data_models/analytics/analytics_entities.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/community/membership.dart';
import 'package:rxdart/rxdart.dart';

class UserDataService with ChangeNotifier {
  String? _currentUserId;

  BehaviorSubjectWrapper<List<Membership>> _memberships =
      BehaviorSubjectWrapper<List<Membership>>(Stream.value([]));
  Stream<List<Membership>> get memberships => _memberships.stream;
  StreamSubscription? _membershipsSubscription;

  final _userCommunities = BehaviorSubject<List<Community>>();
  Stream<List<Community>> get userCommunities => _userCommunities.stream;

  static bool usingEmulator = false;

  Future<void> initialize() async {
    if (usingEmulator) {
      FirebaseDatabase.instance.useDatabaseEmulator('localhost', 9000);
    }
    userService.addListener(() {
      if (_currentUserId != userService.currentUserId) {
        _currentUserId = userService.currentUserId;
        _loadUserData();

        // Setup a listener so that when users disconnect, we can update things in our backend
        if (_currentUserId != null) {
          // Create a reference to this user's specific status node.
          // This is where we will store data about being online/offline.
          final userStatusDatabaseRef =
              FirebaseDatabase.instance.ref('/status/$_currentUserId');

          // We'll create two constants which we will write to
          // the Realtime database when this device is offline
          // or online.
          final isOfflineForDatabase = {
            'state': 'offline',
            'last_changed': ServerValue.timestamp,
          };

          final isOnlineForDatabase = {
            'state': 'online',
            'last_changed': ServerValue.timestamp,
          };

          // Create a reference to the special '.info/connected' path in
          // Realtime Database. This path returns `true` when connected
          // and `false` when disconnected.
          FirebaseDatabase.instance
              .ref('.info/connected')
              .onValue
              .listen((event) {
            final isConnected = event.snapshot.value as bool?;

            // If we're not currently connected, don't do anything.
            if (isConnected == false) {
              return;
            }

            // If we are currently connected, then use the 'onDisconnect()'
            // method to add a set which will only trigger once this
            // client has disconnected by closing the app,
            // losing internet, or any other means.
            userStatusDatabaseRef
                .onDisconnect()
                .set(isOfflineForDatabase)
                .then((_) {
              // The promise returned from .onDisconnect().set() will
              // resolve as soon as the server acknowledges the onDisconnect()
              // request, NOT once we've actually disconnected:
              // https://firebase.google.com/docs/reference/dart/firebase.database.OnDisconnect

              // We can now safely set ourselves as 'online' knowing that the
              // server will mark us as offline once we lose connection.
              debugPrint(
                'OnDisconnect function activated. User is logged as being online.',
              );
              userStatusDatabaseRef.set(isOnlineForDatabase);
            });
          });
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _memberships.dispose();
    _userCommunities.close();
  }

  void _loadUserData() {
    final userId = _currentUserId;
    // If we had been listening to the previous user's membership stream then cancel it.
    _membershipsSubscription?.cancel();

    if (userId == null || !userService.isSignedIn) {
      _memberships = BehaviorSubjectWrapper<List<Membership>>(Stream.value([]));
    } else {
      // Load new memberships stream for user
      _memberships = firestoreMembershipService.userMembershipsStream(userId);

      // Listen to stream.  If memberships change, load new stream.
      _membershipsSubscription =
          _memberships.stream.listen((membershipList) async {
        final communityIds = membershipList
            // Filter out nulls additionally to make sure list is with only String values
            .where((membership) => membership.isMember)
            .map((membership) => membership.communityId)
            .toList();
        final communityDocs =
            await firestoreDatabase.getCommunityDocuments(communityIds);
        _userCommunities.add(communityDocs.withoutNulls.toList());
        notifyListeners();
      });
    }

    notifyListeners();
  }

  Membership getMembership(String communityId) {
    final membership = Membership(
      userId: userService.currentUserId!,
      communityId: communityId,
      status: MembershipStatus.nonmember,
    );

    return _memberships.stream.valueOrNull?.firstWhere(
          (membership) => membership.communityId == communityId,
          orElse: () => membership,
        ) ??
        membership;
  }

  bool isMember({required String communityId}) =>
      getMembership(communityId).isMember;

  /// Make membership change
  Future<void> changeCommunityMembership({
    required String communityId,
    required String userId,
    required MembershipStatus newStatus,
    bool allowMemberDowngrade = true,
  }) async {
    final membership = await firestoreMembershipService
        .getMembershipForUser(
          userId: userId,
          communityId: communityId,
        )
        .first;

    var skipUpdate = membership?.status == newStatus;
    if (!allowMemberDowngrade &&
        [MembershipStatus.member, MembershipStatus.attendee]
            .contains(newStatus) &&
        (membership?.isMember ?? false)) {
      skipUpdate = true;
    }

    if (!skipUpdate) {
      await cloudFunctionsService.updateMembership(
        UpdateMembershipRequest(
          communityId: communityId,
          status: newStatus,
          userId: userId,
          invisible: null,
        ),
      );

      final wasMember = membership?.isMember ?? false;
      final isNowMember = newStatus.isMember;
      if (!wasMember && isNowMember) {
        analytics
            .logEvent(AnalyticsJoinCommunityEvent(communityId: communityId));
      } else if (wasMember && !isNowMember) {
        analytics
            .logEvent(AnalyticsLeaveCommunityEvent(communityId: communityId));
      }
    }
  }

  /// Trigger UI to change membership
  Future<void> requestChangeCommunityMembership({
    required Community community,
    required bool join,
  }) async {
    return guardSignedIn(() async {
      // This should already be handled by firestore rules but this would make a better error message.
      if (userDataService.getMembership(community.id).isAdmin && !join) {
        throw VisibleException('Cannot leave space you are admin of.');
      }

      if (!join) {
        final unsubscribe = await ConfirmDialog(
          title: 'Unfollow',
          mainText:
              'Are you sure you want to unsubscribe from ${community.name}?',
          confirmText: 'Yes',
          cancelText: 'No',
        ).show();
        if (unsubscribe != true) {
          return;
        }
      }
      await userDataService.changeCommunityMembership(
        communityId: community.id,
        userId: userService.currentUserId!,
        newStatus: join ? MembershipStatus.member : MembershipStatus.nonmember,
        allowMemberDowngrade: false,
      );
    });
  }
}
