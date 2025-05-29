import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:budget_app/models/budget_data.dart';
import 'package:budget_app/models/jar.dart' as model_jar;
import 'package:budget_app/models/expense.dart' as model_expense;
import 'package:budget_app/theme/app_colors.dart';
import 'package:budget_app/src/database/database.dart'; // Import AppDatabase
import 'package:drift/drift.dart'
    show Value; // Import Value for Compmodel_jar.Jaranions

const _uuid = Uuid();
const String _resetDayKey = 'resetDay';

class BudgetService extends ChangeNotifier {
  final AppDatabase _db;
  BudgetData? _budgetData;

  BudgetData? get budgetData => _budgetData;

  BudgetService(this._db);

  // Default data structure, similar to your JS version
  BudgetData get _defaultBudgetData {
    final defaultJars = [
      model_jar.Jar(
        id: 'groceries',
        name: 'Groceries',
        iconName: 'ShoppingBasket',
        budget: 500,
        spent: 0,
        color: AppColors.chart1,
      ),
      model_jar.Jar(
        id: 'utilities',
        name: 'Utilities',
        iconName: 'Zap',
        budget: 200,
        spent: 0,
        color: AppColors.chart2,
      ),
      model_jar.Jar(
        id: 'rent',
        name: 'Rent/Mortgage',
        iconName: 'Home',
        budget: 1500,
        spent: 0,
        color: AppColors.chart3,
      ),
      model_jar.Jar(
        id: 'transport',
        name: 'Transport',
        iconName: 'Car',
        budget: 300,
        spent: 0,
        color: AppColors.chart4,
      ),
      model_jar.Jar(
        id: 'fun',
        name: 'Entertainment',
        iconName: 'Film',
        budget: 500,
        spent: 0,
        color: AppColors.chart5,
      ),
    ];
    double totalBudget = defaultJars.fold(0, (sum, jar) => sum + jar.budget);

    return BudgetData(
      totalBudget: totalBudget,
      jars: defaultJars,
      resetDay: 1,
      expenses: [],
      totalSpent: 0,
    );
  }

  Future<void> loadBudgetData() async {
    final dbJars = await _db.getAllJars();
    final dbExpenses = await _db.getAllExpenses();
    final resetDayString = await _db.getSetting(_resetDayKey);

    if (dbJars.isEmpty) {
      // Assuming if jars are empty, it's a fresh setup
      _budgetData = _defaultBudgetData;
      // Save defaults to DB
      for (final jar in _budgetData!.jars) {
        await _db.insertJar(JarsCompanion(
          id: Value(jar.id),
          name: Value(jar.name),
          iconName: Value(jar.iconName),
          budget: Value(jar.budget),
          colorValue: Value(jar.color), // Pass Color object directly
          spent: Value(jar.spent),
        ));
      }
      await _db.setSetting(_resetDayKey, _budgetData!.resetDay.toString());
    } else {
      final List<model_jar.Jar> jars = dbJars
          .map((dbJar) => model_jar.Jar(
                id: dbJar.id,
                name: dbJar.name,
                iconName: dbJar.iconName,
                budget: dbJar.budget,
                spent: dbJar.spent,
                color: dbJar
                    .colorValue, // This is already a Color object due to TypeConverter
              ))
          .toList();

      final List<model_expense.Expense> expenses = dbExpenses
          .map((dbExpense) => model_expense.Expense(
                id: dbExpense.id,
                jarId: dbExpense.jarId,
                amount: dbExpense.amount,
                description: dbExpense.description,
                date: dbExpense.date,
              ))
          .toList();

      _budgetData = BudgetData(
        totalBudget: 0, // Will be recalculated
        jars: jars,
        resetDay:
            resetDayString != null ? int.tryParse(resetDayString) ?? 1 : 1,
        expenses: expenses,
        totalSpent: 0, // Will be recalculated
      );
    }
    _recalculateTotals();
    notifyListeners();
  }

  void _recalculateTotals() {
    if (_budgetData == null) return;

    // Recalculate totalBudget from jars
    _budgetData!.totalBudget =
        _budgetData!.jars.fold(0, (sum, jar) => sum + jar.budget);

    // Reset spent amounts for each jar
    for (var jar in _budgetData!.jars) {
      jar.spent = 0;
    }
    // Recalculate spent for each jar based on expenses
    for (var expense in _budgetData!.expenses) {
      final jar = _budgetData!.jars.firstWhere(
        (j) => j.id == expense.jarId,
        orElse: () => model_jar.Jar(
          // Use alias
          id: 'unknown',
          name: 'Unknown',
          iconName: 'HelpCircle',
          budget: 0,
          color: Colors.grey,
          spent: 0,
        ),
      );
      jar.spent += expense.amount;
    }

    // Recalculate totalSpent
    _budgetData!.totalSpent = _budgetData!.jars.fold(
      0,
      (sum, jar) => sum + jar.spent,
    );

    // Persist updated spent amounts for jars to the database
    if (_budgetData != null) {
      for (final jarModel in _budgetData!.jars) {
        if (jarModel.id != 'unknown') {
          // Don't try to save the temporary 'unknown' jar
          _db.updateJarData(JarsCompanion(
            id: Value(jarModel.id),
            name: Value(
                jarModel.name), // Provide all fields for replace operation
            iconName: Value(jarModel.iconName),
            budget: Value(jarModel.budget),
            colorValue: Value(jarModel.color),
            spent: Value(jarModel.spent),
          ));
        }
      }
    }
  }

