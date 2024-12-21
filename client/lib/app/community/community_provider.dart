import 'dart:async';

import 'package:flutter/material.dart';
import 'package:client/app/community/utils.dart';
import 'package:client/common_widgets/navbar/nav_bar_provider.dart';
import 'package:client/app.dart';
import 'package:client/services/firestore/firestore_utils.dart';
import 'package:client/services/services.dart';
import 'package:client/utils/extensions.dart';
import 'package:data_models/analytics/analytics_entities.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/resources/community_resource.dart';
import 'package:provider/provider.dart';

class CommunityProvider with ChangeNotifier {
  final String _displayId;
  final NavBarProvider navBarProvider;

  CommunityProvider({
    required String displayId,
    required this.navBarProvider,
  }) : _displayId = displayId;

  late BehaviorSubjectWrapper<Community> _community;
  late BehaviorSubjectWrapper<List<Featured>> _featured;
  late BehaviorSubjectWrapper<List<CommunityResource>> _resources;
  BehaviorSubjectWrapper<bool>? _hasTemplates;

  late StreamSubscription _communityListener;
  late StreamSubscription _featuredListener;
  late StreamSubscription _resourcesListener;
  StreamSubscription? _hasTemplatesListener;

  bool get enableHostless => settings.enableHostless;

  Community get community {
    final communityValue = _community.stream.valueOrNull;
    if (communityValue == null) {
      throw Exception('Community must be loaded before being accessed.');
    }

    return communityValue;
  }

  String get communityId => community.id;

  String get displayId => community.displayId;

  Stream<Community> get communityStream => _community.stream;

  Stream<List<Featured>> get featuredStream => _featured.stream;

  BehaviorSubjectWrapper<List<CommunityResource>> get resourcesStream =>
      _resources;

  List<Featured> get featuredItems => _featured.stream.valueOrNull ?? [];

  bool get hasResources => _resources.stream.valueOrNull?.isNotEmpty ?? false;

  bool get hasTemplates => _hasTemplates?.value ?? false;

  CommunitySettings get settings => community.settingsMigration;

  EventSettings get eventSettings => community.eventSettingsMigration;

  void initialize() {
    _community = firestoreDatabase.communityStream(_displayId);
    _communityListener = _community.stream.listen((community) {
      notifyListeners();
      navBarProvider.setCurrentCommunity(community);
      _hasTemplates ??= _listenForTemplates(community.id);
      _hasTemplatesListener ??= _hasTemplates?.stream.listen((value) {
        notifyListeners();
      });
    });

    _featured = wrapInBehaviorSubject(_getFeaturedItems());
    _featuredListener = _featured.stream.listen((featured) {
      notifyListeners();
    });

    loadResources();
  }

  BehaviorSubjectWrapper<bool> _listenForTemplates(String communityId) {
    return wrapInBehaviorSubject(
      firestoreDatabase.communityHasTemplatesStream(communityId),
    );
  }

  void loadResources() {
    _resources = wrapInBehaviorSubject(_getResources());
    _resourcesListener = _resources.stream.listen((resources) {
      notifyListeners();
      _updateNavBar();
    });
  }

  void _updateNavBar() {
    navBarProvider.setHasResources(hasResources);
  }

  Stream<List<Featured>> _getFeaturedItems() async* {
    final community = await _community.stream.first;

    yield* firestoreDatabase.getCommunityFeaturedItems(community.id).stream;
  }

  Stream<List<CommunityResource>> _getResources() async* {
    final community = await _community.stream.first;
    Stream<List<CommunityResource>> stream = firestoreCommunityResourceService
        .getCommunityResources(communityId: community.id);
    yield* stream;
  }

  @override
  void dispose() {
    _communityListener.cancel();
    _featuredListener.cancel();
    _resourcesListener.cancel();
    _hasTemplatesListener?.cancel();
    _resources.dispose();
    _community.dispose();
    _featured.dispose();
    _hasTemplates?.dispose();
    super.dispose();
  }

