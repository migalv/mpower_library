import 'dart:async';
import 'dart:math';

import 'package:cons_calc_lib/cons_calc_lib.dart';
import 'package:cons_calc_lib/src/widgets/title_form.dart';
import 'package:cons_calc_lib/src/widgets/question_card.dart';
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
                _buildMpowerLogo(context),
                _buildTitlesScroll(context),
                _buildQuestionCarousel(context),
              ],
            ),
    );
  }

  Widget _buildMpowerLogo(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Image.network(
          "https://firebasestorage.googleapis.com/v0/b/mpower-dashboard-components.appspot.com/o/assets%2Fmpower_logos%2Flogo-con-text.svg?alt=media&token=3d4fd611-cff2-4a2a-b752-64d935902b29",
          width: MediaQuery.of(context).size.height <= 768
              ? MediaQuery.of(context).size.height / 10
              : MediaQuery.of(context).size.height / 8,
          color: Color.fromRGBO(0, 54, 103, 1),
        ),
      );

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
            child: Container(
              constraints: BoxConstraints(maxWidth: 480.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: titles.length > 3
                    ? titles
                        .getRange(
                            currentFormIndex - 3 < 0 ? 0 : currentFormIndex - 2,
                            currentFormIndex + 1)
                        .toList()
                    : titles,
              ),
            ),
          )
        : Container();
  }

  Widget _buildQuestionCarousel(BuildContext context) {
    double cardWidth = min(MediaQuery.of(context).size.width - 70, 480.0);
    double cardHeight = MediaQuery.of(context).size.height <= 768.0
        ? MediaQuery.of(context).size.height / 2
        : cardWidth;
    double padding = 18.0;

    return Container(
      height: cardHeight + padding * 2,
      child: Stack(
        children: currentForm.questions
            .map(
              (question) => QuestionCard(
                cardWidth: cardWidth,
                cardHeight: cardHeight,
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
