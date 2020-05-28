import 'dart:async';

import 'package:cons_calc_lib/cons_calc_lib.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class DynamicFormUI extends StatefulWidget {
  final _currentForm;
  final List<String> _titles;
  final double _currentTitlePage, _currentCardPage;
  final ButtonStatus _nextButtonStatus;
  final _currentQuestion;
  final Function _isBackButtonVisible,
      _isSelected,
      _setValue,
      _goToPreviousQuestion,
      _goToNextQuestion,
      _finishAndSaveForm,
      _setCurrentPage,
      _saveAndRestartForm,
      _updateKeyboardVisibility;
  final Stream<bool> _isKeyboardVisible;

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
    @required saveAndRestartForm,
    @required isKeyboardVisible,
    @required updateKeyboardVisibility,
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
        _setValue = setValue,
        _saveAndRestartForm = saveAndRestartForm,
        _isKeyboardVisible = isKeyboardVisible,
        _updateKeyboardVisibility = updateKeyboardVisibility;

  @override
  _DynamicFormUIState createState() => _DynamicFormUIState();
}

class _DynamicFormUIState extends State<DynamicFormUI> {
  final _cardController = PageController(),
      _titlesController = PageController();
  List<StreamSubscription> _streamSubscriptions = [];

  @override
  void initState() {
    _listenToPageChanges();
    _streamSubscriptions.add(
        KeyboardVisibility.onChange.listen(widget._updateKeyboardVisibility));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: widget._currentForm == null || widget._titles.isEmpty
          ? Container()
          : Stack(
              children: <Widget>[
                _background(),

                // Titles
                Positioned.fill(
                  child: PageView.builder(
                    reverse: true,
                    itemCount: widget._titles.length,
                    controller: _titlesController,
                    itemBuilder: (context, index) => Container(),
                    scrollDirection: Axis.vertical,
                  ),
                ),
                TitleListScroll(
                  currentPage: widget._currentTitlePage,
                  titles: widget._titles,
                ),

                // Cards
                Positioned.fill(
                  child: PageView.builder(
                    itemCount: widget._currentForm.questions.length,
                    controller: _cardController,
                    itemBuilder: (context, index) => Container(),
                  ),
                ),
                QuestionCardCarousel(
                  currentCardPage: widget._currentCardPage,
                  currentTitlePage: widget._currentTitlePage,
                  cardController: _cardController,
                  isWeb: MediaQuery.of(context).size.aspectRatio > 1,
                  form: widget._currentForm,
                  titlesController: _titlesController,
                  nextButtonStatus: widget._nextButtonStatus,
                  currentQuestion: widget._currentQuestion,
                  finishAndSaveForm: widget._finishAndSaveForm,
                  goToNextQuestion: widget._goToNextQuestion,
                  goToPreviousQuestion: widget._goToPreviousQuestion,
                  setValue: widget._setValue,
                  isSelected: widget._isSelected,
                  isBackButtonVisible: widget._isBackButtonVisible,
                  saveAndRestartForm: widget._saveAndRestartForm,
                  isKeyboardVisible: widget._isKeyboardVisible,
                ),
              ],
            ),
    );
  }

  Widget _background() => Container(color: secondaryMain);

  void _listenToPageChanges() {
    _cardController.addListener(() {
      widget._setCurrentPage(_cardController.page);
    });
    _titlesController.addListener(() {
      widget._setCurrentPage(_titlesController.page, card: false);
    });
  }

  @override
  void dispose() {
    _streamSubscriptions.forEach((s) => s.cancel());
    super.dispose();
  }
}
