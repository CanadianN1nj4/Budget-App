import 'package:budget_app/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:budget_app/theme/app_colors.dart';

class BudgetSummaryWidget extends StatelessWidget {
  final double totalBudget;
  final double totalSpent;
  final int resetDay;

  const BudgetSummaryWidget({
    super.key,
    required this.totalBudget,
    required this.totalSpent,
    required this.resetDay,
  });

  Color _getProgressBarColor(double percentage) {
    if (percentage > 0.9) return AppColors.destructive;
    if (percentage > 0.7) return Colors.orange;
    return AppColors.primary;
  }

  String _getResetInfo() {
    final now = DateTime.now();
    DateTime resetDateThisMonth = DateTime(now.year, now.month, resetDay);
    DateTime nextResetDate;

    if (now.day >= resetDay) {
      nextResetDate = DateTime(now.year, now.month + 1, resetDay);
    } else {
      nextResetDate = resetDateThisMonth;
    }
    final daysUntilReset = nextResetDate.difference(now).inDays;
    return 'Resets in $daysUntilReset day${daysUntilReset != 1 ? 's' : ''} (on ${DateFormat.MMMMd().format(nextResetDate)})';
  }

  @override
  Widget build(BuildContext context) {
    final double remainingBudget = totalBudget - totalSpent;
    final double percentageSpent =
        totalBudget > 0 ? (totalSpent / totalBudget) : 0.0;

    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Budget Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(_getResetInfo(), style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Spent:'),
                Text(
                  '\$${totalSpent.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Remaining:'),
                Text(
                  '\$${remainingBudget.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: remainingBudget >= 0
                            ? Colors.green[700]
                            : AppColors.destructive,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Overall Progress: ${(percentageSpent * 100).toStringAsFixed(0)}% of \$${totalBudget.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: percentageSpent,
              backgroundColor:
                  AppColors.muted.withAlpha(withOpacitytoWithAlpha(0.3)),
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressBarColor(percentageSpent),
              ),
              minHeight: 10,
            ),
          ],
        ),
      ),
    );
  }
}
