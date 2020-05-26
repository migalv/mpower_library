import 'dart:math';

import 'package:cons_calc_lib/cons_calc_lib.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

BuildContext _context;

class QuestionCardCarousel extends StatelessWidget {
  final _currentCardPage;
  final padding = 18.0;
  final verticalInset = 18.0;
  final PageController _cardController, _titlesController;
  final bool _isWeb;
  final _form;
  final _nextButtonStatus;
  final _currentQuestion;
  final Function _isBackButtonVisible,
      _isSelected,
      _setValue,
      _goToPreviousQuestion,
      _goToNextQuestion,
      _finishAndSaveForm,
      _saveAndRestartForm;

  QuestionCardCarousel({
    @required currentCardPage,
    @required cardController,
    @required titlesController,
    @required isWeb,
    @required form,
    @required nextButtonStatus,
    @required currentQuestion,
    @required isBackButtonVisible,
    @required isSelected,
    @required setValue,
    @required finishAndSaveForm,
    @required goToPreviousQuestion,
    @required goToNextQuestion,
    @required saveAndRestartForm,
  })  : _form = form,
        _cardController = cardController,
        _isWeb = isWeb,
        _currentCardPage = currentCardPage,
        _nextButtonStatus = nextButtonStatus,
        _currentQuestion = currentQuestion,
        _isBackButtonVisible = isBackButtonVisible,
        _isSelected = isSelected,
        _goToPreviousQuestion = goToPreviousQuestion,
        _goToNextQuestion = goToNextQuestion,
        _finishAndSaveForm = finishAndSaveForm,
        _setValue = setValue,
        _titlesController = titlesController,
        _saveAndRestartForm = saveAndRestartForm;

