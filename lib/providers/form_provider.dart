import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:formeasy/models/custom_form.dart';
import 'package:formeasy/models/form_entry.dart';

class FormProvider with ChangeNotifier {
  final Box _formBox = Hive.box('forms');
  final Box _entryBox = Hive.box('entries');

  List<CustomForm> _forms = [];
  Map<dynamic, FormEntry> _entries = {};

  List<CustomForm> get forms => _forms;
  List<FormEntry> get allEntries => _entries.values.toList();
  Map<dynamic, FormEntry> get entriesMap => _entries;

  FormProvider() {
    _loadForms();
    _loadEntries();
    _formBox.watch().listen((_) => _loadForms());
    _entryBox.watch().listen((_) => _loadEntries());
  }

  void _loadForms() {
    _forms = _formBox.values.map((data) => CustomForm.fromJson(Map<String, dynamic>.from(data as Map))).toList();
    notifyListeners();
  }

  void _loadEntries() {
    final rawMap = _entryBox.toMap();
    _entries = rawMap.map((key, value) => MapEntry(key, FormEntry.fromJson(Map<String, dynamic>.from(value as Map))));
    notifyListeners();
  }

  Future<void> saveForm(CustomForm form) async {
    await _formBox.put(form.id, form.toJson());
  }

  Future<void> addEntry(FormEntry entry) async {
    await _entryBox.add(entry.toJson());
  }

  Future<void> updateEntry(dynamic key, FormEntry entry) async {
    await _entryBox.put(key, entry.toJson());
  }

  Future<void> deleteEntry(dynamic key) async {
    await _entryBox.delete(key);
  }

  // --- NEW: Method to delete a form AND all of its entries ---
  Future<void> deleteFormAndEntries(String formId) async {
    // 1. Find all keys of entries that belong to this form
    final List<dynamic> keysToDelete = [];
    _entryBox.toMap().forEach((key, value) {
      // We have to decode the entry to check its formId
      final entry = FormEntry.fromJson(Map<String, dynamic>.from(value as Map));
      if (entry.formId == formId) {
        keysToDelete.add(key);
      }
    });

    // 2. Delete all those entries at once
    if (keysToDelete.isNotEmpty) {
      await _entryBox.deleteAll(keysToDelete);
    }

    // 3. Delete the form itself
    await _formBox.delete(formId);

    // The listeners will automatically update the UI
  }

  List<FormEntry> getEntriesByFormId(String formId) {
    return _entries.values.where((entry) => entry.formId == formId).toList();
  }
}