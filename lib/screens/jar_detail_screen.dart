import 'package:budget_app/models/expense.dart';
import 'package:budget_app/models/jar.dart';
import 'package:budget_app/services/budget_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class JarDetailScreen extends StatelessWidget {
  final Jar jar;

  const JarDetailScreen({super.key, required this.jar});

  @override
  Widget build(BuildContext context) {
    final BudgetService budgetService = Provider.of<BudgetService>(context);
    final List<Expense> expensesForJar = budgetService.budgetData?.expenses
            .where((exp) => exp.jarId == jar.id)
            .toList() ??
        [];
    expensesForJar.sort((a, b) => b.date.compareTo(a.date)); // Newest first

    return Scaffold(
      appBar: AppBar(title: Text('${jar.name} Details')),
      body: ListView.builder(
        itemCount: expensesForJar.length,
        itemBuilder: (context, index) {
          final expense = expensesForJar[index];
          return ListTile(
            title: Text(expense.description ?? 'Expense'),
            subtitle: Text(DateFormat.yMMMd().format(expense.date)),
            trailing: Text(
              '-\$${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        },
      ),
    );
  }
}
