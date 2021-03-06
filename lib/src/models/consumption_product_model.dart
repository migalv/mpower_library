import 'package:flutter/widgets.dart';

class ConsumptionProduct {
  double day, night, powerConsumption;
  final id;
  String name;
  List<ConsumptionSubProduct> subProducts;
  final String imageUrl;
  final IconData icon;
  bool expanded;
  int get units => subProducts?.length ?? 1;
  final int defaultUsage;

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
    this.defaultUsage = 1,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "power_consumption": powerConsumption,
        "units": units,
        "default_usage": defaultUsage,
      };
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
