import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:formeasy/models/custom_form.dart';
import 'package:formeasy/widgets/custom_header_delegate.dart';
import 'package:formeasy/widgets/form_card.dart';
import 'package:provider/provider.dart';
import 'package:formeasy/providers/form_provider.dart';
import 'package:formeasy/screens/create_form_screen.dart';
import 'package:formeasy/screens/form_entries_screen.dart';

import '../widgets/quick_acces_card.dart';
import '../widgets/smpty_state_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  String _getGreeting() {
    // Correctly get the time for a proper greeting
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _navigateToViewEntries(BuildContext context, CustomForm form) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => FormEntriesScreen(form: form)));
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, CustomForm form, bool hasEntries) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(hasEntries ? 'This form has entries. Deleting it will also delete all its data permanently. Are you sure?' : 'Are you sure you want to delete this form?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      await Provider.of<FormProvider>(context, listen: false).deleteFormAndEntries(form.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<FormProvider>(
        builder: (context, provider, child) {
          final forms = provider.forms;
          final allEntries = provider.allEntries;

          if (forms.isEmpty) {
            return const EmptyStateWidget();
          }

          final recentForms = forms.length > 4 ? forms.reversed.toList().sublist(0, 4) : forms.reversed.toList();
          final today = DateUtils.dateOnly(DateTime.now());
          final entriesToday = allEntries.where((e) => DateUtils.dateOnly(e.createdAt) == today).length;

          return CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: CustomHeaderDelegate(
                  expandedHeight: 240,
                  greeting: _getGreeting(),
                  formCount: forms.length,
                  entriesTodayCount: entriesToday,
                ),
              ),

              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 60, 16, 16),
                  child: Text('Quick Access', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ),
              ),

              // --- UPDATED: Horizontal Carousel now uses the new card ---
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 200, // Taller height for the new card design
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: recentForms.length,
                    itemBuilder: (context, index) {
                      final form = recentForms[index];
                      final formEntries = allEntries.where((e) => e.formId == form.id).toList();
                      return SizedBox(
                        width: 160,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: QuickAccessCard( // <-- USING THE NEW WIDGET
                            form: form,
                            entries: formEntries,
                            onTap: () => _navigateToViewEntries(context, form),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
                  child: Text('All Forms', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ),
              ),

              AnimationLimiter(
                child: SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100), // Added bottom padding for FAB
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.9,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final form = forms[index];
                        final formEntries = allEntries.where((e) => e.formId == form.id).toList();
                        return AnimationConfiguration.staggeredGrid(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          columnCount: 2,
                          child: ScaleAnimation(
                            child: FadeInAnimation(
                              child: FormCard( // <-- The main grid still uses the detailed card
                                form: form,
                                entries: formEntries,
                                onTap: () => _navigateToViewEntries(context, form),
                                onDelete: () => _showDeleteConfirmationDialog(context, form, formEntries.isNotEmpty),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: forms.length,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateFormScreen())),
        label: const Text('Create Form'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}