import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/shot_code.dart';
import '../../core/widgets/framing_glyph.dart';
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
  bool _reordering = false;

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
    final scenes = project.scenes;
    final mustLeft = scenes
        .expand((scene) => scene.shots)
        .where((shot) => shot.mustHave && !shot.isDone)
        .length;
    final sceneWord = scenes.length == 1 ? 'scene' : 'scenes';

    return Scaffold(
      body: Column(
        children: [
          TopBar(
            actions: [
              CircleIconButton(
                icon: Icons.ios_share_rounded,
                tooltip: 'Export PDF',
                onPressed: _openExport,
              ),
              MenuAnchor(
                menuChildren: [
                  MenuItemButton(
                    leadingIcon: const Icon(Icons.picture_as_pdf_outlined),
                    onPressed: _openExport,
                    child: const Text('Export production PDF'),
                  ),
                  MenuItemButton(
                    leadingIcon: const Icon(Icons.archive_outlined),
                    onPressed: () async {
                      await widget.store.archiveProject(project);
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Text('Archive project'),
                  ),
                ],
                builder: (context, controller, _) => CircleIconButton(
                  icon: Icons.more_vert_rounded,
                  tooltip: 'More options',
                  onPressed: () => controller.isOpen
                      ? controller.close()
                      : controller.open(),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 40),
              children: [
                TitleBlock(
                  eyebrow: '${project.type} · ${scenes.length} $sceneWord',
                  title: project.title,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: StatStrip(
                    stats: [
                      (
                        '${project.completed}/${project.shotCount}',
                        'Shots done'
                      ),
                      ('$mustLeft', 'Must left'),
                      ('${scenes.length}', sceneWord),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: ActionPair(
                    primary: FilledButton.icon(
                      onPressed: _openOnSet,
                      icon: const Icon(
                        Icons.radio_button_checked_rounded,
                        size: 20,
                      ),
                      label: const Text('Start on-set'),
                    ),
                    secondary: OutlinedButton.icon(
                      onPressed: _openExport,
                      icon: const Icon(
                        Icons.picture_as_pdf_outlined,
                        size: 18,
                      ),
                      label: const Text('PDF'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
                  child: SectionLabel(
                    '${scenes.length} $sceneWord',
                    trailing: scenes.length > 1
                        ? TextButton(
                            onPressed: () =>
                                setState(() => _reordering = !_reordering),
                            child: Text(_reordering ? 'Done' : 'Reorder'),
                          )
                        : null,
                  ),
                ),
                if (scenes.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: EmptySlate(
                      title: 'Your slate is empty',
                      body:
                          'Add the first scene, then build its shot list in shooting order.',
                      action: FilledButton.icon(
                        onPressed: _showAddScene,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add scene'),
                      ),
                    ),
                  )
                else ...[
                  if (_reordering)
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      buildDefaultDragHandles: false,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: scenes.length,
                      onReorderItem: (from, to) =>
                          widget.store.moveScene(project, from, to),
                      itemBuilder: (context, index) => Padding(
                        key: ValueKey(scenes[index].id),
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _SceneCard(
                          index: index,
                          scene: scenes[index],
                          store: widget.store,
                          reordering: true,
                          onTap: () {},
                          onActions: () => _sceneActions(scenes[index]),
                        ),
                      ),
                    )
                  else
                    for (var index = 0; index < scenes.length; index++)
                      Padding(
                        key: ValueKey(scenes[index].id),
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: _SceneCard(
                          index: index,
                          scene: scenes[index],
                          store: widget.store,
                          reordering: false,
                          onTap: () => _openScene(scenes[index]),
                          onActions: () => _sceneActions(scenes[index]),
                        ),
                      ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: DashedAddButton(
                      label: 'Add scene',
                      onTap: _showAddScene,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openScene(Scene scene) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SceneScreen(
            store: widget.store,
            project: widget.project,
            scene: scene,
          ),
        ),
      );

  void _openExport() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ExportScreen(store: widget.store, project: widget.project),
        ),
      );

  void _openOnSet() {
    final scenes = widget.project.scenes;
    final scene = scenes.cast<Scene?>().firstWhere(
              (scene) => scene!.shots.any((shot) => !shot.isDone),
              orElse: () => null,
            ) ??
        scenes.cast<Scene?>().firstWhere(
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

  Future<void> _sceneActions(Scene scene) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SheetHandle(),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.copy_rounded),
                title: const Text('Duplicate scene'),
                onTap: () => Navigator.pop(context, 'duplicate'),
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: ShotKitColors.record,
                ),
                title: const Text(
                  'Delete scene',
                  style: TextStyle(color: ShotKitColors.record),
                ),
                onTap: () => Navigator.pop(context, 'delete'),
              ),
            ],
          ),
        ),
      ),
    );
    if (action == 'duplicate') {
      await widget.store.duplicateScene(widget.project, scene);
    } else if (action == 'delete') {
      await _confirmDeleteScene(scene);
    }
  }

  Future<void> _showAddScene() async {
    final title = TextEditingController();
    final location = TextEditingController();
    var tag = TimeOfDayTag.day;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          void add() {
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
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => add(),
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    hintText: 'Set or venue',
                  ),
                ),
                const SizedBox(height: 16),
                const Text('TIME OF DAY', style: ShotKitText.label),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final item in TimeOfDayTag.values)
                      ChoiceChip(
                        avatar: Icon(
                          timeOfDayIcon(item),
                          size: 16,
                          color: tag == item
                              ? ShotKitColors.tapeInk
                              : ShotKitColors.tape,
                        ),
                        label: Text(timeOfDayName(item)),
                        selected: tag == item,
                        showCheckmark: false,
                        onSelected: (_) => setSheetState(() => tag = item),
                        selectedColor: ShotKitColors.tape,
                        backgroundColor: ShotKitColors.surface,
                        side: BorderSide(
                          color: tag == item
                              ? ShotKitColors.tape
                              : ShotKitColors.line,
                        ),
                        labelStyle: TextStyle(
                          color: tag == item
                              ? ShotKitColors.tapeInk
                              : ShotKitColors.paper,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: add,
                    child: const Text('Add scene'),
                  ),
                ),
              ],
            ),
          );
        },
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
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: ShotKitColors.record,
              foregroundColor: ShotKitColors.tapeInk,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.store.deleteScene(widget.project, scene);
    }
  }
}

