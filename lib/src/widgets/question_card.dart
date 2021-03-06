import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cons_calc_lib/cons_calc_lib.dart';
import 'package:cons_calc_lib/src/widgets/custom_expansion_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class QuestionCard extends StatefulWidget {
  final int index;
  final Duration animationDuration;

  QuestionCard(
      {Key key, @required this.index, @required this.animationDuration})
      : super(key: key);

  @override
  _QuestionCardState createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  final verticalInset = 18.0;
  final padding = 18.0;
  double _screenHeight;
  double _screenWidth;

  Map<String, TextEditingController> textFieldControllers = {};
  DynamicFormBloc _dynamicFormBloc;
  Map<String, GlobalKey<FormState>> _formKeys = {};

  @override
  void initState() {
    KeyboardVisibility.onChange.listen((bool visible) {
      _dynamicFormBloc.updateKeyboardVisibility(visible);
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _dynamicFormBloc = Provider.of<DynamicFormBloc>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _screenHeight = MediaQuery.of(context).size.height;
    _screenWidth = MediaQuery.of(context).size.width;

    double cardWidth = min(_screenWidth - 70, 480.0);
    double cardHeight =
        _screenHeight <= 700 ? _screenHeight / 1.75 : _screenHeight / 2;

    return StreamBuilder<QuestionState>(
        stream: _dynamicFormBloc.questionState,
        builder: (context, snapshot) {
          QuestionState questionState = snapshot.data;
          if (questionState == null)
            return Center(child: CircularProgressIndicator());

          Question question = questionState.questions[widget.index];

          double bottom = padding;
          double left = padding;

          bool isCurrentQuestion = widget.index == questionState.currentIndex;
          bool isNextQuestion =
              question == null || widget.index == questionState.getNextIndex;
          int questionDifference = questionState.indexDifference(widget.index);
          double opacity = 1.0;
          double centerFromLeft = _screenWidth / 2 - (cardWidth / 2);

          if (isCurrentQuestion) {
            left = centerFromLeft;
          } else if (isNextQuestion) {
            left = _screenWidth - verticalInset;
          } // Right under the current question
          else if (questionDifference == 1) {
            bottom -= verticalInset * questionDifference;
            left = centerFromLeft - padding;
            opacity = 1;
          } // 2 cards under the current question
          else if (questionDifference == 2) {
            left = centerFromLeft - padding;
            bottom -= verticalInset * questionDifference;
            opacity = 0.7;
          } // 3 cards under the current question but invisible
          else if (questionDifference == 3) {
            left = centerFromLeft - padding;
            bottom -= verticalInset * questionDifference;
            opacity = 0.0;
          } // At the next question location already but invisible
          else if (questionDifference > 3) {
            left = _screenWidth - verticalInset;
            opacity = 0.0;
          }
          return AnimatedPositioned(
            left: left,
            bottom: bottom,
            duration: widget.animationDuration,
            child: AnimatedOpacity(
              opacity: opacity,
              duration: widget.animationDuration,
              child: Material(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.white,
                elevation:
                    isCurrentQuestion || isNextQuestion ? MAX_ELEVATION : 0.0,
                child: StreamBuilder<Object>(
                    stream: _dynamicFormBloc.isKeyboardVisible,
                    initialData: false,
                    builder: (context, keyboardVisibilitySnapshot) {
                      return Container(
                        width: cardWidth,
                        height: cardHeight -
                            (keyboardVisibilitySnapshot.data ? 160.0 : 0.0),
                        child: question == null
                            ? Container()
                            : Column(
                                children: [
                                  _buildQuestion(question),
                                  isCurrentQuestion
                                      ? _buildButtonsRow(question.id)
                                      : Container(),
                                ],
                              ),
                      );
                    }),
              ),
            ),
          );
        });
  }

  Widget _buildButtonsRow(String questionId) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            _backButton(),
            _nextButton(questionId),
          ],
        ),
      );

  Widget _backButton() => StreamBuilder<bool>(
        stream: _dynamicFormBloc.isBackButtonVisible,
        initialData: false,
        builder: (context, snapshot) => snapshot.data
            ? Align(
                alignment: Alignment.bottomLeft,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.black45,
                  ),
                  onPressed: () => _dynamicFormBloc.goToPreviousQuestion(),
                ),
              )
            : Container(),
      );

  Widget _nextButton(String questionId) => Align(
        alignment: Alignment.bottomCenter,
        child: StreamBuilder<ButtonStatus>(
          initialData: ButtonStatus.DISABLED,
          stream: _dynamicFormBloc.nextButtonStatus,
          builder: (context, nextButtonStatusSnapshot) =>
              nextButtonStatusSnapshot.data == ButtonStatus.LOADING
                  ? CircularProgressIndicator()
                  : FlatButton(
                      color: secondaryMain,
                      onPressed:
                          nextButtonStatusSnapshot.data == ButtonStatus.DISABLED
                              ? null
                              : () {
                                  switch (nextButtonStatusSnapshot.data) {
                                    case ButtonStatus.NEXT:
                                      _nextQuestion(questionId);
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
        ),
      );

  Widget _buildQuestion(Question question) => Expanded(
        child: question == null
            ? Container()
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 8.0),
                    child: Text(
                      question.label['en'],
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ),
                  _buildAnswers(question.id, question.answers)
                ],
              ),
      );

  Widget _buildAnswers(String questionId, List<Answer> answers) =>
      StreamBuilder<Map>(
          stream: _dynamicFormBloc.currentFormResults,
          builder: (context, currentFormResultsSnapshot) {
            Map questionResults;
            if (currentFormResultsSnapshot.data != null)
              questionResults = currentFormResultsSnapshot.data[questionId];
            return Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                children: answers
                        .any((answer) => answer.type == AnswerType.IMAGE_OPTION)
                    ? _buildAnswerWithImages(
                        questionId, answers, questionResults)
                    : answers
                        .map((answer) =>
                            _buildAnswer(questionId, answer, questionResults))
                        .toList()
                        .cast<Widget>(),
              ),
            );
          });

  Widget _buildAnswer(String questionId, Answer answer, Map questionResults) {
    Widget answerWidget;
    bool answerIsSelected = isAnswerSelected(answer, questionResults);
    double hPadding = 24.0;

    switch (answer.type) {
      case AnswerType.SELECT:
        answerWidget = _buildSelectAnswer(questionId, answer, answerIsSelected);
        break;
      case AnswerType.OPTION:
        answerWidget = _buildOptionAnswer(questionId, answer, answerIsSelected);
        break;
      case AnswerType.INPUT:
        answerWidget = _buildInputAnswer(questionId, answer, answerIsSelected);
        break;
      case AnswerType.PRODUCT_LIST:
        answerWidget =
            _buildProductListAnswer(questionId, answer, questionResults);
        hPadding = 0.0;
        break;
      case AnswerType.IMAGE_OPTION:
        answerWidget = _buildOptionAnswer(questionId, answer, answerIsSelected);
        break;
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: hPadding),
      child: answerWidget,
    );
  }

  List<Widget> _buildAnswerWithImages(
      String questionId, List<Answer> answers, Map questionResults) {
    List<Widget> widgets = [];
    List<Answer> answersWithImage = answers
        .where((answer) => answer.type == AnswerType.IMAGE_OPTION)
        .toList();
    List<Answer> answersWithoutImages =
        answers.where((answer) => answer.type == AnswerType.OPTION).toList();

    widgets.add(CarouselSlider(
      options: CarouselOptions(
        autoPlay: true,
        aspectRatio: 2.0,
        enlargeCenterPage: true,
        pauseAutoPlayOnTouch: true,
      ),
      items: answersWithImage
          .map((answer) {
            bool isSelected = isAnswerSelected(answer, questionResults);
            return _buildImageCard(questionId, answer, isSelected);
          })
          .cast<Widget>()
          .toList(),
    ));

    widgets.addAll(answersWithoutImages
        .map((answer) {
          bool isSelected = isAnswerSelected(answer, questionResults);
          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
            child: _buildOptionAnswer(questionId, answer, isSelected),
          );
        })
        .cast<Widget>()
        .toList());

    return widgets;
  }

  Widget _buildImageCard(String questionId, Answer answer, bool isSelected) =>
      Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Stack(
          children: [
            InkWell(
              onTap: () => _dynamicFormBloc.setValue(answer, answer.value),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 4,
                    child: Image.network(
                      answer.imageUrl,
                      frameBuilder: (_, child, frame, isLoaded) => isLoaded
                          ? FittedBox(child: child)
                          : Stack(
                              children: [
                                Center(child: CircularProgressIndicator()),
                                Center(
                                  child: AnimatedOpacity(
                                    opacity: frame == null ? 0 : 1,
                                    duration: Duration(seconds: 1),
                                    child: child,
                                  ),
                                ),
                              ],
                            ),
                      errorBuilder: (_, __, ___) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              MdiIcons.fileAlert,
                              color: Colors.black26,
                              size: 32.0,
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              "Unable to download image",
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Divider(
                    height: 1.0,
                    color: Colors.black38,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(_screenWidth < 550 ? 8.0 : 16.0),
                      child: AutoSizeText(
                        answer.label['en'] ?? "",
                        // minFontSize: 12.0,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontFamily: 'LibreFranklin',
                          fontWeight: FontWeight.w500,
                          // fontSize: 19.94,
                          letterSpacing: 0.25,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            isSelected
                ? Container(
                    decoration: BoxDecoration(
                      color: secondaryMain.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.check_circle_outline,
                          size: 32.0,
                          color: secondaryMain,
                        ),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      );
  // Card(
  //   child: Container(
  //     width: _screenWidth / 2 + 32.0,
  //     child: Stack(
  //       children: [
  //         Positioned.fill(
  //           child: Image.network(
  //             answer.imageUrl,
  //             frameBuilder: (_, child, frame, isLoaded) => isLoaded
  //                 ? FittedBox(fit: BoxFit.cover, child: child)
  //                 : Stack(
  //                     children: [
  //                       Center(child: CircularProgressIndicator()),
  //                       Center(
  //                         child: AnimatedOpacity(
  //                           opacity: frame == null ? 0 : 1,
  //                           duration: Duration(seconds: 1),
  //                           child: child,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //             errorBuilder: (_, __, ___) {
  //               return Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Icon(
  //                     MdiIcons.fileAlert,
  //                     color: Colors.black26,
  //                     size: 32.0,
  //                   ),
  //                   SizedBox(height: 8.0),
  //                   Text(
  //                     "Unable to download image",
  //                     style: Theme.of(context).textTheme.subtitle2,
  //                   ),
  //                 ],
  //               );
  //             },
  //           ),
  //         ),
  //         isSelected
  //             ? Container(
  //                 decoration: BoxDecoration(
  //                   color: secondaryMain.withOpacity(0.3),
  //                   borderRadius: BorderRadius.circular(4.0),
  //                 ),
  //                 child: Align(
  //                   alignment: Alignment.bottomRight,
  //                   child: Padding(
  //                     padding: const EdgeInsets.all(8.0),
  //                     child: Icon(
  //                       Icons.check_circle_outline,
  //                       size: 32.0,
  //                       color: secondaryMain,
  //                     ),
  //                   ),
  //                 ),
  //               )
  //             : Material(
  //                 color: Colors.transparent,
  //                 child: InkWell(
  //                   splashColor: Color(0x40FFC107),
  //                   highlightColor: Color(0x20FFC107),
  //                   onTap: () =>
  //                       _dynamicFormBloc.setValue(answer, answer.value),
  //                 ),
  //               ),
  //       ],
  //     ),
  //   ),
  // );

  Widget _buildSelectAnswer(
          String questionId, Answer answer, bool isSelected) =>
      CustomExpansionTile(
        selectedColor: secondaryMain,
        title: Text(answer.label['en'] == null || answer.label['en'] == ""
            ? "Tap to select an option..."
            : answer.label['en']),
        onExpansionChanged: (expanded) => expanded
            ? _dynamicFormBloc.setValue(answer, answer.value[0])
            : null,
        initiallyExpanded: isSelected,
        children: [
          Container(
            height: _screenHeight / 5,
            width: double.infinity,
            child: CupertinoPicker(
              magnification: 1.5,
              itemExtent: 25,
              onSelectedItemChanged: (int index) {
                _dynamicFormBloc.setValue(answer, answer.value[index]);
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

  Widget _buildInputAnswer(String questionId, Answer answer, bool isSelected) {
    List<TextInputFormatter> inputFormatters = [];
    List<String Function(String)> validators = [];
    TextInputType inputType = TextInputType.text;

    if (textFieldControllers[answer.id] == null)
      textFieldControllers[answer.id] = TextEditingController();
    if (_formKeys.containsKey(questionId) == false)
      _formKeys[questionId] = GlobalKey<FormState>();

    if (answer.valueType == "NUMBER") {
      inputFormatters.add(WhitelistingTextInputFormatter.digitsOnly);
      inputType = TextInputType.number;
    }

    answer.validators.forEach((validatorKey, validatorValue) {
      if (validatorKey == "input_format" && validatorValue != null) {
        TextInputFormatter maskFormatter = MaskTextInputFormatter(
            mask: validatorValue, filter: {"#": RegExp(r'[0-9]')});
        inputFormatters.remove(WhitelistingTextInputFormatter.digitsOnly);
        inputFormatters.add(maskFormatter);
      }
      if (validatorKey == "min_length" && validatorValue != null) {
        validators.add((strToValidate) {
          if (strToValidate.length < (int.tryParse(validatorValue) ?? 1))
            return "Min. length $validatorValue";
          return null;
        });
      }
      if (validatorKey == "max_length" && validatorValue != null) {
        validators.add((strToValidate) {
          if (strToValidate.length > (int.tryParse(validatorValue) ?? 1))
            return "Max. length $validatorValue";
          return null;
        });
      }
    });

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Material(
        color: isSelected ? Color(0x20FFC107) : Theme.of(context).canvasColor,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 8.0),
          child: Form(
            key: _formKeys[questionId],
            child: TextFormField(
              controller: textFieldControllers[answer.id],
              inputFormatters: inputFormatters,
              keyboardType: inputType,
              validator: (String value) {
                for (var validator in validators) {
                  String result = validator(value);
                  if (result != null) return result;
                }
                _dynamicFormBloc.setValue(answer, value);
                return null;
              },
              maxLines: 1,
              decoration: InputDecoration(
                hintText: answer.label["en"] == null || answer.label["en"] == ""
                    ? "Tap to start typing..."
                    : answer.label["en"],
                isDense: true,
                isCollapsed: false,
                hintStyle: Theme.of(context).textTheme.subtitle2.copyWith(
                    fontWeight: FontWeight.w600, color: Colors.black45),
              ),
              onTap: () => _dynamicFormBloc.setValue(
                  answer, textFieldControllers[answer.id].text),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionAnswer(
          String questionId, Answer answer, bool isSelected) =>
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Material(
          color: isSelected ? Color(0x20FFC107) : Theme.of(context).canvasColor,
          child: InkWell(
            onTap: () {
              _dynamicFormBloc.setValue(answer, answer.value);
            },
            splashColor: isSelected ? Color(0x40FFC107) : null,
            highlightColor: isSelected ? Color(0x20FFC107) : null,
            child: Container(
              padding: EdgeInsets.all(_screenHeight <= 680 ? 8 : 12),
              width: double.infinity,
              child: Text(
                answer.label['en'],
                style: Theme.of(context).textTheme.subtitle2.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? secondaryMain : Colors.black45,
                    ),
              ),
            ),
          ),
        ),
      );

  Widget _buildProductListAnswer(
          String questionId, Answer answer, Map questionResults) =>
      CarouselSlider(
        options: CarouselOptions(
          autoPlay: true,
          enlargeCenterPage: true,
          pauseAutoPlayOnTouch: true,
        ),
        items: answer.value
            .map((product) {
              bool isSelected =
                  isAnswerSelected(answer, questionResults, value: product);
              return _buildProductCard(product, questionId, answer, isSelected);
            })
            .cast<Widget>()
            .toList(),
      );

  Widget _buildProductCard(
          dynamic product, String questionId, Answer answer, bool isSelected) =>
      Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Stack(
          children: [
            InkWell(
              onTap: () => _dynamicFormBloc.setValue(answer, product),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: Image.network(
                      product.imageURL,
                      frameBuilder: (_, child, frame, isLoaded) => isLoaded
                          ? child
                          : Stack(
                              children: [
                                Center(child: CircularProgressIndicator()),
                                Center(
                                  child: AnimatedOpacity(
                                    opacity: frame == null ? 0 : 1,
                                    duration: Duration(seconds: 1),
                                    child: child,
                                  ),
                                ),
                              ],
                            ),
                      errorBuilder: (_, __, ___) => Icon(
                        MdiIcons.tag,
                        color: Colors.black26,
                        size: 32.0,
                      ),
                    ),
                  ),
                  Divider(
                    height: 1.0,
                    color: Colors.black38,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(_screenWidth < 550 ? 8.0 : 16.0),
                      child: AutoSizeText(
                        product.name,
                        // minFontSize: 12.0,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontFamily: 'LibreFranklin',
                          fontWeight: FontWeight.w500,
                          // fontSize: 19.94,
                          letterSpacing: 0.25,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            isSelected
                ? Container(
                    decoration: BoxDecoration(
                      color: secondaryMain.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.check_circle_outline,
                          size: 32.0,
                          color: secondaryMain,
                        ),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      );

  // METHODS
  Future<void> _nextQuestion(String currentQuestionId) async {
    bool response = true;
    if (_formKeys[currentQuestionId]?.currentState?.validate() ?? true)
      response = await _dynamicFormBloc.nextQuestion();
    if (response == false) _showNoInternetConnectionDialog();
  }

  Future<void> _restartForm() async {
    bool response = await _dynamicFormBloc.saveAndRestartForm();
    if (response == false) _showNoInternetConnectionDialog();
  }

  Future<void> _finishForm() async {
    bool response = await _dynamicFormBloc.finishAndSaveForm();
    if (response == false) _showNoInternetConnectionDialog();
  }

  void _showNoInternetConnectionDialog() => showDialog(
        context: context,
        child: AlertDialog(
          title: Text(
            "Internet connection error",
            style: Theme.of(context).textTheme.headline5,
          ),
          content: Container(
            width: 256.0,
            child: Text(
              "Your internet connection is very poor. Try to get a more stable connection an try again.",
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
          actions: [
            FlatButton(
              child: Text("Dismiss"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      );

  /// Returns true if answer is the one currently selected
  /// optional parameter "value", if not null checks if the value of the answer
  /// is the same as the parameter "value"
  bool isAnswerSelected(Answer answer, Map questionResults, {dynamic value}) {
    if (questionResults != null && answer.id == questionResults[Answer.ID]) {
      if (value != null) {
        if (questionResults['value'] == value) return true;
      } else
        return true;
    }

    return false;
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
  LOADING,
}
