import 'package:flutter/material.dart';
import 'package:formeasy/models/custom_form_field.dart';

extension StringExtension on String {
  String capitalize() {
    return isNotEmpty ? "${this[0].toUpperCase()}${substring(1)}" : "";
  }
}

class FormFieldTile extends StatelessWidget {
  final CustomFormField field;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const FormFieldTile({
    Key? key,
    required this.field,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  IconData _getFieldIcon(String type) {
    switch (type) {
      case 'number': return Icons.pin_outlined;
      case 'date': return Icons.calendar_today_outlined;
      case 'dropdown': return Icons.arrow_drop_down_circle_outlined;
      case 'checkbox': return Icons.check_box_outlined;
      default: return Icons.notes_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Drag Handle & Accent
            Container(
              width: 12,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: const Center(
                child: Icon(Icons.drag_handle, size: 20, color: Colors.grey),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      field.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF333333)),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(_getFieldIcon(field.type), size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text(
                          field.type.capitalize(),
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                        ),
                        const Text('  •  '),
                        Text(
                          field.optional ? 'Optional' : 'Required',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Actions
            IconButton(
              icon: Icon(Icons.edit_outlined, color: Colors.grey.shade600),
              onPressed: onEdit,
              tooltip: 'Edit Field',
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
              onPressed: onDelete,
              tooltip: 'Delete Field',
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}