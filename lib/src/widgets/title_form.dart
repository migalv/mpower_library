import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class TitleForm extends StatelessWidget {
  final int formIndex;
  final int currentFormIndex;
  final String title;

  TitleForm({this.formIndex, this.title, this.currentFormIndex});

  @override
  Widget build(BuildContext context) {
    bool isCurrentForm = formIndex == currentFormIndex;
    bool isNextForm = formIndex > currentFormIndex;
    bool isPreviousForm = formIndex < currentFormIndex;

    return AnimatedContainer(
      constraints: BoxConstraints(maxWidth: 480.0),
      width: isNextForm ? 0.0 : null,
      height: isNextForm ? 0.0 : null,
      padding: EdgeInsets.only(bottom: isPreviousForm ? 10.0 : 0.0),
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      duration: Duration(milliseconds: 400),
      child: AutoSizeText(
        title,
        maxLines: 2,
        style: TextStyle(
          color: isCurrentForm ? Colors.black87 : Colors.black38,
          fontSize: isCurrentForm ? 34 : 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.25,
        ),
      ),
    );
  }
}
