import 'dart:async';

import 'package:beamer/beamer.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:client/app/community/events/event_page/event_provider.dart';
import 'package:client/app/community/events/event_page/widgets/pre_post_event_dialog/pre_post_event_dialog_page.dart';
import 'package:client/app/community/events/event_page/widgets/smart_match_survey/survey_dialog.dart';
import 'package:client/app/community/community_provider.dart';
import 'package:client/app/community/utils.dart';
import 'package:client/common_widgets/confirm_dialog.dart';
import 'package:client/common_widgets/navbar/nav_bar_provider.dart';
import 'package:client/common_widgets/sign_in_dialog.dart';
import 'package:client/app.dart';
import 'package:client/services/firestore/firestore_utils.dart';
import 'package:client/services/services.dart';
import 'package:data_models/analytics/analytics_entities.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/community/community_tag.dart';

import '../../../../routing/locations.dart';

class JoinEventResults {
  final bool isJoined;
  final List<BreakoutQuestion>? surveyQuestions;

  JoinEventResults({required this.isJoined, this.surveyQuestions});
}

Future<bool> verifyAvailableForEvent(Event event) async {
  final date = DateFormat('E, MMM d').format(event.scheduledTime!);
  final time = DateFormat('h:mm a').format(event.scheduledTime!);

  final cancel = await ConfirmDialog(
    title: 'Confirm',
    subText:
        'Please confirm that you are available at $time on $date to participate in this event.',
    confirmText: 'I\'ll be there!',
    cancelText: 'No, cancel',
  ).show();
  return cancel;
}

class EventPageProvider with ChangeNotifier {
  final EventProvider eventProvider;
  final CommunityProvider communityProvider;
  final NavBarProvider navBarProvider;
  final bool cancelParam;

  bool _cancelProcessed = false;
  bool _isEnteredMeeting = false;
  bool _isInstant = false;

  late BehaviorSubjectWrapper<List<CommunityTag>> _tagsStream;
  late StreamSubscription _tagListener;

  EventPageProvider({
    required this.eventProvider,
    required this.communityProvider,
    required this.navBarProvider,
    required this.cancelParam,
  });

  bool get isEnteredMeeting => _isEnteredMeeting;
  bool get isInstant => _isInstant;

  List<CommunityTag> get tags =>
      _tagsStream.stream.valueOrNull?.take(5).toList() ?? [];

  Future<JoinEventResults> joinEvent({
    bool showConfirm = true,
    bool joinCommunity = false,
  }) async {
    final prePostEnabledFuture =
        eventProvider.communityProvider.prePostEnabled();

    final joinResults = await guardSignedIn<JoinEventResults>(() async {
          // Wait for self participant stream to load
          await eventProvider.selfParticipantStream?.first;
          if (eventProvider.isParticipant) {
            return JoinEventResults(isJoined: true);
          }
          if (eventProvider.isBanned) {
            return JoinEventResults(isJoined: false);
          }

          if (eventProvider.event.eventType == EventType.hosted &&
              showConfirm) {
            final confirmed = await verifyAvailableForEvent(
              eventProvider.event,
            );
            if (!confirmed) {
              return JoinEventResults(isJoined: false);
            }
          }

          final hasSurveyQuestions = eventProvider
                  .event.breakoutRoomDefinition?.breakoutQuestions.isNotEmpty ??
              false;
          final showSurveyDialog = hasSurveyQuestions &&
              (!eventProvider.event.isHosted ||
                  eventProvider.allowPredefineBreakoutsOnHosted);
          SurveyDialogResult? surveyDialogResult;
          if (showSurveyDialog) {
            surveyDialogResult = await SurveyDialog.show(
              communityProvider: communityProvider,
              eventProvider: eventProvider,
            );

            if (surveyDialogResult == null) {
              return JoinEventResults(isJoined: false);
            }
          }

          await firestoreEventService.joinEvent(
            communityId: eventProvider.communityId,
            templateId: eventProvider.templateId,
            eventId: eventProvider.eventId,
            breakoutRoomSurveyResults: surveyDialogResult,
          );

          analytics.logEvent(
            AnalyticsRsvpEventEvent(
              communityId: eventProvider.communityId,
              eventId: eventProvider.eventId,
              guideId: eventProvider.templateId,
            ),
          );

          if (joinCommunity) {
            await userDataService.requestChangeCommunityMembership(
              community: eventProvider.communityProvider.community,
              join: true,
            );
          }

          unawaited(
            swallowErrors(
              () => cloudFunctionsService.joinEvent(eventProvider.event),
            ),
          );
          return JoinEventResults(
            isJoined: true,
            surveyQuestions: surveyDialogResult?.questions,
          );
        }) ??
        JoinEventResults(isJoined: false);

    final prePostEnabled = await prePostEnabledFuture;
    final preEventCardData = eventProvider.event.preEventCardData;
    if (prePostEnabled && joinResults.isJoined && preEventCardData != null) {
      if (preEventCardData.hasData) {
        await PrePostEventDialogPage.show(
          prePostCardData: preEventCardData,
          event: eventProvider.event,
        );
      }
    }

    return joinResults;
  }

