import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cons_calc_lib/src/colors.dart';
import 'package:cons_calc_lib/src/models/form_results_model.dart';
import 'package:cons_calc_lib/src/pages/admin_form_results_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminFormsResultsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: _buildFormsResults(context),
      appBar: _buildAppBar(context),
    );
  }

  Widget _buildAppBar(BuildContext context) => AppBar(
        title: FittedBox(
          child: AutoSizeText(
            "Forms Results",
            style: Theme.of(context).textTheme.headline1,
            maxFontSize: MediaQuery.of(context).size.width < 768
                ? 22.0
                : double.infinity,
          ),
        ),
        backgroundColor: secondaryMain,
        centerTitle: true,
      );

  Widget _buildFormsResults(BuildContext context) =>
      FutureBuilder<List<FormResults>>(
          future: _loadFormResults(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.hasError == false)
              return ListView(
                padding: EdgeInsets.all(
                    MediaQuery.of(context).size.width <= 768 ? 8.0 : 32.0),
                children: snapshot.data.isNotEmpty
                    ? snapshot.data
                        .map((formResults) =>
                            _buildResultCard(context, formResults))
                        .toList()
                    : [_buildPlaceholder()],
              );
            else
              return Center(child: CircularProgressIndicator());
          });

  Widget _buildPlaceholder() =>
      Text("No one has answered any questions yet...");

  Widget _buildResultCard(BuildContext context, FormResults formResults) {
    int numAnsweredQuestions = 0;

    formResults.results.values.forEach((form) {
      form.values.forEach((formRepetition) {
        numAnsweredQuestions += formRepetition.keys.length;
      });
    });

    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => AdminFormResultsPage(formResults: formResults))),
        child: Container(
          height: 64.0,
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              _buildLeading(formResults.isCompleted),
              _buildTitles(
                context,
                title: formResults.id.substring(0, 12),
                subtitle: "$numAnsweredQuestions Answered Questions",
              ),
              Expanded(child: Container()),
              _buildTrailing(
                context,
                codeVersion: formResults.codeVersion,
                lastUpdatedAt: DateFormat("dd, MMM, H:mm").format(
                    DateTime.fromMillisecondsSinceEpoch(
                        formResults.lastUpdatedAt)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeading(bool isCompleted) => CircleAvatar(
        backgroundColor: isCompleted ? Colors.green : Colors.red,
        child: Icon(isCompleted ? Icons.check : Icons.close),
      );

  Widget _buildTitles(BuildContext context,
          {String title = "N/A", String subtitle = "N/A"}) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoSizeText(
              title,
              maxLines: 1,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            SizedBox(height: 4.0),
            AutoSizeText(
              subtitle,
              maxLines: 1,
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ],
        ),
      );

  Widget _buildTrailing(BuildContext context,
          {String codeVersion = "N/A", String lastUpdatedAt = "N/A"}) =>
      SizedBox(
        width: 112.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FittedBox(
              child: AutoSizeText(
                codeVersion,
                style: Theme.of(context).textTheme.caption,
              ),
            ),
            Expanded(child: Container()),
            FittedBox(
              child: AutoSizeText(
                lastUpdatedAt,
                style: Theme.of(context).textTheme.caption,
              ),
            ),
          ],
        ),
      );

  // METHOD
  Future<List<FormResults>> _loadFormResults() async {
    QuerySnapshot querySnapshot =
        await Firestore.instance.collection("form_results").getDocuments();
    List<FormResults> formsResults = [];
    querySnapshot.documents.forEach((doc) {
      if (doc != null &&
          parseCode(doc.data["last_answer_code_version"]) >= 110) {
        FormResults formResults =
            FormResults.fromJson(doc.documentID, doc.data);
        formsResults.add(formResults);
      }
    });
    formsResults.sort(
        (form1, form2) => form2.lastUpdatedAt.compareTo(form1.lastUpdatedAt));
    return formsResults;
  }

  int parseCode(String code) =>
      code != null ? int.parse(code.substring(1).split(".").join()) : 0;
}
