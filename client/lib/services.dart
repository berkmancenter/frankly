import 'package:client/core/data/services/cloud_functions.dart';
import 'package:client/features/admin/data/services/cloud_functions_payments_service.dart';
import 'package:client/features/announcements/data/services/cloud_functions_announcements_service.dart';
import 'package:client/features/community/data/services/cloud_functions_community_service.dart';
import 'package:client/features/events/data/services/cloud_functions_event_service.dart';
import 'package:client/features/events/features/live_meeting/data/services/cloud_functions_live_meeting_service.dart';
import 'package:get_it/get_it.dart';
import 'package:client/core/data/services/analytics_service.dart';
import 'package:client/core/data/services/clock_service.dart';
import 'package:client/core/localization/app_localization_service.dart';
import 'package:client/features/admin/data/services/firestore_agreements_service.dart';
import 'package:client/features/announcements/data/services/firestore_announcements_service.dart';
import 'package:client/features/admin/data/services/firestore_billing_subscriptions_service.dart';
import 'package:client/features/chat/data/services/firestore_chat_service.dart';
import 'package:client/core/data/services/firestore_database.dart';
import 'package:client/features/events/data/services/firestore_event_service.dart';
import 'package:client/features/discussion_threads/data/services/firestore_discussion_thread_comments_service.dart';
import 'package:client/features/discussion_threads/data/services/firestore_discussion_threads_service.dart';
import 'package:client/features/community/data/services/firestore_community_join_requests_service.dart';
import 'package:client/features/resources/data/services/firestore_community_resource_service.dart';
import 'package:client/features/events/features/live_meeting/data/services/firestore_live_meeting_service.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/data/services/firestore_meeting_guide_service.dart';
import 'package:client/features/community/data/services/firestore_membership_service.dart';
import 'package:client/features/user/data/services/firestore_private_user_data_service.dart';
import 'package:client/core/data/services/firestore_tag_service.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/services/firestore_user_agenda_service.dart';
import 'package:client/features/user/data/services/firestore_user_service.dart';
import 'package:client/features/user/data/services/user_data_service.dart';
import 'package:client/core/data/services/location_service.dart';
import 'package:client/core/data/services/logging_service.dart';
import 'package:client/core/data/services/media_helper_service.dart';
import 'package:client/core/data/services/responsive_layout_service.dart';
import 'package:client/core/data/services/shared_preferences_service.dart';
import 'package:client/features/admin/data/services/stripe_client_service.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:client/core/data/providers/dialog_provider.dart';
import 'package:client/features/admin/utils/payment_utils.dart';
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

ClockService get clockService => services.get<ClockService>();
UserDataService get userDataService => services.get<UserDataService>();
QueryParametersService get queryParametersService =>
    services.get<QueryParametersService>();
SharedPreferencesService get sharedPreferencesService =>
    services.get<SharedPreferencesService>();
UserService get userService => services.get<UserService>();

CloudFunctionsAnnouncementsService get cloudFunctionsAnnouncementsService =>
    services.get<CloudFunctionsAnnouncementsService>();
CloudFunctionsCommunityService get cloudFunctionsCommunityService =>
    services.get<CloudFunctionsCommunityService>();
CloudFunctionsEventService get cloudFunctionsEventService =>
    services.get<CloudFunctionsEventService>();
CloudFunctionsLiveMeetingService get cloudFunctionsLiveMeetingService =>
    services.get<CloudFunctionsLiveMeetingService>();
CloudFunctionsPaymentsService get cloudFunctionsPaymentsService =>
    services.get<CloudFunctionsPaymentsService>();

CloudFunctions get cloudFunctions => services.get<CloudFunctions>();

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
PaymentUtils get paymentUtils => services.get<PaymentUtils>();
AppLocalizationService get appLocalizationService =>
    services.get<AppLocalizationService>();

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

  services.registerSingleton(CloudFunctions());
  services.registerSingleton(CloudFunctionsAnnouncementsService());
  services.registerSingleton(CloudFunctionsCommunityService());
  services.registerSingleton(CloudFunctionsEventService());
  services.registerSingleton(CloudFunctionsLiveMeetingService());
  services.registerSingleton(CloudFunctionsPaymentsService());

  services.registerSingleton(ClockService());
  services.registerSingleton(UserDataService());
  services.registerSingleton(QueryParametersService());
  services.registerSingleton(SharedPreferencesService());
  services.registerSingleton(UserService());

  services.registerSingleton(AnalyticsService());

  services.registerSingleton(DialogProvider());
  services.registerSingleton(MediaHelperService());
  services.registerSingleton(StripeClientService());
  services.registerSingleton(PaymentUtils());
  services.registerSingleton(AppLocalizationService());
}

Future<void> initializeServices() async {
  await Future.wait([
    analytics.initialize(),
    userService.initialize(),
    firestoreDatabase.initialize(),
    userDataService.initialize(),
    cloudFunctions.initialize(),
    sharedPreferencesService.initialize(),
  ]);

  unawaited(clockService.initialize());
}
