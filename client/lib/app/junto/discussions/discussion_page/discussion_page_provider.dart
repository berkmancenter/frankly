import 'dart:async';

import 'package:beamer/beamer.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/meeting_of_america_partner_dialog.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/pre_post_discussion_dialog/pre_post_discussion_dialog_page.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/smart_match_survey/survey_dialog.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/confirm_dialog.dart';
import 'package:junto/common_widgets/navbar/nav_bar_provider.dart';
import 'package:junto/common_widgets/sign_in_dialog.dart';
import 'package:junto/junto_app.dart';
import 'package:junto/services/firestore/firestore_utils.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/analytics/analytics_entities.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/junto_tag.dart';

import '../../../../routing/locations.dart';

class JoinDiscussionResults {
  final bool isJoined;
  final List<BreakoutQuestion>? surveyQuestions;

  JoinDiscussionResults({required this.isJoined, this.surveyQuestions});
}

Future<bool> verifyAvailableForDiscussion(Discussion discussion) async {
  final date = DateFormat('E, MMM d').format(discussion.scheduledTime!);
  final time = DateFormat('h:mm a').format(discussion.scheduledTime!);

  final cancel = await ConfirmDialog(
    title: 'Confirm',
    subText:
        'Please confirm that you are available at $time on $date to participate in this event.',
    confirmText: 'I\'ll be there!',
    cancelText: 'No, cancel',
  ).show();
  return cancel;
}

class DiscussionPageProvider with ChangeNotifier {
  final DiscussionProvider discussionProvider;
  final JuntoProvider juntoProvider;
  final NavBarProvider navBarProvider;
  final bool cancelParam;

  bool _cancelProcessed = false;
  bool _isEnteredMeeting = false;
  bool _isInstant = false;

  late BehaviorSubjectWrapper<List<JuntoTag>> _tagsStream;
  late StreamSubscription _tagListener;

  DiscussionPageProvider({
    required this.discussionProvider,
    required this.juntoProvider,
    required this.navBarProvider,
    required this.cancelParam,
  });

  bool get isEnteredMeeting => _isEnteredMeeting;
  bool get isInstant => _isInstant;

  List<JuntoTag> get tags => _tagsStream.stream.valueOrNull?.take(5).toList() ?? [];

  Future<JoinDiscussionResults> joinDiscussion({
    bool showConfirm = true,
    bool joinJunto = false,
  }) async {
    final prePostEnabledFuture = discussionProvider.juntoProvider.prePostEnabled();

    final joinResults = await guardSignedIn<JoinDiscussionResults>(() async {
          // Wait for self participant stream to load
          await discussionProvider.selfParticipantStream?.first;
          if (discussionProvider.isParticipant) {
            return JoinDiscussionResults(isJoined: true);
          }
          if (discussionProvider.isBanned) {
            return JoinDiscussionResults(isJoined: false);
          }

          if (discussionProvider.discussion.discussionType == DiscussionType.hosted &&
              showConfirm) {
            final confirmed = await verifyAvailableForDiscussion(discussionProvider.discussion);
            if (!confirmed) {
              return JoinDiscussionResults(isJoined: false);
            }
          }

          final hasSurveyQuestions =
              discussionProvider.discussion.breakoutRoomDefinition?.breakoutQuestions.isNotEmpty ??
                  false;
          final showSurveyDialog = hasSurveyQuestions &&
              (!discussionProvider.discussion.isHosted ||
                  discussionProvider.allowPredefineBreakoutsOnHosted);
          SurveyDialogResult? surveyDialogResult;
          if (showSurveyDialog) {
            surveyDialogResult = await SurveyDialog.show(
              juntoProvider: juntoProvider,
              discussionProvider: discussionProvider,
            );

            if (surveyDialogResult == null) return JoinDiscussionResults(isJoined: false);
          }

          if (juntoProvider.isMeetingOfAmerica && !useBotControls) {
            final partner = await MeetingOfAmericaPartnerDialog.show();
            if (partner != null) {
              queryParametersService.addQueryParameters({'moa-partner': partner});
            }
          }

          await firestoreDiscussionService.joinDiscussion(
            juntoId: discussionProvider.juntoId,
            topicId: discussionProvider.topicId,
            discussionId: discussionProvider.discussionId,
            breakoutRoomSurveyResults: surveyDialogResult,
          );

          analytics.logEvent(AnalyticsRsvpDiscussionEvent(
            juntoId: discussionProvider.juntoId,
            discussionId: discussionProvider.discussionId,
            guideId: discussionProvider.topicId,
          ));

          if (joinJunto) {
            await juntoUserDataService.requestChangeJuntoMembership(
              junto: discussionProvider.juntoProvider.junto,
              join: true,
            );
          }

          unawaited(swallowErrors(
              () => cloudFunctionsService.joinDiscussion(discussionProvider.discussion)));
          return JoinDiscussionResults(
            isJoined: true,
            surveyQuestions: surveyDialogResult?.questions,
          );
        }) ??
        JoinDiscussionResults(isJoined: false);

    final prePostEnabled = await prePostEnabledFuture;
    final preEventCardData = discussionProvider.discussion.preEventCardData;
    if (prePostEnabled && joinResults.isJoined && preEventCardData != null) {
      if (preEventCardData.hasData) {
        await PrePostDiscussionDialogPage.show(
          prePostCardData: preEventCardData,
          discussion: discussionProvider.discussion,
          isMeetingOfAmerica: discussionProvider.juntoProvider.isMeetingOfAmerica,
        );
      }
    }

    return joinResults;
  }

