import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cons_calc_lib/cons_calc_lib.dart';
import 'package:rxdart/rxdart.dart';

class DynamicFormUIBloc {
  DynamicForm _initialForm;
  List<DynamicForm> _forms;
  List<Map> _formResults;
  int _currentFormIndex;
  StreamSubscription _subscription;
  Function _getDynamicFormWithId, _getConsumptionProduct;

  // Streams
  ValueObservable<Map> get currentFormResults =>
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

  // Controllers
  final _currentFormResultsController = BehaviorSubject<Map>();
  final _nextButtonStatusController = BehaviorSubject<ButtonStatus>();
  final _currentQuestionController = BehaviorSubject<Question>();
  final _previousQuestionsController = BehaviorSubject<List<String>>.seeded([]);
  final _currentFormController = BehaviorSubject<DynamicForm>();
  final _currentCardPageController = BehaviorSubject<double>();
  final _currentTitlePageController = PublishSubject<double>();
  final _titlesController = BehaviorSubject<List<String>>.seeded([]);
  final _formsController = BehaviorSubject<List<DynamicForm>>();
  final _isKeyboardVisibleController = StreamController<bool>();

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
  DynamicFormUIBloc({
    @required initialForm,
    @required getDynamicFormWithId,
    @required getConsumptionProduct,
  }) {
    _getDynamicFormWithId = getDynamicFormWithId;
    _getConsumptionProduct = getConsumptionProduct;
    _initialForm = initialForm;
    _forms = [_initialForm];
    _formsController.add(_forms);
    _currentFormController.add(initialForm);
    _currentQuestionController.add(initialForm.questions.first);
    _formResults = [];
    _currentFormIndex = 0;
  }

  // METHODS
  void setValue(Answer answer, dynamic value) {
    Map results = currentFormResults.value ?? {};

    results[currentQuestion.value.id] = {
      Answer.KEY: answer.key,
      Answer.ID: answer.id,
      "value": value,
      Question.QUESTION_PURPOSE: currentQuestion.value.questionPurpose,
      Question.TABLE_ID: currentQuestion.value.tableId,
    };
    _currentFormResultsController.add(results);

    _updateButtonStatus();
  }

  void nextQuestion() {
    // Delayed to avoid an animation flaw
    Future.delayed(Duration(milliseconds: 200), () {
      _previousQuestionsController
          .add(previousQuestions.value..add(currentQuestion.value.id));

      Question question = currentForm.value.questions.singleWhere(
        (q) => q.id == _currentAnswer.nextQuestionId,
        orElse: () => null,
      );
      _currentQuestionController.add(question);

      _updateButtonStatus();
    });
  }

  void saveAndRestartForm() {
    Future.delayed(Duration(milliseconds: 200), () {
      _formResults.add(currentFormResults.value);
      _previousQuestionsController.add([]);
      _currentQuestionController.add(currentForm.value.questions
          .singleWhere((q) => q.id == _currentAnswer.nextQuestionId));
      _currentFormResultsController.add(null);

      _updateButtonStatus();
    });
  }

  Future<List<ConsumptionProduct>> finishAndSaveForm() async {
    List<ConsumptionProduct> consumptionProducts = [];

    // Delay to avoid an animation flaw
    await Future.delayed(Duration(milliseconds: 200), () async {
      _formResults.add(currentFormResults.value);

      for (Map answerData in currentFormResults.value.values) {
        if (answerData[Question.QUESTION_PURPOSE] == QuestionPurpose.ADD_FORM) {
          if (answerData["value"] is String)
            _forms.add(_getDynamicFormWithId(answerData["value"]));
          else if (answerData["value"] is List)
            for (String formId in answerData["value"])
              _forms.add(_getDynamicFormWithId(formId));

          _formsController.add(_forms);
        }
      }

      // There are more forms to show
      if (_forms.length > _currentFormIndex + 1) {
        _currentFormIndex++;
        _previousQuestionsController.add([]);
        _currentFormController.add(_forms[_currentFormIndex]);
        _currentQuestionController.add(currentForm.value.questions.first);
        _currentFormResultsController.add(null);

        _updateButtonStatus();
      } else {
        // It's the last form
        double extraConsumption = 0.0;

        // For each form we recollect the answers for the consumption questions
        for (Map questionsMap in _formResults) {
          int units;
          // We store the atributes to filter the consumption products
          List filters = [];
          questionsMap.forEach(
            (questionId, answersMap) {
              if (answersMap['question_purpose'] ==
                      QuestionPurpose.CONSUMPTION &&
                  answersMap['value'] != null &&
                  answersMap['key'] != null) {
                var value = answersMap['value'];
                if (answersMap[Question.TABLE_ID] == Question.JUST_VALUE)
                  extraConsumption += value;
                else {
                  // Transform number range into its mean
                  if (value is String &&
                      value.contains('-') &&
                      !value.contains(' - ')) {
                    int floor =
                        int.tryParse(value.substring(0, value.indexOf('-')));
                    int ceil = int.tryParse(
                        value.substring(value.indexOf('-') + 1, value.length));

                    if (floor != null && ceil != null)
                      answersMap['value'] =
                          ((floor + ceil) / 2).toStringAsFixed(0);
                  }
                  filters.add(answersMap);
                }
              } else if (answersMap['question_purpose'] ==
                      QuestionPurpose.NUM_OF_UNITS &&
                  answersMap['value'] != null) units = answersMap["value"];
            },
          );

          if (filters.isNotEmpty) {
            ConsumptionProduct consumptionProduct =
                await _getConsumptionProduct(filters);
            // If there are multiple units of the same product we add them as SubProducts
            if (units != null) {
              consumptionProduct.subProducts = [];
              for (int i = 0; i < units - 1; i++) {
                // -1 because we already have 1 unit added
                consumptionProduct.subProducts.add(
                  ConsumptionSubProduct(
                    id: consumptionProduct.id,
                    name: consumptionProduct.name,
                    powerConsumption: consumptionProduct.powerConsumption,
                  ),
                );
              }
            }

            consumptionProducts.add(consumptionProduct);
            consumptionProducts[consumptionProducts.length - 1]
                .powerConsumption += extraConsumption;
          }
        }
      }
    });

    return consumptionProducts;
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
    Future.delayed(Duration(milliseconds: 200), () {
      _currentQuestionController.add(currentForm.value.questions.singleWhere(
          (q) => q.id == _previousQuestionsController.value.last,
          orElse: () => null));
      _previousQuestionsController
          .add(_previousQuestionsController.value..removeLast());

      _updateButtonStatus();
    });
  }

  void setCurrentPage(double page, {bool card = true}) {
    (card ? _currentCardPageController : _currentTitlePageController).add(page);
  }

  bool isSelected(String questionId, Answer answer) =>
      currentFormResults.value != null &&
      currentFormResults.value[questionId] != null &&
      answer.id == currentFormResults.value[questionId][Answer.ID];

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

    _subscription.cancel();
  }
}
