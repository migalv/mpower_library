import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cons_calc_lib/cons_calc_lib.dart';
import 'package:flutter/material.dart';

class ReviewPage extends StatefulWidget {
  final ProductBundle bundle;
  final List<ConsumptionProduct> customerProducts;
  final List<ConsumptionProduct> mPowerProducts;
  final Function createCustomerLead, sendAnalyticsEvent;
  final bool showContactForm;

  const ReviewPage({
    Key key,
    @required this.bundle,
    @required this.customerProducts,
    @required this.mPowerProducts,
    @required this.createCustomerLead,
    @required this.showContactForm,
    @required this.sendAnalyticsEvent,
  }) : super(key: key);

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  bool hasConfirmed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF42515A),
      body: SafeArea(
        child: hasConfirmed
            ? ConfirmationWidget()
            : Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    constraints: BoxConstraints(
                        maxWidth:
                            max(460.0, MediaQuery.of(context).size.width / 3)),
                    child: ListView(
                      padding: const EdgeInsets.all(24.0),
                      children: [
                        widget.customerProducts?.isNotEmpty ?? false
                            ? _buildTitle(
                                context, "You search a solution for your")
                            : Container(),
                        widget.customerProducts?.isNotEmpty ?? false
                            ? _buildProductList(
                                context, widget.customerProducts)
                            : Container(),
                        widget.mPowerProducts?.isNotEmpty ?? false
                            ? _buildTitle(
                                context, "And you would like a new MPower")
                            : Container(),
                        widget.mPowerProducts?.isNotEmpty ?? false
                            ? _buildProductList(context, widget.mPowerProducts)
                            : Container(),
                        _buildTitle(context, "For this you selected the"),
                        _buildSelectedBundle(context),
                        SizedBox(height: 64.0),
                      ],
                    ),
                  ),
                  _buildConfirmButton(context),
                ],
              ),
      ),
    );
  }

  Widget _buildProductList(
          BuildContext context, List<ConsumptionProduct> products) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          children: products
              .map((prod) =>
                  _buildProductRow(context, prod.name, prod.powerConsumption))
              .cast<Widget>()
              .toList(),
        ),
      );

  Widget _buildProductRow(
          BuildContext context, String productName, double consumption) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              constraints: BoxConstraints(
                  maxWidth: min(200, MediaQuery.of(context).size.width / 2)),
              child: AutoSizeText(
                productName,
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    .copyWith(color: Colors.white),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                minFontSize: 14.0,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Divider(color: Colors.white70),
              ),
            ),
            Container(
              width: 64.0,
              child: AutoSizeText(
                consumption.truncate().toString() + "Wh",
                textAlign: TextAlign.end,
                maxLines: 1,
                style: Theme.of(context)
                    .textTheme
                    .subtitle2
                    .copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      );

  Widget _buildSelectedBundle(
    BuildContext context,
  ) {
    List<Widget> bundleContent = [
      Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          widget.bundle.name,
          style: Theme.of(context).textTheme.bodyText1.copyWith(
                color: Colors.white,
                fontSize: 20.0,
              ),
        ),
      ),
    ];

    bundleContent.addAll(
      widget.bundle.bundleProducts
          .map(
            (prod) => Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
              child: Row(
                children: [
                  // units
                  Text(
                    "1x",
                    style: TextStyle(color: Colors.white, fontSize: 12.0),
                  ),
                  SizedBox(width: 2.0),
                  // prod name
                  Expanded(
                    child: AutoSizeText(
                      prod.name,
                      style: TextStyle(color: Colors.white),
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
          )
          .cast<Widget>(),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Image.network(
              widget.bundle.imageUrl,
            ),
          ),
        ),
        // Bundle Content
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: bundleContent),
        ),
      ],
    );
  }

  Widget _buildConfirmButton(BuildContext context) => Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: RaisedButton(
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 32.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(color: black6),
            ),
            color: Color(0xFF009688),
            child: Text(
              "CONFIRM",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
            onPressed: () async {
              Map<String, Map> contactInfo;
              if (widget.showContactForm) {
                widget.sendAnalyticsEvent("contact_form_shown_last");
                contactInfo = await showDialog(
                  context: context,
                  builder: (_) => PersonalInfoFormDialog(
                    title: "Tell us a little more about yourself",
                  ),
                );
                widget.sendAnalyticsEvent("contact_form_completed_last");
              }
              widget.createCustomerLead(contactInfo: contactInfo, extraInfo: {
                "customer_selection": {
                  "mPowerProducts": widget.mPowerProducts
                      .map((prod) => prod.toJson())
                      .toList(),
                  "customerProducts": widget.customerProducts
                      .map((prod) => prod.toJson())
                      .toList(),
                  "bundle": widget.bundle.toJson(),
                },
              });
              setState(() => hasConfirmed = true);
            },
          ),
        ),
      );

  Widget _buildTitle(BuildContext context, String title) => Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Text(
          title,
          style: Theme.of(context)
              .textTheme
              .headline1
              .copyWith(color: Colors.white, fontSize: 26.0),
        ),
      );
}

class ConfirmationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AutoSizeGroup group = AutoSizeGroup();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 128.0,
            ),
            AutoSizeText(
              "Thanks a lot for your time!",
              style: Theme.of(context).textTheme.headline1,
              textAlign: TextAlign.center,
              maxLines: 1,
              group: group,
            ),
            AutoSizeText(
              "An MPower employee will get in touch with you soon.",
              style: Theme.of(context).textTheme.headline1,
              textAlign: TextAlign.center,
              maxLines: 2,
              group: group,
            ),
          ],
        ),
      ),
    );
  }
}
