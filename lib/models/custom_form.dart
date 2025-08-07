// NO import for hive.dart needed here unless you use HiveObject, which we are removing.
import 'package:formeasy/models/custom_form_field.dart';

class CustomForm {
  String id;
  String title;
  List<CustomFormField> fields;

  CustomForm({required this.id, required this.title, required this.fields});

  // Convert a CustomForm instance into a Map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'fields': fields.map((field) => field.toJson()).toList(),
  };

  // Create a CustomForm instance from a Map.
  factory CustomForm.fromJson(Map<String, dynamic> json) => CustomForm(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    fields: (json['fields'] as List<dynamic>? ?? [])
        .map((f) => CustomFormField.fromJson(Map<String, dynamic>.from(f as Map)))
        .toList(),
  );
}