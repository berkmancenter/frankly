import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:client/app/community/admin/overview/overview_contract.dart';
import 'package:client/app/community/community_permissions_provider.dart';
import 'package:client/app/community/discussion_threads/discussion_thread/discussion_thread_contract.dart';
import 'package:client/app/community/discussion_threads/discussion_threads_contract.dart';
import 'package:client/app/community/discussion_threads/discussion_threads_helper.dart';
import 'package:client/app/community/discussion_threads/manipulate_discussion_thread/manipulate_discussion_thread_contract.dart';
import 'package:client/app/community/events/event_page/event_page_provider.dart';
import 'package:client/app/community/events/event_page/event_permissions_provider.dart';
import 'package:client/app/community/events/event_page/event_provider.dart';
import 'package:client/app/community/events/event_page/event_settings/event_settings_contract.dart';
import 'package:client/app/community/events/event_page/event_settings/event_settings_presenter.dart';
import 'package:client/app/community/events/event_page/edit_event/edit_event_contract.dart';
import 'package:client/app/community/events/event_page/edit_event/edit_event_presenter.dart';
import 'package:client/app/community/events/event_page/live_meeting/live_meeting_provider.dart';
import 'package:client/app/community/events/event_page/live_meeting/meeting_guide/meeting_guide_card/items/user_suggestions/meeting_guide_card_item_user_suggestions_contract.dart';
import 'package:client/app/community/events/event_page/live_meeting/meeting_guide/meeting_guide_card_store.dart';
import 'package:client/app/community/events/event_page/live_meeting/video/conference/agora_room.dart';
import 'package:client/app/community/events/event_page/live_meeting/video/conference/conference_room.dart';
import 'package:client/app/community/events/event_page/live_meeting/video/conference/networking_status/networking_status_contract.dart';
import 'package:client/app/community/events/event_page/meeting_agenda/agenda_item_card/agenda_item_contract.dart';
import 'package:client/app/community/events/event_page/meeting_agenda/agenda_item_card/agenda_item_model.dart';
import 'package:client/app/community/events/event_page/meeting_agenda/agenda_item_card/agenda_item_presenter.dart';
import 'package:client/app/community/events/event_page/meeting_agenda/agenda_item_card/items/image/agenda_item_image_contract.dart';
import 'package:client/app/community/events/event_page/meeting_agenda/agenda_item_card/items/image/agenda_item_image_presenter.dart';
import 'package:client/app/community/events/event_page/meeting_agenda/agenda_item_card/items/poll/agenda_item_poll_contract.dart';
import 'package:client/app/community/events/event_page/meeting_agenda/agenda_item_card/items/poll/agenda_item_poll_presenter.dart';
import 'package:client/app/community/events/event_page/meeting_agenda/agenda_item_card/items/video/agenda_item_video_contract.dart';
import 'package:client/app/community/events/event_page/meeting_agenda/agenda_item_card/items/video/agenda_item_video_presenter.dart';
import 'package:client/app/community/events/event_page/meeting_agenda/meeting_agenda_provider.dart';
import 'package:client/app/community/events/event_page/widgets/pre_post_card_widget/pre_post_card_widget_contract.dart';
import 'package:client/app/community/events/event_page/widgets/pre_post_card_widget/pre_post_card_widget_model.dart';
import 'package:client/app/community/events/event_page/widgets/pre_post_card_widget/pre_post_card_widget_presenter.dart';
import 'package:client/app/community/events/event_page/widgets/pre_post_event_dialog/pre_post_event_dialog_contract.dart';
import 'package:client/app/community/events/event_page/widgets/pre_post_event_dialog/pre_post_event_dialog_model.dart';
import 'package:client/app/community/events/event_page/widgets/pre_post_event_dialog/pre_post_event_dialog_presenter.dart';
import 'package:client/app/community/community_provider.dart';
import 'package:client/app/community/templates/template_page_provider.dart';
import 'package:client/common_widgets/navbar/nav_bar/nav_bar_contract.dart';
import 'package:client/common_widgets/user_admin_details_builder.dart';
import 'package:client/services/clock_service.dart';
import 'package:client/services/cloud_functions_service.dart';
import 'package:client/services/firestore/firestore_agreements_service.dart';
import 'package:client/services/firestore/firestore_database.dart';
import 'package:client/services/firestore/firestore_event_service.dart';
import 'package:client/services/firestore/firestore_discussion_thread_comments_service.dart';
import 'package:client/services/firestore/firestore_discussion_threads_service.dart';
import 'package:client/services/firestore/firestore_meeting_guide_service.dart';
import 'package:client/services/logging_service.dart';
import 'package:client/services/media_helper_service.dart';
import 'package:client/services/responsive_layout_service.dart';
import 'package:client/services/shared_preferences_service.dart';
import 'package:client/services/user_service.dart';
import 'package:client/utils/dialogs.dart';
import 'package:client/utils/models_helper.dart';
import 'package:client/utils/payment_utils.dart';
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
  MockSpec<CloudFunctionsService>(),
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
