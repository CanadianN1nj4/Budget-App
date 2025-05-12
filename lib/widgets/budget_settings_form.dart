import 'package:budget_app/models/jar.dart';
import 'package:budget_app/services/budget_service.dart';
import 'package:budget_app/utils/icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class BudgetSettingsForm extends StatefulWidget {
  const BudgetSettingsForm({super.key});

  @override
  State<BudgetSettingsForm> createState() => _BudgetSettingsFormState();
}

class _BudgetSettingsFormState extends State<BudgetSettingsForm> {
  // Form state will be managed here, typically with TextFormFields and Controllers
  // For simplicity, this is a placeholder.
  // You'd typically use a GlobalKey<FormState> and controllers for each field.

  @override
  Widget build(BuildContext context) {
    final budgetService = Provider.of<BudgetService>(context);
    final budgetData = budgetService.budgetData;

    if (budgetData == null) {
      return const Center(child: Text("Loading settings..."));
    }

    // This is a very basic representation. A real form would be more complex.
    return ListView(
      children: [
        Text("Manage Jars", style: Theme.of(context).textTheme.headlineSmall),
        ...budgetData.jars.map(
          (jar) => ListTile(
            leading: Icon(getLucideIcon(jar.iconName)),
            title: Text(jar.name),
            subtitle: Text('Budget: \$${jar.budget.toStringAsFixed(2)}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                // Confirmation dialog recommended here
                await budgetService.removeJar(jar.id);
              },
            ),
            onTap: () {
              // TODO: Implement Jar editing dialog/screen
            },
          ),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text("Add New Jar"),
          onPressed: () {
            // TODO: Implement Add Jar dialog/screen
            // Example:
            // final newJar = Jar(id: Uuid().v4(), name: "New Jar", iconName: "Package", budget: 0, color: Colors.blue);
            // budgetService.addJar(newJar);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Add Jar functionality not fully implemented.'),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        Text(
          "Budget Reset Day",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        DropdownButtonFormField<int>(
          value: budgetData.resetDay,
          decoration: const InputDecoration(labelText: 'Day of Month'),
          items:
              List.generate(31, (index) => index + 1)
                  .map(
                    (day) =>
                        DropdownMenuItem(value: day, child: Text('Day $day')),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) {
              budgetService.updateResetDay(value);
            }
          },
        ),
        const SizedBox(height: 32),
        // ElevatedButton(
        //   onPressed: () {
        //     // This button might not be needed if changes are saved on field modification
        //     // or via specific "Save Jar" / "Save Reset Day" actions.
        //     // If using a Form widget, formKey.currentState.save() would be here.
        //     ScaffoldMessenger.of(context).showSnackBar(
        //       const SnackBar(content: Text('Settings saved (placeholder)')),
        //     );
        //   },
        //   child: const Text('Save All Settings'),
        // ),
      ],
    );
  }
}
