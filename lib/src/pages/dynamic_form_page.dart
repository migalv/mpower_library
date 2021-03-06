import 'dart:async';
import 'dart:collection';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cons_calc_lib/cons_calc_lib.dart';
import 'package:cons_calc_lib/src/widgets/question_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class DynamicFormPage extends StatefulWidget {
  @override
  _DynamicFormPageState createState() => _DynamicFormPageState();
}

class _DynamicFormPageState extends State<DynamicFormPage> {
  DynamicFormBloc _dynamicFormBloc;
  Queue<QuestionCard> _questionCards;
  StreamSubscription _streamSubscription;
  final _animationDuration = Duration(milliseconds: 400);

  @override
  void didChangeDependencies() {
    _dynamicFormBloc = Provider.of<DynamicFormBloc>(context);
    if (_streamSubscription == null)
      _streamSubscription =
          _dynamicFormBloc.reOrderStack.listen(_updateQuestionCards);
    _initQuestionCards();

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
          _buildGreetingText(),
          _buildQuestionCarousel(),
          _buildCodeVersion(_dynamicFormBloc.codeVersion),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          bool sendHelp = (await _showHelpConfirmationDialog()) ?? false;
          if (sendHelp) {
            bool response = _dynamicFormBloc.sendHelpSMS();
            if (response)
              _showConfirmationDialog();
            else
              _showAnswerMoreQuestionsDialog();
          }
        },
        label: Text("Help"),
        icon: Icon(MdiIcons.help),
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

  Widget _buildFormTitle() => Container(
        margin: const EdgeInsets.symmetric(horizontal: 32.0),
        constraints: BoxConstraints(
          maxWidth: 480.0,
        ),
        child: StreamBuilder<String>(
          stream: _dynamicFormBloc.initialFormTitle,
          builder: (context, snapshot) =>
              snapshot.hasData && snapshot.hasError == false
                  ? StreamBuilder<bool>(
                      stream: _dynamicFormBloc.isKeyboardVisible,
                      initialData: false,
                      builder: (_, keyboardVisibilitySnapshot) =>
                          keyboardVisibilitySnapshot.data == false
                              ? _buildTitle(snapshot.data)
                              : Center(child: CircularProgressIndicator()),
                    )
                  : Container(),
        ),
      );

  Widget _buildTitle(String title) => FittedBox(
        alignment: Alignment.topCenter,
        child: AutoSizeText(
          title,
          style: Theme.of(context).textTheme.headline1.copyWith(
              fontSize: MediaQuery.of(context).size.height <= 700 ? 22 : null),
          textAlign: TextAlign.center,
          maxLines: 1,
        ),
      );

  Widget _buildGreetingText() => Expanded(
        child: StreamBuilder<Map<String, String>>(
          stream: _dynamicFormBloc.greetingData,
          builder: (_, greetingDataSnapshot) {
            if (greetingDataSnapshot.hasData == false ||
                greetingDataSnapshot.hasError)
              return Container();
            else if (greetingDataSnapshot.data["title"] == null ||
                greetingDataSnapshot.data["subtitle"] == null)
              return Container();

            return StreamBuilder<bool>(
              stream: _dynamicFormBloc.isFirstQuestion,
              initialData: true,
              builder: (_, isFirstQuestionSnapshot) => StreamBuilder<bool>(
                stream: _dynamicFormBloc.isKeyboardVisible,
                initialData: false,
                builder: (_, keyboardVisibilitySnapshot) {
                  if (keyboardVisibilitySnapshot.data == true)
                    return Container();
                  return AnimatedOpacity(
                    opacity: isFirstQuestionSnapshot.data == true ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 400),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      constraints: BoxConstraints(
                        maxWidth: 480.0,
                        maxHeight: MediaQuery.of(context).size.height * 0.25,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          greetingDataSnapshot.data["title"] != null
                              ? AutoSizeText(
                                  greetingDataSnapshot.data["title"],
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      .copyWith(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22.0,
                                      ),
                                  maxLines: 1,
                                )
                              : Container(),
                          SizedBox(height: 8.0),
                          greetingDataSnapshot.data["subtitle"] != null
                              ? AutoSizeText(
                                  greetingDataSnapshot.data["subtitle"],
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      .copyWith(
                                        color: black70,
                                        fontStyle: FontStyle.italic,
                                        fontSize: 16.0,
                                      ),
                                  textAlign: TextAlign.justify,
                                  maxLines: 3,
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      );

  Widget _buildQuestionCarousel() {
    double screenHeight = MediaQuery.of(context).size.height;

    double cardHeight =
        screenHeight <= 700 ? screenHeight / 1.75 : screenHeight / 2;
    double padding = 18.0;

    return Container(
      height: cardHeight + padding * 2,
      child: Stack(children: _questionCards.toList()),
    );
  }

  Widget _buildCodeVersion(String codeVersion) => Text(
        codeVersion,
        style: Theme.of(context).textTheme.caption,
      );

  // METHODS
  void _initQuestionCards() {
    if (_questionCards == null) {
      setState(() {
        _questionCards = Queue();
        for (int i = 1; i < _dynamicFormBloc.maxQuestionCards; i++)
          _questionCards.add(QuestionCard(
            animationDuration: _animationDuration,
            key: UniqueKey(),
            index: i,
          ));
        _questionCards.add(QuestionCard(
          animationDuration: _animationDuration,
          key: UniqueKey(),
          index: 0,
        ));
      });
    }
  }

  void _updateQuestionCards(bool forward) {
    // Is moving forward (next question)
    setState(() {
      if (forward == true) {
        QuestionCard firstQuestion = _questionCards.removeFirst();
        _questionCards.add(firstQuestion);
      } // Is moving backwards (prev question)
      else {
        Future.delayed(_animationDuration, () {
          QuestionCard lastQuestion = _questionCards.removeLast();
          _questionCards.addFirst(lastQuestion);
        });
      }
    });
  }

  void _showConfirmationDialog() => showDialog(
        context: context,
        child: AlertDialog(
          title: Text(
            "Help petition sent",
            style: Theme.of(context)
                .textTheme
                .headline6
                .copyWith(fontWeight: FontWeight.bold),
          ),
          content: Container(
            width: 256.0,
            child: Text(
              "An MPower employee will get in contact with you as soon as possible. Please wait.",
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
          actions: [
            FlatButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Dismiss"),
            ),
          ],
        ),
      );

  Future<bool> _showAnswerMoreQuestionsDialog() => showDialog(
        context: context,
        child: AlertDialog(
          title: Text(
            "We need more info about you",
            style: Theme.of(context)
                .textTheme
                .headline6
                .copyWith(fontWeight: FontWeight.bold),
          ),
          content: Container(
            width: 256.0,
            child: Text(
              "Please enter your name and phone number so an MPower employee can get in contact with you.",
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
          actions: [
            FlatButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Dismiss"),
            ),
          ],
        ),
      );

  Future<bool> _showHelpConfirmationDialog() async => await showDialog(
        context: context,
        child: AlertDialog(
          title: Text(
            "Do you need help?",
            style: Theme.of(context)
                .textTheme
                .headline6
                .copyWith(fontWeight: FontWeight.bold),
          ),
          content: Container(
            width: 256.0,
            child: Text(
              "If you need help to answer this form, you can contact an MPower employee to help you.",
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
          actions: [
            FlatButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("Cancel"),
            ),
            RaisedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                "I Need Help",
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      );

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }
}
