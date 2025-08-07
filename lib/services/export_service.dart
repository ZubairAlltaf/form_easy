import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:formeasy/models/custom_form.dart';
import 'package:formeasy/models/form_entry.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class ExportService {
  /// Exports a list of entries to a CSV file and returns the file path.
  Future<String> exportToCsv(List<FormEntry> entries, CustomForm form) async {
    // Create the header row from the form's field names
    final List<String> header = [
      'Created At', // Add a timestamp column by default
      ...form.fields.map((f) => f.name)
    ];

    // Create the data rows from each entry
    final List<List<dynamic>> rows = [
      header, // First row is the header
      ...entries.map((entry) {
        return [
          DateFormat('yyyy-MM-dd HH:mm').format(entry.createdAt),
          // For each field in the form, find the corresponding value in the entry
          ...form.fields.map((field) => entry.values[field.name] ?? ''),
        ];
      })
    ];

    final csv = const ListToCsvConverter().convert(rows);
    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${form.title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.csv';
    final path = '${directory.path}/$fileName';
    final file = File(path);
    await file.writeAsString(csv);
    return path;
  }

  /// Exports a list of entries to an Excel (.xlsx) file and returns the file path.
  Future<String> exportToExcel(List<FormEntry> entries, CustomForm form) async {
    final excel = Excel.createExcel();
    final Sheet sheet = excel[excel.getDefaultSheet()!];

    // Create the header row
    final List<CellValue> header = [
       TextCellValue('Created At'),
      ...form.fields.map((f) => TextCellValue(f.name))
    ];
    sheet.appendRow(header);

    // Create the data rows
    for (final entry in entries) {
      final List<CellValue> row = [
        TextCellValue(DateFormat('yyyy-MM-dd HH:mm').format(entry.createdAt)),
        ...form.fields.map((field) {
          final value = entry.values[field.name];
          if (value is num) {
            return DoubleCellValue(value.toDouble());
          }
          // Default to TextCellValue for all other types
          return TextCellValue(value?.toString() ?? '');
        }),
      ];
      sheet.appendRow(row);
    }

    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${form.title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final path = '${directory.path}/$fileName';
    final fileBytes = excel.save();

    if (fileBytes != null) {
      final file = File(path);
      await file.writeAsBytes(fileBytes);
      return path;
    } else {
      throw Exception('Error saving Excel file.');
    }
  }
}