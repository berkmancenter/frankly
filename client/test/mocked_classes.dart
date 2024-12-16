import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:junto/app/junto/admin/overview/overview_contract.dart';
import 'package:junto/app/junto/community_permissions_provider.dart';
import 'package:junto/app/junto/discussion_threads/discussion_thread/discussion_thread_contract.dart';
import 'package:junto/app/junto/discussion_threads/discussion_threads_contract.dart';
import 'package:junto/app/junto/discussion_threads/discussion_threads_helper.dart';
import 'package:junto/app/junto/discussion_threads/manipulate_discussion_thread/manipulate_discussion_thread_contract.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_page_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_permissions_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_settings/discussion_settings_contract.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_settings/discussion_settings_presenter.dart';
import 'package:junto/app/junto/discussions/discussion_page/edit_discussion/edit_discussion_contract.dart';
import 'package:junto/app/junto/discussions/discussion_page/edit_discussion/edit_discussion_presenter.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/live_meeting_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/meeting_guide/meeting_guide_card/items/user_suggestions/meeting_guide_card_item_user_suggestions_contract.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/meeting_guide/meeting_guide_card_store.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/video/conference/agora_room.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/video/conference/conference_room.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/video/conference/networking_status/networking_status_contract.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/agenda_item_card/agenda_item_contract.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/agenda_item_card/agenda_item_model.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/agenda_item_card/agenda_item_presenter.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/agenda_item_card/items/image/agenda_item_image_contract.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/agenda_item_card/items/image/agenda_item_image_presenter.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/agenda_item_card/items/poll/agenda_item_poll_contract.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/agenda_item_card/items/poll/agenda_item_poll_presenter.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/agenda_item_card/items/video/agenda_item_video_contract.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/agenda_item_card/items/video/agenda_item_video_presenter.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/meeting_agenda_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/pre_post_card_widget/pre_post_card_widget_contract.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/pre_post_card_widget/pre_post_card_widget_model.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/pre_post_card_widget/pre_post_card_widget_presenter.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/pre_post_discussion_dialog/pre_post_discussion_dialog_contract.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/pre_post_discussion_dialog/pre_post_discussion_dialog_model.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/pre_post_discussion_dialog/pre_post_discussion_dialog_presenter.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/templates/topic_page_provider.dart';
import 'package:junto/common_widgets/navbar/nav_bar/nav_bar_contract.dart';
import 'package:junto/common_widgets/user_admin_details_builder.dart';
import 'package:junto/services/clock_service.dart';
import 'package:junto/services/cloud_functions_service.dart';
import 'package:junto/services/firestore/firestore_agreements_service.dart';
import 'package:junto/services/firestore/firestore_database.dart';
import 'package:junto/services/firestore/firestore_discussion_service.dart';
import 'package:junto/services/firestore/firestore_discussion_thread_comments_service.dart';
import 'package:junto/services/firestore/firestore_discussion_threads_service.dart';
import 'package:junto/services/firestore/firestore_meeting_guide_service.dart';
import 'package:junto/services/logging_service.dart';
import 'package:junto/services/media_helper_service.dart';
import 'package:junto/services/responsive_layout_service.dart';
import 'package:junto/services/shared_preferences_service.dart';
import 'package:junto/services/user_service.dart';
import 'package:junto/utils/dialogs.dart';
import 'package:junto/utils/models_helper.dart';
import 'package:junto/utils/payment_utils.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/discussion_thread.dart';
import 'package:junto_models/firestore/discussion_thread_comment.dart';
import 'package:junto_models/firestore/emotion.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:junto_models/firestore/meeting_guide.dart';
import 'package:junto_models/firestore/partner_agreement.dart';
import 'package:junto_models/firestore/pre_post_card.dart';
import 'package:junto_models/firestore/pre_post_url_params.dart';
import 'package:junto_models/firestore/topic.dart';
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
  MockSpec<Discussion>(),
  MockSpec<DiscussionPageProvider>(),
  MockSpec<DiscussionPermissionsProvider>(),
  MockSpec<DiscussionProvider>(),
  MockSpec<DiscussionSettingsPresenterHelper>(),
  MockSpec<DiscussionSettingsView>(),
  MockSpec<DiscussionThread>(),
  MockSpec<DiscussionThreadComment>(),
  MockSpec<DiscussionThreadView>(),
  MockSpec<DiscussionThreadsHelper>(),
  MockSpec<DiscussionThreadsView>(),
  MockSpec<DocumentReference>(),
  MockSpec<DocumentSnapshot>(),
  MockSpec<EditDiscussionPresenterHelper>(),
  MockSpec<EditDiscussionView>(),
  MockSpec<Emotion>(),
  MockSpec<EmotionHelper>(),
  MockSpec<FirebaseAuth>(),
  MockSpec<FirebaseFirestore>(),
  MockSpec<FirestoreAgreementsService>(),
  MockSpec<FirestoreDatabase>(),
  MockSpec<FirestoreDiscussionService>(),
  MockSpec<FirestoreDiscussionThreadCommentsService>(),
  MockSpec<FirestoreDiscussionThreadsService>(),
  MockSpec<FirestoreMeetingGuideService>(),
  MockSpec<GlobalKey>(),
  MockSpec<ImagePicker>(),
  MockSpec<JuntoProvider>(),
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
  MockSpec<PrePostDiscussionDialogModel>(),
  MockSpec<PrePostDiscussionDialogPresenterHelper>(),
  MockSpec<PrePostDiscussionDialogView>(),
  MockSpec<PrePostUrlParams>(),
  MockSpec<Query>(),
  MockSpec<QuerySnapshot>(),
  MockSpec<RenderBox>(),
  MockSpec<ResponsiveLayoutService>(),
  MockSpec<ScaffoldState>(),
  MockSpec<SharedPreferencesService>(),
  MockSpec<Stream>(),
  MockSpec<Topic>(),
  MockSpec<TopicPageProvider>(),
  MockSpec<UserAdminDetailsProvider>(),
  MockSpec<UserService>(),
  MockSpec<WriteBatch>(),
  MockSpec<XFile>(),
  MockSpec<FunctionMock>(as: #MockFunction),
  MockSpec<UserService>(as: #MockUserServiceNullable, onMissingStub: null),
])
void main() {}
