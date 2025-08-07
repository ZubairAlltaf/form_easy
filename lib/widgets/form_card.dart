import 'package:flutter/material.dart';
import 'package:formeasy/models/custom_form.dart';
import 'package:formeasy/models/form_entry.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

class FormCard extends StatelessWidget {
  final CustomForm form;
  final List<FormEntry> entries;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const FormCard({
    Key? key,
    required this.form,
    required this.entries,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  String get lastEntryDate {
    if (entries.isEmpty) return 'N/A';
    final sortedEntries = List<FormEntry>.from(entries)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return DateFormat.yMd().format(sortedEntries.first.createdAt);
  }

  Map<String, dynamic> _getVisuals() {
    final colors = [
      Colors.teal, Colors.indigo, Colors.deepOrange, Colors.green,
      Colors.blue, Colors.purple, Colors.amber,
    ];
    final icons = [
      Icons.list_alt_rounded, Icons.edit_document, Icons.inventory_2_outlined,
      Icons.people_alt_outlined, Icons.work_history_outlined, Icons.event_note_outlined,
      Icons.receipt_long_outlined,
    ];
    final hash = form.title.hashCode;
    return {
      'color': colors[hash % colors.length],
      'icon': icons[hash % icons.length],
    };
  }

  @override
  Widget build(BuildContext context) {
    final visuals = _getVisuals();
    final Color color = visuals['color'];
    final IconData icon = visuals['icon'];

    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipPath(
                clipper: _DiagonalClipper(),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.6), color],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            ),
            // --- FIXED: Increased padding for better aesthetics and spacing ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white,
                        child: Icon(icon, color: color, size: 24),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'delete') onDelete();
                        },
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(Icons.delete_forever, color: Colors.red),
                              title: Text('Delete Form', style: TextStyle(color: Colors.red)),
                            ),
                          ),
                        ],
                        icon: Icon(Icons.more_vert, color: Colors.white.withOpacity(0.8)),
                      ),
                    ],
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        form.title,
                        style: const TextStyle(
                          // --- FIXED: Slightly reduced font size to prevent overflow ---
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      // --- FIXED: This Row is now flexible ---
                      Row(
                        // This ensures the two stats are pushed to opposite ends,
                        // preventing overflow regardless of screen size.
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatItem(
                            value: entries.length.toString(),
                            label: 'Entries',
                          ),
                          // The fixed SizedBox is removed
                          _buildStatItem(
                            value: lastEntryDate,
                            label: 'Last Update',
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.grey.shade900,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: Colors.grey.shade900,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.6)
      ..lineTo(0, size.height * 0.9)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}