import 'package:drift/drift.dart';

// Table for App Settings (like resetDay)
class AppSettings extends Table {
  TextColumn get settingKey => text()(); // e.g., "resetDay"
  TextColumn get settingValue =>
      text()(); // Store value as string, parse as needed

  @override
  Set<Column> get primaryKey => {settingKey};
}
