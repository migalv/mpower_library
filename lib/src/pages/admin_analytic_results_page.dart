import 'package:auto_size_text/auto_size_text.dart';
import 'package:cons_calc_lib/cons_calc_lib.dart';
import 'package:cons_calc_lib/src/models/analytics_results_model.dart';
import 'package:flutter/material.dart';

class AdminAnalyticsResultsPage extends StatelessWidget {
  final AnalyticsResults analyticResults;

  const AdminAnalyticsResultsPage({Key key, @required this.analyticResults})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Align(
        alignment: Alignment.topCenter,
        child: Card(
          margin: const EdgeInsets.all(16.0),
          child: Container(
            constraints: BoxConstraints(maxWidth: 768.0),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  analyticResults.formId,
                  style: Theme.of(context).textTheme.headline1,
                ),
                SizedBox(height: 8),
                _buildDataSection(context, "Visitors", [
                  AnalyticDataRow(
                    title: "Number",
                    data: analyticResults.visitors,
                  ),
                ]),
                _buildDataSection(context, "Abandoned ", [
                  AnalyticDataRow(
                      title: "Number", data: analyticResults.bounceCount),
                  AnalyticDataRow(
                    title: "Bounce Rate",
                    data: "${analyticResults.bounceRate.toStringAsFixed(2)}%",
                  ),
                ]),
                _buildDataSection(context, "Users", [
                  AnalyticDataRow(title: "Number", data: analyticResults.users),
                  AnalyticDataRow(
                    title: "Conversion Rate",
                    data:
                        "${analyticResults.userConversionRate.toStringAsFixed(2)}%",
                  ),
                ]),
                _buildDataSection(context, "Leads", [
                  AnalyticDataRow(title: "Number", data: analyticResults.leads),
                  AnalyticDataRow(
                    title: "Conversion Rate",
                    data:
                        "${analyticResults.leadConversionRate.toStringAsFixed(2)}%",
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) => AppBar(
        title: FittedBox(
          child: AutoSizeText(
            "Analytic results",
            style: Theme.of(context).textTheme.headline1,
            maxFontSize: MediaQuery.of(context).size.width < 768
                ? 22.0
                : double.infinity,
          ),
        ),
        backgroundColor: secondaryMain,
        centerTitle: true,
      );

  Widget _buildDataSection(
      BuildContext context, String title, List<AnalyticDataRow> dataRowList) {
    List<Widget> widgets = [
      Text(
        title,
        style: Theme.of(context).textTheme.headline5,
      ),
    ];

    dataRowList.forEach((dataRow) {
      widgets.add(_buildDataRow(dataRow.title, dataRow.data));
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildDataRow(String dataName, dynamic data) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Text(
              dataName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Divider(),
              ),
            ),
            Text("$data"),
          ],
        ),
      );
}

class AnalyticDataRow {
  final String title;
  final dynamic data;

  AnalyticDataRow({@required this.title, @required this.data});
}
