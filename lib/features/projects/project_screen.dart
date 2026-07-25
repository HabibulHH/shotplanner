import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/shotkit_widgets.dart';
import '../../data/models.dart';
import '../../data/shotkit_store.dart';
import '../export/export_screen.dart';
import '../onset/onset_screen.dart';
import '../scenes/scene_screen.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key, required this.store, required this.project});
  final ShotKitStore store;
  final Project project;

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  @override
  void initState() {
    super.initState();
    widget.store.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.store.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    return Scaffold(
      body: Column(
        children: [
          SlateHeader(
            title: project.title,
            subtitle: '${project.type} · ${project.shotCount} shots',
            showBack: true,
            trailing: PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'export') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ExportScreen(store: widget.store, project: project),
                    ),
                  );
                } else if (value == 'archive') {
                  await widget.store.archiveProject(project);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'export',
                  child: Text('Export production PDF'),
                ),
                PopupMenuItem(value: 'archive', child: Text('Archive project')),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 112),
              children: [
                _ProjectRunCard(
                  project: project,
                  onSet: _openOnSet,
                  onExport: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ExportScreen(store: widget.store, project: project),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SectionLabel(
                  'Scene order',
                  trailing: Text(
                    '${project.completed}/${project.shotCount} DONE',
                    style: const TextStyle(
                      color: ShotKitColors.dim,
                      fontFamily: 'monospace',
                      fontSize: 10.5,
                    ),
                  ),
                ),
                if (project.scenes.isEmpty)
                  EmptySlate(
                    title: 'Your slate is empty',
                    body:
                        'Add the first scene, then build its shot list in shooting order.',
                    action: OutlinedButton.icon(
                      onPressed: _showAddScene,
                      icon: const Icon(Icons.add),
                      label: const Text('ADD SCENE'),
                    ),
                  )
                else
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    itemCount: project.scenes.length,
                    onReorder: (oldIndex, newIndex) =>
                        widget.store.reorderScenes(project, oldIndex, newIndex),
                    itemBuilder: (context, index) {
                      final scene = project.scenes[index];
                      return Padding(
                        key: ValueKey(scene.id),
                        padding: const EdgeInsets.only(bottom: 11),
                        child: Row(children: [
                          Expanded(
                              child: _SceneCard(
                            number: index + 1,
                            scene: scene,
                            onDuplicate: () =>
                                widget.store.duplicateScene(project, scene),
                            onDelete: () => _confirmDeleteScene(scene),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SceneScreen(
                                  store: widget.store,
                                  project: project,
                                  scene: scene,
                                ),
                              ),
                            ),
                          )),
                          ReorderableDragStartListener(
                            index: index,
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(Icons.drag_indicator_rounded,
                                  color: ShotKitColors.dim),
                            ),
                          ),
                        ]),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddScene,
        icon: const Icon(Icons.add_rounded),
        label: const Text('ADD SCENE'),
      ),
    );
  }

  void _openOnSet() {
    final scene = widget.project.scenes.cast<Scene?>().firstWhere(
          (scene) => scene!.shots.isNotEmpty,
          orElse: () => null,
        );
    if (scene == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one shot before entering On-set mode.'),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OnSetScreen(
          store: widget.store,
          project: widget.project,
          scene: scene,
        ),
      ),
    );
  }

  Future<void> _showAddScene() async {
    final title = TextEditingController();
    final location = TextEditingController();
    var tag = TimeOfDayTag.day;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            14,
            16,
            MediaQuery.viewInsetsOf(context).bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ShotKitColors.line,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Add scene',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: title,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Scene name',
                  hintText: 'e.g. Couple first look',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: location,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'Set or venue',
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: TimeOfDayTag.values
                    .map(
                      (item) => ChoiceChip(
                        label: Text(item.label),
                        selected: tag == item,
                        onSelected: (_) => setSheetState(() => tag = item),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (title.text.trim().isEmpty) return;
                    widget.store.addScene(
                      widget.project,
                      title.text.trim(),
                      location.text.trim().isEmpty
                          ? 'Location TBC'
                          : location.text.trim(),
                      tag,
                    );
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text('ADD TO SLATE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    // Delay disposal until the sheet's exit animation has released the fields.
    Future<void>.delayed(const Duration(seconds: 1), () {
      title.dispose();
      location.dispose();
    });
  }

  Future<void> _confirmDeleteScene(Scene scene) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete scene?'),
        content: Text(
            '${scene.title} and all ${scene.shots.length} shots will be removed.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCEL')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('DELETE')),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.store.deleteScene(widget.project, scene);
    }
  }
}

class _ProjectRunCard extends StatelessWidget {
  const _ProjectRunCard({
    required this.project,
    required this.onSet,
    required this.onExport,
  });
  final Project project;
  final VoidCallback onSet;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: ShotKitColors.raised,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ShotKitColors.line),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PRODUCTION RUN',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${(project.progress * 100).round()}% in the can',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
              Text(
                '${project.completed} / ${project.shotCount}',
                style: const TextStyle(
                  color: ShotKitColors.tape,
                  fontFamily: 'monospace',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FilmProgress(value: project.progress, height: 7),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onSet,
                  icon: const Icon(
                    Icons.radio_button_checked_rounded,
                    size: 18,
                  ),
                  label: const Text('ON-SET MODE'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.outlined(
                onPressed: onExport,
                tooltip: 'Export PDF',
                icon: const Icon(Icons.ios_share_rounded),
                style: IconButton.styleFrom(
                  minimumSize: const Size(50, 48),
                  side: const BorderSide(color: ShotKitColors.line),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SceneCard extends StatelessWidget {
  const _SceneCard({
    required this.number,
    required this.scene,
    required this.onTap,
    required this.onDuplicate,
    required this.onDelete,
  });
  final int number;
  final Scene scene;
  final VoidCallback onTap;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'SC ${number.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      color: ShotKitColors.tape,
                      fontFamily: 'monospace',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      scene.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  DataPill(scene.timeOfDay.label),
                  const SizedBox(width: 4),
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    onSelected: (value) {
                      if (value == 'duplicate') onDuplicate();
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                          value: 'duplicate', child: Text('Duplicate scene')),
                      PopupMenuItem(
                          value: 'delete', child: Text('Delete scene')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: ShotKitColors.dim,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      scene.location,
                      style: const TextStyle(
                        color: ShotKitColors.dim,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    '${scene.completed}/${scene.shots.length}',
                    style: const TextStyle(
                      color: ShotKitColors.dim,
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FilmProgress(value: scene.progress),
            ],
          ),
        ),
      ),
    );
  }
}
