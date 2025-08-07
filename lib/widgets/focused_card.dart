import 'package:flutter/material.dart';
import 'package:formeasy/models/custom_form.dart';
import 'package:formeasy/models/form_entry.dart';
import 'package:intl/intl.dart';

import '../models/custom_form_field.dart';

class FocusedEntryCard extends StatelessWidget {
  final FormEntry entry;
  final CustomForm form;

  const FocusedEntryCard({Key? key, required this.entry, required this.form})
      : super(key: key);

  IconData _getIconForType(String fieldName) {
    final fieldType = form.fields
        .firstWhere((f) => f.name == fieldName,
        orElse: () => CustomFormField(name: '', type: 'text', optional: true))
        .type;
    switch (fieldType) {
      case 'number':
        return Icons.pin_outlined;
      case 'date':
        return Icons.calendar_today_outlined;
      default:
        return Icons.notes_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Entry Details'.toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Recorded on ${DateFormat.yMMMMd().add_jm().format(entry.createdAt)}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const Divider(height: 32),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: entry.values.entries.map((data) {
                  if (data.value == null || data.value.toString().isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(_getIconForType(data.key), color: Colors.grey.shade400, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.key,
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                data.value.toString(),
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF333333)
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}