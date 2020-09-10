import 'package:flutter/material.dart';

class Product {
  Product({
    this.id,
    this.name,
    this.updatedAt,
    this.availableTo,
    this.createdAt,
    this.description,
    this.isLocal,
    this.isOutOfDate,
    this.sku,
    this.stockUnitsByTeam,
    this.type,
    this.imageURL,
    this.extraInfo,
  });

  bool isLocal, isOutOfDate;
  int createdAt, updatedAt;
  double get consumption => extraInfo[CONSUMPTION]?.toDouble() ?? 1;
  double get production => extraInfo[PRODUCTION]?.toDouble() ?? 1;
  double get capacity => extraInfo[CAPACITY]?.toDouble() ?? 1;
  double get powerPeak => extraInfo[POWER_PEAK]?.toDouble() ?? 1;
  int get defaultUsage => extraInfo[DEFAULT_USAGE] ?? 4;
  Map availableTo, stockUnitsByTeam;

  /// Extra information about the product
  Map<String, dynamic> extraInfo;
  String id,
      name,
      sku,
      type,
      description,
      createdBy,
      createdByName,
      lastUpdatedBy,
      lastUpdatedByName,
      manufacturerId;
  String imageURL;

  Product.fromJson(String id, final Map<String, dynamic> json) {
    this.id = id;
    this.availableTo = json["availableTo"] != null
        ? Map.fromEntries(json["availableTo"].entries)
        : null;
    this.createdAt = json["created_at"];
    this.createdBy = json["created_by"];
    this.createdByName = json["created_by_name"];
    this.description = json["description"];
    this.imageURL = json["imageURL"] ?? "";
    this.lastUpdatedBy = json["last_updated_by"];
    this.lastUpdatedByName = json["last_updated_by_name"];
    this.name = json["name"];
    this.sku = json["sku"];
    this.stockUnitsByTeam = json["stock_units_by_team"] != null
        ? Map.fromEntries(json["stock_units_by_team"].entries)
        : null;
    this.type = json["type"];
    this.updatedAt = json["updated_at"];
    this.extraInfo = json[EXTRA_INFO] != null
        ? Map<String, dynamic>.from(json[EXTRA_INFO])
        : {};
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'availableTo': availableTo,
        'created_at': createdAt,
        'description': description,
        'name': name,
        'sku': sku,
        'stock_units_by_team': stockUnitsByTeam,
        'type': type,
        'updated_at': updatedAt,
      };

  @override
  bool operator ==(product) => product is Product && product.id == id;

  @override
  int get hashCode => id.hashCode;

  static const String POWER_DETAILS = "power_details";
  static const String EXTRA_INFO = "extra_info";
  static const String POWER_PEAK = "power_peak";
  static const String DEFAULT_USAGE = "default_usage";
  static const String CONSUMPTION = "consumption";
  static const String CAPACITY = "capacity";
  static const String PRODUCTION = "production";
}

class Panel {
  double production, percentage;
  final String id, imageUrl, name;

  Panel({
    @required this.id,
    this.name,
    this.production,
    this.imageUrl,
    this.percentage,
  });

  @override
  bool operator ==(panel) => panel is Panel && panel.id == id;

  @override
  int get hashCode => id.hashCode;
}

class Battery {
  double capacity, percentage;
  final String id, imageUrl, name;

  Battery({
    @required this.id,
    this.capacity,
    this.name,
    this.imageUrl,
    this.percentage,
  });

  @override
  bool operator ==(battery) => battery is Battery && battery.id == id;

  @override
  int get hashCode => id.hashCode;
}

class ProductType {
  static const BATTERY = "0";
  static const PANEL = "1";
  static const LOAD = "2";
  static const MPOWER_USE = "3";
}
