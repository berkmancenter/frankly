import 'dart:async';

import 'package:flutter/material.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/navbar/nav_bar_provider.dart';
import 'package:junto/junto_app.dart';
import 'package:junto/services/firestore/firestore_utils.dart';
import 'package:junto/services/services.dart';
import 'package:junto/utils/extensions.dart';
import 'package:junto_models/analytics/analytics_entities.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:junto_models/firestore/junto_resource.dart';
import 'package:provider/provider.dart';

class JuntoProvider with ChangeNotifier {
  final String _displayId;
  final NavBarProvider navBarProvider;

  JuntoProvider({
    required String displayId,
    required this.navBarProvider,
  }) : _displayId = displayId;

  late BehaviorSubjectWrapper<Junto> _junto;
  late BehaviorSubjectWrapper<List<Featured>> _featured;
  late BehaviorSubjectWrapper<List<JuntoResource>> _resources;
  BehaviorSubjectWrapper<bool>? _hasTopics;

  late StreamSubscription _juntoListener;
  late StreamSubscription _featuredListener;
  late StreamSubscription _resourcesListener;
  StreamSubscription? _hasTopicsListener;

  bool get enableHostless => settings.enableHostless;

  Junto get junto {
    final juntoValue = _junto.stream.valueOrNull;
    if (juntoValue == null) {
      throw Exception('Junto must be loaded before being accessed.');
    }

    return juntoValue;
  }

  String get juntoId => junto.id;

  String get displayId => junto.displayId;

  Stream<Junto> get juntoStream => _junto.stream;

  Stream<List<Featured>> get featuredStream => _featured.stream;

  BehaviorSubjectWrapper<List<JuntoResource>> get resourcesStream => _resources;

  List<Featured> get featuredItems => _featured.stream.valueOrNull ?? [];

  bool get hasResources => _resources.stream.valueOrNull?.isNotEmpty ?? false;

  bool get hasTopics => _hasTopics?.value ?? false;

  bool get isUnifyAmerica => juntoId == 'unify-america';
  bool get isMeetingOfAmerica => juntoId == 'meetingofamerica';
  bool get isAmericaTalks => juntoId == 'america-talks' || juntoId == 'CWPWy0JEovERcH1roZ4F';

  bool get isDeliberations => juntoId == 'deliberations-us' || juntoId == 'deliberations-us-dev';

  CommunitySettings get settings => junto.settingsMigration;

  DiscussionSettings get discussionSettings => junto.discussionSettingsMigration;

  void initialize() {
    _junto = firestoreDatabase.juntoStream(_displayId);
    _juntoListener = _junto.stream.listen((junto) {
      notifyListeners();
      navBarProvider.setCurrentJunto(junto);
      _hasTopics ??= _listenForTopics(junto.id);
      _hasTopicsListener ??= _hasTopics?.stream.listen((value) {
        notifyListeners();
      });
    });

    _featured = wrapInBehaviorSubject(_getFeaturedItems());
    _featuredListener = _featured.stream.listen((featured) {
      notifyListeners();
    });

    loadResources();
  }

  BehaviorSubjectWrapper<bool> _listenForTopics(String juntoId) {
    return wrapInBehaviorSubject(firestoreDatabase.juntoHasTopicsStream(juntoId));
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
    final junto = await _junto.stream.first;

    yield* firestoreDatabase.getJuntoFeaturedItems(junto.id).stream;
  }

  Stream<List<JuntoResource>> _getResources() async* {
    final junto = await _junto.stream.first;
    Stream<List<JuntoResource>> _stream =
        firestoreJuntoResourceService.getJuntoResources(juntoId: junto.id);
    yield* _stream;
  }

  @override
  void dispose() {
    _juntoListener.cancel();
    _featuredListener.cancel();
    _resourcesListener.cancel();
    _hasTopicsListener?.cancel();
    _resources.dispose();
    _junto.dispose();
    _featured.dispose();
    _hasTopics?.dispose();
    super.dispose();
  }

  Future<void> updateBanner(String url) async {
    await cloudFunctionsService.updateJunto(UpdateJuntoRequest(
      junto: junto.copyWith(bannerImageUrl: url),
      keys: ['bannerImageUrl'],
    ));
    analytics.logEvent(AnalyticsUpdateJuntoImageEvent(juntoId: junto.id));
  }

  Future<void> updateProfilePic(String url) async {
    await cloudFunctionsService.updateJunto(UpdateJuntoRequest(
      junto: junto.copyWith(profileImageUrl: url),
      keys: ['profileImageUrl'],
    ));
    analytics.logEvent(AnalyticsUpdateJuntoImageEvent(juntoId: junto.id));
  }

  Future<bool> donationsEnabled() async {
    final response = await cloudFunctionsService
        .getJuntoDonationsEnabled(GetJuntoDonationsEnabledRequest(juntoId: junto.id));
    return response.donationsEnabled;
  }

  Future<bool> prePostEnabled() async {
    final response = await cloudFunctionsService
        .getJuntoPrePostEnabled(GetJuntoPrePostEnabledRequest(juntoId: junto.id));
    return response.prePostEnabled;
  }

  Future<void> addNewOnboardingStep(OnboardingStep onboardingStep) async {
    final onboardingSteps = List.of(junto.onboardingSteps);
    final isOnboardingStepAlreadyExists =
        onboardingSteps.any((element) => element == onboardingStep);

    if (isOnboardingStepAlreadyExists) {
      loggingService.log(
          'JuntoProvider.addNewOnboardingStep: Junto: ${junto.id}. Onboarding step already exists $onboardingStep');
      return;
    }

    onboardingSteps.add(onboardingStep);
    loggingService.log(
        'JuntoProvider.addNewOnboardingStep: Junto: ${junto.id}. Adding new onboarding step $onboardingStep');

    await cloudFunctionsService.updateJunto(
      UpdateJuntoRequest(
        junto: junto.copyWith(onboardingSteps: onboardingSteps),
        keys: [Junto.kFieldOnboardingSteps],
      ),
    );
    analytics.logEvent(AnalyticsUpdateJuntoImageEvent(juntoId: junto.id));

    notifyListeners();
  }

  OnboardingStep? getCurrentOnboardingStep() {
    final currentOnboardingSteps = junto.onboardingSteps.toList();

    // If no items in the steps list, return very first onboarding step
    if (currentOnboardingSteps.isEmpty) {
      return OnboardingStep.values.firstWhere((element) => element.positionInOnboarding == 1);
    }

    // Find missing onboarding steps, because user can perform onboarding not in order.
    // 1. Find all missing steps
    // 2. Sort them asc, so that we know very first step will be the next one to take.
    final missingOnboardingStepsAsc = List.of(OnboardingStep.values)
        .where((onboardingStep) => !currentOnboardingSteps
            .any((existingOnboardingStep) => existingOnboardingStep == onboardingStep))
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
    return junto.onboardingSteps.any((element) => element == onboardingStep);
  }

  static JuntoProvider watch(BuildContext context) => Provider.of<JuntoProvider>(context);

  static JuntoProvider read(BuildContext context) =>
      Provider.of<JuntoProvider>(context, listen: false);

  static JuntoProvider? readOrNull(BuildContext context) =>
      providerOrNull(() => Provider.of<JuntoProvider>(context, listen: false));
}
