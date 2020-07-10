import 'dart:async';

import 'package:cons_calc_lib/src/dynamic_forms_repository.dart';
import 'package:flutter/material.dart';
import 'package:cons_calc_lib/cons_calc_lib.dart';
import 'package:rxdart/rxdart.dart';

class DynamicFormBloc {
  final String initialFormId;
  final DynamicFormsRepository repository;

  List<DynamicForm> get _forms => _formsController.value;
  Map<String, Map> _formResults;
  int _currentFormIndex;
  Question _firstQuestion;

  // Streams
  Stream<String> get initialFormTitle => _initialFormTitleController.stream;
  ValueObservable<Map<String, Map>> get currentFormResults =>
      _currentFormResultsController.stream;
  ValueObservable<ButtonStatus> get nextButtonStatus =>
      _nextButtonStatusController.stream;
  ValueObservable<Question> get currentQuestion =>
      _currentQuestionController.stream;
  ValueObservable<List<String>> get previousQuestions =>
      _previousQuestionsController.stream;
  ValueObservable<DynamicForm> get currentForm => _currentFormController.stream;
  Stream<List<DynamicForm>> get forms => _formsController.stream;
  Stream<bool> get isKeyboardVisible => _isKeyboardVisibleController.stream;
  Stream<bool> get isFirstQuestion => _isFirstQuestionController.stream;
  Stream<Map<String, String>> get greetingData =>
      _greetingDataController.stream;

  // Controllers
  final _initialFormTitleController = StreamController<String>();
  final _currentFormResultsController = BehaviorSubject<Map<String, Map>>();
  final _nextButtonStatusController = BehaviorSubject<ButtonStatus>();
  final _currentQuestionController = BehaviorSubject<Question>();
  final _previousQuestionsController = BehaviorSubject<List<String>>.seeded([]);
  final _currentFormController = BehaviorSubject<DynamicForm>();
  final _currentCardPageController = BehaviorSubject<double>();
  final _currentTitlePageController = PublishSubject<double>();
  final _titlesController = BehaviorSubject<List<String>>.seeded([]);
  final _formsController = BehaviorSubject<List<DynamicForm>>();
  final _isKeyboardVisibleController = BehaviorSubject<bool>();
  final _isFirstQuestionController = StreamController<bool>();
  final _greetingDataController = StreamController<Map<String, String>>();

  // Getters
  bool get _isCurrentQuestionAnswered =>
      currentFormResults.value != null &&
      currentFormResults.value[currentQuestion.value.id] != null;
  Answer get _currentAnswer => _isCurrentQuestionAnswered &&
          currentFormResults.value[currentQuestion.value.id][Answer.ID] != null
      ? currentQuestion.value.answers.singleWhere(
          (a) =>
              a.id ==
              currentFormResults.value[currentQuestion.value.id][Answer.ID],
          orElse: () => null)
      : null;

  //
  // CONSTRUCTOR
  DynamicFormBloc({
    @required this.initialFormId,
    @required this.repository,
  }) {
    repository.getFormWithId(initialFormId).then((initialForm) {
      repository.initialForm = initialForm;
      _initialFormTitleController.add(initialForm.title);
      _formsController.add([initialForm]);
      _currentFormController.add(initialForm);
      _firstQuestion = initialForm.questions.first;
      _greetingDataController.add({
        "title": initialForm.greetingTitle,
        "subtitle": initialForm.greetingSubtitle,
      });
      currentQuestion.listen((currentQuestion) =>
          _isFirstQuestionController.add(_firstQuestion == currentQuestion));
      _currentQuestionController.add(initialForm.questions.first);

      _formResults = {};
      _currentFormIndex = 0;
    });
  }

  // METHODS
  void setValue(Answer answer, dynamic value) {
    Map<String, Map> results = currentFormResults.value ?? {};

    results[currentQuestion.value.id] = {
      Question.LABEL: currentQuestion.value.label,
      Answer.LABEL: answer.label,
      Answer.ID: answer.id,
      "value": value,
      Question.QUESTION_PURPOSE: currentQuestion.value.questionPurpose,
    };
    _currentFormResultsController.add(results);

    _updateButtonStatus();
  }

