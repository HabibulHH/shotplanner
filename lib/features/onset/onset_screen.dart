import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/shot_code.dart';
import '../../core/widgets/framing_glyph.dart';
import '../../core/widgets/shotkit_widgets.dart';
import '../../data/models.dart';
import '../../data/shotkit_store.dart';

class OnSetScreen extends StatefulWidget {
  const OnSetScreen({
    super.key,
    required this.store,
    required this.project,
    required this.scene,
  });
  final ShotKitStore store;
  final Project project;
  final Scene scene;

  @override
  State<OnSetScreen> createState() => _OnSetScreenState();
}

class _OnSetScreenState extends State<OnSetScreen> {
  bool _wakeLockEnabled = false;
  bool _daylight = false;
  bool _showDone = false;

  /// Shots skipped during this session, oldest first. They move to the back
  /// of the queue without being marked done.
  final List<int> _skipped = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
    widget.store.addListener(_refresh);
    // Messages from the planning screens don't belong on set.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ScaffoldMessenger.of(context).hideCurrentSnackBar();
    });
  }

  @override
  void dispose() {
    if (_wakeLockEnabled) WakelockPlus.disable();
    widget.store.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  Future<void> _loadSettings() async {
    final database = widget.store.database;
    final keepAwake = (await database.setting('keepAwake')) != 'false';
    final daylight = (await database.setting('onsetDaylight')) == 'true';
    if (keepAwake) {
      await WakelockPlus.enable();
      _wakeLockEnabled = true;
    }
    if (mounted && daylight != _daylight) setState(() => _daylight = daylight);
  }

  void _toggleDaylight() {
    setState(() => _daylight = !_daylight);
    widget.store.database.setSetting('onsetDaylight', _daylight.toString());
  }

  List<Shot> get _pending =>
      widget.scene.shots.where((shot) => !shot.isDone).toList();

  /// Pending shots in shooting order: untouched ones first, then skipped ones
  /// in the order they were skipped.
  List<Shot> get _queue {
    final pending = _pending;
    final fresh = pending.where((shot) => !_skipped.contains(shot.id));
    final skipped = [
      for (final id in _skipped) ...pending.where((shot) => shot.id == id),
    ];
    return [...fresh, ...skipped];
  }

  Future<void> _done(Shot shot) async {
    HapticFeedback.mediumImpact();
    _skipped.remove(shot.id);
    await widget.store.toggleShot(widget.project, widget.scene, shot);
    if (_pending.isEmpty) await widget.store.reviews.maybeAsk();
  }

  void _skip(Shot shot) {
    HapticFeedback.selectionClick();
    setState(() {
      _skipped
        ..remove(shot.id)
        ..add(shot.id);
    });
  }

  void _toggle(Shot shot) {
    HapticFeedback.selectionClick();
    if (!shot.isDone) _skipped.remove(shot.id);
    widget.store.toggleShot(widget.project, widget.scene, shot);
  }

  @override
  Widget build(BuildContext context) {
    final p = _daylight ? OnSetPalette.daylightPalette : OnSetPalette.dark;
    final scene = widget.scene;
    final sceneIndex = widget.project.scenes.indexOf(scene);
    final queue = _queue;
    final current = queue.isEmpty ? null : queue.first;
    final upNext = queue.skip(1).toList();
    final done = scene.shots.where((shot) => shot.isDone).toList();
    final mustLeft =
        scene.shots.where((shot) => shot.mustHave && !shot.isDone).length;
    String code(Shot shot) => shotCode(sceneIndex, scene.shots.indexOf(shot));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _daylight ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: p.ground,
        body: DefaultTextStyle.merge(
          style: TextStyle(color: p.text),
          child: IconTheme.merge(
            data: IconThemeData(color: p.text),
            child: SafeArea(
              child: Column(
                children: [
                  HazardStripe(color: p.stripe),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        CircleIconButton(
                          icon: Icons.close_rounded,
                          tooltip: 'Close on-set mode',
                          onPressed: () => Navigator.pop(context),
                          color: p.text,
                          background: p.surface,
                          border: p.line,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: p.record,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'ON SET',
                                    style: ShotKitText.mono(
                                      size: 10.5,
                                      weight: FontWeight.w700,
                                      color: p.record,
                                      spacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${sceneCode(sceneIndex)} · ${scene.title}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        CircleIconButton(
                          icon: _daylight
                              ? Icons.dark_mode_outlined
                              : Icons.light_mode_outlined,
                          tooltip: _daylight
                              ? 'Switch to dark mode'
                              : 'Switch to daylight mode',
                          onPressed: _toggleDaylight,
                          color: p.accentText,
                          background: p.surface,
                          border: p.line,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: ShotProgressBar(
                      shots: scene.shots,
                      next: current,
                      done: p.success,
                      current: p.accent,
                      empty: p.line,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 7, 16, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${done.length} / ${scene.shots.length} CAPTURED',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: ShotKitText.mono(
                              size: 10.5,
                              color: p.dim,
                              spacing: .6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          mustLeft == 0
                              ? 'ALL MUST-HAVES IN'
                              : '$mustLeft MUST-HAVE${mustLeft == 1 ? '' : 'S'} LEFT',
                          style: ShotKitText.mono(
                            size: 10.5,
                            color: mustLeft == 0 ? p.success : p.dim,
                            spacing: .6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                      children: [
                        if (current == null)
                          _WrapCard(
                            palette: p,
                            shotCount: scene.shots.length,
                            nextScene: _nextScene(),
                            onNextScene: _goToNextScene,
                            onClose: () => Navigator.pop(context),
                          )
                        else ...[
                          _NextUpCard(
                            palette: p,
                            shot: current,
                            code: code(current),
                            store: widget.store,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              OutlinedButton.icon(
                                onPressed: upNext.isEmpty
                                    ? null
                                    : () => _skip(current),
                                icon: const Icon(Icons.skip_next_rounded),
                                label: const Text('Skip'),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 58),
                                  backgroundColor: p.surface,
                                  foregroundColor: p.text,
                                  disabledBackgroundColor: p.surface,
                                  disabledForegroundColor:
                                      p.dim.withValues(alpha: .5),
                                  side: BorderSide(color: p.line),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () => _done(current),
                                  icon:
                                      const Icon(Icons.check_rounded, size: 24),
                                  label: Text(
                                    upNext.isEmpty
                                        ? 'Done · wrap scene'
                                        : 'Done · next shot',
                                  ),
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size(0, 58),
                                    backgroundColor: p.accent,
                                    foregroundColor: p.onAccent,
                                    textStyle: const TextStyle(
                                      fontFamily: ShotKitFonts.sans,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              upNext.isEmpty ? 'NOTHING QUEUED' : 'UP NEXT',
                              style: ShotKitText.label.copyWith(color: p.dim),
                            ),
                            const Spacer(),
                            if (done.isNotEmpty)
                              TextButton.icon(
                                onPressed: () =>
                                    setState(() => _showDone = !_showDone),
                                iconAlignment: IconAlignment.end,
                                icon: Icon(
                                  _showDone
                                      ? Icons.expand_less_rounded
                                      : Icons.expand_more_rounded,
                                  size: 18,
                                ),
                                label: Text('DONE (${done.length})'),
                                style: TextButton.styleFrom(
                                  foregroundColor: p.dim,
                                  textStyle: ShotKitText.mono(
                                    weight: FontWeight.w700,
                                    spacing: 1,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        for (final shot in upNext)
                          _QueueRow(
                            palette: p,
                            shot: shot,
                            code: code(shot),
                            skipped: _skipped.contains(shot.id),
                            onToggle: () => _toggle(shot),
                          ),
                        if (_showDone)
                          for (final shot in done)
                            _QueueRow(
                              palette: p,
                              shot: shot,
                              code: code(shot),
                              skipped: false,
                              onToggle: () => _toggle(shot),
                            ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ({Scene scene, int index})? _nextScene() {
    final scenes = widget.project.scenes;
    final start = scenes.indexOf(widget.scene);
    for (var i = start + 1; i < scenes.length; i++) {
      if (scenes[i].shots.any((shot) => !shot.isDone)) {
        return (scene: scenes[i], index: i);
      }
    }
    return null;
  }

  void _goToNextScene() {
    final next = _nextScene();
    if (next == null) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OnSetScreen(
          store: widget.store,
          project: widget.project,
          scene: next.scene,
        ),
      ),
    );
  }
}

class _NextUpCard extends StatelessWidget {
  const _NextUpCard({
    required this.palette,
    required this.shot,
    required this.code,
    required this.store,
  });
  final OnSetPalette palette;
  final Shot shot;
  final String code;
  final ShotKitStore store;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final chips = [
      shot.size,
      shot.angle,
      shot.movement,
      if (shot.lens.isNotEmpty) shot.lens,
      shot.camera,
    ];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ShotThumb(
                    shot: shot,
                    media: store.media,
                    radius: 12,
                    background: p.frame,
                    stroke: p.glyph,
                    fill: p.glyphFill,
                    grid: p.grid,
                  ),
                ),
                Positioned.fill(
                  child: CustomPaint(painter: _BracketPainter(p.bracket)),
                ),
                Positioned(
                  left: 34,
                  top: 10,
                  child: _FrameLabel(
                    'NEXT UP · $code',
                    palette: p,
                    color: p.accentText,
                  ),
                ),
                if (shot.lens.isNotEmpty)
                  Positioned(
                    right: 34,
                    bottom: 10,
                    child: _FrameLabel(
                      shot.lens.toUpperCase(),
                      palette: p,
                      color: p.dim,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 12, 4, 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shot.description,
                  style: ShotKitText.headline(color: p.text),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (var i = 0; i < chips.length; i++)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: p.line),
                        ),
                        child: Text(
                          chips[i].toUpperCase(),
                          style: ShotKitText.mono(
                            weight: i == 0 ? FontWeight.w700 : FontWeight.w500,
                            color: p.text,
                          ),
                        ),
                      ),
                    if (!shot.mustHave)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: p.raised,
                        ),
                        child: Text(
                          'OPTIONAL',
                          style: ShotKitText.mono(
                            weight: FontWeight.w700,
                            color: p.dim,
                          ),
                        ),
                      ),
                  ],
                ),
                if (shot.notes.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.sticky_note_2_outlined,
                          size: 16,
                          color: p.dim,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          shot.notes.trim(),
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: p.dim,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FrameLabel extends StatelessWidget {
  const _FrameLabel(this.text, {required this.palette, required this.color});
  final String text;
  final OnSetPalette palette;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: .82),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: ShotKitText.mono(
          weight: FontWeight.w700,
          color: color,
          spacing: 1,
        ),
      ),
    );
  }
}

class _BracketPainter extends CustomPainter {
  const _BracketPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const inset = 10.0;
    const arm = 18.0;
    final corners = [
      (const Offset(inset, inset), 1.0, 1.0),
      (Offset(size.width - inset, inset), -1.0, 1.0),
      (Offset(inset, size.height - inset), 1.0, -1.0),
      (Offset(size.width - inset, size.height - inset), -1.0, -1.0),
    ];
    for (final (point, dx, dy) in corners) {
      canvas
        ..drawLine(point, point.translate(arm * dx, 0), paint)
        ..drawLine(point, point.translate(0, arm * dy), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BracketPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _QueueRow extends StatelessWidget {
  const _QueueRow({
    required this.palette,
    required this.shot,
    required this.code,
    required this.skipped,
    required this.onToggle,
  });
  final OnSetPalette palette;
  final Shot shot;
  final String code;
  final bool skipped;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return InkWell(
      onTap: onToggle,
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: p.line)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              child: Text(
                code,
                style: ShotKitText.mono(
                  size: 13,
                  weight: FontWeight.w700,
                  color: shot.isDone ? p.success : p.accentText,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shot.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: shot.isDone ? p.dim : p.text,
                      decoration:
                          shot.isDone ? TextDecoration.lineThrough : null,
                      decorationColor: p.dim,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    [
                      shotSpec(shot, includeCamera: true),
                      if (skipped) 'SKIPPED',
                      if (!shot.mustHave) 'OPTIONAL',
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ShotKitText.mono(size: 10.5, color: p.dim),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            CheckButton(
              done: shot.isDone,
              onPressed: onToggle,
              doneColor: p.success,
              onDoneColor: p.onSuccess,
              outline: p.line,
            ),
          ],
        ),
      ),
    );
  }
}

class _WrapCard extends StatelessWidget {
  const _WrapCard({
    required this.palette,
    required this.shotCount,
    required this.nextScene,
    required this.onNextScene,
    required this.onClose,
  });
  final OnSetPalette palette;
  final int shotCount;
  final ({Scene scene, int index})? nextScene;
  final VoidCallback onNextScene;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final next = nextScene;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.success.withValues(alpha: .6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.task_alt_rounded, color: p.success, size: 34),
          const SizedBox(height: 12),
          Text(
            'SCENE WRAPPED',
            style: ShotKitText.mono(
              weight: FontWeight.w700,
              color: p.success,
              spacing: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'All $shotCount shots are in the can.',
            style: ShotKitText.headline(color: p.text),
          ),
          const SizedBox(height: 18),
          if (next != null)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onNextScene,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(
                  'Next: ${sceneCode(next.index)} · ${next.scene.title}',
                  overflow: TextOverflow.ellipsis,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: p.accent,
                  foregroundColor: p.onAccent,
                ),
              ),
            ),
          if (next != null) const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onClose,
              style: OutlinedButton.styleFrom(
                backgroundColor: p.raised,
                foregroundColor: p.text,
                side: BorderSide(color: p.line),
              ),
              child: const Text('Back to shot list'),
            ),
          ),
        ],
      ),
    );
  }
}
