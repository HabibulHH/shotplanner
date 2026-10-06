import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/framing_glyph.dart';
import '../../core/widgets/shotkit_widgets.dart';
import '../../data/models.dart';
import '../../data/shotkit_store.dart';
import '../onset/onset_launcher.dart';
import '../settings/settings_screen.dart';
import 'new_project_sheet.dart';
import 'project_row.dart';
import 'project_screen.dart';

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
                            ? ProjectRow(
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
                                child: ProjectRow(
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
                      itemCount: kProjectTemplates.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) => TemplateChip(
                        label: kProjectTemplates[index],
                        onTap: () =>
                            _showNewProject(template: kProjectTemplates[index]),
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
        onHome: () => Navigator.of(context).popUntil((route) => route.isFirst),
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

  void _openOnSetFor(Project project) =>
      openOnSetForProject(context, widget.store, project);

  Future<void> _openOnSet() => openOnSetPicker(context, widget.store);

  Future<void> _showNewProject({String template = 'Wedding'}) async {
    final created =
        await showNewProjectSheet(context, widget.store, template: template);
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
