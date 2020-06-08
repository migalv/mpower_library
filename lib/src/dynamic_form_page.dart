import 'dart:async';

import 'package:cons_calc_lib/cons_calc_lib.dart';
import 'package:cons_calc_lib/src/title_form.dart';
import 'package:cons_calc_lib/src/question_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DynamicFormUI extends StatelessWidget {
  final DynamicForm currentForm;
  final List<DynamicForm> forms;
  final ButtonStatus nextButtonStatus;
  final Stream currentQuestionStream;
  final Function isBackButtonVisible,
      isSelected,
      setValue,
      goToPreviousQuestion,
      goToNextQuestion,
      finishAndSaveForm,
      saveAndRestartForm;
  final bool isKeyboardVisible;

  DynamicFormUI({
    @required this.currentForm,
    @required this.forms,
    @required this.nextButtonStatus,
    @required this.currentQuestionStream,
    @required this.isBackButtonVisible,
    @required this.isSelected,
    @required this.setValue,
    @required this.finishAndSaveForm,
    @required this.goToPreviousQuestion,
    @required this.goToNextQuestion,
    @required this.saveAndRestartForm,
    @required this.isKeyboardVisible,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryMain,
      body: currentForm == null || forms.isEmpty
          ? Container()
          : Column(
              children: [
                _buildTitlesScroll(context),
                _buildQuestionCarousel(context),
              ],
            ),
    );
  }

  Widget _buildTitlesScroll(BuildContext context) {
    List<Widget> titles = [];
    int currentFormIndex = forms.indexOf(currentForm);

    for (int i = 0; i < forms.length; i++)
      titles.add(TitleForm(
        formIndex: i,
        currentFormIndex: currentFormIndex,
        title: forms[i].title,
      ));

    return isKeyboardVisible == false
        ? Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: titles.length > 3
                  ? titles
                      .getRange(currentFormIndex - 3, currentFormIndex)
                      .toList()
                  : titles,
            ),
          )
        : Container();
  }

  Widget _buildQuestionCarousel(BuildContext context) {
    double cardSize = MediaQuery.of(context).size.width - 70;
    double padding = 18.0;

    return Container(
      height: cardSize + padding * 2,
      child: Stack(
        children: currentForm.questions
            .map(
              (question) => QuestionCard(
                cardSize: cardSize,
                isWeb: MediaQuery.of(context).size.aspectRatio > 1,
                nextButtonStatus: nextButtonStatus,
                currentQuestionStream: currentQuestionStream,
                finishAndSaveForm: finishAndSaveForm,
                goToNextQuestion: goToNextQuestion,
                goToPreviousQuestion: goToPreviousQuestion,
                setValue: setValue,
                isSelected: isSelected,
                isBackButtonVisible: isBackButtonVisible,
                saveAndRestartForm: saveAndRestartForm,
                question: question,
                isKeyboardVisible: isKeyboardVisible,
              ),
            )
            .cast<Widget>()
            .toList(),
      ),
    );
  }
}
