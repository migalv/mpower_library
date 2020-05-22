import 'package:flutter/widgets.dart';

class ConsumptionProduct {
  double day, night, powerConsumption;
  final id;
  String name;
  List<ConsumptionSubProduct> subProducts;
  final String imageUrl;
  final IconData icon;
  bool expanded;

  ConsumptionProduct({
    this.day = 0,
    this.night = 0,
    this.name,
    this.subProducts,
    this.id,
    this.expanded = false,
    this.powerConsumption,
    this.imageUrl,
    this.icon,
  });
}

class ConsumptionSubProduct {
  double day, night, powerConsumption;
  final id;
  String name;

  ConsumptionSubProduct({
    this.day = 0,
    this.night = 0,
    @required this.name,
    @required this.id,
    this.powerConsumption,
  });
}
