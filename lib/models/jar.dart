import 'package:flutter/material.dart';

class Jar {
  String id;
  String name;
  String iconName; // Store icon name (e.g., 'ShoppingBasket')
  double budget;
  double spent;
  Color color; // Store as Flutter Color

  Jar({
    required this.id,
    required this.name,
    required this.iconName,
    required this.budget,
    this.spent = 0.0,
    required this.color,
  });

  factory Jar.fromJson(Map<String, dynamic> json) {
    return Jar(
      id: json['id'] as String,
      name: json['name'] as String,
      iconName:
          json['iconName'] as String, // Ensure this matches the key in JSON
      budget: (json['budget'] as num).toDouble(),
      spent: (json['spent'] as num? ?? 0.0).toDouble(),
      color: Color(
        int.parse((json['color'] as String).substring(1), radix: 16) +
            0xFF000000,
      ), // Assuming hex string like #RRGGBB
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'iconName': iconName,
    'budget': budget,
    'spent': spent,
    'color':
        '#${color.value.toRadixString(16).substring(2)}', // Store as hex string
  };
}
