import 'package:budget_app/src/database/database.dart' show AppDatabase;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budget_app/screens/dashboard_screen.dart';
import 'package:budget_app/services/budget_service.dart';
import 'package:budget_app/theme/app_colors.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  final AppDatabase db = AppDatabase();

  // Create an instance of BudgetService and load data
  final budgetService = BudgetService(db);
  await budgetService.loadBudgetData(); // Load data initially

  runApp(
    ChangeNotifierProvider(
      create: (context) => budgetService,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JarBudget',
      theme: ThemeData(
        primarySwatch: AppColors.primarySwatch,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: AppColors.primarySwatch,
          accentColor: AppColors.accent,
          backgroundColor: AppColors.background,
          cardColor: AppColors.card,
          errorColor: AppColors.destructive,
        ).copyWith(
          onPrimary: AppColors.primaryForeground, // Text on primary color
        ),
        fontFamily: 'Arial', // Matching the CSS
      ),
      home: const DashboardScreen(),
    );
  }
}
