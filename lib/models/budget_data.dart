import 'package:budget_app/models/jar.dart';
import 'package:budget_app/models/expense.dart';
import 'package:flutter/material.dart'; // For Color

class BudgetData {
  double totalBudget;
  List<Jar> jars;
  int resetDay;
  List<Expense> expenses;
  double totalSpent;

  BudgetData({
    required this.totalBudget,
    required this.jars,
    required this.resetDay,
    required this.expenses,
    required this.totalSpent,
  });

  factory BudgetData.fromJson(Map<String, dynamic> json) {
    return BudgetData(
      totalBudget: (json['totalBudget'] as num).toDouble(),
      jars:
          (json['jars'] as List<dynamic>)
              .map((jarJson) => Jar.fromJson(jarJson as Map<String, dynamic>))
              .toList(),
      resetDay: json['resetDay'] as int,
      expenses:
          (json['expenses'] as List<dynamic>)
              .map(
                (expJson) => Expense.fromJson(expJson as Map<String, dynamic>),
              )
              .toList(),
      totalSpent: (json['totalSpent'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'totalBudget': totalBudget,
    'jars': jars.map((jar) => jar.toJson()).toList(),
    'resetDay': resetDay,
    'expenses': expenses.map((exp) => exp.toJson()).toList(),
    'totalSpent': totalSpent,
  };
}
