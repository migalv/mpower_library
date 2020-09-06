import 'package:auto_size_text/auto_size_text.dart';
import 'package:cons_calc_lib/src/colors.dart';
import 'package:cons_calc_lib/src/pages/admin_forms_results_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AdminDashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Column(
        children: [
          _buildAdminActions(context),
        ],
      ),
      appBar: _buildAppBar(context),
    );
  }

  Widget _buildAppBar(BuildContext context) => AppBar(
        title: FittedBox(
          child: AutoSizeText(
            "Dynamic Forms Admin Dashboard",
            style: Theme.of(context).textTheme.headline1,
            maxFontSize: MediaQuery.of(context).size.width < 768
                ? 22.0
                : double.infinity,
          ),
        ),
        backgroundColor: secondaryMain,
        centerTitle: true,
      );

  Widget _buildAdminActions(BuildContext context) => Expanded(
        child: Column(
          children: [
            Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              height: 128.0,
              width: 256.0,
              child: Card(
                child: InkWell(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => AdminFormsResultsPage())),
                  child: Center(
                    child: Text(
                      "View form results",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
