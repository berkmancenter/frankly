import 'package:client/features/admin/data/services/cloud_functions_payments_service.dart';
import 'package:client/features/announcements/data/services/cloud_functions_announcements_service.dart';
import 'package:client/features/community/data/services/cloud_functions_community_service.dart';
import 'package:client/features/events/data/services/cloud_functions_event_service.dart';
import 'package:client/features/events/features/live_meeting/data/services/cloud_functions_live_meeting_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:client/features/admin/presentation/views/overview_contract.dart';
import 'package:client/features/community/data/providers/community_permissions_provider.dart';
import 'package:client/features/discussion_threads/presentation/views/discussion_thread_contract.dart';
import 'package:client/features/discussion_threads/presentation/views/discussion_threads_contract.dart';
import 'package:client/features/discussion_threads/data/services/discussion_threads_helper.dart';
import 'package:client/features/discussion_threads/presentation/views/manipulate_discussion_thread_contract.dart';
import 'package:client/features/events/features/event_page/data/providers/event_page_provider.dart';
import 'package:client/features/events/features/event_page/data/providers/event_permissions_provider.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/events/features/event_page/presentation/views/event_settings_contract.dart';
import 'package:client/features/events/features/event_page/presentation/event_settings_presenter.dart';
import 'package:client/features/events/features/edit_event/presentation/views/edit_event_contract.dart';
import 'package:client/features/events/features/edit_event/presentation/edit_event_presenter.dart';
import 'package:client/features/events/features/live_meeting/data/providers/live_meeting_provider.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/presentation/views/meeting_guide_card_item_user_suggestions_contract.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/data/providers/meeting_guide_card_store.dart';
import 'package:client/features/events/features/live_meeting/features/video/data/providers/agora_room.dart';
import 'package:client/features/events/features/live_meeting/features/video/data/providers/conference_room.dart';
import 'package:client/features/events/features/live_meeting/features/video/presentation/views/networking_status_contract.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/views/agenda_item_contract.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_model.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/agenda_item_presenter.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/views/agenda_item_image_contract.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/agenda_item_image_presenter.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/views/agenda_item_poll_contract.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/agenda_item_poll_presenter.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/views/agenda_item_video_contract.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/agenda_item_video_presenter.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/providers/meeting_agenda_provider.dart';
import 'package:client/features/events/features/event_page/presentation/views/pre_post_card_widget_contract.dart';
import 'package:client/features/events/features/event_page/data/models/pre_post_card_widget_model.dart';
import 'package:client/features/events/features/event_page/presentation/pre_post_card_widget_presenter.dart';
import 'package:client/features/events/features/event_page/presentation/views/pre_post_event_dialog_contract.dart';
import 'package:client/features/events/features/event_page/data/models/pre_post_event_dialog_model.dart';
import 'package:client/features/events/features/event_page/presentation/pre_post_event_dialog_presenter.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/features/templates/data/providers/template_page_provider.dart';
import 'package:client/core/widgets/navbar/nav_bar/nav_bar_contract.dart';
import 'package:client/features/community/data/providers/user_admin_details_builder.dart';
import 'package:client/core/data/services/clock_service.dart';
import 'package:client/features/admin/data/services/firestore_agreements_service.dart';
import 'package:client/core/data/services/firestore_database.dart';
import 'package:client/features/events/data/services/firestore_event_service.dart';
import 'package:client/features/discussion_threads/data/services/firestore_discussion_thread_comments_service.dart';
import 'package:client/features/discussion_threads/data/services/firestore_discussion_threads_service.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/data/services/firestore_meeting_guide_service.dart';
import 'package:client/core/data/services/logging_service.dart';
import 'package:client/core/data/services/media_helper_service.dart';
import 'package:client/core/data/services/responsive_layout_service.dart';
import 'package:client/core/data/services/shared_preferences_service.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:client/core/utils/dialogs.dart';
import 'package:client/features/discussion_threads/data/services/models_helper.dart';
import 'package:client/features/admin/utils/payment_utils.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/discussion_threads/discussion_thread.dart';
import 'package:data_models/discussion_threads/discussion_thread_comment.dart';
import 'package:data_models/chat/emotion.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/events/live_meetings/meeting_guide.dart';
import 'package:data_models/admin/partner_agreement.dart';
import 'package:data_models/events/pre_post_card.dart';
import 'package:data_models/events/pre_post_url_params.dart';
import 'package:data_models/templates/template.dart';
import 'package:mockito/annotations.dart';

import 'mock_function.dart';

