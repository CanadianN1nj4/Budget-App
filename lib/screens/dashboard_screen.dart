import 'package:budget_app/screens/jar_detail_screen.dart';
import 'package:budget_app/screens/settings_screen.dart';
import 'package:budget_app/widgets/add_expense_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budget_app/services/budget_service.dart';
import 'package:budget_app/widgets/budget_summary_widget.dart';
import 'package:budget_app/widgets/jar_card.dart';
import 'package:budget_app/models/jar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Budget Jars'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<BudgetService>(
        builder: (context, budgetService, child) {
          if (budgetService.budgetData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = budgetService.budgetData!;

          return RefreshIndicator(
            onRefresh: () => budgetService.loadBudgetData(),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                BudgetSummaryWidget(
                  totalBudget: data.totalBudget,
                  totalSpent: data.totalSpent,
                  resetDay: data.resetDay,
                ),
                const SizedBox(height: 24),
                Text('Jars', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                if (data.jars.isEmpty)
                  const Center(
                    child: Text(
                      'No jars configured yet. Go to Settings to add some!',
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(), // To disable GridView's own scrolling
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          MediaQuery.of(context).size.width > 600 ? 3 : 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2, // Adjust as needed
                    ),
                    itemCount: data.jars.length,
                    itemBuilder: (context, index) {
                      final jar = data.jars[index];
                      return JarCard(
                        jar: jar,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JarDetailScreen(jar: jar),
                            ),
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final budgetService = Provider.of<BudgetService>(
            context,
            listen: false,
          );
          if (budgetService.budgetData != null &&
              budgetService.budgetData!.jars.isNotEmpty) {
            showDialog(
              context: context,
              builder:
                  (BuildContext dialogContext) =>
                      AddExpenseDialog(jars: budgetService.budgetData!.jars),
            );
          }
        },
        label: const Text('Add Expense'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
