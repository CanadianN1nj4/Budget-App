import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart' show Color; // Import Color

// Import table definitions
import 'tables/jars_table.dart';
import 'tables/expenses_table.dart';
import 'tables/app_settings_table.dart';
import 'converters/color_converter.dart'; // Import ColorConverter

part 'database.g.dart';

@DriftDatabase(tables: [Jars, Expenses, AppSettings])
class AppDatabase extends _$AppDatabase {
  @override
  int get schemaVersion => 1;

  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'budget_jars_db', // Changed name slightly
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }

  // Methods for Jars
  Future<List<Jar>> getAllJars() =>
      select(jars).get(); // Generated class is JarData
  Future<int> insertJar(JarsCompanion jar) => into(jars).insert(jar);
  Future<bool> updateJarData(JarsCompanion jar) => update(jars).replace(jar);
  Future<int> deleteJar(String id) =>
      (delete(jars)..where((tbl) => tbl.id.equals(id))).go();

  // Methods for Expenses
  Future<List<Expense>> getAllExpenses() =>
      select(expenses).get(); // Generated class is ExpenseData
  Future<int> insertExpense(ExpensesCompanion expense) =>
      into(expenses).insert(expense);
  Future<bool> updateExpenseData(ExpensesCompanion expense) =>
      update(expenses).replace(expense);
  Future<int> deleteExpense(String id) =>
      (delete(expenses)..where((tbl) => tbl.id.equals(id))).go();

  // Methods for AppSettings
  Future<String?> getSetting(String key) async {
    final AppSetting? setting =
        await (select(appSettings) // Generated class is AppSettingData
              ..where((tbl) => tbl.settingKey.equals(key)))
            .getSingleOrNull();
    return setting?.settingValue;
  }

  Future<int> setSetting(String key, String value) {
    return into(appSettings).insertOnConflictUpdate(AppSettingsCompanion(
        settingKey: Value(key), settingValue: Value(value)));
  }
}
