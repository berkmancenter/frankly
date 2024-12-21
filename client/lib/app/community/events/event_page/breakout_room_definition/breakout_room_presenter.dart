import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:client/app/community/events/event_page/event_provider.dart';
import 'package:client/app/community/utils.dart';
import 'package:client/app.dart';
import 'package:client/services/logging_service.dart';
import 'package:client/services/services.dart';
import 'package:data_models/events/event.dart';

enum BreakoutCardViewType {
  overview,
  edit,
}

class BreakoutRoomPresenter extends ChangeNotifier {
  static final BreakoutRoomDefinition defaultBreakoutRoomDefinition =
      BreakoutRoomDefinition(
    creatorId: userService.currentUserId,
    targetParticipants: 8,
    breakoutQuestions: [],
    categories: [],
    assignmentMethod: BreakoutAssignmentMethod.targetPerRoom,
  );

  static const List<String> _kAlphabet = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
  ];

  final List<BreakoutCategory> _unsavedCategories = [];
  bool get isCategoryNotSaved => _unsavedCategories.isNotEmpty;

  final void Function(String message, ToastType toastType) showRegularToast;
  final EventProvider eventProvider;

  BreakoutRoomPresenter({
    required this.showRegularToast,
    required this.eventProvider,
  });

  late BreakoutRoomDefinition _breakoutRoomDefinition;

  BreakoutRoomDefinition get breakoutRoomDefinitionDetails =>
      _breakoutRoomDefinition;

  void initialize() {
    _breakoutRoomDefinition = eventProvider.event.breakoutRoomDefinition ??
        eventProvider.defaultBreakoutRoomDefinition;
    addInitialCategories();
  }

  Future<void> updateAssignmentMethod({
    required BreakoutAssignmentMethod assignmentMethod,
  }) async {
    _breakoutRoomDefinition =
        _breakoutRoomDefinition.copyWith(assignmentMethod: assignmentMethod);
    await _updateEventDetails();
  }

  Future<void> updateParticipants({required int participantsNumber}) async {
    _breakoutRoomDefinition = _breakoutRoomDefinition.copyWith(
      targetParticipants: participantsNumber,
    );
    await _updateEventDetails();
  }

  void addQuestion() {
    final questions = _breakoutRoomDefinition.breakoutQuestions;
    if (questions.isNotEmpty &&
        !isQuestionAndAnswersCompleted(questions.last)) {
      showRegularToast(
        'Please complete previous question and both answers',
        ToastType.failed,
      );
    } else {
      _breakoutRoomDefinition.breakoutQuestions.add(
        BreakoutQuestion(
          id: uuid.v4(),
          title: '',
          answerOptionId: '',
          answers: [
            BreakoutAnswer(
              id: uuid.v4(),
              options: [
                BreakoutAnswerOption(id: uuid.v4(), title: 'Yes'),
              ],
            ),
            BreakoutAnswer(
              id: uuid.v4(),
              options: [
                BreakoutAnswerOption(id: uuid.v4(), title: 'No'),
              ],
            ),
          ],
        ),
      );
      notifyListeners();
    }
  }

  bool isQuestionAndAnswersCompleted(BreakoutQuestion question) {
    final questionEmpty = isNullOrEmpty(question.title);
    final options = question.answers.map((e) => e.options).flattened.toList();
    final answersEntered = question.answers.length >= 2;
    final answersEmpty = options.any((option) => isNullOrEmpty(option.title));

    return !questionEmpty && answersEntered && !answersEmpty;
  }

  bool _areAllQuestionsCompleted() {
    return breakoutRoomDefinitionDetails.breakoutQuestions.every(
      (breakoutQuestion) => isQuestionAndAnswersCompleted(breakoutQuestion),
    );
  }

  void updateQuestionData({
    required String question,
    required String questionId,
  }) {
    final breakoutQuestionIndex =
        _breakoutRoomDefinition.breakoutQuestions.indexWhere(
      (element) => element.id == questionId,
    );
    if (breakoutQuestionIndex == -1) {
      loggingService.log(
        'BreakoutRoomPresenter.updateQuestionData: breakoutQuestionIndex is -1, ID: $questionId',
        logType: LogType.error,
      );
      return;
    }

    _breakoutRoomDefinition.breakoutQuestions[breakoutQuestionIndex] =
        _breakoutRoomDefinition.breakoutQuestions[breakoutQuestionIndex]
            .copyWith(title: question);
    notifyListeners();
  }

  void updateQuestionAnswerData({
    required String value,
    required String questionId,
    required BreakoutAnswerOption breakoutAnswerOption,
  }) {
    final questionIndex = _breakoutRoomDefinition.breakoutQuestions
        .indexWhere((element) => element.id == questionId);
    final option = breakoutAnswerOption.copyWith(title: value);
    final question = getQuestion(questionId);
    final answerIndex = question.answers.indexWhere(
      (answer) =>
          answer.options.any((option) => option.id == breakoutAnswerOption.id),
    );
    final answer = question.answers[answerIndex];
    final optionIndex = answer.options
        .indexWhere((element) => element.id == breakoutAnswerOption.id);

    _breakoutRoomDefinition.breakoutQuestions[questionIndex]
        .answers[answerIndex].options[optionIndex] = option;

    notifyListeners();
  }

  BreakoutQuestion getQuestion(String questionId) {
    return _breakoutRoomDefinition.breakoutQuestions.firstWhere(
      (element) => element.id == questionId,
    );
  }

  Future<bool> updateBreakoutRoomQuestion() async {
    final areAllQuestionsCompleted = _areAllQuestionsCompleted();

    if (!areAllQuestionsCompleted) {
      showRegularToast(
        'Please complete all your questions and answers!',
        ToastType.failed,
      );
      return false;
    } else {
      await _updateEventDetails();
      showRegularToast('Question saved!', ToastType.success);
      return true;
    }
  }

  Future<void> deleteBreakoutRoomQuestion(String questionId) async {
    _breakoutRoomDefinition.breakoutQuestions
        .removeWhere((element) => element.id == questionId);
    await _updateEventDetails();
    showRegularToast('Question deleted!', ToastType.success);
  }

  Future<void> _updateEventDetails() async {
    _breakoutRoomDefinition.breakoutQuestions
        .removeWhere((q) => isNullOrEmpty(q.title));
    _breakoutRoomDefinition = _breakoutRoomDefinition.copyWith(
      breakoutQuestions: _breakoutRoomDefinition.breakoutQuestions,
      categories: _breakoutRoomDefinition.categories,
    );

    final event = eventProvider.event
        .copyWith(breakoutRoomDefinition: breakoutRoomDefinitionDetails);

    await firestoreEventService.updateEvent(
      event: event,
      keys: [Event.kFieldBreakoutRoomDefinition],
    );

    showRegularToast('Breakout Updated!', ToastType.success);
    notifyListeners();
  }

  void reorderQuestions({
    required int draggedIndex,
    required int newPositionIndex,
  }) {
    final removed =
        breakoutRoomDefinitionDetails.breakoutQuestions.removeAt(draggedIndex);
    breakoutRoomDefinitionDetails.breakoutQuestions
        .insert(newPositionIndex, removed);
    notifyListeners();
  }

  Future<void> saveReorder() async {
    final areAllQuestionsCompleted = _areAllQuestionsCompleted();

    if (areAllQuestionsCompleted) {
      await _updateEventDetails();
    } else {
      showRegularToast(
        'Reordering not saved until all questions are completed.',
        ToastType.failed,
      );
    }
  }

  void addCategory() {
    _breakoutRoomDefinition.categories
        .add(BreakoutCategory(id: uuid.v4(), category: ''));
    notifyListeners();
  }

  void updateCategoryData({required String category, required int position}) {
    _breakoutRoomDefinition.categories[position] = _breakoutRoomDefinition
        .categories[position]
        .copyWith(category: category);
    setCategoryUnsaved(category: _breakoutRoomDefinition.categories[position]);

    notifyListeners();
  }

  BreakoutCategory? getCategory(int position) {
    return _breakoutRoomDefinition.categories[position];
  }

  Future<void> updateBreakoutRoomCategory() async {
    _breakoutRoomDefinition.categories
        .removeWhere((q) => isNullOrEmpty(q.category));
    if (_breakoutRoomDefinition.categories.length < 2) {
      return showRegularToast(
        'You must add atleast two (2) categories.',
        ToastType.failed,
      );
    }
    _unsavedCategories.clear();
    setCategoryUnsaved();
    await _updateEventDetails();
  }

  Future<void> deleteBreakoutRoomCategory(int position) async {
    final category = _breakoutRoomDefinition.categories[position];
    _breakoutRoomDefinition.categories.removeAt(position);
    _unsavedCategories.removeWhere((element) => element.id == category.id);
    await _updateEventDetails();
  }

  void addInitialCategories() {
    if (_breakoutRoomDefinition.categories.length < 2) {
      _breakoutRoomDefinition = _breakoutRoomDefinition.copyWith(
        categories: [
          BreakoutCategory(id: uuid.v4(), category: ''),
          BreakoutCategory(id: uuid.v4(), category: ''),
        ],
      );
    }
  }

  void setCategoryUnsaved({BreakoutCategory? category}) {
    if (category == null) return;
    if (category.category.isNotEmpty) {
      _unsavedCategories.add(category);
    } else {
      _unsavedCategories.removeWhere((element) => element.id == category.id);
    }
    notifyListeners();
  }

  int getQuestionPosition(String questionId) {
    return _breakoutRoomDefinition.breakoutQuestions.indexWhere(
      (element) => element.id == questionId,
    );
  }

  /// Gets text for the label.
  ///
  /// If item is first, it will generate `Answer 1`
  /// If item is second (and further), it will generate Answer 1B,...Answer 1Z.
  String getLabelText(
    List<BreakoutAnswerOption> breakoutAnswerOptions,
    String id,
    int answerIndex,
  ) {
    final answerOptionPosition =
        breakoutAnswerOptions.indexWhere((element) => element.id == id);
    if (answerOptionPosition == -1) {
      return '';
    }

    if (answerOptionPosition == 0) {
      return 'Answer ${answerIndex + 1}';
    }

    final alphabetLetterIndex = answerOptionPosition % _kAlphabet.length;

    return 'Answer ${answerIndex + 1}${_kAlphabet[alphabetLetterIndex]}';
  }

  void addAnswer(BreakoutAnswer breakoutAnswer) {
    breakoutAnswer.options.add(BreakoutAnswerOption(id: uuid.v4(), title: ''));
    notifyListeners();
  }

  void removeAnswerOption(
    BreakoutAnswer breakoutAnswer,
    String answerOptionId,
  ) {
    breakoutAnswer.options
        .removeWhere((element) => element.id == answerOptionId);
    notifyListeners();
  }
}
