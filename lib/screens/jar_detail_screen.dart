import 'package:budget_app/models/expense.dart';
import 'package:budget_app/models/jar.dart';
import 'package:budget_app/services/budget_service.dart';
import 'package:budget_app/screens/edit_expense_screen.dart'; // Import the new screen
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class JarDetailScreen extends StatelessWidget {
  final Jar jar;

  const JarDetailScreen({super.key, required this.jar});

  @override
  Widget build(BuildContext context) {
    final BudgetService budgetService = Provider.of<BudgetService>(context);
    final allJars = budgetService.budgetData?.jars ?? [];
    final List<Expense> expensesForJar = budgetService.budgetData?.expenses
            .where((exp) => exp.jarId == jar.id)
            .toList() ??
        [];
    expensesForJar.sort((a, b) => b.date.compareTo(a.date)); // Newest first

    void showDeleteConfirmationDialog(BuildContext context, Expense expense) {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Delete Expense?'),
            content: Text(
                'Are you sure you want to delete "${expense.description ?? 'this expense'}"? This action cannot be undone.'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              TextButton(
                child:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  Provider.of<BudgetService>(context, listen: false)
                      .deleteExpense(expense.id);
                  Navigator.of(dialogContext).pop();
                },
              ),
            ],
          );
        },
      );
    }

    expensesForJar.sort((a, b) => b.date.compareTo(a.date)); // Newest first

    return Scaffold(
      appBar: AppBar(title: Text('${jar.name} Details')),
      body: ListView.builder(
        itemCount: expensesForJar.length,
        itemBuilder: (context, index) {
          final expense = expensesForJar[index];
          return Card(
            // Wrap ListTile in a Card for better visual separation if desired
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              title: Text(expense.description ?? 'Expense',
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              subtitle:
                  Text(DateFormat.yMMMd().format(expense.date)), // Added time
              leading: CircleAvatar(
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withAlpha(25),
                child: Text(
                  '-\$${expense.amount.toStringAsFixed(0)}', // Show amount without decimals for brevity
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueGrey),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => EditExpenseScreen(
                                    expense: expense, jars: allJars)));
                      }),
                  IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () =>
                          showDeleteConfirmationDialog(context, expense)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
