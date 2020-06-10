import 'package:auto_size_text/auto_size_text.dart';
import 'package:cons_calc_lib/cons_calc_lib.dart';
import 'package:flutter/material.dart';

class ReviewPage extends StatelessWidget {
  final ProductBundle bundle;
  final List<ConsumptionProduct> customerProducts;
  final List<ConsumptionProduct> mPowerProducts;

  const ReviewPage({
    Key key,
    @required this.bundle,
    @required this.customerProducts,
    @required this.mPowerProducts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF42515A),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                // Text("You search a solution for your"),
                customerProducts?.isNotEmpty ?? false
                    ? _buildTitle(context, "You search a solution for your")
                    : Container(),
                customerProducts?.isNotEmpty ?? false
                    ? _buildProductList(context, customerProducts)
                    : Container(),
                mPowerProducts?.isNotEmpty ?? false
                    ? _buildTitle(context, "And you would like a new MPower")
                    : Container(),
                mPowerProducts?.isNotEmpty ?? false
                    ? _buildProductList(context, mPowerProducts)
                    : Container(),
                _buildTitle(context, "For this you selected the"),
                _buildSelectedBundle(context),
              ],
            ),
            _buildConfirmButton(),
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
              constraints: BoxConstraints(maxWidth: 256.0),
              child: Text(
                productName,
                textWidthBasis: TextWidthBasis.longestLine,
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    .copyWith(color: Colors.white),
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
                    .copyWith(color: Colors.white, fontSize: 16.0),
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
          bundle.name,
          style: Theme.of(context).textTheme.bodyText1.copyWith(
                color: Colors.white,
                fontSize: 20.0,
              ),
        ),
      ),
    ];

    bundleContent.addAll(
      bundle.bundleProducts
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
                    child: Text(
                      prod.name,
                      style: TextStyle(color: Colors.white, fontSize: 16.0),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Image.network(
            bundle.imageUrl,
            height: 128.0,
            width: 128.0,
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

  Widget _buildConfirmButton() => Align(
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
            onPressed: () {},
            color: Color(0xFF009688),
            child: Text(
              "CONFIRM",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
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
