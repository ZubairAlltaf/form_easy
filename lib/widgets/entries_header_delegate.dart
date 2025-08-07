import 'package:flutter/material.dart';
import 'dart:ui'; // For lerpDouble

class EntriesHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final String formTitle;
  final int entryCount;
  final TextEditingController searchController;

  EntriesHeaderDelegate({
    required this.expandedHeight,
    required this.formTitle,
    required this.entryCount,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Calculate animation progress (0.0 = expanded, 1.0 = collapsed)
    final progress = (shrinkOffset / (expandedHeight - minExtent)).clamp(0.0, 1.0);

    // Interpolated values for smooth animations
    final titleOpacity = 1.0 - (progress * 2).clamp(0.0, 1.0);
    final titleSize = lerpDouble(28, 20, progress)!;
    final searchBarWidth = lerpDouble(50, MediaQuery.of(context).size.width - 32, progress)!;
    final searchIconOpacity = 1.0 - (progress * 3).clamp(0.0, 1.0);
    final searchHintOpacity = (progress - 0.5).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).primaryColor, const Color(0xFF00695c)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // --- 1. Background Pattern ---
          Opacity(
            opacity: 0.1,
            child: CustomPaint(painter: GridPainter(), child: Container()),
          ),

          // --- 2. Main Title (fades out) ---
          Positioned(
            left: 16,
            bottom: 20,
            child: Opacity(
              opacity: titleOpacity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formTitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$entryCount Total Entries',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

          // --- 3. Collapsed Title (fades in) ---
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Opacity(
                opacity: progress,
                child: Text(
                  formTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // --- 4. Animated Search Bar ---
          Positioned(
            bottom: 10,
            right: 16,
            child: Container(
              width: searchBarWidth,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // The actual TextField, hint text fades in
                  Padding(
                    padding: const EdgeInsets.only(left: 50, right: 16),
                    child: Opacity(
                      opacity: searchHintOpacity,
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search entries...',
                          border: InputBorder.none,
                          filled: false,
                        ),
                      ),
                    ),
                  ),
                  // The search icon, always visible on the left
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Icon(Icons.search, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => 120; // Collapsed height

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}

// --- Custom Painter for the background grid ---
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 0.5;

    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}