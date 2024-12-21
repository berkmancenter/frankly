import 'package:flutter/material.dart';
import 'package:client/app/community/utils.dart';
import 'package:client/app/self/social_media/social_media_item_data.dart';
import 'package:client/services/firestore/firestore_utils.dart';
import 'package:client/services/services.dart';
import 'package:data_models/community/membership.dart';
import 'package:data_models/user/public_user_info.dart';

class ProfileTabController extends ChangeNotifier {
  PublicUserInfo userInfo;

  final Set<String> _changeKeys = {};

  BehaviorSubjectWrapper<Membership?>? _membershipStream;

  late PublicUserInfo _changeRecord;

  final String currentUserId;

  final String? communityId;

  List<SocialMediaItem> _allowedSocialPlatforms = allowedSocialPlatforms;

  Stream<Membership?>? get membershipStream => _membershipStream;
  Membership? get membership => _membershipStream?.value;

  PublicUserInfo get changeRecord => _changeRecord;

  Set<String> get changeKeys => _changeKeys;

  ProfileTabController({
    required this.currentUserId,
    required this.userInfo,
    this.communityId,
  });

  List<SocialMediaItem> get socialMediaItems => _allowedSocialPlatforms;

  void initialize() {
    final userId = currentUserId;

    if (communityId != null) {
      _membershipStream = wrapInBehaviorSubject(
        firestoreMembershipService.getMembershipForUser(
          communityId: communityId!,
          userId: userId,
        ),
      );
    }
    _initChangeRecord();
  }

  @override
  void dispose() {
    super.dispose();

    _membershipStream?.dispose();
  }

  Future<void> _initChangeRecord() async {
    _changeRecord = userInfo;

    _allowedSocialPlatforms =
        allowedSocialPlatforms.map((e) => _replaceIfItemExist(e)).toList();
  }

  SocialMediaItem _replaceIfItemExist(SocialMediaItem item) {
    final result = _changeRecord.socialMediaItems.firstWhere(
      (e) => e.socialMediaKey == item.socialMediaKey,
      orElse: () => item,
    );
    return result;
  }

  void onChangedName(String name) {
    _changeKeys.add('displayName');
    _changeRecord = _changeRecord.copyWith(displayName: name);

    notifyListeners();
  }

  void onChangedAboutMe(String about) {
    _changeKeys.add('about');
    _changeRecord = _changeRecord.copyWith(about: about);

    notifyListeners();
  }

  void onEditSocialMedia({
    required String value,
    required SocialMediaItem platform,
  }) {
    _changeKeys.add('socialMediaItems');

    var index = _allowedSocialPlatforms
        .indexWhere((item) => item.socialMediaKey == platform.socialMediaKey);
    _allowedSocialPlatforms[index] = platform.copyWith(url: value);

    notifyListeners();
  }

  Future<void> submitPressed() async {
    final socialPlatforms = List.of(_allowedSocialPlatforms);
    socialPlatforms.removeWhere((item) => isNullOrEmpty(item.url));
    _changeRecord = _changeRecord.copyWith(socialMediaItems: socialPlatforms);

    await userService.updateCurrentUserInfo(_changeRecord, _changeKeys);
    _changeKeys.clear();
  }

  Future<void> updateImage(String img) async {
    await userService.updateCurrentUserInfo(
      _changeRecord.copyWith(imageUrl: img),
      ['imageUrl'],
    );

    _changeKeys.add('imageUrl');
    _changeRecord = _changeRecord.copyWith(imageUrl: img);
    notifyListeners();
  }
}
