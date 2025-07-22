import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:client/core/localization/app_localization_service.dart';

/// Test helper functions for setting up common test dependencies
class TestHelpers {
  /// Initialize GetIt and AppLocalizationService for tests
  static void setupLocalizationForTests() {
    // Check if already registered, if so skip setup
    if (GetIt.instance.isRegistered<AppLocalizationService>()) {
      try {
        // Create a minimal mock localization and set it
        final mockLocalizations = _MockAppLocalizations();
        GetIt.instance.get<AppLocalizationService>().setLocalization(mockLocalizations);
      } catch (e) {
        // If error setting localization, service might be in bad state, reset and try again
        GetIt.instance.unregister<AppLocalizationService>();
        GetIt.instance.registerSingleton<AppLocalizationService>(AppLocalizationService());
        final mockLocalizations = _MockAppLocalizations();
        GetIt.instance.get<AppLocalizationService>().setLocalization(mockLocalizations);
      }
      return;
    }
    
    // Register AppLocalizationService
    GetIt.instance.registerSingleton<AppLocalizationService>(AppLocalizationService());
    
    // Create a minimal mock localization and set it
    final mockLocalizations = _MockAppLocalizations();
    GetIt.instance.get<AppLocalizationService>().setLocalization(mockLocalizations);
  }
  
  /// Clean up GetIt registrations after tests
  static Future<void> cleanupAfterTests() async {
    await GetIt.instance.reset();
  }
}

/// Minimal mock implementation of AppLocalizations for testing
class _MockAppLocalizations extends AppLocalizations {
  _MockAppLocalizations() : super('en');
  
  // Override only the methods we need for testing
  @override
  String get lookingGood => 'Looking Good';
  
  @override
  String get getPeopleTalking => 'Get People Talking';
  
  @override
  String get getItOnTheBooks => 'Get It On The Books';
  
  @override
  String get startProcessingPayments => 'Start Processing Payments';
  
  @override
  String get brandSpace => 'Brand Space';
  
  @override
  String get createGuide => 'Create Guide';
  
  @override
  String get hostEvent => 'Host Event';
  
  @override
  String get inviteYourPeople => 'Invite Your People';
  
  @override
  String get linkYourStripeAccount => 'Link Your Stripe Account';
  
  // Add more getters as needed for other tests
  @override
  String deleteAgendaItemName(Object name) => 'Delete $name';
  
  @override
  String get cancel => 'Cancel';
  
  @override
  String whatMessageDoYouWantToShowParticipantsBeforeAfterTheEvent(String type) => 'What message do you want to show participants before/after the event?';
  
  @override
  String addActionLinksParticipantsShouldVisitBeforeAfterTheEvent(String type) => 'Add action links participants should visit before/after the event';
  
  // Event type titles
  @override
  String get hosted => 'Hosted';
  
  @override
  String get hostless => 'Hostless';
  
  @override
  String get livestream => 'Livestream';
  
  // Agenda item type titles
  @override
  String get question => 'Question';
  
  @override
  String get wordCloud => 'Word Cloud';
  
  @override
  String get suggestions => 'Suggestions';
  
  @override
  String get video => 'Video';
  
  @override
  String get image => 'Image';
  
  // For text agenda items - this might be a method that returns a default title
  @override
  String get textTitle => 'Text Title';
  
  // Error messages for agenda item validation
  @override
  String get questionIsRequired => 'Question is required';
  
  @override
  String get answersIsRequired => 'Please add some answers';
  
  @override
  String get wordCloudPromptIsRequired => 'Word Cloud prompt is required';
  
  @override
  String get titleIsRequired => 'Title is required';
  
  @override
  String get imageUrlIsRequired => 'Image URL is required';
  
  @override
  String get videoUrlIsRequired => 'Video URL is required';
  
  @override
  String get contentIsRequired => 'Content is required';
  
  @override
  String get messageIsRequired => 'Message is required';
  
  // Override the noSuchMethod to return empty string for any missing getters
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.isGetter) {
      return 'Mock String';
    }
    return super.noSuchMethod(invocation);
  }
} 