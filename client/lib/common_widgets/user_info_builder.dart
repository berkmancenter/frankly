import 'package:flutter/material.dart';
import 'package:client/services/services.dart';
import 'package:data_models/user/public_user_info.dart';
import 'package:provider/provider.dart';

class UserInfoProvider extends ChangeNotifier {
  final String userId;
  UserInfoProvider._(this.userId);

  static final _userInfoProviderLookup = <String, UserInfoProvider>{};

  factory UserInfoProvider.forUser(String userId) {
    return _userInfoProviderLookup[userId] ??= UserInfoProvider._(userId);
  }

  PublicUserInfo? info;
  Future<PublicUserInfo>? _infoFuture;

  Future<PublicUserInfo> get infoFuture => _infoFuture ??= _getUserInfo();

  static void reloadUser(String userId) {
    UserInfoProvider.forUser(userId).reload();
  }

  void reload() {
    info = null;
    _infoFuture = null;
    notifyListeners();
  }

  void setInfo(PublicUserInfo newInfo) {
    info = newInfo;
    notifyListeners();
  }

  Future<PublicUserInfo> _getUserInfo() async {
    final PublicUserInfo userInfo =
        await firestoreUserService.getPublicUser(userId: userId);

    info = userInfo;
    notifyListeners();

    return userInfo;
  }
}

class UserInfoBuilder extends StatelessWidget {
  final String? userId;
  final Widget Function(
    BuildContext context,
    bool isLoading,
    AsyncSnapshot<PublicUserInfo?> snapshot,
  ) builder;

  const UserInfoBuilder({
    Key? key,
    this.userId,
    required this.builder,
  }) : super(key: key);

  Widget _buildContent(BuildContext context) {
    final localUserId = userId;

    if (localUserId == null) {
      return builder(
        context,
        false,
        AsyncSnapshot.withData(ConnectionState.done, null),
      );
    }

    final provider = Provider.of<UserInfoProvider>(context);
    final info = provider.info;

    if (info != null) {
      return builder(
        context,
        false,
        AsyncSnapshot.withData(
          ConnectionState.done,
          info.copyWith(displayName: info.displayName),
        ),
      );
    }

    return FutureBuilder<PublicUserInfo?>(
      key: Key(localUserId),
      future: provider.infoFuture,
      builder: (context, snapshot) => builder(
        context,
        snapshot.connectionState != ConnectionState.done,
        AsyncSnapshot.withData(
          snapshot.connectionState,
          snapshot.data?.copyWith(displayName: snapshot.data?.displayName),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: UserInfoProvider.forUser(userId!),
      builder: (context, __) => _buildContent(context),
    );
  }
}
