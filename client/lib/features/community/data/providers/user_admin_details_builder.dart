import 'package:flutter/material.dart';
import 'package:client/core/data/services/logging_service.dart';
import 'package:client/services.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:provider/provider.dart';

class UserAdminDetailsProvider extends ChangeNotifier {
  final String userId;
  UserAdminDetailsProvider._(this.userId);

  static final List<String> _currentMicrotaskIds = [];
  static Future<GetUserAdminDetailsResponse>? _currentMicrotaskFuture;

  static final _userAdminDetailsProviderLookup =
      <String, UserAdminDetailsProvider>{};

  factory UserAdminDetailsProvider.forUser(String userId) {
    return _userAdminDetailsProviderLookup[userId] ??=
        UserAdminDetailsProvider._(userId);
  }

  UserAdminDetails? _info;
  Future<UserAdminDetails>? _infoFuture;
  GetUserAdminDetailsRequest? _lastRequest;

  UserAdminDetails? getInfo({
    String? communityId,
    String? eventPath,
  }) {
    if (_info == null) return null;

    final newRequest = GetUserAdminDetailsRequest(
      communityId: communityId,
      eventPath: eventPath,
      userIds: [userId],
    );

    if (_lastRequest != newRequest) return null;

    return _info;
  }

  Future<UserAdminDetails?> getInfoFuture({
    String? communityId,
    String? eventPath,
  }) async {
    final newRequest = GetUserAdminDetailsRequest(
      communityId: communityId,
      eventPath: eventPath,
      userIds: [userId],
    );

    if (newRequest != _lastRequest) {
      _infoFuture = _getUserAdminDetails(newRequest);
      _lastRequest = newRequest;
    }

    return _infoFuture;
  }

  static void reloadUser(String userId) {
    UserAdminDetailsProvider.forUser(userId).reload();
  }

  void reload() {
    _info = null;
    _infoFuture = null;
    _lastRequest = null;
    notifyListeners();
  }

  Future<UserAdminDetails> _getUserAdminDetails(
    GetUserAdminDetailsRequest request,
  ) async {
    final UserAdminDetails userDetails;

    final currentUserEmail = userService.firebaseAuth.currentUser?.email;
    if (userId == userService.currentUserId && currentUserEmail != null) {
      userDetails = await Future.microtask(
        () => UserAdminDetails(email: currentUserEmail),
      );
    } else {
      _currentMicrotaskIds.add(userId);
      final index = _currentMicrotaskIds.length - 1;
      _currentMicrotaskFuture ??= Future.microtask(() {
        // This is not 100% accurate. If multiple communityIds or events were
        // calling this at the same time, it would be disregarding those different values
        // and using the communityId and eventId of the first caller.
        // This could cause some very weird bugs if people aren't aware of this
        // nuance. But it is worth it to not make 100s of calls in the admin
        // console when searching user emails.
        // This could be altered to take that into account but it currently shouldn't
        // ever happen so I think this is better.
        final future = cloudFunctionsCommunityService.getUserAdminDetails(
          request.copyWith(userIds: _currentMicrotaskIds),
        );
        _currentMicrotaskFuture = null;
        _currentMicrotaskIds.clear();
        return future;
      });

      final response = await _currentMicrotaskFuture!;
      userDetails = response.userAdminDetails.firstWhere(
        (user) => user.userId == userId,
        orElse: () => response.userAdminDetails[index],
      );
    }

    if (request == _lastRequest) {
      _info = userDetails;
    }
    notifyListeners();

    return userDetails;
  }
}

class UserAdminDetailsBuilder extends StatefulWidget {
  final String? communityId;
  final String? eventPath;
  final String userId;
  final Widget Function(
    BuildContext context,
    bool isLoading,
    AsyncSnapshot<UserAdminDetails?> snapshot,
  ) builder;

  const UserAdminDetailsBuilder({
    required this.userId,
    this.communityId,
    this.eventPath,
    required this.builder,
  });

  @override
  _UserAdminDetailsBuilderState createState() =>
      _UserAdminDetailsBuilderState();
}

class _UserAdminDetailsBuilderState extends State<UserAdminDetailsBuilder> {
  Widget _buildContent(BuildContext context) {
    final userId = widget.userId;

    final provider = Provider.of<UserAdminDetailsProvider>(context);
    final info = provider.getInfo(
      communityId: widget.communityId,
      eventPath: widget.eventPath,
    );

    if (info != null) {
      return widget.builder(
        context,
        false,
        AsyncSnapshot.withData(ConnectionState.done, info),
      );
    }

    return FutureBuilder<UserAdminDetails?>(
      key: Key(userId),
      future: provider.getInfoFuture(
        communityId: widget.communityId,
        eventPath: widget.eventPath,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          loggingService.log(
            '_UserAdminDetailsBuilderState._buildContent: Error: ${snapshot.error}',
            logType: LogType.error,
          );
        }

        return widget.builder(
          context,
          snapshot.connectionState != ConnectionState.done,
          snapshot,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: UserAdminDetailsProvider.forUser(widget.userId),
      builder: (context, __) => _buildContent(context),
    );
  }
}
