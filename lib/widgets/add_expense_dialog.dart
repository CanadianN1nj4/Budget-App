import 'package:budget_app/models/jar.dart';
import 'package:budget_app/services/budget_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddExpenseDialog extends StatefulWidget {
  final List<Jar> jars;

  const AddExpenseDialog({super.key, required this.jars});

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedJarId;
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.jars.isNotEmpty) {
      _selectedJarId = widget.jars.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Expense'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          // Added for scrollability if content overflows
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount.';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Please enter a valid positive amount.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                ),
              ),
              DropdownButtonFormField<String>(
                value: _selectedJarId,
                decoration: const InputDecoration(labelText: 'Jar'),
                items: widget.jars.map((Jar jar) {
                  return DropdownMenuItem<String>(
                    value: jar.id,
                    child: Text(jar.name),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedJarId = newValue;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a jar.' : null,
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: const Text('Add Expense'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Provider.of<BudgetService>(context, listen: false).addExpense(
                jarId: _selectedJarId!,
                amount: double.parse(_amountController.text),
                description: _descriptionController.text.isNotEmpty
                    ? _descriptionController.text
                    : null,
              );
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
