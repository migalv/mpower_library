import 'package:auto_size_text/auto_size_text.dart';
import 'package:cons_calc_lib/cons_calc_lib.dart';
import 'package:cons_calc_lib/src/widgets/custom_expansion_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class QuestionCard extends StatefulWidget {
  final ButtonStatus nextButtonStatus;
  final Question question;
  final Function isBackButtonVisible,
      isSelected,
      setValue,
      goToPreviousQuestion,
      goToNextQuestion,
      finishAndSaveForm,
      saveAndRestartForm;
  final Stream<Question> currentQuestionStream;
  final double cardWidth, cardHeight;
  final bool isKeyboardVisible;

  QuestionCard({
    @required this.question,
    @required this.nextButtonStatus,
    @required this.isBackButtonVisible,
    @required this.isSelected,
    @required this.setValue,
    @required this.finishAndSaveForm,
    @required this.goToPreviousQuestion,
    @required this.goToNextQuestion,
    @required this.saveAndRestartForm,
    @required this.currentQuestionStream,
    @required this.cardWidth,
    @required this.cardHeight,
    @required this.isKeyboardVisible,
  });

  @override
  _QuestionCardState createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  final verticalInset = 18.0;
  final padding = 18.0;
  Map<String, TextEditingController> textFieldControllers = {};

  @override
  Widget build(BuildContext context) {
    print('building question ${widget.question.id} ...');
    return StreamBuilder<Question>(
        stream: widget.currentQuestionStream,
        builder: (context, snapshot) {
          Question currentQuestion = snapshot.data;
          if (currentQuestion == null) return Container();
          double bottom = padding;
          double left = padding;

          bool isCurrentQuestion =
              widget.question.index == currentQuestion.index;
          bool isNextQuestion = widget.question.index > currentQuestion.index;
          int questionDifference =
              currentQuestion.index - widget.question.index;
          double opacity = 1.0;
          double centerFromLeft =
              MediaQuery.of(context).size.width / 2 - (widget.cardWidth / 2);

          if (isCurrentQuestion) {
            left = centerFromLeft;
          } else if (isNextQuestion) {
            left = MediaQuery.of(context).size.width - verticalInset;
          } else if (questionDifference == 1) {
            bottom -= verticalInset * questionDifference;
            left = centerFromLeft - padding;
            opacity = 0.7;
          } else if (questionDifference == 2) {
            left = centerFromLeft - padding;
            bottom -= verticalInset * questionDifference;
            opacity = 0.5;
          } else if (questionDifference == 3) {
            left = centerFromLeft - padding;
            bottom -= verticalInset * questionDifference;
            opacity = 0.3;
          } else if (questionDifference > 3) {
            left = centerFromLeft - padding;
            bottom -= verticalInset * 3;
            opacity = 0.0;
          }
          return AnimatedPositioned(
            left: left,
            bottom: bottom,
            duration: Duration(milliseconds: 400),
            child: AnimatedOpacity(
              opacity: opacity,
              duration: Duration(milliseconds: 400),
              child: Material(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.white,
                elevation: isCurrentQuestion ||
                        widget.question.index == currentQuestion.index + 1
                    ? MAX_ELEVATION
                    : 0.0,
                child: Container(
                  width: widget.cardWidth,
                  height: widget.cardHeight -
                      (widget.isKeyboardVisible ? 160.0 : 0.0),
                  child: Column(
                    children: [
                      _question(),
                      isCurrentQuestion ? _buildButtonsRow() : Container(),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget _buildButtonsRow() => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            _backButton(),
            _nextButton(),
          ],
        ),
      );

  Widget _backButton() => widget.isBackButtonVisible()
      ? Align(
          alignment: Alignment.bottomLeft,
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black45,
            ),
            onPressed: () => widget.goToPreviousQuestion(),
          ),
        )
      : Container();

  Widget _nextButton() => Align(
        alignment: Alignment.bottomCenter,
        child: FlatButton(
          color: secondaryMain,
          onPressed: widget.nextButtonStatus == ButtonStatus.DISABLED
              ? null
              : () {
                  switch (widget.nextButtonStatus) {
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

  Widget _question() => Expanded(
        child: widget.question == null
            ? Container()
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 8.0),
                    child: Text(
                      widget.question.label['en'],
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ),
                  _answers(widget.question.id, widget.question.answers)
                ],
              ),
      );

  Widget _answers(String questionId, List<Answer> answers) => Expanded(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
          children: answers
                  .any((answer) => answer.type == AnswerType.IMAGE_OPTION)
              ? _buildAnswerWithImages(questionId, answers)
              : answers
                  .map((answer) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: answer.type == AnswerType.SELECT
                            ? _buildSelectAnswer(questionId, answer)
                            : answer.type == AnswerType.INPUT
                                ? _buildInputAnswer(questionId, answer)
                                : answer.type == AnswerType.PRODUCT_LIST
                                    ? _buildProductListAnswer(
                                        questionId, answer)
                                    : _buildOptionAnswer(questionId, answer),
                      ))
                  .toList()
                  .cast<Widget>(),
        ),
      );

  List<Widget> _buildAnswerWithImages(String questionId, List<Answer> answers) {
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
      ),
      items: answersWithImage
          .map((answer) => _buildImageCard(questionId, answer))
          .cast<Widget>()
          .toList(),
    ));

    widgets.addAll(answersWithoutImages
        .map((answer) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: _buildOptionAnswer(questionId, answer),
            ))
        .cast<Widget>()
        .toList());

    return widgets;
  }

  Widget _buildImageCard(String questionId, Answer answer) => Card(
        child: Container(
          width: MediaQuery.of(context).size.width / 2 + 32.0,
          child: Stack(
            children: [
              Positioned.fill(
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
              widget.isSelected(questionId, answer)
                  ? Container(
                      decoration: BoxDecoration(
                        color: secondaryMain.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Align(
                        alignment: Alignment.bottomRight,
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
                  : Material(
                      color: Colors.transparent,
                      child: InkWell(
                        splashColor: Color(0x40FFC107),
                        highlightColor: Color(0x20FFC107),
                        onTap: () => widget.setValue(answer, answer.value),
                      ),
                    ),
            ],
          ),
        ),
      );

  Widget _buildSelectAnswer(String questionId, Answer answer) =>
      CustomExpansionTile(
        selectedColor: secondaryMain,
        title: Text(answer.label['en']),
        onExpansionChanged: (expanded) =>
            expanded ? widget.setValue(answer, answer.value[0]) : null,
        initiallyExpanded: widget.isSelected(questionId, answer),
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 5,
            width: double.infinity,
            child: CupertinoPicker(
              magnification: 1.5,
              itemExtent: 25,
              onSelectedItemChanged: (int index) {
                widget.setValue(answer, answer.value[index]);
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
    if (textFieldControllers[answer.id] == null)
      textFieldControllers[answer.id] = TextEditingController();
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Material(
        color: widget.isSelected(questionId, answer)
            ? Color(0x20FFC107)
            : Theme.of(context).canvasColor,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 8.0),
          child: TextFormField(
            controller: textFieldControllers[answer.id],
            inputFormatters: answer.valueType == "NUMBER"
                ? [WhitelistingTextInputFormatter.digitsOnly]
                : [],
            keyboardType: answer.valueType == "NUMBER"
                ? TextInputType.number
                : TextInputType.text,
            autovalidate: true,
            validator: (String value) {
              if (answer.validators.containsKey("min_length") &&
                  answer.validators["min_length"] != null) {
                if (value.length <
                    (int.tryParse(answer.validators["min_length"]) ?? 1))
                  return "Min. length ${answer.validators['min_length']}";
              }
              if (answer.validators.containsKey("max_length") &&
                  answer.validators["max_length"] != null) {
                if (value.length >
                    (int.tryParse(answer.validators["max_length"]) ?? 1))
                  return "Max. length ${answer.validators['max_length']}";
              }
              return null;
            },
            maxLines: 1,
            decoration: InputDecoration(
              hintText: answer.label["en"] == null || answer.label["en"] == ""
                  ? "Tap to start typing"
                  : answer.label["en"],
              isDense: true,
              isCollapsed: false,
              hintStyle: Theme.of(context)
                  .textTheme
                  .subtitle2
                  .copyWith(fontWeight: FontWeight.w600, color: Colors.black45),
            ),
            onFieldSubmitted: (text) {
              if (text != null && text.length > 0)
                widget.setValue(answer, text);
            },
            onEditingComplete: () {
              if (textFieldControllers[answer.id].text != null &&
                  textFieldControllers[answer.id].text.length > 0)
                widget.setValue(answer, textFieldControllers[answer.id].text);
            },
            onTap: () {
              if (textFieldControllers[answer.id].text != null &&
                  textFieldControllers[answer.id].text.length > 0)
                widget.setValue(answer, textFieldControllers[answer.id].text);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOptionAnswer(String questionId, Answer answer) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Material(
          color: widget.isSelected(questionId, answer)
              ? Color(0x20FFC107)
              : Theme.of(context).canvasColor,
          child: InkWell(
            onTap: () {
              widget.setValue(answer, answer.value);
            },
            splashColor: widget.isSelected(questionId, answer)
                ? Color(0x40FFC107)
                : null,
            highlightColor: widget.isSelected(questionId, answer)
                ? Color(0x20FFC107)
                : null,
            child: Container(
              padding: EdgeInsets.all(
                  MediaQuery.of(context).size.height <= 680 ? 8 : 12),
              width: double.infinity,
              child: Text(
                answer.label['en'],
                style: Theme.of(context).textTheme.subtitle2.copyWith(
                      fontWeight: FontWeight.w600,
                      color: widget.isSelected(questionId, answer)
                          ? secondaryMain
                          : Colors.black45,
                    ),
              ),
            ),
          ),
        ),
      );

  Widget _buildProductListAnswer(String questionId, Answer answer) =>
      CarouselSlider(
        options: CarouselOptions(
          autoPlay: true,
          enlargeCenterPage: true,
        ),
        items: answer.value
            .map((product) => _buildProductCard(product, questionId, answer))
            .cast<Widget>()
            .toList(),
      );

  Widget _buildProductCard(dynamic product, String questionId, Answer answer) =>
      Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Stack(
          children: [
            InkWell(
              onTap: () => widget.setValue(answer, product),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Image.network(
                      product.imageURL,
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
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width < 480 ? 8.0 : 16.0),
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
            widget.isSelected(questionId, answer, value: product)
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

  // METHODS
  void _nextQuestion() => widget.goToNextQuestion();

  void _restartForm() => widget.saveAndRestartForm();

  void _finishForm() => widget.finishAndSaveForm();

  bool isValidURL(String url) {
    bool valid = false;
    var urlPattern =
        r"(https?|http)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?";
    if (url != null) {
      var match = new RegExp(urlPattern, caseSensitive: false).firstMatch(url);
      valid = match != null;
    }

    return valid;
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
