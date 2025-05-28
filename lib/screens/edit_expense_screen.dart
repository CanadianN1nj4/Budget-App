import 'package:budget_app/models/expense.dart';
import 'package:budget_app/models/jar.dart';
import 'package:budget_app/services/budget_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EditExpenseScreen extends StatefulWidget {
  final Expense expense;
  final List<Jar> jars;

  const EditExpenseScreen({
    super.key,
    required this.expense,
    required this.jars,
  });

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late String _selectedJarId;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _amountController =
        TextEditingController(text: widget.expense.amount.toStringAsFixed(2));
    _descriptionController =
        TextEditingController(text: widget.expense.description ?? '');
    _selectedJarId = widget.expense.jarId;
    _selectedDate = widget.expense.date;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      final updatedExpense = Expense(
        id: widget.expense.id,
        jarId: _selectedJarId,
        amount: double.parse(_amountController.text),
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        date: _selectedDate,
      );
      Provider.of<BudgetService>(context, listen: false)
          .updateExpense(updatedExpense);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Expense'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveExpense,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                    labelText: 'Amount', prefixText: '\$'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter an amount.';
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0)
                    return 'Please enter a valid positive amount.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration:
                    const InputDecoration(labelText: 'Description (Optional)'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedJarId,
                decoration: const InputDecoration(labelText: 'Jar'),
                items: widget.jars.map((Jar jar) {
                  return DropdownMenuItem<String>(
                      value: jar.id, child: Text(jar.name));
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedJarId = newValue;
                    });
                  }
                },
                validator: (value) =>
                    value == null ? 'Please select a jar.' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title:
                    Text("Date: ${DateFormat.yMMMd().format(_selectedDate)}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDate(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
