import 'dart:math';

import 'package:cons_calc_lib/cons_calc_lib.dart';
import 'package:cons_calc_lib/src/blocs/bundle_suggestion_bloc.dart';
import 'package:cons_calc_lib/src/models/product_bundle_model.dart';
import 'package:cons_calc_lib/src/models/product_type.dart';
import 'package:cons_calc_lib/src/review_page.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class BundleSuggestionPage extends StatefulWidget {
  @override
  _BundleSuggestionPageState createState() => _BundleSuggestionPageState();
}

class _BundleSuggestionPageState extends State<BundleSuggestionPage> {
  TextTheme _textTheme;
  Size _size;
  BundleSuggestionBloc bloc;
  PageController controller;

  @override
  void didChangeDependencies() {
    bloc = Provider.of<BundleSuggestionBloc>(context);
    controller = PageController(viewportFraction: 1);
    controller.addListener(() {
      bloc.setCurrentPage(controller.page);
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _textTheme = Theme.of(context).textTheme;
    _size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        body: StreamBuilder<double>(
          initialData: 0.0,
          stream: bloc.currentPage,
          builder: (context, pageSnapshot) =>
              StreamBuilder<List<ProductBundle>>(
            stream: bloc.recommendedBundles,
            builder: (context, bundleSnapshot) =>
                (bundleSnapshot?.data?.isEmpty ?? true)
                    ? Container()
                    : Container(
                        decoration: _background(
                            bundleSnapshot.data,
                            pageSnapshot.data.toInt(),
                            controller.hasClients
                                ? controller.page - controller.page.toInt()
                                : 0),
                        child: Column(
                          children: <Widget>[
                            _title(context),
                            _images(bundleSnapshot.data, pageSnapshot.data),
                            Expanded(
                              child: PageView.builder(
                                controller: controller,
                                itemCount: bundleSnapshot.data.length,
                                itemBuilder: (_, index) => _buildBundleCard(
                                    context,
                                    index,
                                    pageSnapshot.data,
                                    bundleSnapshot.data[index]),
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
        ),
      ),
    );
  }

  Widget _buildBundleCard(BuildContext context, int index, double currentPage,
      ProductBundle productBundle) {
    List<dynamic> panels = [], batteries = [];

    productBundle.bundleProducts.forEach((prod) =>
        prod.type == ProductType.BATTERY
            ? batteries.add(prod)
            : prod.type == ProductType.PANEL ? panels.add(prod) : null);

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(40.0, 16.0, 40.0, 32.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              _getShadow(index, currentPage),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bundle Name
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
                child: Text(
                  productBundle.name,
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              // Bundle content
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.grey.withAlpha(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // BATTERIES
                    Row(
                      children: [
                        Icon(
                          Icons.battery_full,
                          size: 14,
                          color: Colors.black26,
                        ),
                        Container(
                          width: 8,
                        ),
                        Text(
                          'BATTERIES',
                          style: _textTheme.overline.copyWith(
                            color: Colors.black38,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: batteries
                            .map(
                              (battery) => Text(
                                battery.name,
                                style: _textTheme.subtitle2,
                              ),
                            )
                            .cast<Widget>()
                            .toList(),
                      ),
                    ),
                    SizedBox(height: 8.0),
                    // PANELS
                    Row(
                      children: [
                        Icon(
                          Icons.grid_on,
                          size: 14,
                          color: Colors.black26,
                        ),
                        Container(
                          width: 8,
                        ),
                        Text(
                          'PANELS',
                          style: _textTheme.overline.copyWith(
                            color: Colors.black38,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: panels
                            .map(
                              (panel) => Text(
                                panel.name,
                                style: _textTheme.subtitle2,
                              ),
                            )
                            .cast<Widget>()
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Recommendation chip
                    Container(
                      decoration: ShapeDecoration(
                        shape: StadiumBorder(),
                        color: Colors.green.shade100,
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'RECOMMENDED',
                            style: _textTheme.caption.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4.0),
                          Icon(
                            MdiIcons.check,
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: Container()),
                    // Price
                    Text(
                      productBundle.price.toString(),
                      style: Theme.of(context).textTheme.headline4.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.black38,
                          ),
                    ),
                    Text(
                      '€',
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(color: Colors.black26),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        // Select button
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: RaisedButton(
            color: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 40.0, vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
              side: BorderSide(color: black6),
            ),
            child: Text(
              "Select",
              style:
                  Theme.of(context).textTheme.button.copyWith(fontSize: 18.0),
            ),
            onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ReviewPage(
                    bundle: productBundle,
                    customerProducts: bloc.customerProducts,
                    mPowerProducts: bloc.mPowerProducts,
                  ),
                )),
          ),
        ),
      ],
    );
  }

  BoxDecoration _background(
          List<ProductBundle> bundles, int currentIndex, double percentage) =>
      BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            currentIndex + 1 < bundles.length
                ? Color.lerp(bundles[currentIndex].backgroundBottomColor,
                    bundles[currentIndex + 1].backgroundBottomColor, percentage)
                : bundles.last.backgroundBottomColor,
            currentIndex + 1 < bundles.length
                ? Color.lerp(bundles[currentIndex].backgroundTopColor,
                    bundles[currentIndex + 1].backgroundTopColor, percentage)
                : bundles.last.backgroundTopColor,
          ],
        ),
      );

  Widget _title(BuildContext context) => Container(
        padding: const EdgeInsets.all(16.0),
        width: MediaQuery.of(context).size.width,
        child: Text(
          'We recommend these bundles for you',
          style: Theme.of(context).textTheme.headline1.copyWith(fontSize: 32.0),
        ),
      );

  Widget _images(List<ProductBundle> bundles, double currentPage) {
    var delta = currentPage.truncate() - currentPage;
    var opacity = 1 - max(-2 * delta, 0.0);
    var opacityInv = (opacity - 1).abs();

    return Container(
      width: _size.width,
      height: _size.height * .3,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: opacity < 0 ? 0 : opacity > 1 ? 1 : opacity,
            child: Image.network(bundles[currentPage.truncate()].imageUrl),
          ),
          currentPage.truncate() + 1 <= bundles.length - 1
              ? Opacity(
                  opacity: opacityInv < 0 ? 0 : opacityInv > 1 ? 1 : opacityInv,
                  child: Image.network(
                      bundles[currentPage.truncate() + 1].imageUrl),
                )
              : Container(),
        ],
      ),
    );
  }

  BoxShadow _getShadow(int index, double currentPage) {
    var delta = currentPage.truncate() - currentPage;
    var blurRadius = 15 - max(-15 * delta, 7.0);
    var spreadRadius = 10 - max(-10 * delta, 5.0);

    return BoxShadow(
      color: Colors.black12,
      spreadRadius: spreadRadius < 5 ? 5 : spreadRadius,
      blurRadius: blurRadius < 7 ? 7 : blurRadius,
      offset: Offset(0, 3),
    );
  }
}

// // Category
// Padding(
//   padding: EdgeInsets.symmetric(horizontal: 16),
//   child: Row(
//     children: [
//       Container(
//         decoration: ShapeDecoration(
//           shape: StadiumBorder(),
//           color: Colors.black.withAlpha(20),
//         ),
//         padding:
//             EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               'Min',
//               style: _textTheme.caption
//                   .copyWith(color: Colors.black12),
//             ),
//             Container(
//               width: 8,
//             ),
//             Text(
//               productBundle.minConsumption.toStringAsFixed(0),
//               style:
//                   _textTheme.subtitle2.copyWith(fontSize: 16),
//             ),
//             Container(
//               margin: EdgeInsetsDirectional.only(
//                   bottom: 8, start: 4),
//               height: 6,
//               width: 6,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.green,
//               ),
//             ),
//             Text(
//               ' W',
//               style:
//                   _textTheme.subtitle2.copyWith(fontSize: 16),
//             ),
//           ],
//         ),
//       ),
//       Expanded(
//         child: Container(),
//       ),
//       Container(
//         decoration: ShapeDecoration(
//           shape: StadiumBorder(),
//           color: Colors.black.withAlpha(20),
//         ),
//         padding:
//             EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               'Max',
//               style: _textTheme.caption
//                   .copyWith(color: Colors.black12),
//             ),
//             Container(
//               width: 8,
//             ),
//             Text(
//               productBundle.maxConsumption.toStringAsFixed(0),
//               style:
//                   _textTheme.subtitle2.copyWith(fontSize: 16),
//             ),
//             Container(
//               margin: EdgeInsetsDirectional.only(
//                   bottom: 8, start: 4),
//               height: 6,
//               width: 6,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.red,
//               ),
//             ),
//             Text(
//               ' W',
//               style:
//                   _textTheme.subtitle2.copyWith(fontSize: 16),
//             ),
//           ],
//         ),
//       ),
//     ],
//   ),
// ),

// final bundleSnapshot.data = [
//   ProductBundle(
//     id: 'asd',
//     name: 'Bundle 1',
//     price: 1225,
//     imageUrl: 'assets/panel.png',
//     maxConsumption: 1500,
//     minConsumption: 200,
//     bundleProducts: [
//       Product(
//         name: 'Suner Power',
//         type: ProductType.PANEL,
//       ),
//       Product(
//         name: 'Powery Battery',
//         type: ProductType.BATTERY,
//       ),
//       Product(
//         name: 'Light Bulbs',
//         type: ProductType.LOAD,
//       ),
//     ],
//     backgroundTopColor: Color(0xFF006494),
//     backgroundBottomColor: Color(0xFF003554),
//   ),
// ];

// class ProductBundle {
//   final String id;
//   final String name;
//   final double price;
//   final String imageUrl;
//   final double maxConsumption;
//   final double minConsumption;
//   final List<Product> bundleProducts;
//   final Color backgroundTopColor, backgroundBottomColor;

//   ProductBundle({
//     this.id,
//     this.name,
//     this.price,
//     this.imageUrl,
//     this.maxConsumption,
//     this.minConsumption,
//     this.bundleProducts,
//     this.backgroundTopColor,
//     this.backgroundBottomColor,
//   });
// }
