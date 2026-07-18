import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/shotkit_widgets.dart';
import '../../core/widgets/pro_upsell.dart';
import '../../data/models.dart';
import '../../data/shotkit_store.dart';
import '../onset/onset_screen.dart';
import '../settings/settings_screen.dart';
import 'project_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key, required this.store});
  final ShotKitStore store;

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
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
    return Scaffold(
      body: Column(
        children: [
          SlateHeader(
            title: 'ShotKit',
            subtitle:
                'Production desk · ${widget.store.activeProjects.length} active projects',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              children: [
                _SetStatusCard(projects: widget.store.activeProjects),
                const SizedBox(height: 24),
                const SectionLabel('Active slates', trailing: OfflinePill()),
                if (widget.store.activeProjects.isEmpty)
                  EmptySlate(
                    title: 'Slate your first production',
                    body:
                        'Start blank or load a field-tested template. Everything works offline.',
                    action: FilledButton.icon(
                      onPressed: _showNewProject,
                      icon: const Icon(Icons.add),
                      label: const Text('NEW PROJECT'),
                    ),
                  )
                else
                  ...widget.store.activeProjects.map(
                    (project) => Dismissible(
                      key: ValueKey(project.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.only(right: 20),
                        alignment: Alignment.centerRight,
                        color: ShotKitColors.record,
                        child: const Icon(Icons.archive_outlined),
                      ),
                      onDismissed: (_) => widget.store.archiveProject(project),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ProjectCard(
                          project: project,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProjectScreen(
                                store: widget.store,
                                project: project,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: ShotKitCommandDock(
        onSlates: () {},
        onOnSet: _openOnSet,
        onCreate: _showNewProject,
        onArchive: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SettingsScreen(
              store: widget.store,
              initiallyShowArchived: true,
            ),
          ),
        ),
        onKit: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SettingsScreen(store: widget.store),
          ),
        ),
      ),
    );
  }

  Future<void> _openOnSet() async {
    final choices = <({Project project, Scene scene})>[];
    for (final project in widget.store.activeProjects) {
      for (final scene in project.scenes) {
        if (scene.shots.isNotEmpty) {
          choices.add((project: project, scene: scene));
        }
      }
    }
    if (choices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one shot before entering On-set mode.'),
        ),
      );
      return;
    }

    var selected = choices.first;
    if (choices.length > 1) {
      final result =
          await showModalBottomSheet<({Project project, Scene scene})>(
        context: context,
        builder: (context) => SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            children: [
              const SectionLabel('Choose an on-set slate'),
              ...choices.map(
                (choice) => Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.radio_button_checked_rounded,
                      color: ShotKitColors.record,
                    ),
                    title: Text(choice.scene.title),
                    subtitle: Text(
                      '${choice.project.title} · ${choice.scene.shots.length} shots',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.pop(context, choice),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      if (result == null) return;
      selected = result;
    }
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OnSetScreen(
          store: widget.store,
          project: selected.project,
          scene: selected.scene,
        ),
      ),
    );
  }

  Future<void> _showNewProject() async {
    if (!widget.store.canCreateProject) {
      await showProUpsell(
        context,
        widget.store,
        reason:
            'The free kit includes one active project. Unlock Pro for unlimited productions.',
      );
      return;
    }
    final titleController = TextEditingController();
    String template = widget.store.isPro ? 'Wedding' : 'Blank';
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            10,
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
                'Slate a new project',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 5),
              const Text(
                'Pick a starting rig. Everything stays editable.',
                style: TextStyle(color: ShotKitColors.dim),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: titleController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Project title',
                  hintText: 'e.g. Nabila & Arif Wedding',
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'STARTING TEMPLATE',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'Wedding',
                  'Interview',
                  'Music video',
                  'Short film',
                  'Blank'
                ].map((
                  item,
                ) {
                  final selected = template == item;
                  final locked = !widget.store.isPro && item != 'Blank';
                  return ChoiceChip(
                    avatar: locked
                        ? const Icon(Icons.lock_outline, size: 15)
                        : null,
                    label: Text(item),
                    selected: selected,
                    onSelected: (_) {
                      if (locked) {
                        showProUpsell(context, widget.store,
                            reason:
                                'Production templates are included with ShotKit Pro.');
                        return;
                      }
                      setSheetState(() => template = item);
                    },
                    selectedColor: ShotKitColors.tape,
                    labelStyle: TextStyle(
                      color: selected
                          ? ShotKitColors.tapeInk
                          : ShotKitColors.paper,
                      fontWeight: FontWeight.w700,
                    ),
                    side: BorderSide(
                      color: selected ? ShotKitColors.tape : ShotKitColors.line,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;
                    widget.store.addProject(title, template);
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text('CREATE PROJECT'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    titleController.dispose();
  }
}

class _SetStatusCard extends StatelessWidget {
  const _SetStatusCard({required this.projects});
  final List<Project> projects;

  @override
  Widget build(BuildContext context) {
    final totalShots = projects.fold(
      0,
      (sum, project) => sum + project.shotCount,
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ShotKitColors.raised,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ShotKitColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ShotKitColors.tape.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.camera_roll_outlined,
              color: ShotKitColors.tape,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'READY FOR THE NEXT CALL',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalShots shots packed locally · no signal required',
                  style: const TextStyle(
                    color: ShotKitColors.dim,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project, required this.onTap});
  final Project project;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ShotKitColors.tape,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${project.id.toString().padLeft(2, '0')}A',
                      style: const TextStyle(
                        color: ShotKitColors.tapeInk,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${project.type} · ${project.scenes.length} SCENES · ${project.shotCount} SHOTS',
                          style: const TextStyle(
                            color: ShotKitColors.dim,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: .5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: ShotKitColors.dim,
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: FilmProgress(value: project.progress)),
                  const SizedBox(width: 12),
                  Text(
                    '${project.completed}/${project.shotCount}',
                    style: const TextStyle(
                      color: ShotKitColors.dim,
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Text(
                'Updated ${project.updatedLabel}',
                style: const TextStyle(color: ShotKitColors.dim, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
