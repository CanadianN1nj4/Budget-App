import 'package:drift/drift.dart';
import 'package:flutter/material.dart'
    show Color; // Only needed for the Color type hint
import '../converters/color_converter.dart';

// Table for Jars
class Jars extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get iconName => text()();
  RealColumn get budget => real()();
  IntColumn get colorValue => integer()
      .map(const ColorConverter())(); // Store Color as int via converter
  RealColumn get spent => real().withDefault(const Constant(0.0))();

  @override
  Set<Column> get primaryKey => {id};
}