  void nextQuestion() {
    _previousQuestionsController
        .add(previousQuestions.value..add(currentQuestion.value.id));

    Question question = currentForm.value.questions.singleWhere(
      (q) => q.id == _currentAnswer.nextQuestionId,
      orElse: () => null,
    );
    _currentQuestionController.add(question);

    _updateButtonStatus();
  }

  void saveAndRestartForm() {
    _formResults[currentForm.value.id] = currentFormResults.value;
    _previousQuestionsController.add([]);
    _currentQuestionController.add(currentForm.value.questions
        .singleWhere((q) => q.id == _currentAnswer.nextQuestionId));
    _currentFormResultsController.add(null);

    _updateButtonStatus();
  }

  /// Saves the form results from the current form. Then checks if there are
  /// more forms to be shown.
  ///
  /// Returns true if there are more forms to show. False if not
  Future<bool> finishAndSaveForm() async {
    List<DynamicForm> forms = _forms;
    bool newFormsAdded = false;

    _formResults[currentForm.value.id] = currentFormResults.value;
    repository.uploadFormResults(currentFormResults.value);

    for (Map answerData in currentFormResults.value.values) {
      if (answerData[Question.QUESTION_PURPOSE] == QuestionPurpose.ADD_FORM) {
        if (answerData["value"] is String && answerData["value"] != null) {
          DynamicForm form =
              await repository.getFormWithId(answerData["value"]);
          forms.add(form);
        } else if (answerData["value"] is List) {
          for (String formId in answerData["value"]) {
            DynamicForm form = await repository.getFormWithId(formId);
            forms.add(form);
          }
        }
        newFormsAdded = true;
      }
    }
    if (newFormsAdded) _formsController.add(forms);

    // There are more forms to show
    if (_forms.length > _currentFormIndex + 1) {
      _currentFormIndex++;
      _previousQuestionsController.add([]);

      _currentFormController.add(_forms[_currentFormIndex]);
      _currentQuestionController.add(currentForm.value.questions.first);
      _currentFormResultsController.add(null);

      _updateButtonStatus();
      return true;
    }

    // It's the last form
    repository.updateFormResults(_formResults);

    return false;
  }

  void _updateButtonStatus() {
    if (_isCurrentQuestionAnswered) {
      if (_currentAnswer.restartForm)
        _nextButtonStatusController.add(ButtonStatus.RESTART);
      else
        _nextButtonStatusController.add(
            _currentAnswer.nextQuestionId != Answer.FINISH_FORM
                ? ButtonStatus.NEXT
                : ButtonStatus.FINISH);
    } else
      _nextButtonStatusController.add(ButtonStatus.DISABLED);
  }

  void updateKeyboardVisibility(bool isVisible) =>
      _isKeyboardVisibleController.add(isVisible);

  void goToPreviousQuestion() {
    currentFormResults.value.remove(currentQuestion.value.id);

    _currentQuestionController.add(currentForm.value.questions.singleWhere(
        (q) => q.id == _previousQuestionsController.value.last,
        orElse: () => null));
    _previousQuestionsController
        .add(_previousQuestionsController.value..removeLast());
    _currentFormResultsController.add(currentFormResults.value);

    _updateButtonStatus();
  }

  bool isBackButtonVisible() =>
      _previousQuestionsController.value?.isNotEmpty ?? false;

  void dispose() {
    _currentFormResultsController.close();
    _nextButtonStatusController.close();
    _currentQuestionController.close();
    _previousQuestionsController.close();
    _currentFormController.close();
    _currentCardPageController.close();
    _currentTitlePageController.close();
    _titlesController.close();
    _formsController.close();
    _isKeyboardVisibleController.close();
    _initialFormTitleController.close();
    _isFirstQuestionController.close();
    _greetingDataController.close();
  }
}
