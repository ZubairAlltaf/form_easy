class CustomFormField {
  String name;
  String type; // "text", "number", "date"
  bool optional;

  CustomFormField({required this.name, required this.type, required this.optional});

  // Convert a CustomFormField instance into a Map.
  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'optional': optional,
  };

  // Create a CustomFormField instance from a Map.
  factory CustomFormField.fromJson(Map<String, dynamic> json) => CustomFormField(
    name: json['name'] as String? ?? '',
    type: json['type'] as String? ?? 'text',
    optional: json['optional'] as bool? ?? true,
  );
}