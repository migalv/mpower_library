import 'package:flutter/material.dart';

class InstructionsCard extends StatelessWidget {
  final String instructions;

  const InstructionsCard({Key key, @required this.instructions})
      : super(key: key);
  @override
  Widget build(BuildContext context) => Container(
        margin: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
        padding: EdgeInsets.all(12.0),
        width: double.infinity,
        decoration: new BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
        child: Text(
          instructions,
          style: Theme.of(context).textTheme.bodyText1,
        ),
      );
}
