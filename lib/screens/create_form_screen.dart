import 'package:flutter/material.dart';
import 'package:formeasy/models/custom_form_field.dart';
import 'package:formeasy/models/custom_form.dart';
import 'package:formeasy/providers/form_provider.dart';
import 'package:formeasy/widgets/form_field_tile.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:ui';

class CreateFormScreen extends StatefulWidget {
  const CreateFormScreen({Key? key}) : super(key: key);

  @override
  _CreateFormScreenState createState() => _CreateFormScreenState();
}

class _CreateFormScreenState extends State<CreateFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final List<CustomFormField> _fields = [];

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _showFieldDialog({CustomFormField? fieldToEdit, int? index}) async {
    final fieldNameController = TextEditingController(text: fieldToEdit?.name ?? '');
    String fieldType = fieldToEdit?.type ?? 'text';
    bool isOptional = fieldToEdit?.optional ?? true;
    final isEditing = fieldToEdit != null;

    final result = await showDialog<CustomFormField?>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Field' : 'Add New Field'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: fieldNameController,
                    decoration: const InputDecoration(labelText: 'Field Name', border: OutlineInputBorder()),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: fieldType,
                    decoration: const InputDecoration(labelText: 'Field Type', border: OutlineInputBorder()),
                    items: ['text', 'number', 'date', 'dropdown', 'checkbox'].map((type) {
                      return DropdownMenuItem(value: type, child: Text(type.capitalize()));
                    }).toList(),
                    onChanged: (value) => setDialogState(() => fieldType = value!),
                  ),
                  SwitchListTile(
                    title: const Text('Optional Field'),
                    value: isOptional,
                    onChanged: (value) => setDialogState(() => isOptional = value!),
                    contentPadding: EdgeInsets.zero,
                    activeColor: Theme.of(context).colorScheme.secondary,
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    if (fieldNameController.text.isNotEmpty) {
                      Navigator.of(context).pop(
                        CustomFormField(
                          name: fieldNameController.text,
                          type: fieldType,
                          optional: isOptional,
                        ),
                      );
                    }
                  },
                  child: Text(isEditing ? 'Save Changes' : 'Add Field'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        if (isEditing && index != null) {
          _fields[index] = result;
        } else {
          _fields.add(result);
        }
      });
    }
  }

  void _saveForm() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      if (_fields.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one field to the form.'), backgroundColor: Colors.orange),
        );
        return;
      }
      final form = CustomForm(
        id: const Uuid().v4(),
        title: _titleController.text,
        fields: _fields,
      );
      Provider.of<FormProvider>(context, listen: false).saveForm(form);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _FluidHeaderDelegate(
              expandedHeight: 220,
              formKey: _formKey,
              titleController: _titleController,
              onSave: _saveForm,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'FORM FIELDS (${_fields.length})',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 1.2),
                  ),
                  TextButton.icon(
                    onPressed: () => _showFieldDialog(),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Add Field'),
                  )
                ],
              ),
            ),
          ),

          _fields.isEmpty
              ? const SliverToBoxAdapter(child: _EmptyFieldsState())
              : SliverReorderableList(
            itemCount: _fields.length,
            itemBuilder: (context, index) {
              final field = _fields[index];
              return ReorderableDragStartListener(
                key: ValueKey(field.hashCode),
                index: index,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FormFieldTile(
                    field: field,
                    onEdit: () => _showFieldDialog(fieldToEdit: field, index: index),
                    onDelete: () => setState(() => _fields.removeAt(index)),
                  ),
                ),
              );
            },
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex -= 1;
                final field = _fields.removeAt(oldIndex);
                _fields.insert(newIndex, field);
              });
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveForm,
        label: const Text('Save Form'),
        icon: const Icon(Icons.check_circle_outline),
      ),
    );
  }
}

class _EmptyFieldsState extends StatelessWidget {
  const _EmptyFieldsState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.grid_on_outlined, size: 90, color: Colors.grey.shade300),
                Icon(Icons.add, size: 45, color: Colors.grey.shade400),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Design Your Form',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the "Add Field" button to build your custom form.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _FluidHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final VoidCallback onSave;

  _FluidHeaderDelegate({
    required this.expandedHeight,
    required this.formKey,
    required this.titleController,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = (shrinkOffset / (expandedHeight - minExtent)).clamp(0.0, 1.0);
    final titleFontSize = lerpDouble(32, 20, progress)!;
    final titlePaddingBottom = lerpDouble(20, 14, progress)!;
    final titlePaddingLeft = lerpDouble(16, 56, progress)!;

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Theme.of(context).scaffoldBackgroundColor),
        // --- UPDATED: Passing theme colors into the painter ---
        CustomPaint(
          painter: _ShapePainter(
            progress: progress,
            accentColor: Theme.of(context).colorScheme.secondary,
            primaryColor: Colors.grey,
          ),
        ),

        AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(progress),
          elevation: progress > 0.8 ? 2 : 0,
          leading: const BackButton(),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Opacity(
                opacity: progress > 0.5 ? 1.0 : 0.0,
                child: IconButton(
                  icon: const Icon(Icons.check_circle_outline),
                  onPressed: onSave,
                  tooltip: 'Save Form',
                ),
              ),
            )
          ],
        ),

        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            padding: EdgeInsets.only(bottom: titlePaddingBottom, left: titlePaddingLeft, right: 16),
            child: Form(
              key: formKey,
              child: TextFormField(
                controller: titleController,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
                decoration: const InputDecoration(
                  hintText: 'Untitled Form',
                  border: InputBorder.none,
                  errorStyle: TextStyle(height: 0, fontSize: 0),
                ),
                validator: (value) => (value == null || value.isEmpty) ? '' : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  double get maxExtent => expandedHeight;
  @override
  double get minExtent => kToolbarHeight + 30;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}

class _ShapePainter extends CustomPainter {
  final double progress;
  // --- FIXED: Added Color properties to receive from the parent ---
  final Color accentColor;
  final Color primaryColor;

  _ShapePainter({
    required this.progress,
    required this.accentColor,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // --- FIXED: Using the passed-in colors instead of Theme.of(context) ---
    final accentPaint = Paint()..color = accentColor.withOpacity(0.1);
    final primaryPaint = Paint()..color = primaryColor.withOpacity(0.1);

    final circle1Offset = lerpDouble(0, -40, progress)!;
    final rect1Offset = lerpDouble(0, 60, progress)!;

    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.4 + circle1Offset), 60, accentPaint);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.8), 40, primaryPaint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.1 + rect1Offset, size.height * 0.1, 80, 80),
          const Radius.circular(20),
        ),
        primaryPaint);
  }

  // --- FIXED: Added the missing shouldRepaint method ---
  @override
  bool shouldRepaint(covariant _ShapePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.primaryColor != primaryColor;
  }
}