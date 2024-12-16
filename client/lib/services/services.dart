import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get_it/get_it.dart';
import 'package:client/services/algolia_search_service.dart';
import 'package:client/services/analytics_service.dart';
import 'package:client/services/clock_service.dart';
import 'package:client/services/cloud_functions_service.dart';
import 'package:client/services/firestore/firestore_agreements_service.dart';
import 'package:client/services/firestore/firestore_announcements_service.dart';
import 'package:client/services/firestore/firestore_billing_subscriptions_service.dart';
import 'package:client/services/firestore/firestore_chat_service.dart';
import 'package:client/services/firestore/firestore_database.dart';
import 'package:client/services/firestore/firestore_event_service.dart';
import 'package:client/services/firestore/firestore_discussion_thread_comments_service.dart';
import 'package:client/services/firestore/firestore_discussion_threads_service.dart';
import 'package:client/services/firestore/firestore_community_join_requests_service.dart';
import 'package:client/services/firestore/firestore_community_resource_service.dart';
import 'package:client/services/firestore/firestore_live_meeting_service.dart';
import 'package:client/services/firestore/firestore_meeting_guide_service.dart';
import 'package:client/services/firestore/firestore_membership_service.dart';
import 'package:client/services/firestore/firestore_private_user_data_service.dart';
import 'package:client/services/firestore/firestore_tag_service.dart';
import 'package:client/services/firestore/firestore_user_agenda_service.dart';
import 'package:client/services/firestore/firestore_user_service.dart';
import 'package:client/services/user_data_service.dart';
import 'package:client/services/location_service.dart';
import 'package:client/services/logging_service.dart';
import 'package:client/services/media_helper_service.dart';
import 'package:client/services/responsive_layout_service.dart';
import 'package:client/services/shared_preferences_service.dart';
import 'package:client/services/stripe_client_service.dart';
import 'package:client/services/user_service.dart';
import 'package:client/utils/dialog_provider.dart';
import 'package:client/utils/payment_utils.dart';
import 'package:pedantic/pedantic.dart';

final services = GetIt.instance;

/// This getter immediately registers and returns a singleton. This is used because this can be
/// called before create is called below.
///
/// This is a temporary workaround (hopefully).
LoggingService get loggingService {
  if (!services.isRegistered<LoggingService>()) {
    services.registerSingleton(LoggingService());
  }
  return services.get<LoggingService>();
}

ResponsiveLayoutService get responsiveLayoutService {
  if (!services.isRegistered<ResponsiveLayoutService>()) {
    services.registerSingleton(ResponsiveLayoutService());
  }
  return services.get<ResponsiveLayoutService>();
}

// ******************* Regular initialisation *******************

AlgoliaSearchService get algoliaSearchService =>
    services.get<AlgoliaSearchService>();
ClockService get clockService => services.get<ClockService>();
UserDataService get userDataService => services.get<UserDataService>();
QueryParametersService get queryParametersService =>
    services.get<QueryParametersService>();
SharedPreferencesService get sharedPreferencesService =>
    services.get<SharedPreferencesService>();
UserService get userService => services.get<UserService>();

CloudFunctionsService get cloudFunctionsService =>
    services.get<CloudFunctionsService>();

FirestoreAgreementsService get firestoreAgreementsService =>
    services.get<FirestoreAgreementsService>();
FirestoreAnnouncementsService get firestoreAnnouncementsService =>
    services.get<FirestoreAnnouncementsService>();
FirestoreBillingSubscriptionsService get firestoreBillingSubscriptionsService =>
    services.get<FirestoreBillingSubscriptionsService>();
FirestoreChatService get firestoreChatService =>
    services.get<FirestoreChatService>();
FirestoreDatabase get firestoreDatabase => services.get<FirestoreDatabase>();
FirestoreEventService get firestoreEventService =>
    services.get<FirestoreEventService>();
FirestoreCommunityJoinRequestsService
    get firestoreCommunityJoinRequestsService =>
        services.get<FirestoreCommunityJoinRequestsService>();
FirestoreLiveMeetingService get firestoreLiveMeetingService =>
    services.get<FirestoreLiveMeetingService>();
FirestoreMembershipService get firestoreMembershipService =>
    services.get<FirestoreMembershipService>();
FirestoreMeetingGuideService get firestoreMeetingGuideService =>
    services.get<FirestoreMeetingGuideService>();
FirestorePrivateUserDataService get firestorePrivateUserDataService =>
    services.get<FirestorePrivateUserDataService>();
FirestoreUserAgendaService get firestoreUserAgendaService =>
    services.get<FirestoreUserAgendaService>();
FirestoreUserService get firestoreUserService =>
    services.get<FirestoreUserService>();
FirestoreCommunityResourceService get firestoreCommunityResourceService =>
    services.get<FirestoreCommunityResourceService>();
FirestoreTagService get firestoreTagService =>
    services.get<FirestoreTagService>();

DialogProvider get dialogProvider => services.get<DialogProvider>();

AnalyticsService get analytics => services.get<AnalyticsService>();
FirebaseAnalytics get firebaseAnalytics => services.get<FirebaseAnalytics>();
PaymentUtils get paymentUtils => services.get<PaymentUtils>();

/// This file initializes all of our "services" inside of GetIt. This is basically
/// just a rudimentary way of doing dependency injection. If we write tests for
/// individual widgets we can mock our services by injecting them into the [services]
/// object in this file. The getters above make it easy to access the services
/// throughout our code by just using the service name.
///
/// Ex: firestoreDatabase.createEvent('blah blah');
void createServices() {
  services.registerSingleton(FirestoreDatabase());
  services.registerSingleton(FirestoreAgreementsService());
  services.registerSingleton(FirestoreAnnouncementsService());
  services.registerSingleton(FirestoreBillingSubscriptionsService());
  services.registerSingleton(FirestoreChatService());
  services.registerSingleton(FirestoreEventService());
  services.registerSingleton(FirestoreDiscussionThreadCommentsService());
  services.registerSingleton(FirestoreDiscussionThreadsService());
  services.registerSingleton(FirestoreCommunityJoinRequestsService());
  services.registerSingleton(FirestoreLiveMeetingService());
  services.registerSingleton(FirestoreMembershipService());
  services.registerSingleton(FirestoreMeetingGuideService());
  services.registerSingleton(FirestorePrivateUserDataService());
  services.registerSingleton(FirestoreUserAgendaService());
  services.registerSingleton(FirestoreUserService());
  services.registerSingleton(FirestoreCommunityResourceService());
  services.registerSingleton(FirestoreTagService());
  services.registerSingleton(CloudFunctionsService());

  services.registerSingleton(AlgoliaSearchService());
  services.registerSingleton(ClockService());
  services.registerSingleton(UserDataService());
  services.registerSingleton(QueryParametersService());
  services.registerSingleton(SharedPreferencesService());
  services.registerSingleton(UserService());

  services.registerSingleton(AnalyticsService());
  services.registerSingleton(FirebaseAnalytics.instance);

  services.registerSingleton(DialogProvider());
  services.registerSingleton(MediaHelperService());
  services.registerSingleton(StripeClientService());
  services.registerSingleton(PaymentUtils());
}

Future<void> initializeServices() async {
  await Future.wait([
    userService.initialize(),
    firestoreDatabase.initialize(),
    userDataService.initialize(),
    cloudFunctionsService.initialize(),
    sharedPreferencesService.initialize(),
  ]);

  unawaited(clockService.initialize());
}
