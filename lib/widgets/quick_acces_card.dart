import 'package:flutter/material.dart';
import 'package:formeasy/models/custom_form.dart';
import 'package:formeasy/models/form_entry.dart';

class QuickAccessCard extends StatelessWidget {
  final CustomForm form;
  final List<FormEntry> entries;
  final VoidCallback onTap;

  const QuickAccessCard({
    Key? key,
    required this.form,
    required this.entries,
    required this.onTap,
  }) : super(key: key);

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
            // --- 1. The NEW Subtle Gradient Background ---
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.1), Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // --- 2. The NEW Illustrative Watermark Icon ---
            Positioned(
              top: -20,
              right: -20,
              child: Icon(
                icon,
                size: 120,
                color: color.withOpacity(0.15),
              ),
            ),

            // --- 3. The Main Content ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Icon
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    child: Icon(icon, size: 24, color: color),
                  ),
                  const Spacer(flex: 2),

                  // Title and Subtitle
                  Text(
                    form.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2d3436),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${entries.length} Entries',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const Spacer(flex: 1),

                  // --- 4. The NEW Clean Call-to-Action ---
                  Row(
                    children: [
                      Text(
                        'View',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios, size: 14, color: color),
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
}