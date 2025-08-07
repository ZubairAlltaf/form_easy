import 'package:flutter/material.dart';
import 'package:formeasy/models/custom_form.dart';
import 'package:formeasy/models/custom_form_field.dart';
import 'package:formeasy/models/form_entry.dart';
import '../screens/add_entry_screen.dart';
import 'package:intl/intl.dart';

class EntryCard extends StatefulWidget {
  final CustomForm form;
  final FormEntry entry;
  final dynamic entryKey;
  final int entryNumber;

  const EntryCard({
    Key? key,
    required this.form,
    required this.entry,
    required this.entryKey,
    required this.entryNumber,
  }) : super(key: key);

  @override
  State<EntryCard> createState() => _EntryCardState();
}

class _EntryCardState extends State<EntryCard> {
  bool _isExpanded = false;

  // This helper generates the unique color and icon for the form,
  // ensuring visual consistency with the HomeScreen.
  Map<String, dynamic> _getVisuals() {
    final colors = [
      Colors.teal, Colors.indigo, Colors.deepOrange, Colors.green,
      Colors.blue, Colors.blueGrey, Colors.amber,
    ];
    final icons = [
      Icons.list_alt_rounded, Icons.edit_document, Icons.inventory_2_outlined,
      Icons.people_alt_outlined, Icons.work_history_outlined, Icons.event_note_outlined,
      Icons.receipt_long_outlined,
    ];
    final hash = widget.form.title.hashCode;
    return {
      'color': colors[hash % colors.length],
      'icon': icons[hash % icons.length],
    };
  }

  IconData _getIconForType(String fieldName) {
    final fieldType = widget.form.fields
        .firstWhere((f) => f.name == fieldName, orElse: () => CustomFormField(name: '', type: 'text', optional: true))
        .type;
    switch (fieldType) {
      case 'number': return Icons.pin_outlined;
      case 'date': return Icons.calendar_today_outlined;
      case 'dropdown': return Icons.arrow_drop_down_circle_outlined;
      case 'checkbox': return Icons.check_box_outlined;
      default: return Icons.notes_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final visuals = _getVisuals();
    final Color accentColor = visuals['color'];
    final IconData formIcon = visuals['icon'];

    final title = widget.entry.values.values
        .firstWhere((v) => v is String && v.isNotEmpty, orElse: () => 'Entry #${widget.entryNumber}')
        .toString();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Stack(
              children: [
                // --- Background Watermark (only visible when expanded) ---
                if (_isExpanded)
                  Positioned(
                    top: 20,
                    right: -30,
                    child: Icon(
                      formIcon,
                      size: 150,
                      color: accentColor.withOpacity(0.05),
                    ),
                  ),

                Row(
                  children: [
                    // --- The Accent Color Bar ---
                    Container(width: 6, color: accentColor),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    DateFormat.yMMMMd().format(widget.entry.createdAt),
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                                  ),
                                ),
                                AnimatedRotation(
                                  turns: _isExpanded ? 0.5 : 0,
                                  duration: const Duration(milliseconds: 200),
                                  child: const Icon(Icons.expand_more, color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              title,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            if (!_isExpanded) ...[
                              const SizedBox(height: 4),
                              Text(
                                '${widget.entry.values.values.where((v) => v.toString().isNotEmpty).length} fields filled',
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                              )
                            ],

                            if (_isExpanded) ...[
                              const Divider(height: 32),
                              ...widget.entry.values.entries.map((data) {
                                if (data.value == null || data.value.toString().isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(_getIconForType(data.key), color: accentColor, size: 18),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(data.key, style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w500)),
                                            const SizedBox(height: 2),
                                            Text(
                                              data.value.toString(),
                                              style: const TextStyle(fontSize: 16, color: Color(0xFF333333)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => AddEntryScreen(
                                        form: widget.form,
                                        entryToEdit: widget.entry,
                                        entryKey: widget.entryKey,
                                      ),
                                    ));
                                  },
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                  label: const Text('Edit Entry'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: accentColor,
                                    side: BorderSide(color: accentColor.withOpacity(0.5)),
                                  ),
                                ),
                              )
                            ]
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}