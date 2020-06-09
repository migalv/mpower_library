import 'dart:ui';

import 'package:cons_calc_lib/cons_calc_lib.dart';

class ProductBundle {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final double maxConsumption;
  final double minConsumption;
  final List<dynamic> bundleProducts;
  final Color backgroundBottomColor;
  final Color backgroundTopColor;

  ProductBundle({
    this.id,
    this.name,
    this.price,
    this.imageUrl,
    this.maxConsumption,
    this.minConsumption,
    this.bundleProducts,
    this.backgroundBottomColor,
    this.backgroundTopColor,
  });

  ProductBundle.fromJson(String id, Map<String, dynamic> json,
      {this.bundleProducts})
      : this.id = id,
        this.name = json[NAME],
        this.price = json[PRICE]?.toDouble() ?? 0.0,
        this.imageUrl = json[IMAGE_URL],
        this.maxConsumption = json[MAX_CONSUMPTION]?.toDouble() ?? 0.0,
        this.minConsumption = json[MIN_CONSUMPTION]?.toDouble() ?? 0.0,
        this.backgroundBottomColor = Color(
            int.parse(json[BG_BOTTOM_COLOR], radix: 16) ?? secondaryMain.value),
        this.backgroundTopColor = Color(
            int.parse(json[BG_TOP_COLOR], radix: 16) ?? secondaryMain.value);

  static const String NAME = "bundle_name";
  static const String PRICE = "bundle_price";
  static const String IMAGE_URL = "image_url";
  static const String PRODUCTS = "bundle_products";
  static const String MAX_CONSUMPTION = "max_consumption";
  static const String MIN_CONSUMPTION = "min_consumption";
  static const String BG_BOTTOM_COLOR = "bg_bottom_color";
  static const String BG_TOP_COLOR = "bg_top_color";
}
