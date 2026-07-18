import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/shotkit_widgets.dart';
import '../../core/utils/shot_code.dart';
import '../../data/models.dart';
import '../../data/shotkit_store.dart';
import '../onset/onset_screen.dart';
import '../shots/shot_editor_sheet.dart';

class SceneScreen extends StatefulWidget {
  const SceneScreen({
    super.key,
    required this.store,
    required this.project,
    required this.scene,
  });
  final ShotKitStore store;
  final Project project;
  final Scene scene;

  @override
  State<SceneScreen> createState() => _SceneScreenState();
}

class _SceneScreenState extends State<SceneScreen> {
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
    final scene = widget.scene;
    final sceneNumber = widget.project.scenes.indexOf(scene) + 1;
    return Scaffold(
      body: Column(
        children: [
          SlateHeader(
            title: scene.title,
            subtitle:
                'SC ${sceneNumber.toString().padLeft(2, '0')} · ${scene.location}',
            showBack: true,
            trailing: IconButton(
              onPressed: _openOnSet,
              tooltip: 'On-set mode',
              icon: const Icon(
                Icons.radio_button_checked_rounded,
                color: ShotKitColors.record,
              ),
            ),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                  sliver: SliverToBoxAdapter(
                    child: _SceneMeter(scene: scene, onSet: _openOnSet),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: SectionLabel(
                      'Shooting order',
                      trailing: Text(
                        'HOLD & DRAG',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ),
                ),
                if (scene.shots.isEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: EmptySlate(
                        title: 'No shots on this slate',
                        body:
                            'Add the master first, then coverage and inserts.',
                        action: FilledButton.icon(
                          onPressed: _addShot,
                          icon: const Icon(Icons.add),
                          label: const Text('ADD FIRST SHOT'),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
                    sliver: SliverReorderableList(
                      itemCount: scene.shots.length,
                      onReorder: (oldIndex, newIndex) =>
                          widget.store.reorderShots(scene, oldIndex, newIndex),
                      itemBuilder: (context, index) => Padding(
                        key: ValueKey(scene.shots[index].id),
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ShotRow(
                          index: index,
                          sceneIndex: sceneNumber - 1,
                          shot: scene.shots[index],
                          store: widget.store,
                          onToggle: () => widget.store.toggleShot(
                            widget.project,
                            scene,
                            scene.shots[index],
                          ),
                          onEdit: () => _editShot(scene.shots[index]),
                          onDuplicate: () => widget.store.duplicateShot(
                              widget.project, scene, scene.shots[index]),
                          onDelete: () => widget.store.deleteShot(
                              widget.project, scene, scene.shots[index]),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addShot,
        icon: const Icon(Icons.add_rounded),
        label: const Text('ADD SHOT'),
      ),
    );
  }

  Future<void> _addShot() async {
    var addAnother = true;
    while (addAnother && mounted) {
      if (!mounted) return;
      final draft =
          await showShotEditor(context, widget.scene, widget.store.media);
      if (draft == null) return;
      await widget.store.addShot(
          widget.project,
          widget.scene,
          Shot(
            id: widget.store.nextId(),
            description: draft.description,
            size: draft.size,
            angle: draft.angle,
            movement: draft.movement,
            lens: draft.lens,
            camera: draft.camera,
            notes: draft.notes,
            durationSec: draft.durationSec,
            imagePath: draft.imagePath,
            mustHave: draft.mustHave,
          ));
      addAnother = draft.addAnother;
    }
  }

  Future<void> _editShot(Shot shot) async {
    final draft = await showShotEditor(
        context, widget.scene, widget.store.media,
        existing: shot);
    if (draft == null) return;
    shot
      ..description = draft.description
      ..size = draft.size
      ..angle = draft.angle
      ..movement = draft.movement
      ..lens = draft.lens
      ..camera = draft.camera
      ..notes = draft.notes
      ..durationSec = draft.durationSec
      ..imagePath = draft.imagePath
      ..mustHave = draft.mustHave;
    await widget.store.updateShot(widget.project, shot);
  }

  void _openOnSet() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OnSetScreen(
            store: widget.store,
            project: widget.project,
            scene: widget.scene,
          ),
        ),
      );
}

class _SceneMeter extends StatelessWidget {
  const _SceneMeter({required this.scene, required this.onSet});
  final Scene scene;
  final VoidCallback onSet;

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
                      '${scene.completed} OF ${scene.shots.length} DONE',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      scene.progress == 1
                          ? 'Scene wrapped'
                          : '${(scene.progress * 100).round()}% covered',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: onSet,
                icon: const Icon(Icons.fullscreen_rounded),
                label: const Text('ON SET'),
                style: FilledButton.styleFrom(
                  backgroundColor: ShotKitColors.tape.withValues(alpha: .12),
                  foregroundColor: ShotKitColors.tape,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FilmProgress(value: scene.progress, height: 7),
        ],
      ),
    );
  }
}

class _ShotRow extends StatelessWidget {
  const _ShotRow({
    required this.index,
    required this.sceneIndex,
    required this.shot,
    required this.store,
    required this.onToggle,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
  });
  final int index;
  final int sceneIndex;
  final Shot shot;
  final ShotKitStore store;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final code = shotCode(sceneIndex, index);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: shot.isDone ? .5 : 1,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: ShotKitColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ShotKitColors.line),
        ),
        child: Row(
          children: [
            _ShotThumb(shot: shot, store: store),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: ShotKitColors.tape,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          code,
                          style: const TextStyle(
                            color: ShotKitColors.tapeInk,
                            fontFamily: 'monospace',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          shot.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (shot.mustHave)
                        const Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Text(
                            'MUST',
                            style: TextStyle(
                              color: ShotKitColors.record,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: .8,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 5,
                    runSpacing: 4,
                    children: [
                      DataPill(shot.size),
                      DataPill(shot.movement),
                      DataPill(shot.lens),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 7),
            InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(9),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color:
                      shot.isDone ? ShotKitColors.success : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: shot.isDone
                        ? ShotKitColors.success
                        : ShotKitColors.line,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 18,
                  color: shot.isDone
                      ? const Color(0xFF06220F)
                      : Colors.transparent,
                ),
              ),
            ),
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'duplicate') onDuplicate();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit shot')),
                PopupMenuItem(
                    value: 'duplicate', child: Text('Duplicate shot')),
                PopupMenuItem(value: 'delete', child: Text('Delete shot')),
              ],
            ),
            ReorderableDragStartListener(
              index: index,
              child: const Padding(
                padding: EdgeInsets.all(3),
                child: Icon(
                  Icons.drag_indicator_rounded,
                  color: ShotKitColors.dim,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShotThumb extends StatelessWidget {
  const _ShotThumb({required this.shot, required this.store});
  final Shot shot;
  final ShotKitStore store;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: store.media.resolve(shot.imagePath),
      builder: (context, snapshot) {
        final file = snapshot.data;
        return Container(
          width: 62,
          height: 42,
          alignment: Alignment.center,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: ShotKitColors.raised,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: ShotKitColors.line),
          ),
          child: file != null
              ? Image.file(file, width: 62, height: 42, fit: BoxFit.cover)
              : Icon(
                  shot.isDone
                      ? Icons.check_rounded
                      : Icons.photo_size_select_large_outlined,
                  color:
                      shot.isDone ? ShotKitColors.success : ShotKitColors.dim,
                  size: 19,
                ),
        );
      },
    );
  }
}
