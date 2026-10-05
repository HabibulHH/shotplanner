import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/shot_code.dart';
import '../../core/widgets/framing_glyph.dart';
import '../../core/widgets/shotkit_widgets.dart';
import '../../data/models.dart';
import '../../data/shotkit_store.dart';
import '../onset/onset_screen.dart';
import '../settings/settings_screen.dart';
import 'project_screen.dart';

const _templates = [
  'Wedding',
  'Interview',
  'Music video',
  'Short film',
  'Blank'
];

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key, required this.store});
  final ShotKitStore store;

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  bool _showArchived = false;

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

  /// The most recently touched project that still has shots to get.
  Project? get _focus {
    for (final project in widget.store.activeProjects) {
      if (project.shotCount > project.completed) return project;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.store.activeProjects;
    final archived = widget.store.archivedProjects;
    final focus = _focus;
    final listed = _showArchived ? archived : active;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HazardStripe(),
            _HomeHeader(
              activeCount: active.length,
              onNew: () => _showNewProject(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
                children: [
                  if (focus != null) ...[
                    _NextUpCard(
                      project: focus,
                      store: widget.store,
                      onSet: () => _openOnSetFor(focus),
                      onOpen: () => _openProject(focus),
                    ),
                    const SizedBox(height: 22),
                  ],
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      Text(
                        'Projects',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontSize: 19),
                      ),
                      if (archived.isNotEmpty || _showArchived)
                        SegmentedPill(
                          labels: [
                            'Active ${active.length}',
                            'Archived ${archived.length}',
                          ],
                          selected: _showArchived ? 1 : 0,
                          onChanged: (index) =>
                              setState(() => _showArchived = index == 1),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (listed.isEmpty)
                    _showArchived
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              'No archived projects.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: ShotKitColors.dim),
                            ),
                          )
                        : EmptySlate(
                            title: 'Slate your first production',
                            body:
                                'Start blank or load a field-tested template. Everything works offline.',
                            action: FilledButton.icon(
                              onPressed: () => _showNewProject(),
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('New project'),
                            ),
                          )
                  else
                    for (final project in listed)
                      Padding(
                        key: ValueKey(project.id),
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _showArchived
                            ? _ProjectRow(
                                project: project,
                                onTap: () => _openProject(project),
                                trailing: TextButton(
                                  onPressed: () =>
                                      widget.store.unarchiveProject(project),
                                  child: const Text('Restore'),
                                ),
                              )
                            : _ArchivableRow(
                                project: project,
                                onArchive: () => _archive(project),
                                child: _ProjectRow(
                                  project: project,
                                  onTap: () => _openProject(project),
                                ),
                              ),
                      ),
                  const SizedBox(height: 10),
                  const SectionLabel('Start from a template'),
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _templates.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) => _TemplateChip(
                        label: _templates[index],
                        onTap: () =>
                            _showNewProject(template: _templates[index]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ShotKitNavBar(
        onProjects: () => setState(() => _showArchived = false),
        onOnSet: _openOnSet,
        onKit: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SettingsScreen(store: widget.store),
          ),
        ),
      ),
    );
  }

  void _openProject(Project project) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProjectScreen(store: widget.store, project: project),
        ),
      );

  Future<void> _archive(Project project) async {
    await widget.store.archiveProject(project);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${project.title} archived'),
          persist: false,
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => widget.store.unarchiveProject(project),
          ),
        ),
      );
  }

  void _openOnSetFor(Project project) {
    final scene = project.scenes.cast<Scene?>().firstWhere(
          (scene) => scene!.shots.any((shot) => !shot.isDone),
          orElse: () => null,
        );
    if (scene == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OnSetScreen(
          store: widget.store,
          project: project,
          scene: scene,
        ),
      ),
    );
  }

  Future<void> _openOnSet() async {
    final choices = <({Project project, Scene scene, int index})>[];
    for (final project in widget.store.activeProjects) {
      for (var i = 0; i < project.scenes.length; i++) {
        if (project.scenes[i].shots.isNotEmpty) {
          choices.add((project: project, scene: project.scenes[i], index: i));
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
      final result = await showModalBottomSheet<
          ({Project project, Scene scene, int index})>(
        context: context,
        isScrollControlled: true,
        builder: (context) => SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * .75,
            ),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              children: [
                const SheetHandle(),
                const SizedBox(height: 14),
                Text(
                  'Go on set',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Pick the scene you are shooting now.',
                  style: TextStyle(color: ShotKitColors.dim),
                ),
                const SizedBox(height: 14),
                for (final choice in choices)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _SceneChoice(
                      code: sceneCode(choice.index),
                      title: choice.scene.title,
                      subtitle: choice.project.title,
                      progress:
                          '${choice.scene.completed}/${choice.scene.shots.length}',
                      onTap: () => Navigator.pop(context, choice),
                    ),
                  ),
              ],
            ),
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

  Future<void> _showNewProject({String template = 'Wedding'}) async {
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
            final project = await widget.store.addProject(title, selected);
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
                    for (final item in _templates)
                      _TemplateChip(
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
    if (created != null && mounted) _openProject(created);
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.activeCount, required this.onNew});
  final int activeCount;
  final VoidCallback onNew;

  static const _days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  static const _months = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', //
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final date =
        '${_days[now.weekday - 1]} ${now.day} ${_months[now.month - 1]}';
    final slates =
        '$activeCount ACTIVE ${activeCount == 1 ? 'SLATE' : 'SLATES'}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // The wordmark never breaks mid-word; it shrinks instead.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'SHOTKIT',
                    maxLines: 1,
                    style: ShotKitText.display(size: 31).copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: .4,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$date · $slates',
                  style: ShotKitText.mono(spacing: 1.2),
                ),
              ],
            ),
          ),
          IconButton.filled(
            onPressed: onNew,
            tooltip: 'New project',
            icon: const Icon(Icons.add_rounded, size: 26),
            style: IconButton.styleFrom(
              fixedSize: const Size.square(48),
              backgroundColor: ShotKitColors.tape,
              foregroundColor: ShotKitColors.tapeInk,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextUpCard extends StatelessWidget {
  const _NextUpCard({
    required this.project,
    required this.store,
    required this.onSet,
    required this.onOpen,
  });
  final Project project;
  final ShotKitStore store;
  final VoidCallback onSet;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final shots = project.scenes.expand((scene) => scene.shots).toList();
    final upcoming = shots.where((shot) => !shot.isDone).take(6).toList();
    final mustLeft =
        shots.where((shot) => shot.mustHave && !shot.isDone).length;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ShotKitColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ShotKitColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'UP NEXT',
                style: ShotKitText.mono(
                  weight: FontWeight.w700,
                  color: ShotKitColors.tape,
                  spacing: 1.4,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: OutlinePill('Updated ${project.updatedLabel}'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.5,
            child: Text(
              project.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: ShotKitText.headline(size: 27),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < 6; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: i < upcoming.length
                        ? ShotThumb(
                            shot: upcoming[i],
                            media: store.media,
                            radius: 6,
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: StatValue(
                  value: '${project.completed}/${project.shotCount}',
                  label: 'Shots done',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatValue(value: '$mustLeft', label: 'Must left'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatValue(
                  value: '${project.scenes.length}',
                  label: project.scenes.length == 1 ? 'Scene' : 'Scenes',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SceneProgressBar(scenes: project.scenes),
          const SizedBox(height: 16),
          ActionPair(
            primary: FilledButton.icon(
              onPressed: onSet,
              icon: const Icon(Icons.radio_button_checked_rounded, size: 20),
              label: const Text('Start on-set'),
            ),
            secondary:
                OutlinedButton(onPressed: onOpen, child: const Text('Open')),
          ),
        ],
      ),
    );
  }
}

class _ProjectRow extends StatelessWidget {
  const _ProjectRow(
      {required this.project, required this.onTap, this.trailing});
  final Project project;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final wrapped =
        project.shotCount > 0 && project.completed == project.shotCount;
    final scenes =
        '${project.scenes.length} ${project.scenes.length == 1 ? 'SCENE' : 'SCENES'}';
    return Material(
      color: ShotKitColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: ShotKitColors.line),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: ShotKitColors.raised,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  projectTypeIcon(project.type),
                  color: ShotKitColors.tape,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Expanded(
                          child: Text(
                            project.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          wrapped
                              ? 'WRAPPED'
                              : '${project.completed}/${project.shotCount}',
                          style: ShotKitText.mono(
                            size: 12,
                            weight: wrapped ? FontWeight.w700 : FontWeight.w500,
                            color: wrapped
                                ? ShotKitColors.success
                                : ShotKitColors.dim,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${project.type} · $scenes · ${project.updatedLabel}'
                          .toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ShotKitText.mono(size: 10.5, spacing: .8),
                    ),
                    const SizedBox(height: 8),
                    FilmProgress(value: project.progress),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 6),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Swipe a project away to archive it.
class _ArchivableRow extends StatelessWidget {
  const _ArchivableRow({
    required this.project,
    required this.onArchive,
    required this.child,
  });
  final Project project;
  final VoidCallback onArchive;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('archive-${project.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onArchive(),
      background: Container(
        padding: const EdgeInsets.only(right: 22),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: ShotKitColors.raised,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.archive_outlined, color: ShotKitColors.tape),
            SizedBox(width: 8),
            Text(
              'Archive',
              style: TextStyle(
                color: ShotKitColors.tape,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      child: child,
    );
  }
}

class _TemplateChip extends StatelessWidget {
  const _TemplateChip({
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

class _SceneChoice extends StatelessWidget {
  const _SceneChoice({
    required this.code,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.onTap,
  });
  final String code;
  final String title;
  final String subtitle;
  final String progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ShotKitColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: ShotKitColors.line),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Text(
                code,
                style: ShotKitText.mono(
                  size: 12,
                  weight: FontWeight.w700,
                  color: ShotKitColors.tape,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: ShotKitColors.dim,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Text(progress, style: ShotKitText.mono(size: 12)),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, color: ShotKitColors.dim),
            ],
          ),
        ),
      ),
    );
  }
}
