import 'package:flutter/material.dart';
import 'package:client/app/community/events/event_page/event_provider.dart';
import 'package:client/app/community/community_provider.dart';
import 'package:client/services/services.dart';
import 'package:data_models/events/event.dart';

class SurveyPresenter extends ChangeNotifier {
  final CommunityProvider communityProvider;
  final EventProvider eventProvider;

  SurveyPresenter({
    required this.communityProvider,
    required this.eventProvider,
  });

  late List<BreakoutQuestion> _surveyQuestions;

  final zipCodeController = TextEditingController();

  List<BreakoutQuestion> get surveyQuestions => _surveyQuestions;

  void initialize() {
    final breakoutQuestions =
        eventProvider.event.breakoutRoomDefinition?.breakoutQuestions ?? [];

    _surveyQuestions = breakoutQuestions.map((b) => b.copyWith()).toList();
    zipCodeController.addListener(notifyListeners);
  }

  @override
  void dispose() {
    zipCodeController.removeListener(notifyListeners);
    super.dispose();
  }

  void setQuestionAnswer({required String id, required String answerOptionId}) {
    final questionIndex = _surveyQuestions.indexWhere((q) => q.id == id);

    if (questionIndex < 0) {
      loggingService.log(
        'SurveyPresenter.setQuestionAnswer: question is null, questionID: $id',
      );
      return;
    }

    _surveyQuestions[questionIndex] = _surveyQuestions[questionIndex]
        .copyWith(answerOptionId: answerOptionId);

    notifyListeners();
  }

  bool checkSurveyCompleted() {
    final surveyCompleted =
        !surveyQuestions.any((q) => q.answerOptionId.isEmpty);

    return surveyCompleted;
  }
}
