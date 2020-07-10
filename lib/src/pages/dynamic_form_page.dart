import 'dart:math';

import 'package:cons_calc_lib/cons_calc_lib.dart';
import 'package:cons_calc_lib/src/widgets/title_form.dart';
import 'package:cons_calc_lib/src/widgets/question_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class DynamicFormPage extends StatefulWidget {
  @override
  _DynamicFormPageState createState() => _DynamicFormPageState();
}

class _DynamicFormPageState extends State<DynamicFormPage> {
  DynamicFormBloc _dynamicFormBloc;

  @override
  void didChangeDependencies() {
    _dynamicFormBloc = Provider.of<DynamicFormBloc>(context);
    KeyboardVisibility.onChange.listen((bool visible) {
      _dynamicFormBloc.updateKeyboardVisibility(visible);
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryMain,
      body: Column(
        children: [
          _buildMpowerLogo(),
          _buildFormTitle(),
          // _buildTitlesScroll(),
          _buildQuestionCarousel(),
        ],
      ),
    );
  }

  Widget _buildMpowerLogo() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Image.network(
          "https://firebasestorage.googleapis.com/v0/b/mpower-dashboard-components.appspot.com/o/assets%2Fmpower_logos%2Flogo-con-text.svg?alt=media&token=3d4fd611-cff2-4a2a-b752-64d935902b29",
          width: MediaQuery.of(context).size.height <= 768
              ? MediaQuery.of(context).size.height / 10
              : MediaQuery.of(context).size.height / 8,
          color: Color.fromRGBO(0, 54, 103, 1),
        ),
      );

  Widget _buildFormTitle() => Expanded(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 480.0,
          ),
          child: StreamBuilder<String>(
            stream: _dynamicFormBloc.initialFormTitle,
            builder: (context, snapshot) =>
                snapshot.hasData && snapshot.hasError == false
                    ? Text(
                        snapshot.data,
                        style: Theme.of(context).textTheme.headline1,
                        textAlign: TextAlign.center,
                      )
                    : Container(),
          ),
        ),
      );

  Widget _buildTitlesScroll() => StreamBuilder<List<DynamicForm>>(
        stream: _dynamicFormBloc.forms,
        initialData: [],
        builder: (_, snapshotForms) => StreamBuilder<DynamicForm>(
          stream: _dynamicFormBloc.currentForm,
          builder: (_, currentFormSnapshot) {
            DynamicForm currentForm;
            List<DynamicForm> forms = snapshotForms.data;

            if (currentFormSnapshot.hasData == false ||
                currentFormSnapshot.hasError)
              return Center(child: CircularProgressIndicator());
            else
              currentForm = currentFormSnapshot.data;

            List<Widget> titles = [];
            int currentFormIndex = forms.indexOf(currentForm);

            for (int i = 0; i < forms.length; i++)
              titles.add(TitleForm(
                formIndex: i,
                currentFormIndex: currentFormIndex,
                title: forms[i].title,
              ));

            return StreamBuilder<bool>(
              stream: _dynamicFormBloc.isKeyboardVisible,
              initialData: false,
              builder: (_, keyboardVisibilitySnapshot) =>
                  keyboardVisibilitySnapshot.data == false
                      ? Expanded(
                          child: Container(
                            constraints: BoxConstraints(maxWidth: 480.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: titles.length > 3
                                  ? titles
                                      .getRange(
                                          currentFormIndex - 3 < 0
                                              ? 0
                                              : currentFormIndex - 2,
                                          currentFormIndex + 1)
                                      .toList()
                                  : titles,
                            ),
                          ),
                        )
                      : Container(),
            );
          },
        ),
      );

  Widget _buildQuestionCarousel() => StreamBuilder<DynamicForm>(
        stream: _dynamicFormBloc.currentForm,
        builder: (_, currentFormSnapshot) {
          DynamicForm currentForm;

          if (currentFormSnapshot.hasData == false ||
              currentFormSnapshot.hasError)
            return Center(child: CircularProgressIndicator());
          else
            currentForm = currentFormSnapshot.data;

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
                      question: question,
                    ),
                  )
                  .cast<Widget>()
                  .toList(),
            ),
          );
        },
      );
}
