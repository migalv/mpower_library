import 'dart:async';

import 'package:cons_calc_lib/src/dynamic_forms_repository.dart';
import 'package:flutter/material.dart';
import 'package:cons_calc_lib/cons_calc_lib.dart';
import 'package:rxdart/rxdart.dart';

class DynamicFormBloc {
  final String initialFormId;
  final DynamicFormsRepository repository;
  final int maxQuestionCards = 6;
  String _codeVersion;
  String get codeVersion => _codeVersion;

  List<DynamicForm> get _forms => _formsController.value;
  Map<String, List<Map>> _formResults;
  int _currentFormIndex;
  DynamicForm _currentForm;
  Question _currentQuestion;
  Question _firstQuestion;
  List<Question> _previousQuestions = [];

  /// Indicates if the form is being repeated. If so, it tells you on which
  /// repetition we are
  int repetitionIndex;

  // Streams
  Stream<String> get initialFormTitle => _initialFormTitleController.stream;
  ValueObservable<Map<String, Map>> get currentFormResults =>
      _currentFormResultsController.stream;
  ValueObservable<ButtonStatus> get nextButtonStatus =>
      _nextButtonStatusController.stream;
  Stream<List<DynamicForm>> get forms => _formsController.stream;
  Stream<bool> get isKeyboardVisible => _isKeyboardVisibleController.stream;
  Stream<bool> get isFirstQuestion => _isFirstQuestionController.stream;
  Stream<Map<String, String>> get greetingData =>
      _greetingDataController.stream;

  ValueObservable<QuestionState> get questionState =>
      _questionStateController.stream;
  Stream<bool> get reOrderStack => _reOrderStackController.stream;

  Stream<bool> get isBackButtonVisible => _isBackButtonVisibleController.stream;

  // Controllers
  final _initialFormTitleController = StreamController<String>();
  final _currentFormResultsController = BehaviorSubject<Map<String, Map>>();
  final _nextButtonStatusController = BehaviorSubject<ButtonStatus>();
  final _formsController = BehaviorSubject<List<DynamicForm>>();
  final _isKeyboardVisibleController = BehaviorSubject<bool>();
  final _isFirstQuestionController = StreamController<bool>();
  final _greetingDataController = StreamController<Map<String, String>>();
  final _isBackButtonVisibleController = BehaviorSubject<bool>();
  final _questionStateController = BehaviorSubject<QuestionState>();
  final _reOrderStackController = BehaviorSubject<bool>();

  QuestionState get _questionState => _questionStateController.value;

  // Getters
  bool get _isCurrentQuestionAnswered =>
      currentFormResults.value != null &&
      currentFormResults.value[_currentQuestion.id] != null;
  Answer get _currentAnswer => _isCurrentQuestionAnswered &&
          currentFormResults.value[_currentQuestion.id][Answer.ID] != null
      ? _currentQuestion.answers.singleWhere(
          (a) =>
              a.id == currentFormResults.value[_currentQuestion.id][Answer.ID],
          orElse: () => null)
      : null;

  //
  // CONSTRUCTOR
  DynamicFormBloc({
    @required this.initialFormId,
    @required this.repository,
  }) {
    _codeVersion = repository.codeVersion;
    repository.getFormWithId(initialFormId).then((initialForm) async {
      await repository.signInAnonymously();
      repository.updateEmailList(
          emails: initialForm.emailList, formId: initialFormId);
      repository.initialForm = initialForm;
      repetitionIndex = 0;
      _initialFormTitleController.add(initialForm.title);
      _formsController.add([initialForm]);
      _currentForm = initialForm;
      _firstQuestion = initialForm.questions.first;

      List<Question> questions = [];

      questions.add(_firstQuestion);
      for (int i = 1; i < maxQuestionCards; i++) questions.add(null);

      _questionStateController.add(QuestionState(
        0,
        questions,
        maxQuestionCards,
      ));

      _currentQuestion = _firstQuestion;

      _greetingDataController.add({
        "title": initialForm.greetingTitle,
        "subtitle": initialForm.greetingSubtitle,
      });
      questionState.listen((questionState) => _isFirstQuestionController.add(
          _firstQuestion ==
              questionState.questions[questionState.currentIndex]));

      _formResults = {};
      _currentFormIndex = 0;
    });
  }

  // METHODS
  void setValue(Answer answer, dynamic value) {
    Map<String, Map> results = currentFormResults.value ?? {};
    Map answerResults = {
      Question.LABEL: _currentQuestion.label,
      Answer.LABEL: answer.label,
      Answer.ID: answer.id,
      Answer.KEY: answer.key,
      "value": value,
      Question.QUESTION_PURPOSE: _currentQuestion.questionPurpose,
      Question.APPLIANCE_KEY: _currentQuestion.applianceKey,
    };

    results[_currentQuestion.id] = answerResults;
    _currentFormResultsController.add(results);

    _updateButtonStatus();
  }