  Future<void> enterMeeting({List<BreakoutQuestion>? surveyQuestions}) async {
    final participant = await discussionProvider.selfParticipantStream!.first;
    final participantAnswers = surveyQuestions ?? participant.breakoutRoomSurveyQuestions;
    final currentSurveyQuestions =
        discussionProvider.discussion.breakoutRoomDefinition?.breakoutQuestions ?? [];
    final questionsMatch = listEquals(
        participantAnswers
            .map((q) => BreakoutQuestion(
                  id: q.id,
                  title: q.title,
                  answerOptionId: '',
                  answers: q.answers,
                ))
            .toList(),
        currentSurveyQuestions
            .map((q) => BreakoutQuestion(
                  id: q.id,
                  title: q.title,
                  answerOptionId: '',
                  answers: q.answers,
                ))
            .toList());
    final answeredAllQuestions = participantAnswers.every((q) => q.answerOptionId.isNotEmpty);

    final showSurveyDialog = (!questionsMatch || !answeredAllQuestions) &&
        (currentSurveyQuestions.isNotEmpty) &&
        (!discussionProvider.discussion.isHosted ||
            discussionProvider.allowPredefineBreakoutsOnHosted);
    if (showSurveyDialog) {
      final surveyDialogResult = await SurveyDialog.show(
        juntoProvider: juntoProvider,
        discussionProvider: discussionProvider,
      );

      if (surveyDialogResult == null) {
        return;
      }

      await firestoreDiscussionService.updateParticipantBreakoutSurveyAnswers(
        discussion: discussionProvider.discussion,
        surveyDialogResult: surveyDialogResult,
      );
    }

    navBarProvider.forceHideNav();
    _isEnteredMeeting = true;
    notifyListeners();
  }

  void initialize() {
    if (userService.isSignedIn &&
        (routerDelegate.currentBeamLocation?.state as BeamState).queryParameters['status'] ==
            'joined') {
      unawaited(Future.microtask(() async {
        // Wait to load if the user is a participant or not and only enter the meeting if so.
        await discussionProvider.selfParticipantStream?.first;
        if (discussionProvider.isParticipant) {
          _isInstant = true;
          await enterMeeting();
        }
      }));
    }

    final testEmail =
        (routerDelegate.currentBeamLocation?.state as BeamState).queryParameters['test'];
    if (testEmail != null) {
      _setupTest(testEmail);
    }

    if (cancelParam && !_cancelProcessed) {
      _cancelProcessed = true;
      _processCancelParam();
    }

    _tagsStream = wrapInBehaviorSubject(firestoreTagService.getJuntoTags(
      juntoId: juntoProvider.juntoId,
      taggedItemId: discussionProvider.topicId,
      taggedItemType: TaggedItemType.topic,
    ));
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
    await joinDiscussion(showConfirm: false);

    // Enter meeting
    await enterMeeting();
  }

  Future<bool> cancelDiscussion() async {
    final cancel = await ConfirmDialog(
      title: 'Cancel Event',
      mainText: 'Are you sure you want to cancel event? This '
          'cannot be undone and will notify all participants.',
      confirmText: 'Yes, cancel',
    ).show();
    if (!cancel) return false;

    await firestoreDiscussionService.updateDiscussion(
      discussion: discussionProvider.discussion.copyWith(
        status: DiscussionStatus.canceled,
      ),
      keys: [Discussion.kFieldStatus],
    );

    return true;
  }

  Future<void> _processCancelParam() async {
    if (!userService.isSignedIn) {
      await Future.microtask(() => SignInDialog.show());
    }

    if (!userService.isSignedIn) return;

    Discussion discussion;
    try {
      discussion = await discussionProvider.discussionStream.first;
      await discussionProvider.selfParticipantStream!.first;
    } catch (e) {
      loggingService.log('Error during cancel param processing', error: e);
      return;
    }

    if (discussion.creatorId == userService.currentUserId) {
      await cancelDiscussion();
    } else if (discussionProvider.isParticipant) {
      final cancelParticipation = await ConfirmDialog(
        title: 'Cancel Participation',
        mainText: 'Are you sure you want to cancel?',
        confirmText: 'Yes, cancel',
      ).show();
      if (cancelParticipation) {
        await alertOnError(
          navigatorState.context,
          () => firestoreDiscussionService.removeParticipant(
            juntoId: discussion.juntoId,
            topicId: discussion.topicId,
            discussionId: discussion.id,
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
