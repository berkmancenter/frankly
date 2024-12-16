import 'package:flutter/material.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_provider.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/firestore/discussion.dart';

class SurveyPresenter extends ChangeNotifier {
  final JuntoProvider juntoProvider;
  final DiscussionProvider discussionProvider;

  SurveyPresenter({
    required this.juntoProvider,
    required this.discussionProvider,
  });

  late List<BreakoutQuestion> _surveyQuestions;

  final zipCodeController = TextEditingController();
  bool _optInAmericaTalks = true;

  bool get optInAmericaTalks => _optInAmericaTalks;
  set optInAmericaTalks(bool value) {
    _optInAmericaTalks = value;
    notifyListeners();
  }

  List<BreakoutQuestion> get surveyQuestions => _surveyQuestions;

  void initialize() {
    final breakoutQuestions =
        discussionProvider.discussion.breakoutRoomDefinition?.breakoutQuestions ?? [];

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
      loggingService.log('SurveyPresenter.setQuestionAnswer: question is null, questionID: $id');
      return;
    }

    _surveyQuestions[questionIndex] =
        _surveyQuestions[questionIndex].copyWith(answerOptionId: answerOptionId);

    notifyListeners();
  }

  bool checkSurveyCompleted() {
    final surveyCompleted = !surveyQuestions.any((q) => q.answerOptionId.isEmpty);

    final americaTalksCompleted = (zipCodeController.text.trim().isNotEmpty);

    return surveyCompleted && (!juntoProvider.isAmericaTalks || americaTalksCompleted);
  }
}
