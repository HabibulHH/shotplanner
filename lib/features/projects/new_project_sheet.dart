import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/shotkit_widgets.dart';
import '../../data/models.dart';
import '../../data/shotkit_store.dart';

const kProjectTemplates = [
  'Wedding',
  'Interview',
  'Music video',
  'Short film',
  'Blank'
];

/// Bottom sheet that creates a project from a template. Resolves to the new
/// project, or null when dismissed.
Future<Project?> showNewProjectSheet(
  BuildContext context,
  ShotKitStore store, {
  String template = 'Wedding',
}) async {
  final titleController = TextEditingController();
  var selected = template;
  final created = await showModalBottomSheet<Project>(
    context: context,
    isScrollControlled: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setSheetState) {
        Future<void> create() async {
          final title = titleController.text.trim();
          if (title.isEmpty) return;
          final project = await store.addProject(title, selected);
          if (context.mounted) Navigator.pop(context, project);
        }

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.viewInsetsOf(context).bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SheetHandle(),
              const SizedBox(height: 18),
              Text(
                'New project',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              const Text(
                'Pick a starting template. Everything stays editable.',
                style: TextStyle(color: ShotKitColors.dim),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: titleController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => create(),
                decoration: const InputDecoration(
                  labelText: 'Project title',
                  hintText: 'e.g. Nabila & Arif Wedding',
                ),
              ),
              const SizedBox(height: 18),
              const Text('TEMPLATE', style: ShotKitText.label),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in kProjectTemplates)
                    TemplateChip(
                      label: item,
                      selected: selected == item,
                      onTap: () => setSheetState(() => selected = item),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: create,
                  child: const Text('Create project'),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
  // Delay disposal until the sheet's exit animation has released the field.
  Future<void>.delayed(const Duration(seconds: 1), titleController.dispose);
  return created;
}

class TemplateChip extends StatelessWidget {
  const TemplateChip({
    super.key,
    required this.label,
    required this.onTap,
    this.selected = false,
  });
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final icon =
        label == 'Blank' ? Icons.add_box_outlined : projectTypeIcon(label);
    return Material(
      color: selected ? ShotKitColors.tape : ShotKitColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? ShotKitColors.tape : ShotKitColors.line,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? ShotKitColors.tapeInk : ShotKitColors.tape,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: selected ? ShotKitColors.tapeInk : ShotKitColors.paper,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
