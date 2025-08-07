class FormEntry {
  String formId;
  DateTime createdAt;
  Map<String, dynamic> values;

  FormEntry({required this.formId, required this.createdAt, required this.values});

  // Convert a FormEntry instance into a Map.
  Map<String, dynamic> toJson() => {
    'formId': formId,
    'createdAt': createdAt.toIso8601String(),
    'values': values,
  };

  // Create a FormEntry instance from a Map.
  factory FormEntry.fromJson(Map<String, dynamic> json) => FormEntry(
    formId: json['formId'] as String? ?? '',
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    values: Map<String, dynamic>.from(json['values'] as Map? ?? {}),
  );
}