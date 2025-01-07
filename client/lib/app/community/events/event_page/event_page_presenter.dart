import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:client/app/community/community_permissions_provider.dart';
import 'package:client/app/community/events/event_page/event_page_contract.dart';
import 'package:client/app/community/events/event_page/event_page_provider.dart';
import 'package:client/app/community/events/event_page/event_provider.dart';
import 'package:client/app/community/events/event_page/template_provider.dart';
import 'package:client/app/community/community_provider.dart';
import 'package:client/app/community/utils.dart';
import 'package:client/services/clock_service.dart';
import 'package:client/services/cloud_functions_service.dart';
import 'package:client/services/firestore/firestore_event_service.dart';
import 'package:client/services/logging_service.dart';
import 'package:client/services/services.dart';
import 'package:client/services/shared_preferences_service.dart';
import 'package:client/services/user_service.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/event_message.dart';
import 'package:data_models/community/member_details.dart';
import 'package:data_models/templates/template.dart';
import 'package:provider/provider.dart';

class EventPagePresenter {
  static const String kSubCollectionEventMessages = 'event-messages';

  final EventPageView _view;
  final CloudFunctionsService _cloudFunctionsService;
  final CommunityProvider _communityProvider;
  final TemplateProvider _templateProvider;
  final EventProvider _eventProvider;
  final UserService _userService;
  final SharedPreferencesService _sharedPreferencesService;
  final ClockService _clockService;
  final FirestoreEventService _firestoreEventService;
  final CommunityPermissionsProvider _communityPermissionsProvider;

  bool _isEditTemplateTooltipShown = false;

  bool get isEditTemplateTooltipShown => _isEditTemplateTooltipShown;

  EventPagePresenter(
    BuildContext context,
    this._view, {
    CloudFunctionsService? testCloudFunctionsService,
    CommunityProvider? communityProvider,
    TemplateProvider? templateProvider,
    EventPageProvider? eventPageProvider,
    EventProvider? eventProvider,
    UserService? userService,
    SharedPreferencesService? sharedPreferencesService,
    ClockService? clockService,
    FirestoreEventService? firestoreEventService,
    CommunityPermissionsProvider? communityPermissionsProvider,
  })  : _cloudFunctionsService = testCloudFunctionsService ??
            GetIt.instance<CloudFunctionsService>(),
        _communityProvider =
            communityProvider ?? context.read<CommunityProvider>(),
        _templateProvider =
            templateProvider ?? context.read<TemplateProvider>(),
        _eventProvider = eventProvider ?? context.read<EventProvider>(),
        _userService = userService ?? context.read<UserService>(),
        _sharedPreferencesService = sharedPreferencesService ??
            GetIt.instance<SharedPreferencesService>(),
        _clockService = clockService ?? GetIt.instance<ClockService>(),
        _firestoreEventService =
            firestoreEventService ?? GetIt.instance<FirestoreEventService>(),
        _communityPermissionsProvider = communityPermissionsProvider ??
            context.read<CommunityPermissionsProvider>();

  String get eventPath =>
      '${_eventProvider.event.collectionPath}/${_eventProvider.event.id}';

  void init() async {
    final event = await _eventProvider.eventStream.first;
    _isEditTemplateTooltipShown = event.templateId != defaultTemplateId &&
        _communityPermissionsProvider.canModerateContent &&
        _sharedPreferencesService.isEditTemplateTooltipShown();
    _view.updateView();
  }

  Future<void> sendMessage(String message) async {
    final EventMessage eventMessage = EventMessage(
      creatorId: _userService.currentUserId!,
      createdAt: _clockService.now(),
      message: message,
    );

    await _cloudFunctionsService.sendEventMessage(
      SendEventMessageRequest(
        communityId: _communityProvider.communityId,
        templateId: _eventProvider.templateId,
        eventId: _eventProvider.eventId,
        eventMessage: eventMessage,
      ),
    );
  }

  Future<void> removeMessage(EventMessage eventMessage) async {
    final docId = eventMessage.docId;

    if (docId == null) {
      loggingService.log(
        'EventPagePresenter.removeMessage: DocID is null. EventMessage: ${eventMessage.toJson()}',
        logType: LogType.error,
      );
      return;
    }

    await _firestoreEventService
        .eventReference(
          communityId: _communityProvider.communityId,
          templateId: _eventProvider.templateId,
          eventId: _eventProvider.eventId,
        )
        .collection(kSubCollectionEventMessages)
        .doc(docId)
        .delete();
  }

  Future<void> refreshEvent() async {
    await _eventProvider.refreshEvent(
      _templateProvider.template,
      _eventProvider.event,
    );
  }

  Future<GetMeetingChatsSuggestionsDataResponse> getChatsAndSuggestions() {
    return _cloudFunctionsService.getMeetingChatSuggestionData(
      request: GetMeetingChatsSuggestionsDataRequest(
        eventPath: eventPath,
      ),
    );
  }

  Future<List<MemberDetails>> getMembersData(List<String> userIds) async {
    return await _userService.getMemberDetails(
      membersList: userIds,
      communityId: _communityProvider.communityId,
      eventPath: eventPath,
    );
  }

  Template getCombinedTemplateFromEvent() {
    final event = _eventProvider.event;
    final currentTemplate = _templateProvider.template;

    return currentTemplate.copyWith(
      title: event.title,
      image: event.image,
      agendaItems: event.agendaItems,
      preEventCardData: event.preEventCardData,
      postEventCardData: event.postEventCardData,
      prerequisiteTemplateId: event.prerequisiteTemplateId,
    );
  }

  Future<void> deleteAgendaItems() async {
    final eventDetails = _eventProvider.event.copyWith(agendaItems: []);
    await _firestoreEventService.updateEvent(
      event: eventDetails,
      keys: [Event.kFieldAgendaItems],
    );
    _view.updateView();
    _view.showMessage(
      'Agenda items were removed',
      toastType: ToastType.success,
    );
  }

  void hideEditTooltip() {
    // Update UI state immediately without causing any loading
    _isEditTemplateTooltipShown = false;
    _view.updateView();

    // Update shared prefs afterwards
    _sharedPreferencesService.updateEditTemplateTooltipVisibility(false);
  }
}
