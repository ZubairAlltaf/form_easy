import 'package:flutter/material.dart';
import 'package:formeasy/widgets/wave_clipper.dart';
import 'dart:ui'; // For lerpDouble and ImageFilter

class CustomHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final String greeting;
  final int formCount;
  final int entriesTodayCount;

  CustomHeaderDelegate({
    required this.expandedHeight,
    required this.greeting,
    required this.formCount,
    required this.entriesTodayCount,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = (shrinkOffset / (expandedHeight - minExtent)).clamp(0.0, 1.0);

    final greetingOpacity = 1.0 - (progress * 1.5).clamp(0.0, 1.0);
    final greetingFontSize = lerpDouble(30, 20, progress)!;
    final greetingTop = lerpDouble(60, 45, progress)!;
    final cardTop = lerpDouble(expandedHeight - 80, minExtent - 50, progress)!;
    final cardScale = lerpDouble(1.0, 0.0, progress)!;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Background Wave (no changes needed here)
        ClipPath(
          clipper: WaveClipper(),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(top: -50, left: -50, child: Opacity(opacity: (1 - progress).clamp(0.0, 1.0), child: CircleAvatar(radius: 100, backgroundColor: Colors.white.withOpacity(0.05)))),
                Positioned(bottom: -80, right: -50, child: Opacity(opacity: (1 - progress).clamp(0.0, 1.0), child: CircleAvatar(radius: 120, backgroundColor: Colors.white.withOpacity(0.08)))),
              ],
            ),
          ),
        ),

        // Greeting and Title (no changes needed here)
        Positioned(
          top: greetingTop,
          left: 30,
          child: Opacity(
            opacity: greetingOpacity,
            child: Text(
              greeting,
              style: TextStyle(color: Colors.white, fontSize: greetingFontSize, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          ),
        ),
        Positioned(
          top: 45,
          left: 0,
          right: 0,
          child: Opacity(
            opacity: progress,
            child: const Text('Dashboard', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ),

        // --- THE UPDATED "FROSTED GLASS" STATS CARD ---
        Positioned(
          top: cardTop,
          left: 20,
          right: 20,
          child: Transform.scale(
            scale: cardScale,
            alignment: Alignment.topCenter,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  decoration: BoxDecoration(
                    // --- CHANGED: Made the glass whiter and more opaque for better contrast ---
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn('Total Forms', formCount.toString(), Icons.inventory_2_outlined),
                      Container(height: 40, width: 1, color: Colors.black.withOpacity(0.1)),
                      _buildStatColumn('Entries Today', entriesTodayCount.toString(), Icons.today_outlined),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- UPDATED: _buildStatColumn now uses dark, high-contrast colors ---
  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            // Use a darker color for the icon
            Icon(icon, color: Colors.grey.shade700, size: 20),
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                // Use a dark color for the number
                color: const Color(0xFF333333),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            // Use a medium-dark color for the label
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight + 40;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}