import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:budget_app/models/budget_data.dart';
import 'package:budget_app/models/jar.dart';
import 'package:budget_app/models/expense.dart';
import 'package:budget_app/theme/app_colors.dart'; // For default colors

const String _storageKey = 'jarBudgetData';
const _uuid = Uuid();

class BudgetService extends ChangeNotifier {
  BudgetData? _budgetData;

  BudgetData? get budgetData => _budgetData;

  // Default data structure, similar to your JS version
  BudgetData get _defaultBudgetData {
    final defaultJars = [
      Jar(
        id: 'groceries',
        name: 'Groceries',
        iconName: 'ShoppingBasket',
        budget: 500,
        spent: 0,
        color: AppColors.chart1,
      ),
      Jar(
        id: 'utilities',
        name: 'Utilities',
        iconName: 'Zap',
        budget: 200,
        spent: 0,
        color: AppColors.chart2,
      ),
      Jar(
        id: 'rent',
        name: 'Rent/Mortgage',
        iconName: 'Home',
        budget: 1500,
        spent: 0,
        color: AppColors.chart3,
      ),
      Jar(
        id: 'transport',
        name: 'Transport',
        iconName: 'Car',
        budget: 300,
        spent: 0,
        color: AppColors.chart4,
      ),
      Jar(
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
    final prefs = await SharedPreferences.getInstance();
    final String? dataString = prefs.getString(_storageKey);

    if (dataString != null) {
      try {
        final Map<String, dynamic> jsonData =
            jsonDecode(dataString) as Map<String, dynamic>;
        _budgetData = BudgetData.fromJson(jsonData);
      } catch (e) {
        debugPrint("Error decoding budget data: $e. Loading defaults.");
        _budgetData = _defaultBudgetData;
      }
    } else {
      _budgetData = _defaultBudgetData;
    }
    _recalculateTotals(); // Always ensure totals are correct after loading
    notifyListeners();
  }

  Future<void> saveBudgetData() async {
    if (_budgetData == null) return;
    _recalculateTotals(); // Ensure totals are up-to-date before saving

    final prefs = await SharedPreferences.getInstance();
    final String dataString = jsonEncode(_budgetData!.toJson());
    await prefs.setString(_storageKey, dataString);
    notifyListeners();
  }

  void _recalculateTotals() {
    if (_budgetData == null) return;

    // Recalculate totalBudget from jars
    _budgetData!.totalBudget = _budgetData!.jars.fold(
      0,
      (sum, jar) => sum + jar.budget,
    );

    // Reset spent amounts for each jar
    for (var jar in _budgetData!.jars) {
      jar.spent = 0;
    }

    // Recalculate spent for each jar based on expenses
    for (var expense in _budgetData!.expenses) {
      final jar = _budgetData!.jars.firstWhere(
        (j) => j.id == expense.jarId,
        orElse: () => Jar(
          id: 'unknown',
          name: 'Unknown',
          iconName: 'HelpCircle',
          budget: 0,
          color: Colors.grey,
        ),
      );
      jar.spent += expense.amount;
    }

    // Recalculate totalSpent
    _budgetData!.totalSpent = _budgetData!.jars.fold(
      0,
      (sum, jar) => sum + jar.spent,
    );
  }

  Future<void> addExpense({
    required String jarId,
    required double amount,
    String? description,
  }) async {
    if (_budgetData == null) await loadBudgetData(); // Ensure data is loaded
    if (_budgetData == null)
      return; // Should not happen if loadBudgetData works

    final newExpense = Expense(
      id: _uuid.v4(),
      jarId: jarId,
      amount: amount,
      description: description,
      date: DateTime.now(),
    );

    _budgetData!.expenses.add(newExpense);
    await saveBudgetData(); // This will also recalculate totals and notify listeners
  }

  Future<void> deleteExpense(String expenseId) async {
    if (_budgetData == null) return;

    _budgetData!.expenses.removeWhere((expense) => expense.id == expenseId);
    await saveBudgetData(); // Recalculates totals and notifies
  }

  Future<void> updateExpense(Expense updatedExpense) async {
    if (_budgetData == null) return;

    final index = _budgetData!.expenses
        .indexWhere((expense) => expense.id == updatedExpense.id);
    if (index != -1) {
      _budgetData!.expenses[index] = updatedExpense;
      await saveBudgetData(); // Recalculates totals and notifies
    } else {
      // Optionally handle case where expense to update is not found
      debugPrint("Expense with ID ${updatedExpense.id} not found for update.");
    }
  }

  Future<void> updateJar(Jar updatedJar) async {
    if (_budgetData == null) return;
    final index = _budgetData!.jars.indexWhere(
      (jar) => jar.id == updatedJar.id,
    );
    if (index != -1) {
      _budgetData!.jars[index] = updatedJar;
      await saveBudgetData();
    }
  }

  Future<void> addJar(Jar newJar) async {
    if (_budgetData == null) return;
    _budgetData!.jars.add(newJar);
    await saveBudgetData();
  }

  Future<void> removeJar(String jarId) async {
    if (_budgetData == null) return;
    _budgetData!.jars.removeWhere((jar) => jar.id == jarId);
    // Also remove expenses associated with this jar
    _budgetData!.expenses.removeWhere((expense) => expense.jarId == jarId);
    await saveBudgetData();
  }

  Future<void> updateResetDay(int day) async {
    if (_budgetData == null) return;
    _budgetData!.resetDay = day;
    await saveBudgetData();
  }
}
