import 'dart:math';

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
      width: isNextForm ? 0.0 : null,
      height: isNextForm ? 0.0 : null,
      padding: EdgeInsets.only(bottom: isPreviousForm ? 10.0 : 0.0),
      duration: Duration(milliseconds: 400),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Text(
          title,
          style: TextStyle(
            color: isCurrentForm ? Colors.black87 : Colors.black38,
            fontSize: isCurrentForm ? 34 : 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.25,
          ),
        ),
      ),
    );
  }
}
