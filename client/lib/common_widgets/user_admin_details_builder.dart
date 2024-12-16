import 'package:flutter/material.dart';
import 'package:junto/services/logging_service.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:provider/provider.dart';

class UserAdminDetailsProvider extends ChangeNotifier {
  final String userId;
  UserAdminDetailsProvider._(this.userId);

  static final List<String> _currentMicrotaskIds = [];
  static Future<GetUserAdminDetailsResponse>? _currentMicrotaskFuture;

  static final _userAdminDetailsProviderLookup = <String, UserAdminDetailsProvider>{};

  factory UserAdminDetailsProvider.forUser(String userId) {
    return _userAdminDetailsProviderLookup[userId] ??= UserAdminDetailsProvider._(userId);
  }

  UserAdminDetails? _info;
  Future<UserAdminDetails>? _infoFuture;
  GetUserAdminDetailsRequest? _lastRequest;

  UserAdminDetails? getInfo({
    String? juntoId,
    String? discussionPath,
  }) {
    if (_info == null) return null;

    final newRequest = GetUserAdminDetailsRequest(
      juntoId: juntoId,
      discussionPath: discussionPath,
      userIds: [userId],
    );

    if (_lastRequest != newRequest) return null;

    return _info;
  }

  Future<UserAdminDetails?> getInfoFuture({
    String? juntoId,
    String? discussionPath,
  }) async {
    final newRequest = GetUserAdminDetailsRequest(
      juntoId: juntoId,
      discussionPath: discussionPath,
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

  Future<UserAdminDetails> _getUserAdminDetails(GetUserAdminDetailsRequest request) async {
    final UserAdminDetails userDetails;

    final currentUserEmail = userService.firebaseAuth.currentUser?.email;
    if (userId == userService.currentUserId && currentUserEmail != null) {
      userDetails = await Future.microtask(() => UserAdminDetails(email: currentUserEmail));
    } else {
      _currentMicrotaskIds.add(userId);
      final index = _currentMicrotaskIds.length - 1;
      _currentMicrotaskFuture ??= Future.microtask(() {
        // This is not 100% accurate. If multiple juntoIds or discussions were
        // calling this at the same time, it would be disregarding those different values
        // and using the juntoId and discussionId of the first caller.
        // This could cause some very weird bugs if people aren't aware of this
        // nuance. But it is worth it to not make 100s of calls in the admin
        // console when searching user emails.
        // This could be altered to take that into account but it currently shouldn't
        // ever happen so I think this is better.
        final future = cloudFunctionsService
            .getUserAdminDetails(request.copyWith(userIds: _currentMicrotaskIds));
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
  final String? juntoId;
  final String? discussionPath;
  final String userId;
  final Widget Function(
    BuildContext context,
    bool isLoading,
    AsyncSnapshot<UserAdminDetails?> snapshot,
  ) builder;

  const UserAdminDetailsBuilder({
    required this.userId,
    this.juntoId,
    this.discussionPath,
    required this.builder,
  });

  @override
  _UserAdminDetailsBuilderState createState() => _UserAdminDetailsBuilderState();
}

class _UserAdminDetailsBuilderState extends State<UserAdminDetailsBuilder> {
  Widget _buildContent(BuildContext context) {
    final userId = widget.userId;

    final provider = Provider.of<UserAdminDetailsProvider>(context);
    final info = provider.getInfo(
      juntoId: widget.juntoId,
      discussionPath: widget.discussionPath,
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
          juntoId: widget.juntoId,
          discussionPath: widget.discussionPath,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            loggingService.log(
                '_UserAdminDetailsBuilderState._buildContent: Error: ${snapshot.error}',
                logType: LogType.error);
          }

          return widget.builder(
            context,
            snapshot.connectionState != ConnectionState.done,
            snapshot,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: UserAdminDetailsProvider.forUser(widget.userId),
      builder: (context, __) => _buildContent(context),
    );
  }
}
