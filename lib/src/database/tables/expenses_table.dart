import 'package:drift/drift.dart';
import 'jars_table.dart'; // For referencing the Jars table

// Table for Expenses
class Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get jarId =>
      text().references(Jars, #id, onDelete: KeyAction.cascade)();
  RealColumn get amount => real()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get date => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