  void nextQuestion() {
    _previousQuestions.add(_currentQuestion);

    Question question = _currentForm.questions.singleWhere(
      (q) => q.id == _currentAnswer.nextQuestionId,
      orElse: () => null,
    );

    repository.uploadAnswer(
      _currentForm.id,
      _currentQuestion.id,
      currentFormResults.value[_currentQuestion.id],
      repetitionIndex,
    );

    _currentQuestion = question;
    _questionState.changeQuestionAtNextIndex(question);
    _questionState.nextIndex();
    _questionStateController.add(_questionState);
    _reOrderStackController.add(true);

    _updateButtonStatus();
  }

  void saveAndRestartForm() {
    if (_formResults[_currentForm.id] == null)
      _formResults[_currentForm.id] = List();
    _formResults[_currentForm.id].add(currentFormResults.value);

    Question nextQuestion = _currentForm.questions
        .singleWhere((q) => q.id == _currentAnswer.nextQuestionId);

    _currentQuestion = nextQuestion;
    _questionState.changeQuestionAtNextIndex(nextQuestion);
    _questionState.nextIndex();
    _questionStateController.add(_questionState);
    _reOrderStackController.add(true);

    _currentFormResultsController.add({});
    repetitionIndex++;

    _updateButtonStatus();
  }

  /// Saves the form results from the current form. Then checks if there are
  /// more forms to be shown.
  ///
  /// Returns true if there are more forms to show. False if not
  Future<bool> finishAndSaveForm() async {
    List<DynamicForm> forms = _forms;
    bool newFormsAdded = false;

    _nextButtonStatusController.add(ButtonStatus.LOADING);
    _isBackButtonVisibleController.add(false);

    if (_formResults[_currentForm.id] == null)
      _formResults[_currentForm.id] = List();
    _formResults[_currentForm.id].add(currentFormResults.value);

    repetitionIndex = 0;

    // We add the next forms to the list
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

      _currentForm = _forms[_currentFormIndex];
      Question nextQuestion = _currentForm.questions.first;

      _currentQuestion = nextQuestion;
      _questionState.changeQuestionAtNextIndex(nextQuestion);
      _questionState.nextIndex();
      _questionStateController.add(_questionState);
      _reOrderStackController.add(true);

      _previousQuestions.clear();

      _currentFormResultsController.add(null);

      _updateButtonStatus();
      return true;
    }

    // It's the last form
    repository.formFinished(_formResults);

    return false;
  }

  void _updateButtonStatus() {
    _isBackButtonVisibleController.add(_previousQuestions.isNotEmpty);
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
    currentFormResults.value.remove(_currentQuestion.id);

    Question prevQuestion = _previousQuestions.removeLast();
    _currentQuestion = prevQuestion;
    _questionState.changeQuestionAtPrevIndex(prevQuestion);
    _questionState.prevIndex();
    _questionStateController.add(_questionState);
    _reOrderStackController.add(false);

    _currentFormResultsController.add(currentFormResults.value);

    _updateButtonStatus();
  }

  void dispose() {
    _currentFormResultsController.close();
    _nextButtonStatusController.close();
    _formsController.close();
    _isKeyboardVisibleController.close();
    _initialFormTitleController.close();
    _isFirstQuestionController.close();
    _greetingDataController.close();
    _isBackButtonVisibleController.close();
    _questionStateController.close();
  }
}

class QuestionState {
  int _currentIndex;
  int get currentIndex => _currentIndex;
  List<Question> _questions;
  List<Question> get questions => _questions;
  final int _maxQuestions;

  QuestionState(this._currentIndex, this._questions, this._maxQuestions)
      : assert(_questions != null && _questions.length == _maxQuestions);

  void prevIndex() {
    if (_currentIndex - 1 >= 0)
      _currentIndex--;
    else
      _currentIndex = _maxQuestions - 1;
  }

  int indexDifference(int index) => _currentIndex - index < 0
      ? (_currentIndex - index + _maxQuestions)
      : _currentIndex - index;

  void nextIndex() {
    if (_currentIndex + 1 >= _maxQuestions)
      _currentIndex = 0;
    else
      _currentIndex++;
  }

  int get getNextIndex =>
      _currentIndex + 1 >= _maxQuestions ? 0 : _currentIndex + 1;

  int get getPrevIndex =>
      _currentIndex - 1 >= 0 ? _currentIndex - 1 : _maxQuestions - 1;

  void changeQuestionAtNextIndex(Question newQuestion) =>
      _questions[getNextIndex] = newQuestion;

  void changeQuestionAtPrevIndex(Question newQuestion) =>
      _questions[getPrevIndex] = newQuestion;
}
