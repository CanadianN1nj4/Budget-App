import 'package:drift/drift.dart';
import 'package:flutter/material.dart' show Color;

// Color converter for Drift
class ColorConverter extends TypeConverter<Color, int> {
  const ColorConverter();
  @override
  Color fromSql(int fromDb) => Color(fromDb);
  @override
  int toSql(Color value) => value.toARGB32();
}
