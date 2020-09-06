import 'package:auto_size_text/auto_size_text.dart';
import 'package:cons_calc_lib/src/colors.dart';
import 'package:cons_calc_lib/src/models/form_results_model.dart';
import 'package:flutter/material.dart';

class AdminFormResultsPage extends StatelessWidget {
  final FormResults formResults;

  const AdminFormResultsPage({Key key, @required this.formResults})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: _buildFormResults(context),
      appBar: _buildAppBar(context),
    );
  }

  Widget _buildAppBar(BuildContext context) => AppBar(
        title: FittedBox(
          child: AutoSizeText(
            "Form Results",
            style: Theme.of(context).textTheme.headline1,
            maxFontSize: MediaQuery.of(context).size.width < 768
                ? 22.0
                : double.infinity,
          ),
        ),
        backgroundColor: secondaryMain,
        centerTitle: true,
      );

  Widget _buildFormResults(BuildContext context) => ListView(
        children: formResults.results.entries
            .map((entry) => _buildFormCard(context, entry.key, entry.value))
            .toList(),
      );

  Widget _buildFormCard(BuildContext context, String formId, Map results) =>
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              formId,
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          _buildQuestionsResults(context, results),
        ],
      );

  Widget _buildQuestionsResults(BuildContext context, Map results) {
    List questionsResults = results.values.toList().first.values.toList();

    questionsResults.sort((a, b) => a["index"].compareTo(b["index"]));

    return Column(
      children: questionsResults
          .map((questionMap) => _buildQuestionCard(context, questionMap))
          .toList(),
    );
  }

  Widget _buildQuestionCard(BuildContext context, Map questionMap) {
    return Card(
      child: Container(
        width: 768.0,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Question ${questionMap["index"] + 1}",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  Text(
                    "Label",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(questionMap["question_label"]["en"]),
                ],
              ),
            ),
            questionMap["answer_label"]["en"] != ""
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          "Answer label",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        Text(questionMap["answer_label"]["en"]),
                      ],
                    ),
                  )
                : Container(),
            questionMap["value"] != null
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          "Answer value",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        Text("${questionMap["value"]}"),
                      ],
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
