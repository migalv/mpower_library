import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cons_calc_lib/cons_calc_lib.dart';
import 'package:cons_calc_lib/src/models/analytics_results_model.dart';
import 'package:cons_calc_lib/src/pages/admin_analytic_results_page.dart';
import 'package:flutter/material.dart';

class AdminAnalyticsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: _buildAnalytics(context),
      appBar: _buildAppBar(context),
    );
  }

  Widget _buildAppBar(BuildContext context) => AppBar(
        title: FittedBox(
          child: AutoSizeText(
            "Analytics results",
            style: Theme.of(context).textTheme.headline1,
            maxFontSize: MediaQuery.of(context).size.width < 768
                ? 22.0
                : double.infinity,
          ),
        ),
        backgroundColor: secondaryMain,
        centerTitle: true,
      );

  Widget _buildAnalytics(BuildContext context) => Center(
        child: FutureBuilder<List<AnalyticsResults>>(
            future: _loadAnalyticResults(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.hasError == false)
                return Container(
                  constraints: BoxConstraints(
                    maxWidth: 768,
                  ),
                  padding: EdgeInsets.all(16.0),
                  child: ListView(
                    children: snapshot.data.isNotEmpty
                        ? snapshot.data
                            .map((formResults) =>
                                _buildResultCard(context, formResults))
                            .toList()
                        : [_buildPlaceholder()],
                  ),
                );
              else
                return CircularProgressIndicator();
            }),
      );

  Widget _buildPlaceholder() => Text("No analytics have been registered yet");

  Widget _buildResultCard(
      BuildContext context, AnalyticsResults analyticResults) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) =>
                AdminAnalyticsResultsPage(analyticResults: analyticResults))),
        child: Container(
          height: 64.0,
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              _buildTitles(
                context,
                title: analyticResults.formId,
                subtitle: "Visitors: ${analyticResults.visitors}",
              ),
            ],
          ),
        ),
      ),
    );
  }

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

  Future<List<AnalyticsResults>> _loadAnalyticResults() async {
    QuerySnapshot querySnapshot = await Firestore.instance
        .collection("dynamic_forms_analytics")
        .getDocuments();
    List<AnalyticsResults> analyticsResults = querySnapshot.documents
        .map((doc) =>
            AnalyticsResults.fromJson(formId: doc.documentID, json: doc.data))
        .toList();
    return analyticsResults;
  }
}