  Future<void> addExpense({
    required String jarId,
    required double amount,
    String? description,
  }) async {
    if (_budgetData == null) await loadBudgetData(); // Ensure data is loaded
    if (_budgetData == null) {
      return; // Should not happen if loadBudgetData works
    }

    final newExpense = model_expense.Expense(
      id: _uuid.v4(),
      jarId: jarId,
      amount: amount,
      description: description,
      date: DateTime.now(),
    );

    await _db.insertExpense(ExpensesCompanion(
      id: Value(newExpense.id),
      jarId: Value(newExpense.jarId),
      amount: Value(newExpense.amount),
      description: Value(newExpense.description),
      date: Value(newExpense.date),
    ));

    _budgetData!.expenses.add(newExpense);
    _recalculateTotals(); // Recalculates totals and persists jar spent amounts
    notifyListeners();
  }

  Future<void> deleteExpense(String expenseId) async {
    if (_budgetData == null) return;

    await _db.deleteExpense(expenseId);
    _budgetData!.expenses.removeWhere((expense) => expense.id == expenseId);
    _recalculateTotals();
    notifyListeners();
  }

  Future<void> updateExpense(model_expense.Expense updatedExpense) async {
    if (_budgetData == null) return;

    final index = _budgetData!.expenses
        .indexWhere((expense) => expense.id == updatedExpense.id);
    if (index != -1) {
      await _db.updateExpenseData(ExpensesCompanion(
        id: Value(updatedExpense.id),
        jarId: Value(updatedExpense.jarId),
        amount: Value(updatedExpense.amount),
        description: Value(updatedExpense.description),
        date: Value(updatedExpense.date),
      ));
      _budgetData!.expenses[index] = updatedExpense;
      _recalculateTotals();
      notifyListeners();
    } else {
      debugPrint("Expense with ID ${updatedExpense.id} not found for update.");
    }
  }

  Future<void> updateJar(model_jar.Jar updatedJar) async {
    if (_budgetData == null) return;
    final index = _budgetData!.jars.indexWhere(
      (jar) => jar.id == updatedJar.id,
    );
    if (index != -1) {
      await _db.updateJarData(JarsCompanion(
        id: Value(updatedJar.id),
        name: Value(updatedJar.name),
        iconName: Value(updatedJar.iconName),
        budget: Value(updatedJar.budget),
        colorValue: Value(updatedJar.color),
        spent: Value(updatedJar
            .spent), // Keep existing spent, _recalculateTotals will adjust if needed
      ));
      _budgetData!.jars[index] = updatedJar;
      _recalculateTotals();
      notifyListeners();
    }
  }

  Future<void> addJar(model_jar.Jar newJar) async {
    if (_budgetData == null) await loadBudgetData(); // Ensure data is loaded
    if (_budgetData == null) return;

    await _db.insertJar(JarsCompanion(
      id: Value(newJar.id),
      name: Value(newJar.name),
      iconName: Value(newJar.iconName),
      budget: Value(newJar.budget),
      colorValue: Value(newJar.color),
      spent: Value(newJar.spent), // Should be 0 for a new jar
    ));
    _budgetData!.jars.add(newJar);
    _recalculateTotals();
    notifyListeners();
  }

  Future<void> removeJar(String jarId) async {
    if (_budgetData == null) return;
    // ON DELETE CASCADE in DB schema will handle deleting associated expenses from DB
    await _db.deleteJar(jarId);
    _budgetData!.jars.removeWhere((jar) => jar.id == jarId);
    _budgetData!.expenses.removeWhere((expense) => expense.jarId == jarId);
    _recalculateTotals();
    notifyListeners();
  }

  Future<void> updateResetDay(int day) async {
    if (_budgetData == null) await loadBudgetData(); // Ensure data is loaded
    if (_budgetData == null) return;

    await _db.setSetting(_resetDayKey, day.toString());
    _budgetData!.resetDay = day;
    notifyListeners(); // Recalculate not strictly needed unless reset day affects totals directly
  }
}
