import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/services.dart';
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
  final freeTextResponseController = TextEditingController();

  List<BreakoutQuestion> get surveyQuestions => _surveyQuestions;

  BreakoutQuestion? get freeTextQuestion => _surveyQuestions
      .firstWhereOrNull((q) => q.type == BreakoutQuestionType.freeText);

  void initialize() {
    final breakoutQuestions =
        eventProvider.event.breakoutRoomDefinition?.breakoutQuestions ?? [];

    _surveyQuestions = breakoutQuestions.map((b) => b.copyWith()).toList();
    freeTextResponseController.text = freeTextQuestion?.freeTextAnswer ?? '';
    zipCodeController.addListener(notifyListeners);
    freeTextResponseController.addListener(_onFreeTextResponseChanged);
  }

  @override
  void dispose() {
    zipCodeController.removeListener(notifyListeners);
    freeTextResponseController.removeListener(_onFreeTextResponseChanged);
    zipCodeController.dispose();
    freeTextResponseController.dispose();
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

  void _onFreeTextResponseChanged() {
    final question = freeTextQuestion;
    if (question == null) return;

    final questionIndex = _surveyQuestions.indexWhere(
      (q) => q.id == question.id,
    );
    _surveyQuestions[questionIndex] = _surveyQuestions[questionIndex]
        .copyWith(freeTextAnswer: freeTextResponseController.text);

    notifyListeners();
  }

  bool checkSurveyCompleted() {
    return surveyQuestions.every((q) {
      if (q.type == BreakoutQuestionType.freeText) {
        return !isNullOrEmpty(q.freeTextAnswer);
      }
      return q.answerOptionId.isNotEmpty;
    });
  }
}
