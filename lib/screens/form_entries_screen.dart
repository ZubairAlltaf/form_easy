import 'package:flutter/material.dart';
import 'package:formeasy/models/form_entry.dart';
import 'package:formeasy/screens/add_entry_screen.dart';
import 'package:formeasy/services/export_service.dart';
import 'package:formeasy/widgets/entry_card.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import 'package:formeasy/models/custom_form.dart';
import 'package:formeasy/providers/form_provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

import '../widgets/focused_card.dart';

class FormEntriesScreen extends StatefulWidget {
  final CustomForm form;
  const FormEntriesScreen({Key? key, required this.form}) : super(key: key);

  @override
  State<FormEntriesScreen> createState() => _FormEntriesScreenState();
}

class _FormEntriesScreenState extends State<FormEntriesScreen> {
  // --- State for the UI ---
  bool _isFocusView = false;
  int _focusedIndex = 0;
  PageController _pageController = PageController();
  Offset _tiltOffset = Offset.zero;

  // --- Search and Data logic ---
  final TextEditingController _searchController = TextEditingController();

  // --- Export Service ---
  final ExportService _exportService = ExportService();
  bool _isExporting = false;

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // Filter logic is now a pure function that takes data and returns a filtered list
  List<FormEntry> _runFilter(Map<dynamic, FormEntry> allEntriesMap) {
    String query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      return allEntriesMap.values.toList();
    } else {
      return allEntriesMap.values.where((entry) {
        return entry.values.values.any((value) => value.toString().toLowerCase().contains(query));
      }).toList();
    }
  }

  Map<String, List<FormEntry>> _groupEntriesByDate(List<FormEntry> entries) {
    final Map<String, List<FormEntry>> grouped = {};
    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    for (var entry in entries) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      final entryDate = DateTime(entry.createdAt.year, entry.createdAt.month, entry.createdAt.day);
      String key;
      if (entryDate == today) { key = 'Today'; }
      else if (entryDate == yesterday) { key = 'Yesterday'; }
      else { key = DateFormat.yMMMMd().format(entry.createdAt); }
      if (grouped[key] == null) { grouped[key] = []; }
      grouped[key]!.add(entry);
    }
    return grouped;
  }

  dynamic _getKeyForEntry(Map<dynamic, FormEntry> allEntriesMap, FormEntry entryToFind) {
    for (var entry in allEntriesMap.entries) {
      if (entry.value == entryToFind) {
        return entry.key;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FormProvider>(
      builder: (context, provider, child) {
        // Get fresh data from the provider on every build
        final allEntriesMap = Map.fromEntries(provider.entriesMap.entries
            .where((entry) => entry.value.formId == widget.form.id));

        final filteredEntries = _runFilter(allEntriesMap);

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
          child: _isFocusView
              ? _buildFocusView(context, allEntriesMap)
              : _buildListView(context, allEntriesMap, filteredEntries),
        );
      },
    );
  }

  Widget _buildListView(BuildContext context, Map<dynamic, FormEntry> allEntriesMap, List<FormEntry> filteredEntries) {
    final groupedEntries = _groupEntriesByDate(filteredEntries);
    final groupKeys = groupedEntries.keys.toList();
    final provider = Provider.of<FormProvider>(context, listen: false);

    return Scaffold(
      key: const ValueKey('ListView'),
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(widget.form.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            pinned: true,
            floating: true,
            actions: [
              IconButton(icon: const Icon(Icons.download_outlined), onPressed: () => _showExportDialog(allEntriesMap), tooltip: 'Export Data'),
              if (allEntriesMap.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.view_carousel_outlined),
                  tooltip: 'Focus View',
                  onPressed: () => setState(() { _focusedIndex = 0; _isFocusView = true; }),
                ),
            ],
            flexibleSpace: ClipRRect(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), child: Container(color: Colors.transparent))),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SearchBarDelegate(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search in ${allEntriesMap.length} entries...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                  ),
                ),
              ),
            ),
          ),

          if (allEntriesMap.isEmpty)
            _buildEmptyStateSliver('No entries yet.', 'Tap the "+" button to add your first entry.'),

          if (allEntriesMap.isNotEmpty && filteredEntries.isEmpty)
            _buildEmptyStateSliver('No results found.', 'Try a different search query.'),

          if (filteredEntries.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate((context, groupIndex) {
                final groupTitle = groupKeys[groupIndex];
                final entriesInGroup = groupedEntries[groupTitle]!;
                return Column(
                  key: ValueKey(groupTitle),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 16, 8),
                      child: Text(groupTitle.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1.1)),
                    ),
                    ...entriesInGroup.map((entry) {
                      final key = _getKeyForEntry(allEntriesMap, entry);
                      return Dismissible(
                        key: ValueKey(key),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirm Deletion'),
                              content: const Text('Are you sure you want to delete this entry? This action cannot be undone.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                                TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          );
                          if (confirmed == true && key != null) {
                            await provider.deleteEntry(key);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entry Deleted'), duration: Duration(seconds: 2)));
                            }
                          }
                          return confirmed ?? false;
                        },
                        background: Container(
                          color: Colors.red.shade700,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: const Icon(Icons.delete_forever, color: Colors.white),
                        ),
                        child: EntryCard(
                          form: widget.form,
                          entry: entry,
                          entryKey: key,
                          entryNumber: allEntriesMap.values.toList().indexOf(entry) + 1,
                        ),
                      );
                    })
                  ],
                );
              },
                childCount: groupKeys.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddEntryScreen(form: widget.form))),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFocusView(BuildContext context, Map<dynamic, FormEntry> allEntriesMap) {
    _pageController = PageController(initialPage: _focusedIndex);
    final entriesList = allEntriesMap.values.toList();

    return Scaffold(
      key: const ValueKey('FocusView'),
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => setState(() => _isFocusView = false)),
      ),
      body: GestureDetector(
        onPanUpdate: (details) => setState(() => _tiltOffset += details.delta / 100),
        onPanEnd: (_) => setState(() => _tiltOffset = Offset.zero),
        child: PageView.builder(
          controller: _pageController,
          itemCount: entriesList.length,
          onPageChanged: (index) => setState(() => _focusedIndex = index),
          itemBuilder: (context, index) {
            final entry = entriesList[index];
            final key = _getKeyForEntry(allEntriesMap, entry);
            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(_tiltOffset.dy * 0.1)
                ..rotateY(-_tiltOffset.dx * 0.1),
              alignment: FractionalOffset.center,
              child: Hero(
                tag: 'entry_card_$key',
                child: FocusedEntryCard(entry: entry, form: widget.form),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyStateSliver(String title, String subtitle) {
    return SliverFillRemaining(hasScrollBody: false, child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade300), const SizedBox(height: 16), Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey.shade700)), const SizedBox(height: 8), Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),],),),);
  }

  void _showExportDialog(Map<dynamic, FormEntry> allEntriesMap) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('Choose the format to export your data.'),
        actions: [
          TextButton(child: const Text('CSV'), onPressed: () { Navigator.of(context).pop(); _exportData('CSV', allEntriesMap); }),
          TextButton(child: const Text('Excel (XLSX)'), onPressed: () { Navigator.of(context).pop(); _exportData('Excel', allEntriesMap); }),
        ],
      ),
    );
  }

  Future<void> _exportData(String format, Map<dynamic, FormEntry> allEntriesMap) async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      if (allEntriesMap.values.isEmpty) {
        scaffoldMessenger.showSnackBar(const SnackBar(content: Text('No entries to export.')));
        return;
      }
      String? path;
      if (format == 'CSV') {
        path = await _exportService.exportToCsv(allEntriesMap.values.toList(), widget.form);
      } else if (format == 'Excel') {
        path = await _exportService.exportToExcel(allEntriesMap.values.toList(), widget.form);
      }
      if (path != null && mounted) {
        scaffoldMessenger.showSnackBar(SnackBar(
          content: Text('Exported to $format successfully!'),
          action: SnackBarAction(label: 'OPEN', onPressed: () => OpenFilex.open(path!)),
        ));
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Error exporting data: $e')));
    } finally {
      if(mounted) setState(() => _isExporting = false);
    }
  }
}

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _SearchBarDelegate({required this.child});
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;
  @override
  double get maxExtent => 64.0;
  @override
  double get minExtent => 64.0;
  @override
  bool shouldRebuild(_SearchBarDelegate oldDelegate) => child != oldDelegate.child;
}