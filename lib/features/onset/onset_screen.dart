import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/shotkit_widgets.dart';
import '../../core/utils/shot_code.dart';
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

  @override
  void initState() {
    super.initState();
    _configureWakelock();
    widget.store.addListener(_refresh);
  }

  @override
  void dispose() {
    if (_wakeLockEnabled) WakelockPlus.disable();
    widget.store.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  Future<void> _configureWakelock() async {
    final enabled =
        (await widget.store.database.setting('keepAwake')) != 'false';
    if (enabled) {
      await WakelockPlus.enable();
      _wakeLockEnabled = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.scene;
    final sceneIndex = widget.project.scenes.indexOf(scene);
    Shot? next;
    for (final shot in scene.shots) {
      if (!shot.isDone) {
        next = shot;
        break;
      }
    }
    final nextIndex = next == null ? -1 : scene.shots.indexOf(next);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 14, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: ShotKitColors.surface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const _RecBadge(),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scene.title.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: .5,
                          ),
                        ),
                        Text(
                          '${scene.completed} / ${scene.shots.length} CAPTURED',
                          style: const TextStyle(
                            color: ShotKitColors.dim,
                            fontFamily: 'monospace',
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const OfflinePill(compact: true),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilmProgress(value: scene.progress, height: 4),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _Viewfinder(
                  scene: scene,
                  shot: next,
                  index: nextIndex,
                  sceneIndex: sceneIndex),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 17, 18, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'SHOT QUEUE',
                      style: TextStyle(
                        color: ShotKitColors.dim,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.3,
                      ),
                    ),
                  ),
                  Text(
                    'TAP TO LOG',
                    style: TextStyle(
                      color: ShotKitColors.dim,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                itemCount: scene.shots.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final shot = scene.shots[index];
                  return _OnSetShot(
                    index: index,
                    sceneIndex: sceneIndex,
                    shot: shot,
                    onTap: () =>
                        widget.store.toggleShot(widget.project, scene, shot),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecBadge extends StatelessWidget {
  const _RecBadge();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: ShotKitColors.record.withValues(alpha: .13),
        border: Border.all(color: ShotKitColors.record.withValues(alpha: .5)),
        borderRadius: BorderRadius.circular(7),
      ),
      child: const Row(
        children: [
          CircleAvatar(radius: 3.5, backgroundColor: ShotKitColors.record),
          SizedBox(width: 6),
          Text(
            'ON SET',
            style: TextStyle(
              color: ShotKitColors.record,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: .8,
            ),
          ),
        ],
      ),
    );
  }
}

class _Viewfinder extends StatelessWidget {
  const _Viewfinder({
    required this.scene,
    required this.shot,
    required this.index,
    required this.sceneIndex,
  });
  final Scene scene;
  final Shot? shot;
  final int index;
  final int sceneIndex;

  @override
  Widget build(BuildContext context) {
    final wrapped = shot == null;
    final code = wrapped ? 'WRAP' : shotCode(sceneIndex, index);
    return AspectRatio(
      aspectRatio: 16 / 7.8,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF090A0B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: wrapped ? ShotKitColors.success : ShotKitColors.line,
          ),
        ),
        child: CustomPaint(
          painter: _FramePainter(
            color: wrapped ? ShotKitColors.success : ShotKitColors.dim,
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wrapped ? 'SCENE WRAPPED' : 'NEXT UP · $code',
                  style: TextStyle(
                    color: wrapped ? ShotKitColors.success : ShotKitColors.tape,
                    fontFamily: 'monospace',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .8,
                  ),
                ),
                const Spacer(),
                Text(
                  wrapped ? 'Everything is in the can.' : shot!.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  wrapped
                      ? '${scene.shots.length} shots captured'
                      : '${shot!.size}  ·  ${shot!.angle}  ·  ${shot!.movement}  ·  ${shot!.lens}',
                  style: const TextStyle(
                    color: ShotKitColors.dim,
                    fontFamily: 'monospace',
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FramePainter extends CustomPainter {
  const _FramePainter({required this.color});
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color.withValues(alpha: .42)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    const l = 13.0;
    canvas.drawLine(Offset.zero, const Offset(l, 0), p);
    canvas.drawLine(Offset.zero, const Offset(0, l), p);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - l, 0), p);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, l), p);
    canvas.drawLine(Offset(0, size.height), Offset(l, size.height), p);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - l), p);
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width - l, size.height),
      p,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - l),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant _FramePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _OnSetShot extends StatelessWidget {
  const _OnSetShot({
    required this.index,
    required this.sceneIndex,
    required this.shot,
    required this.onTap,
  });
  final int index;
  final int sceneIndex;
  final Shot shot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: shot.isDone ? const Color(0xFF101A14) : ShotKitColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: shot.isDone
              ? ShotKitColors.success.withValues(alpha: .35)
              : ShotKitColors.line,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Text(
                shotCode(sceneIndex, index),
                style: TextStyle(
                  color:
                      shot.isDone ? ShotKitColors.success : ShotKitColors.tape,
                  fontFamily: 'monospace',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 14),
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
                        fontWeight: FontWeight.w700,
                        decoration:
                            shot.isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${shot.size} · ${shot.movement} · ${shot.lens}',
                      style: const TextStyle(
                        color: ShotKitColors.dim,
                        fontFamily: 'monospace',
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color:
                      shot.isDone ? ShotKitColors.success : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color:
                        shot.isDone ? ShotKitColors.success : ShotKitColors.dim,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: shot.isDone
                      ? const Color(0xFF05220E)
                      : Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