/// Run 'flutter pub run build_runner build' in the console prior to executing tests
/// to generate mock classes for the classes below.
@GenerateNiceMocks([
  MockSpec<AgendaItem>(),
  MockSpec<AgendaItemHelper>(),
  MockSpec<AgendaItemImageHelper>(),
  MockSpec<AgendaItemImageView>(),
  MockSpec<AgendaItemModel>(),
  MockSpec<AgendaItemPollHelper>(),
  MockSpec<AgendaItemPollView>(),
  MockSpec<AgendaItemVideoHelper>(),
  MockSpec<AgendaItemVideoView>(),
  MockSpec<AgendaItemView>(),
  MockSpec<AgendaProvider>(),
  MockSpec<AgendaProviderParams>(),
  MockSpec<AgoraRoom>(),
  MockSpec<AgoraParticipant>(),
  MockSpec<AppDrawerProvider>(),
  MockSpec<BuildContext>(),
  MockSpec<ClockService>(),
  MockSpec<CloudFunctionsPaymentsService>(),
  MockSpec<CloudFunctionsCommunityService>(),
  MockSpec<CloudFunctionsEventService>(),
  MockSpec<CloudFunctionsLiveMeetingService>(),
  MockSpec<CloudFunctionsAnnouncementsService>(),
  MockSpec<CloudinaryFile>(),
  MockSpec<CloudinaryPublic>(),
  MockSpec<CloudinaryResponse>(),
  MockSpec<CollectionReference>(),
  MockSpec<CommunityPermissionsProvider>(),
  MockSpec<CommunitySettings>(),
  MockSpec<ConferenceRoom>(),
  MockSpec<Event>(),
  MockSpec<EventPageProvider>(),
  MockSpec<EventPermissionsProvider>(),
  MockSpec<EventProvider>(),
  MockSpec<EventSettingsPresenterHelper>(),
  MockSpec<EventSettingsView>(),
  MockSpec<DiscussionThread>(),
  MockSpec<DiscussionThreadComment>(),
  MockSpec<DiscussionThreadView>(),
  MockSpec<DiscussionThreadsHelper>(),
  MockSpec<DiscussionThreadsView>(),
  MockSpec<DocumentReference>(),
  MockSpec<DocumentSnapshot>(),
  MockSpec<EditEventPresenterHelper>(),
  MockSpec<EditEventView>(),
  MockSpec<Emotion>(),
  MockSpec<EmotionHelper>(),
  MockSpec<FirebaseAuth>(),
  MockSpec<FirebaseFirestore>(),
  MockSpec<FirestoreAgreementsService>(),
  MockSpec<FirestoreDatabase>(),
  MockSpec<FirestoreEventService>(),
  MockSpec<FirestoreDiscussionThreadCommentsService>(),
  MockSpec<FirestoreDiscussionThreadsService>(),
  MockSpec<FirestoreMeetingGuideService>(),
  MockSpec<GlobalKey>(),
  MockSpec<ImagePicker>(),
  MockSpec<CommunityProvider>(),
  MockSpec<LiveMeetingProvider>(),
  MockSpec<LoggingService>(),
  MockSpec<ManipulateDiscussionThreadView>(),
  MockSpec<MediaHelperService>(),
  MockSpec<MediaQueryData>(),
  MockSpec<MeetingGuideCardItemUserSuggestionsView>(),
  MockSpec<MeetingGuideCardStore>(),
  MockSpec<MeetingUserSuggestion>(),
  MockSpec<NavBarView>(),
  MockSpec<NetworkingStatusView>(),
  MockSpec<OverviewView>(),
  MockSpec<PartnerAgreement>(),
  MockSpec<PaymentUtils>(),
  MockSpec<PrePostCard>(),
  MockSpec<PrePostCardWidgetModel>(),
  MockSpec<PrePostCardWidgetPresenterHelper>(),
  MockSpec<PrePostCardWidgetView>(),
  MockSpec<PrePostEventDialogModel>(),
  MockSpec<PrePostEventDialogPresenterHelper>(),
  MockSpec<PrePostEventDialogView>(),
  MockSpec<PrePostUrlParams>(),
  MockSpec<Query>(),
  MockSpec<QuerySnapshot>(),
  MockSpec<RenderBox>(),
  MockSpec<ResponsiveLayoutService>(),
  MockSpec<ScaffoldState>(),
  MockSpec<SharedPreferencesService>(),
  MockSpec<Stream>(),
  MockSpec<Template>(),
  MockSpec<TemplatePageProvider>(),
  MockSpec<UserAdminDetailsProvider>(),
  MockSpec<UserService>(),
  MockSpec<WriteBatch>(),
  MockSpec<XFile>(),
  MockSpec<FunctionMock>(as: #MockFunction),
  MockSpec<UserService>(as: #MockUserServiceNullable, onMissingStub: null),
])
void main() {}
