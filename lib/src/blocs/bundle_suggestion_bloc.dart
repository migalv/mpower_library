import 'dart:async';

import 'package:cons_calc_lib/src/models/product_bundle_model.dart';

class BundleSuggestionBloc {
  // Streams
  Stream<double> get currentPage => _currentPageController.stream;
  Stream<List<ProductBundle>> get recommendedBundles =>
      _recommendedBundlesController.stream;

  // Controllers
  final _recommendedBundlesController = StreamController<List<ProductBundle>>();
  final _currentPageController = StreamController<double>.broadcast();

  BundleSuggestionBloc({consumption, getBundleRecommendations}) {
    getBundleRecommendations(consumption)
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
