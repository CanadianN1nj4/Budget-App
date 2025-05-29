import 'package:budget_app/utils/helpers.dart';
import 'package:budget_app/utils/icons.dart';
import 'package:flutter/material.dart';
import 'package:budget_app/models/jar.dart';
import 'package:budget_app/theme/app_colors.dart'; // For progress bar colors

class JarCard extends StatelessWidget {
  final Jar jar;
  final VoidCallback? onTap;

  const JarCard({super.key, required this.jar, this.onTap});

  Color _getProgressColor(double percentage) {
    if (percentage > 0.9) return AppColors.destructive;
    if (percentage > 0.7) return Colors.orange; // Using a standard orange
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final double percentageSpent =
        jar.budget > 0 ? (jar.spent / jar.budget) : 0.0;
    final double remaining = jar.budget - jar.spent;

    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: jar.color,
          width: 3,
        ), // Using jar.color for border
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    jar.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Icon(
                    getLucideIcon(jar.iconName),
                    size: 20,
                    color: Theme.of(
                      context,
                    )
                        .colorScheme
                        .onSurface
                        .withAlpha(withOpacitytoWithAlpha(0.7)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$${remaining.toStringAsFixed(2)} left',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentageSpent,
                    backgroundColor:
                        AppColors.muted.withAlpha(withOpacitytoWithAlpha(0.3)),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(percentageSpent),
                    ),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Spent \$${jar.spent.toStringAsFixed(2)} of \$${jar.budget.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
