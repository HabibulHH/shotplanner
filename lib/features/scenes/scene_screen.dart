import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/shot_options.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/shot_code.dart';
import '../../core/widgets/framing_glyph.dart';
import '../../core/widgets/shotkit_widgets.dart';
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
  final _quickAdd = TextEditingController();
  final _quickAddFocus = FocusNode();
  bool _reordering = false;

  @override
  void initState() {
    super.initState();
    widget.store.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.store.removeListener(_refresh);
    _quickAdd.dispose();
    _quickAddFocus.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final scene = widget.scene;
    final sceneIndex = widget.project.scenes.indexOf(scene);
    final shots = scene.shots;
    final next = shots.cast<Shot?>().firstWhere(
          (shot) => !shot!.isDone,
          orElse: () => null,
        );
    final mustLeft =
        shots.where((shot) => shot.mustHave && !shot.isDone).length;

    return Scaffold(
      body: Column(
        children: [
          TopBar(
            actions: [
              CircleIconButton(
                icon: Icons.radio_button_checked_rounded,
                tooltip: 'On-set mode',
                color: ShotKitColors.record,
                onPressed: shots.isEmpty ? null : _openOnSet,
              ),
            ],
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: TitleBlock(
                    eyebrow:
                        '${sceneCode(sceneIndex)} · ${scene.timeOfDay.label}',
                    title: scene.title,
                    meta: MetaRow(
                      items: [
                        MetaItem(
                          icon: Icons.place_outlined,
                          text: scene.location,
                        ),
                        MetaItem(
                          icon: Icons.view_agenda_outlined,
                          text:
                              '${shots.length} ${shots.length == 1 ? 'shot' : 'shots'}',
                        ),
                      ],
                    ),
                  ),
                ),
                if (shots.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Expanded(
                                child: Text(
                                  scene.progress == 1
                                      ? 'Scene wrapped'
                                      : '${scene.completed} of ${shots.length} done',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                mustLeft == 0
                                    ? 'ALL MUST-HAVES IN'
                                    : '$mustLeft MUST-HAVE${mustLeft == 1 ? '' : 'S'} LEFT',
                                style: ShotKitText.mono(
                                  weight: FontWeight.w700,
                                  spacing: .8,
                                  color: mustLeft == 0
                                      ? ShotKitColors.success
                                      : ShotKitColors.tape,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ShotProgressBar(shots: shots, next: next),
                        ],
                      ),
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 2),
                  sliver: SliverToBoxAdapter(
                    child: SectionLabel(
                      'Shot list',
                      trailing: shots.length > 1
                          ? TextButton(
                              onPressed: () =>
                                  setState(() => _reordering = !_reordering),
                              child: Text(_reordering ? 'Done' : 'Reorder'),
                            )
                          : null,
                    ),
                  ),
                ),
                if (shots.isEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(
                      child: EmptySlate(
                        title: 'No shots on this slate',
                        body:
                            'Type a quick description below, or open the shot builder for framing, angle and movement.',
                        action: FilledButton.icon(
                          onPressed: () => _addShot(),
                          icon: const Icon(Icons.tune_rounded),
                          label: const Text('Open shot builder'),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    sliver: SliverReorderableList(
                      itemCount: shots.length,
                      onReorderItem: (from, to) =>
                          widget.store.moveShot(scene, from, to),
                      itemBuilder: (context, index) {
                        final shot = shots[index];
                        return Padding(
                          key: ValueKey(shot.id),
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ShotRow(
                            index: index,
                            code: shotCode(sceneIndex, index),
                            shot: shot,
                            isNext: identical(shot, next),
                            store: widget.store,
                            reordering: _reordering,
                            onToggle: () {
                              HapticFeedback.selectionClick();
                              widget.store
                                  .toggleShot(widget.project, scene, shot);
                            },
                            onEdit: () => _editShot(shot),
                            onDuplicate: () => widget.store
                                .duplicateShot(widget.project, scene, shot),
                            onDelete: () => _deleteShot(shot),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          _QuickAddBar(
            controller: _quickAdd,
            focusNode: _quickAddFocus,
            onAdd: _submitQuickAdd,
            onOpenBuilder: () => _addShot(initialDescription: _quickAdd.text),
          ),
        ],
      ),
    );
  }

  Future<void> _submitQuickAdd() async {
    final text = _quickAdd.text.trim();
    if (text.isEmpty) {
      await _addShot();
      return;
    }
    final scene = widget.scene;
    final shot = Shot(
      id: widget.store.nextId(),
      description: text,
      size: ShotOptions.quickSize,
      angle: ShotOptions.quickAngle,
      movement: ShotOptions.quickMovement,
      lens: ShotOptions.quickLens,
    );
    _quickAdd.clear();
    await widget.store.addShot(widget.project, scene, shot);
    if (!mounted) return;
    final code = shotCode(
      widget.project.scenes.indexOf(scene),
      scene.shots.indexOf(shot),
    );
    _snack(
      'Added $code · ${ShotOptions.quickSize}, ${ShotOptions.quickLens}',
      action: SnackBarAction(label: 'Edit', onPressed: () => _editShot(shot)),
    );
  }

  Future<void> _addShot({String? initialDescription}) async {
    var description = initialDescription?.trim();
    var addAnother = true;
    while (addAnother) {
      if (!mounted) return;
      final draft = await showShotEditor(
        context,
        widget.scene,
        widget.store.media,
        initialDescription:
            description == null || description.isEmpty ? null : description,
      );
      if (draft == null) return;
      if (description != null) _quickAdd.clear();
      description = null;
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
        ),
      );
      addAnother = draft.addAnother;
    }
  }

  Future<void> _editShot(Shot shot) async {
    final draft = await showShotEditor(
      context,
      widget.scene,
      widget.store.media,
      existing: shot,
    );
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

  Future<void> _deleteShot(Shot shot) async {
    await widget.store.deleteShot(widget.project, widget.scene, shot);
    if (!mounted) return;
    _snack('Deleted “${shot.description}”');
  }

  void _snack(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: action,
          persist: false,
          // Sit above the quick-add bar instead of covering it.
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 86),
        ),
      );
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

/// A shot card that slides left to reveal Duplicate and Delete.
class _ShotRow extends StatefulWidget {
  const _ShotRow({
    required this.index,
    required this.code,
    required this.shot,
    required this.isNext,
    required this.store,
    required this.reordering,
    required this.onToggle,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
  });
  final int index;
  final String code;
  final Shot shot;
  final bool isNext;
  final ShotKitStore store;
  final bool reordering;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  State<_ShotRow> createState() => _ShotRowState();
}

class _ShotRowState extends State<_ShotRow>
    with SingleTickerProviderStateMixin {
  static const _actionWidth = 72.0;
  static const _revealWidth = _actionWidth * 2;

  late final AnimationController _reveal = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
  );

  @override
  void didUpdateWidget(covariant _ShotRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reordering && _reveal.value > 0) _reveal.reverse();
  }

  @override
  void dispose() {
    _reveal.dispose();
    super.dispose();
  }

  void _dragUpdate(DragUpdateDetails details) {
    _reveal.value -= (details.primaryDelta ?? 0) / _revealWidth;
  }

  void _dragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final open =
        velocity < -300 || (velocity.abs() <= 300 && _reveal.value > .5);
    open ? _reveal.forward() : _reveal.reverse();
  }

  void _run(VoidCallback action) {
    _reveal.reverse();
    action();
  }

  @override
  Widget build(BuildContext context) {
    final shot = widget.shot;
    final card = _card(context, shot);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _reveal,
              builder: (context, child) =>
                  _reveal.value == 0 ? const SizedBox.shrink() : child!,
              child: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SwipeAction(
                      icon: Icons.copy_rounded,
                      label: 'Duplicate',
                      background: ShotKitColors.line,
                      foreground: ShotKitColors.paper,
                      onTap: () => _run(widget.onDuplicate),
                    ),
                    _SwipeAction(
                      icon: Icons.delete_outline_rounded,
                      label: 'Delete',
                      background: ShotKitColors.record,
                      foreground: ShotKitColors.tapeInk,
                      onTap: () => _run(widget.onDelete),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _reveal,
            builder: (context, child) => Transform.translate(
              offset: Offset(-_reveal.value * _revealWidth, 0),
              child: child,
            ),
            child: GestureDetector(
              onHorizontalDragUpdate: widget.reordering ? null : _dragUpdate,
              onHorizontalDragEnd: widget.reordering ? null : _dragEnd,
              child: card,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, Shot shot) {
    final tags = <Widget>[
      if (widget.isNext) const ShotTag('Next up', tone: TagTone.accent),
      if (!shot.mustHave) const ShotTag('Optional'),
      if (shot.camera != 'A-Cam') ShotTag(shot.camera, tone: TagTone.cam),
    ];
    return Material(
      color: ShotKitColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: widget.isNext
              ? ShotKitColors.tape.withValues(alpha: .55)
              : ShotKitColors.line,
        ),
      ),
      child: InkWell(
        onTap: widget.reordering
            ? null
            : () => _reveal.value > 0 ? _reveal.reverse() : widget.onEdit(),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Opacity(
                opacity: shot.isDone ? .55 : 1,
                child: Stack(
                  children: [
                    ShotThumb(
                      shot: shot,
                      media: widget.store.media,
                      width: 80,
                      height: 45,
                    ),
                    Positioned(left: 5, top: 5, child: CodeBadge(widget.code)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shot.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                        color: shot.isDone
                            ? ShotKitColors.dim
                            : ShotKitColors.paper,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      shotSpec(shot),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ShotKitText.mono(spacing: .3),
                    ),
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(spacing: 6, runSpacing: 4, children: tags),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (widget.reordering)
                ReorderableDragStartListener(
                  index: widget.index,
                  child: const SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(
                      Icons.drag_indicator_rounded,
                      color: ShotKitColors.dim,
                    ),
                  ),
                )
              else
                CheckButton(done: shot.isDone, onPressed: widget.onToggle),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwipeAction extends StatelessWidget {
  const _SwipeAction({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: _ShotRowState._actionWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: foreground),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  color: foreground,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom bar: type a description and add it with sensible defaults, or open
/// the guided builder for full framing details.
class _QuickAddBar extends StatelessWidget {
  const _QuickAddBar({
    required this.controller,
    required this.focusNode,
    required this.onAdd,
    required this.onOpenBuilder,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onAdd;
  final VoidCallback onOpenBuilder;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: ShotKitColors.ink,
        border: Border(top: BorderSide(color: ShotKitColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {
                    onAdd();
                    focusNode.requestFocus();
                  },
                  decoration: InputDecoration(
                    hintText: 'Describe the next shot…',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    prefixIcon: IconButton(
                      onPressed: onOpenBuilder,
                      tooltip: 'Open the shot builder',
                      icon: const Icon(
                        Icons.tune_rounded,
                        color: ShotKitColors.tape,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: onAdd,
                style: FilledButton.styleFrom(minimumSize: const Size(0, 50)),
                child: const Text('Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
