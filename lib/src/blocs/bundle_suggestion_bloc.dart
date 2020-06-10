import 'dart:async';

import 'package:cons_calc_lib/cons_calc_lib.dart';
import 'package:cons_calc_lib/src/models/product_bundle_model.dart';

class BundleSuggestionBloc {
  final List<ConsumptionProduct> customerProducts;
  final List<ConsumptionProduct> mPowerProducts;

  // Streams
  Stream<double> get currentPage => _currentPageController.stream;
  Stream<List<ProductBundle>> get recommendedBundles =>
      _recommendedBundlesController.stream;

  // Controllers
  final _recommendedBundlesController = StreamController<List<ProductBundle>>();
  final _currentPageController = StreamController<double>.broadcast();

  BundleSuggestionBloc(
      {this.customerProducts, this.mPowerProducts, getBundleRecommendations}) {
    double totalConsumption = 0.0;

    customerProducts.forEach(
        (prod) => totalConsumption += prod.powerConsumption * prod.units);
    mPowerProducts.forEach((prod) => totalConsumption += prod.powerConsumption);

    getBundleRecommendations(totalConsumption)
        .then((bundles) => _recommendedBundlesController.add(bundles));
  }

  void setCurrentPage(double page) {
    _currentPageController.add(page);
  }

  void dispose() {
    _currentPageController.close();
    _recommendedBundlesController.close();
  }
}