class _SceneCard extends StatelessWidget {
  const _SceneCard({
    required this.index,
    required this.scene,
    required this.store,
    required this.reordering,
    required this.onTap,
    required this.onActions,
  });
  final int index;
  final Scene scene;
  final ShotKitStore store;
  final bool reordering;
  final VoidCallback onTap;
  final VoidCallback onActions;

  @override
  Widget build(BuildContext context) {
    final golden = scene.timeOfDay == TimeOfDayTag.golden;
    return Material(
      color: ShotKitColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: ShotKitColors.line),
      ),
      child: InkWell(
        onTap: reordering ? null : onTap,
        onLongPress: reordering ? null : onActions,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          sceneCode(index),
                          style: ShotKitText.mono(
                            size: 12,
                            weight: FontWeight.w700,
                            color: ShotKitColors.tape,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            scene.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${scene.completed}/${scene.shots.length}',
                          style: ShotKitText.mono(size: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    MetaRow(
                      items: [
                        MetaItem(
                          icon: Icons.place_outlined,
                          text: scene.location,
                        ),
                        MetaItem(
                          icon: timeOfDayIcon(scene.timeOfDay),
                          text: timeOfDayName(scene.timeOfDay),
                          color:
                              golden ? ShotKitColors.tape : ShotKitColors.dim,
                        ),
                      ],
                    ),
                    if (scene.shots.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _Filmstrip(shots: scene.shots, store: store),
                    ],
                    const SizedBox(height: 10),
                    FilmProgress(
                      value: scene.progress,
                      color: ShotKitColors.success,
                    ),
                  ],
                ),
              ),
              if (reordering) ...[
                const SizedBox(width: 4),
                IconButton(
                  onPressed: onActions,
                  tooltip: 'Scene actions',
                  icon: const Icon(Icons.more_vert_rounded),
                  color: ShotKitColors.dim,
                ),
                ReorderableDragStartListener(
                  index: index,
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.drag_indicator_rounded,
                      color: ShotKitColors.dim,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A row of shot thumbnails that fits the card width, ending in "+n".
class _Filmstrip extends StatelessWidget {
  const _Filmstrip({required this.shots, required this.store});
  final List<Shot> shots;
  final ShotKitStore store;

  static const _width = 42.0;
  static const _height = 25.0;
  static const _gap = 5.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fits = ((constraints.maxWidth + _gap) / (_width + _gap)).floor();
        final overflow = shots.length > fits;
        final visible = overflow ? fits - 1 : shots.length;
        return Row(
          children: [
            for (var i = 0; i < visible; i++) ...[
              if (i > 0) const SizedBox(width: _gap),
              Opacity(
                opacity: shots[i].isDone ? .45 : 1,
                child: ShotThumb(
                  shot: shots[i],
                  media: store.media,
                  width: _width,
                  height: _height,
                  radius: 5,
                ),
              ),
            ],
            if (overflow) ...[
              const SizedBox(width: _gap),
              Container(
                width: _width,
                height: _height,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ShotKitColors.raised,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '+${shots.length - visible}',
                  style: ShotKitText.mono(size: 10, weight: FontWeight.w700),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