  Future<void> updateBanner(String url) async {
    await cloudFunctionsService.updateCommunity(
      UpdateCommunityRequest(
        community: community.copyWith(bannerImageUrl: url),
        keys: ['bannerImageUrl'],
      ),
    );
    analytics.logEvent(
      AnalyticsUpdateCommunityImageEvent(communityId: community.id),
    );
  }

  Future<void> updateProfilePic(String url) async {
    await cloudFunctionsService.updateCommunity(
      UpdateCommunityRequest(
        community: community.copyWith(profileImageUrl: url),
        keys: ['profileImageUrl'],
      ),
    );
    analytics.logEvent(
      AnalyticsUpdateCommunityImageEvent(communityId: community.id),
    );
  }

  Future<bool> donationsEnabled() async {
    final response = await cloudFunctionsService.getCommunityDonationsEnabled(
      GetCommunityDonationsEnabledRequest(communityId: community.id),
    );
    return response.donationsEnabled;
  }

  Future<bool> prePostEnabled() async {
    final response = await cloudFunctionsService.getCommunityPrePostEnabled(
      GetCommunityPrePostEnabledRequest(communityId: community.id),
    );
    return response.prePostEnabled;
  }

  Future<void> addNewOnboardingStep(OnboardingStep onboardingStep) async {
    final onboardingSteps = List.of(community.onboardingSteps);
    final isOnboardingStepAlreadyExists =
        onboardingSteps.any((element) => element == onboardingStep);

    if (isOnboardingStepAlreadyExists) {
      loggingService.log(
        'CommunityProvider.addNewOnboardingStep: Community: ${community.id}. Onboarding step already exists $onboardingStep',
      );
      return;
    }

    onboardingSteps.add(onboardingStep);
    loggingService.log(
      'CommunityProvider.addNewOnboardingStep: Community: ${community.id}. Adding new onboarding step $onboardingStep',
    );

    await cloudFunctionsService.updateCommunity(
      UpdateCommunityRequest(
        community: community.copyWith(onboardingSteps: onboardingSteps),
        keys: [Community.kFieldOnboardingSteps],
      ),
    );
    analytics.logEvent(
      AnalyticsUpdateCommunityImageEvent(communityId: community.id),
    );

    notifyListeners();
  }

  OnboardingStep? getCurrentOnboardingStep() {
    final currentOnboardingSteps = community.onboardingSteps.toList();

    // If no items in the steps list, return very first onboarding step
    if (currentOnboardingSteps.isEmpty) {
      return OnboardingStep.values
          .firstWhere((element) => element.positionInOnboarding == 1);
    }

    // Find missing onboarding steps, because user can perform onboarding not in order.
    // 1. Find all missing steps
    // 2. Sort them asc, so that we know very first step will be the next one to take.
    final missingOnboardingStepsAsc = List.of(OnboardingStep.values)
        .where(
          (onboardingStep) => !currentOnboardingSteps.any(
            (existingOnboardingStep) =>
                existingOnboardingStep == onboardingStep,
          ),
        )
        .toList()
      ..sort(
        (a, b) => a.positionInOnboarding.compareTo(b.positionInOnboarding),
      );

    if (!kShowStripeFeatures) {
      missingOnboardingStepsAsc.remove(OnboardingStep.createStripeAccount);
    }

    // If there are no items in missing onboarding list, it means user finished all onboarding.
    if (missingOnboardingStepsAsc.isNotEmpty) {
      return missingOnboardingStepsAsc.first;
    }

    // Onboarding fully completed
    return null;
  }

  bool isOnboardingStepCompleted(OnboardingStep onboardingStep) {
    return community.onboardingSteps
        .any((element) => element == onboardingStep);
  }

  static CommunityProvider watch(BuildContext context) =>
      Provider.of<CommunityProvider>(context);

  static CommunityProvider read(BuildContext context) =>
      Provider.of<CommunityProvider>(context, listen: false);

  static CommunityProvider? readOrNull(BuildContext context) => providerOrNull(
        () => Provider.of<CommunityProvider>(context, listen: false),
      );
}