  Future<void> enterMeeting({List<BreakoutQuestion>? surveyQuestions}) async {
    final participant = await eventProvider.selfParticipantStream!.first;
    final participantAnswers =
        surveyQuestions ?? participant.breakoutRoomSurveyQuestions;
    final currentSurveyQuestions =
        eventProvider.event.breakoutRoomDefinition?.breakoutQuestions ?? [];
    final questionsMatch = listEquals(
      participantAnswers
          .map(
            (q) => BreakoutQuestion(
              id: q.id,
              title: q.title,
              answerOptionId: '',
              answers: q.answers,
            ),
          )
          .toList(),
      currentSurveyQuestions
          .map(
            (q) => BreakoutQuestion(
              id: q.id,
              title: q.title,
              answerOptionId: '',
              answers: q.answers,
            ),
          )
          .toList(),
    );
    final answeredAllQuestions =
        participantAnswers.every((q) => q.answerOptionId.isNotEmpty);

    final showSurveyDialog = (!questionsMatch || !answeredAllQuestions) &&
        (currentSurveyQuestions.isNotEmpty) &&
        (!eventProvider.event.isHosted ||
            eventProvider.allowPredefineBreakoutsOnHosted);
    if (showSurveyDialog) {
      final surveyDialogResult = await SurveyDialog.show(
        communityProvider: communityProvider,
        eventProvider: eventProvider,
      );

      if (surveyDialogResult == null) {
        return;
      }

      await firestoreEventService.updateParticipantBreakoutSurveyAnswers(
        event: eventProvider.event,
        surveyDialogResult: surveyDialogResult,
      );
    }

    navBarProvider.forceHideNav();
    _isEnteredMeeting = true;
    notifyListeners();
  }

  void initialize() {
    if (userService.isSignedIn &&
        (routerDelegate.currentBeamLocation.state as BeamState)
                .queryParameters['status'] ==
            'joined') {
      unawaited(
        Future.microtask(() async {
          // Wait to load if the user is a participant or not and only enter the meeting if so.
          await eventProvider.selfParticipantStream?.first;
          if (eventProvider.isParticipant) {
            _isInstant = true;
            await enterMeeting();
          }
        }),
      );
    }

    final testEmail = (routerDelegate.currentBeamLocation.state as BeamState)
        .queryParameters['test'];
    if (testEmail != null) {
      _setupTest(testEmail);
    }

    if (cancelParam && !_cancelProcessed) {
      _cancelProcessed = true;
      _processCancelParam();
    }

    _tagsStream = wrapInBehaviorSubject(
      firestoreTagService.getCommunityTags(
        communityId: communityProvider.communityId,
        taggedItemId: eventProvider.templateId,
        taggedItemType: TaggedItemType.template,
      ),
    );
    _tagListener = _tagsStream.stream.listen((tags) {
      notifyListeners();
    });
  }

  Future<void> _setupTest(String email) async {
    // Sign in with email
    await userService.registerWithEmail(
      displayName: email,
      email: email,
      password: 'password',
    );

    await Future.delayed(Duration(seconds: 5));

    // Register
    await joinEvent(showConfirm: false);

    // Enter meeting
    await enterMeeting();
  }

  Future<bool> cancelEvent() async {
    final cancel = await ConfirmDialog(
      title: 'Cancel Event',
      mainText: 'Are you sure you want to cancel event? This '
          'cannot be undone and will notify all participants.',
      confirmText: 'Yes, cancel',
    ).show();
    if (!cancel) return false;

    await firestoreEventService.updateEvent(
      event: eventProvider.event.copyWith(
        status: EventStatus.canceled,
      ),
      keys: [Event.kFieldStatus],
    );

    return true;
  }

  Future<void> _processCancelParam() async {
    if (!userService.isSignedIn) {
      await Future.microtask(() => SignInDialog.show());
    }

    if (!userService.isSignedIn) return;

    Event event;
    try {
      event = await eventProvider.eventStream.first;
      await eventProvider.selfParticipantStream!.first;
    } catch (e) {
      loggingService.log('Error during cancel param processing', error: e);
      return;
    }

    if (event.creatorId == userService.currentUserId) {
      await cancelEvent();
    } else if (eventProvider.isParticipant) {
      final cancelParticipation = await ConfirmDialog(
        title: 'Cancel Participation',
        mainText: 'Are you sure you want to cancel?',
        confirmText: 'Yes, cancel',
      ).show();
      if (cancelParticipation) {
        await alertOnError(
          navigatorState.context,
          () => firestoreEventService.removeParticipant(
            communityId: event.communityId,
            templateId: event.templateId,
            eventId: event.id,
            participantId: userService.currentUserId!,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tagListener.cancel();
    _tagsStream.dispose();
    super.dispose();
  }
}
