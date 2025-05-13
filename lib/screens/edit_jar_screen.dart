import 'package:budget_app/models/jar.dart';
import 'package:budget_app/services/budget_service.dart';
import 'package:budget_app/utils/icons.dart'; // For getLucideIcon and a list of icons
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

class EditJarScreen extends StatefulWidget {
  final Jar jar;

  const EditJarScreen({super.key, required this.jar});

  @override
  State<EditJarScreen> createState() => _EditJarScreenState();
}

class _EditJarScreenState extends State<EditJarScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _budgetController;
  late String _selectedIconName;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.jar.name);
    _budgetController =
        TextEditingController(text: widget.jar.budget.toStringAsFixed(2));
    _selectedIconName = kAvailableIconNames.contains(widget.jar.iconName)
        ? widget.jar.iconName
        : 'Package';
    _selectedColor = widget.jar.color;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _pickColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) {
              setState(() => _selectedColor = color);
            },
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Got it'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _saveJar() {
    if (_formKey.currentState!.validate()) {
      final budgetService = Provider.of<BudgetService>(context, listen: false);
      final updatedJar = Jar(
        id: widget.jar.id,
        name: _nameController.text,
        iconName: _selectedIconName,
        budget: double.tryParse(_budgetController.text) ?? widget.jar.budget,
        spent: widget.jar.spent, // Keep existing spent amount
        color: _selectedColor,
      );
      budgetService.updateJar(updatedJar).then((_) {
        Navigator.of(context).pop(); // Go back after saving
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${updatedJar.name} updated successfully!')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update jar: $error')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.jar.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveJar,
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
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Jar Name'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a name'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _budgetController,
                decoration: const InputDecoration(
                    labelText: 'Monthly Budget', prefixText: '\$'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a budget.';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) < 0) {
                    return 'Please enter a valid non-negative budget.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedIconName,
                decoration: const InputDecoration(labelText: 'Icon'),
                items: kAvailableIconNames.map((String iconName) {
                  return DropdownMenuItem<String>(
                    value: iconName,
                    child: Row(
                      children: [
                        Icon(getLucideIcon(iconName), size: 20),
                        const SizedBox(width: 10),
                        Text(iconName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() => _selectedIconName = newValue);
                  }
                },
              ),
              const SizedBox(height: 24),
              ListTile(
                title: const Text('Jar Color'),
                trailing: CircleAvatar(backgroundColor: _selectedColor),
                onTap: _pickColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
