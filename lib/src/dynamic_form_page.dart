import 'package:cons_calc_lib/cons_calc_lib.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DynamicFormUI extends StatelessWidget {
  final _cardController = PageController(),
      _titlesController = PageController();

  // TODO Envolvover en stream
  final _currentForm;
  final List<String> _titles;
  final double _currentTitlePage, _currentCardPage;
  final ButtonStatus _nextButtonStatus;
  final _currentQuestion;
  //

  final Function _isBackButtonVisible,
      _isSelected,
      _setValue,
      _goToPreviousQuestion,
      _goToNextQuestion,
      _finishAndSaveForm,
      _setCurrentPage;

  DynamicFormUI({
    Key key,
    @required currentForm,
    @required titles,
    @required currentTitlePage,
    @required currentCardPage,
    @required nextButtonStatus,
    @required currentQuestion,
    @required isBackButtonVisible,
    @required isSelected,
    @required setValue,
    @required finishAndSaveForm,
    @required goToPreviousQuestion,
    @required goToNextQuestion,
    @required setCurrentPage,
  })  : _currentForm = currentForm,
        _titles = titles,
        _nextButtonStatus = nextButtonStatus,
        _currentQuestion = currentQuestion,
        _currentTitlePage = currentTitlePage,
        _currentCardPage = currentCardPage,
        _isBackButtonVisible = isBackButtonVisible,
        _isSelected = isSelected,
        _goToPreviousQuestion = goToPreviousQuestion,
        _goToNextQuestion = goToNextQuestion,
        _finishAndSaveForm = finishAndSaveForm,
        _setCurrentPage = setCurrentPage,
        _setValue = setValue;

  @override
  Widget build(BuildContext context) {
    _listenToPageChanges();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _currentForm == null
          ? Container()
          : _titles.isEmpty
              ? Container()
              : Stack(
                  children: <Widget>[
                    _background(),

                    // Titles
                    Positioned.fill(
                      child: PageView.builder(
                        reverse: true,
                        itemCount: _titles.length,
                        controller: _titlesController,
                        itemBuilder: (context, index) => Container(),
                        scrollDirection: Axis.vertical,
                      ),
                    ),
                    TitleListScroll(
                      currentPage: _currentTitlePage,
                      titles: _titles,
                    ),

                    // Cards
                    Positioned.fill(
                      child: PageView.builder(
                        itemCount: _currentForm.questions.length,
                        controller: _cardController,
                        itemBuilder: (context, index) => Container(),
                      ),
                    ),
                    QuestionCardCarousel(
                      currentCardPage: _currentCardPage,
                      cardController: _cardController,
                      isWeb: MediaQuery.of(context).size.aspectRatio > 1,
                      form: _currentForm,
                      titlesController: _titlesController,
                      nextButtonStatus: _nextButtonStatus,
                      currentQuestion: _currentQuestion,
                      finishAndSaveForm: _finishAndSaveForm,
                      goToNextQuestion: _goToNextQuestion,
                      goToPreviousQuestion: _goToPreviousQuestion,
                      setValue: _setValue,
                      isSelected: _isSelected,
                      isBackButtonVisible: _isBackButtonVisible,
                    ),
                  ],
                ),
    );
  }

  Widget _background() => Container(color: secondaryMain);

  void _listenToPageChanges() {
    _cardController.addListener(() {
      _setCurrentPage(_cardController.page);
    });
    _titlesController.addListener(() {
      _setCurrentPage(_titlesController.page, card: false);
    });
  }
}
