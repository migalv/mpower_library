import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cons_calc_lib/cons_calc_lib.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class QuestionCardCarousel extends StatefulWidget {
  final _currentCardPage, _currentTitlePage;
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
  final Stream<bool> _isKeyboardVisible;

  QuestionCardCarousel({
    @required currentCardPage,
    @required currentTitlePage,
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
    @required isKeyboardVisible,
  })  : _form = form,
        _cardController = cardController,
        _currentTitlePage = currentTitlePage,
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
        _saveAndRestartForm = saveAndRestartForm,
        _isKeyboardVisible = isKeyboardVisible;

  @override
  _QuestionCardCarouselState createState() => _QuestionCardCarouselState();
}

class _QuestionCardCarouselState extends State<QuestionCardCarousel> {
  final padding = 18.0;

  final verticalInset = 18.0;
  Map<String, TextEditingController> textFieldControllers = {};

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: widget._isKeyboardVisible,
        initialData: false,
        builder: (context, isKeyboardVisibleSnapshot) {
          return LayoutBuilder(
            builder: (context, contraints) {
              List<Widget> children = [];

              for (var i = 0; i < widget._form.questions.length; i++) {
                var delta = i - widget._currentCardPage;
                bool isOnRight = delta > 0;

                var start = padding +
                    (widget._isWeb
                        ? max(20 - 50 * -delta * (isOnRight ? 90 : 1), 0.0)
                        : max(20 - 20 * -delta * (isOnRight ? 18 : 1), 0.0));

                var elevation =
                    MAX_ELEVATION - max(-MAX_ELEVATION * delta, 0.0);
                var opacity = MAX_OPACITY - max(-delta, 0.0);

                children.add(
                  Positioned.directional(
                    textDirection: TextDirection.ltr,
                    top: MediaQuery.of(context).size.height * .45 +
                        verticalInset * max(-delta, 0.0) -
                        (isKeyboardVisibleSnapshot.data ? 160.0 : 0.0),
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
                                child: Column(
                                  children: [
                                    _question(),
                                    _buildButtonsRow(),
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
        });
  }

  Widget _buildButtonsRow() => Stack(
        children: [
          _backButton(),
          _nextButton(),
        ],
      );

  Widget _backButton() => widget._isBackButtonVisible()
      ? Align(
          alignment: Alignment.bottomLeft,
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black45,
            ),
            onPressed: () {
              widget._goToPreviousQuestion();

              widget._cardController.animateToPage(
                widget._currentCardPage.truncate() - 1,
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
          onPressed: widget._nextButtonStatus == ButtonStatus.DISABLED
              ? null
              : () {
                  switch (widget._nextButtonStatus) {
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: widget._currentQuestion == null
              ? Container()
              : Column(
                  children: [
                    Text(
                      widget._currentQuestion.label['en'],
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    _answers(widget._currentQuestion.id,
                        widget._currentQuestion.answers)
                  ],
                ),
        ),
      );

  Widget _answers(String questionId, List<Answer> answers) => Expanded(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
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

  Widget _buildImageCard(String questionId, Answer answer) =>
      CachedNetworkImage(
        useOldImageOnUrlChange: true,
        imageUrl: answer.imageUrl,
        placeholder: (_, __) => Card(
          child: Container(
            width: MediaQuery.of(context).size.width / 2 + 32.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  MdiIcons.fileAlert,
                  color: Colors.black26,
                  size: 32.0,
                ),
                SizedBox(height: 8.0),
                // TODO TRANSLATE
                Text(
                  "Unable to download image",
                  style: Theme.of(context).textTheme.subtitle2,
                ),
              ],
            ),
          ),
        ),
        errorWidget: (_, __, ___) => Card(
          child: Container(
            width: MediaQuery.of(context).size.width / 2 + 32.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  MdiIcons.fileAlert,
                  color: Colors.black26,
                  size: 32.0,
                ),
                SizedBox(height: 8.0),
                // TODO TRANSLATE
                Text(
                  "Unable to download image",
                  style: Theme.of(context).textTheme.subtitle2,
                ),
              ],
            ),
          ),
        ),
        imageBuilder: (context, image) {
          return Card(
            child: Container(
              width: MediaQuery.of(context).size.width / 2 + 32.0,
              child: Stack(
                children: [
                  Material(
                    child: Ink.image(
                      image: image,
                      child: InkWell(
                        splashColor: Color(0x40FFC107),
                        highlightColor: Color(0x20FFC107),
                        onTap: () => widget._setValue(answer, answer.value),
                      ),
                    ),
                  ),
                  widget._isSelected(questionId, answer)
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
                      : Container(),
                ],
              ),
            ),
          );
        },
      );

  Widget _buildSelectAnswer(String questionId, Answer answer) =>
      CustomExpansionTile(
        selectedColor: secondaryMain,
        title: Text(answer.label['en']),
        onExpansionChanged: (expanded) =>
            expanded ? widget._setValue(answer, answer.value[0]) : null,
        initiallyExpanded: widget._isSelected(questionId, answer),
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 5,
            width: double.infinity,
            child: CupertinoPicker(
              magnification: 1.5,
              itemExtent: 25,
              onSelectedItemChanged: (int index) {
                widget._setValue(answer, answer.value[index]);
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
        color: widget._isSelected(questionId, answer)
            ? Color(0x20FFC107)
            : Theme.of(context).canvasColor,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 8.0),
          child: TextField(
            controller: textFieldControllers[answer.id],
            decoration: InputDecoration(
              // TODO ENABLE LANGUAGES
              hintText: answer.label["en"],
              isDense: true,
              isCollapsed: false,
              hintStyle: Theme.of(context)
                  .textTheme
                  .subtitle2
                  .copyWith(fontWeight: FontWeight.w600, color: Colors.black45),
            ),
            onChanged: (text) => widget._setValue(answer, text),
            onTap: () =>
                widget._setValue(answer, textFieldControllers[answer.id].text),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionAnswer(String questionId, Answer answer) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Material(
          color: widget._isSelected(questionId, answer)
              ? Color(0x20FFC107)
              : Theme.of(context).canvasColor,
          child: InkWell(
            onTap: () {
              widget._setValue(answer, answer.value);
            },
            splashColor: widget._isSelected(questionId, answer)
                ? Color(0x40FFC107)
                : null,
            highlightColor: widget._isSelected(questionId, answer)
                ? Color(0x20FFC107)
                : null,
            child: Container(
              padding: EdgeInsets.all(12),
              width: double.infinity,
              child: Text(
                answer.label['en'],
                style: Theme.of(context).textTheme.subtitle2.copyWith(
                      fontWeight: FontWeight.w600,
                      color: widget._isSelected(questionId, answer)
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
          aspectRatio: 2.0,
          enlargeCenterPage: true,
        ),
        items: answer.value
            .map((product) => _buildProductCard(product))
            .cast<Widget>()
            .toList(),
      );

  Widget _buildProductCard(dynamic product) => Container(
        width: 184.0,
        margin: const EdgeInsets.only(right: 8.0),
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Column(
            children: <Widget>[
              Container(
                height: 74.0,
                width: 184.0,
                child: isValidURL(product.imageURL)
                    ? CachedNetworkImage(
                        useOldImageOnUrlChange: true,
                        imageUrl: product.imageURL,
                        placeholder: (_, __) => Icon(
                          MdiIcons.tag,
                          color: Colors.black26,
                          size: 32.0,
                        ),
                      )
                    : Icon(
                        MdiIcons.tag,
                        color: Colors.black26,
                        size: 32.0,
                      ),
              ),
              Divider(
                height: 1.0,
                color: Colors.black38,
              ),
              Container(
                height: 32.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  alignment: Alignment.bottomCenter,
                  height: 24.0,
                  child: AutoSizeText(
                    product.name,
                    minFontSize: 12.0,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'LibreFranklin',
                      fontWeight: FontWeight.w500,
                      fontSize: 19.94,
                      letterSpacing: 0.25,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  // METHODS
  void _nextQuestion() {
    widget._goToNextQuestion();

    widget._cardController.animateToPage(
      widget._currentCardPage.truncate() + 1,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _finishForm() async {
    var consumptionProducts = await widget._finishAndSaveForm();

    // TODO Revisar
    // if (consumptionProducts.isNotEmpty) {
    //   Navigator.pop(context);
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
    widget._cardController.animateToPage(
      widget._currentCardPage.truncate() + 1,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    widget._titlesController.animateToPage(
      widget._currentTitlePage.truncate() + 1,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _restartForm() {
    widget._saveAndRestartForm();

    widget._cardController.animateToPage(
      widget._currentCardPage.truncate() + 1,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

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