  @override
  Widget build(BuildContext context) {
    _context = context;

    return LayoutBuilder(
      builder: (context, contraints) {
        List<Widget> children = [];

        for (var i = 0; i < _form.questions.length; i++) {
          var delta = i - _currentCardPage;
          bool isOnRight = delta > 0;

          var start = padding +
              (_isWeb
                  ? max(20 - 50 * -delta * (isOnRight ? 90 : 1), 0.0)
                  : max(20 - 20 * -delta * (isOnRight ? 18 : 1), 0.0));

          var elevation = MAX_ELEVATION - max(-MAX_ELEVATION * delta, 0.0);
          var opacity = MAX_OPACITY - max(-delta, 0.0);

          children.add(
            Positioned.directional(
              textDirection: TextDirection.ltr,
              top: MediaQuery.of(context).size.height * .45 +
                  verticalInset * max(-delta, 0.0),
              bottom: padding + verticalInset * max(-delta, 0.0),
              start: start,
              child: Opacity(
                opacity: opacity < MIN_OPACITY ? MIN_OPACITY : opacity,
                child: Material(
                  color: Colors.transparent,
                  elevation: elevation < 0 ? 0 : elevation,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width - 70,
                      child: Opacity(
                        opacity: opacity < 0 ? 0 : opacity,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Stack(
                            children: [
                              _backButton(),
                              _nextButton(),
                              _question(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return Stack(
          fit: StackFit.expand,
          children: children,
        );
      },
    );
  }

  // Build

  Widget _backButton() => _isBackButtonVisible()
      ? Align(
          alignment: Alignment.bottomLeft,
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black45,
            ),
            onPressed: () {
              _goToPreviousQuestion();

              _cardController.animateToPage(
                _currentCardPage.truncate() - 1,
                duration: Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            },
          ),
        )
      : Container();

  Widget _nextButton() => Align(
        alignment: Alignment.bottomCenter,
        child: FlatButton(
          color: secondaryMain,
          onPressed: _nextButtonStatus == ButtonStatus.DISABLED
              ? null
              : () {
                  switch (_nextButtonStatus) {
                    case ButtonStatus.NEXT:
                      _nextQuestion();
                      break;
                    case ButtonStatus.FINISH:
                      _finishForm();
                      break;
                    case ButtonStatus.RESTART:
                      _restartForm();
                      break;
                    default:
                      break;
                  }
                },
          child: Text('next'),
        ),
      );
  Widget _question() => Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _currentQuestion == null
              ? Container()
              : Column(
                  children: [
                    Text(
                      _currentQuestion.label['en'],
                      style: Theme.of(_context).textTheme.subtitle1,
                    ),
                    Container(height: 16),
                    _answers(_currentQuestion.id, _currentQuestion.answers)
                  ],
                ),
        ),
      );

  Widget _answers(String questionId, List<Answer> answers) => Column(
        children: answers
            .map(
              (answer) => Column(
                children: [
                  answer.type == AnswerType.SELECT
                      ? _buildSelectAnswer(questionId, answer)
                      : answer.type == AnswerType.INPUT
                          ? _buildInputAnswer(questionId, answer)
                          : _buildOptionAnswer(questionId, answer),
                  Container(height: 12),
                ],
              ),
            )
            .toList()
            .cast<Widget>(),
      );

  Widget _buildSelectAnswer(String questionId, Answer answer) =>
      CustomExpansionTile(
        selectedColor: secondaryMain,
        title: Text(answer.label['en']),
        onExpansionChanged: (expanded) =>
            expanded ? _setValue(answer, answer.value[0]) : null,
        initiallyExpanded: _isSelected(questionId, answer),
        children: [
          Container(
            height: MediaQuery.of(_context).size.height / 5,
            width: double.infinity,
            child: CupertinoPicker(
              magnification: 1.5,
              itemExtent: 25,
              onSelectedItemChanged: (int index) {
                _setValue(answer, answer.value[index]);
              },
              children: answer.value
                  .map(
                    (option) => Container(
                      margin: EdgeInsets.only(top: 4, bottom: 4),
                      child: Text(
                        option.toString(),
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  )
                  .cast<Widget>()
                  .toList(),
            ),
          ),
        ],
      );

  Widget _buildInputAnswer(String questionId, Answer answer) {
    TextEditingController controller = TextEditingController();
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Material(
        color: _isSelected(questionId, answer)
            ? Color(0x20FFC107)
            : Theme.of(_context).canvasColor,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 8.0),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              // TODO ENABLE LANGUAGES
              hintText: answer.label["en"],
              isDense: true,
              isCollapsed: false,
              hintStyle: Theme.of(_context)
                  .textTheme
                  .subtitle2
                  .copyWith(fontWeight: FontWeight.w600, color: Colors.black45),
            ),
            onChanged: (text) => _setValue(answer, text),
            onTap: () => _setValue(answer, controller.text),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionAnswer(String questionId, Answer answer) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Material(
          color: _isSelected(questionId, answer)
              ? Color(0x20FFC107)
              : Theme.of(_context).canvasColor,
          child: InkWell(
            onTap: () {
              _setValue(answer, answer.value);
            },
            child: Container(
              padding: EdgeInsets.all(12),
              width: double.infinity,
              child: Text(
                answer.label['en'],
                style: Theme.of(_context).textTheme.subtitle2.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _isSelected(questionId, answer)
                          ? secondaryMain
                          : Colors.black45,
                    ),
              ),
            ),
          ),
        ),
      );

  // Methods
  void _nextQuestion() {
    _goToNextQuestion();

    _cardController.animateToPage(
      _currentCardPage.truncate() + 1,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _finishForm() async {
    var consumptionProducts = await _finishAndSaveForm();

    // TODO Revisar
    // if (consumptionProducts.isNotEmpty) {
    //   Navigator.pop(_context);
    //   utils.push(
    //     context,
    //     BlocProvider<BundleRecommendationBloc>(
    //       initBloc: (_, bloc) =>
    //           bloc ?? BundleRecommendationBloc(consumptionProducts),
    //       onDispose: (_, bloc) => bloc.dispose(),
    //       child: BundleRecommendationPage(),
    //     ),
    //   );
    // }
    // }

    // TODO No animar si no hay mas cartas despues
    _cardController.animateToPage(
      _currentCardPage.truncate() + 1,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    _titlesController.animateToPage(
      _currentCardPage.truncate() + 1,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _restartForm() {
    _saveAndRestartForm();

    _cardController.animateToPage(
      _currentCardPage.truncate() + 1,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }
}

const double MIN_OPACITY = 0.5;
const double MAX_OPACITY = 1.0;
const double MAX_ELEVATION = 4.0;

enum ButtonStatus {
  DISABLED,
  NEXT,
  FINISH,
  RESTART,
}

enum AnswerType {
  SELECT,
  OPTION,
  INPUT,
  PRODUCT_LIST,
}
