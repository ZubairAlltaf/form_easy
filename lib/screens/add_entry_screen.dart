import 'package:flutter/material.dart';
import 'package:formeasy/models/custom_form_field.dart';
import 'package:provider/provider.dart';
import 'package:formeasy/models/custom_form.dart';
import 'package:formeasy/models/form_entry.dart';
import 'package:formeasy/providers/form_provider.dart';
import 'package:intl/intl.dart';

class AddEntryScreen extends StatefulWidget {
  final CustomForm form;
  final FormEntry? entryToEdit;
  final dynamic entryKey;

  const AddEntryScreen({
    Key? key,
    required this.form,
    this.entryToEdit,
    this.entryKey,
  }) : super(key: key);

  @override
  _AddEntryScreenState createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, TextEditingController> _controllers;
  final Map<String, dynamic> _values = {};
  bool get _isEditing => widget.entryToEdit != null;

  @override
  void initState() {
    super.initState();
    _controllers = {};
    for (var field in widget.form.fields) {
      final existingValue = widget.entryToEdit?.values[field.name]?.toString() ?? '';
      _controllers[field.name] = TextEditingController(text: existingValue);
    }
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _saveEntry() async {
    FocusScope.of(context).unfocus(); // Hide keyboard before saving
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final provider = Provider.of<FormProvider>(context, listen: false);

      if (_isEditing) {
        final updatedEntry = FormEntry(
          formId: widget.entryToEdit!.formId,
          createdAt: widget.entryToEdit!.createdAt,
          values: _values,
        );
        await provider.updateEntry(widget.entryKey, updatedEntry);
      } else {
        final newEntry = FormEntry(
          formId: widget.form.id,
          createdAt: DateTime.now(),
          values: _values,
        );
        await provider.addEntry(newEntry);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  // --- NEW: A beautifully styled custom input field builder ---
  Widget _buildFieldInput(CustomFormField field) {
    InputDecoration customDecoration(String label, IconData icon) {
      return InputDecoration(
        hintText: label,
        prefixIcon: Icon(icon, color: Colors.grey.shade500),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 2),
        ),
      );
    }

    switch (field.type) {
      case 'number':
        return TextFormField(
          controller: _controllers[field.name],
          decoration: customDecoration(field.name, Icons.pin_outlined),
          keyboardType: TextInputType.number,
          onSaved: (value) => _values[field.name] = num.tryParse(value ?? '') ?? value,
          validator: (value) => !field.optional && (value == null || value.isEmpty) ? '${field.name} is required' : null,
        );
      case 'date':
        return TextFormField(
          controller: _controllers[field.name],
          decoration: customDecoration(field.name, Icons.calendar_today_outlined),
          readOnly: true,
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.tryParse(_controllers[field.name]!.text) ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (pickedDate != null) {
              String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
              _controllers[field.name]!.text = formattedDate;
            }
          },
          onSaved: (value) => _values[field.name] = value,
          validator: (value) => !field.optional && (value == null || value.isEmpty) ? '${field.name} is required' : null,
        );
      default: // 'text'
        return TextFormField(
          controller: _controllers[field.name],
          decoration: customDecoration(field.name, Icons.notes_outlined),
          onSaved: (value) => _values[field.name] = value ?? '',
          validator: (value) => !field.optional && (value == null || value.isEmpty) ? '${field.name} is required' : null,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body is a CustomScrollView for a fluid layout
      body: CustomScrollView(
        slivers: [
          // --- 1. A Clean, Pinned AppBar ---
          SliverAppBar(
            pinned: true,
            title: Text(_isEditing ? 'Edit Entry' : 'Add New Entry'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilledButton.icon(
                  onPressed: _saveEntry,
                  label: Text(_isEditing ? 'Save' : 'Add'),
                  icon: Icon(_isEditing ? Icons.save_alt_outlined : Icons.add_task_outlined),
                ),
              ),
            ],
          ),

          // --- 2. The Form Body ---
          SliverToBoxAdapter(
            child: widget.form.fields.isEmpty
                ? _buildNoFieldsWidget()
                : Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: widget.form.fields.map((field) {
                    // --- 3. Each field is wrapped in an organized container ---
                    return Container(
                      margin: const EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            field.name,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333)
                            ),
                          ),
                          if (field.optional)
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0, bottom: 8.0),
                              child: Text(
                                'Optional',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                              ),
                            )
                          else
                            const SizedBox(height: 8),
                          _buildFieldInput(field),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoFieldsWidget() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 80, color: Colors.orangeAccent),
          const SizedBox(height: 24),
          Text(
            'This Form Has No Fields',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'You cannot add an entry because no input fields have been defined for this form.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}