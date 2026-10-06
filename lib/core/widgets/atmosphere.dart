import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show PointMode;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'motion.dart';

/// Static film grain laid over a surface. It is painted once per size into
/// its own layer, so it costs nothing while the content underneath scrolls.
class FilmGrain extends StatelessWidget {
  const FilmGrain({super.key, this.density = .055, this.strength = 1});

  /// Specks per square logical pixel.
  final double density;

  /// Multiplies every speck's opacity.
  final double strength;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _GrainPainter(density: density, strength: strength),
        ),
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  const _GrainPainter({required this.density, required this.strength});
  final double density;
  final double strength;

  // (is light, opacity) per bucket. Light specks carry the grain on dark
  // ground; the few dark ones add tooth on lighter cards.
  static const _buckets = [
    (true, .022),
    (true, .035),
    (true, .05),
    (false, .05),
    (false, .08),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final count = math.min((size.width * size.height * density).round(), 30000);
    final perBucket = count ~/ _buckets.length;
    final rng = math.Random(1337);
    for (final (light, alpha) in _buckets) {
      final points = Float32List(perBucket * 2);
      for (var i = 0; i < points.length; i += 2) {
        points[i] = rng.nextDouble() * size.width;
        points[i + 1] = rng.nextDouble() * size.height;
      }
      canvas.drawRawPoints(
        PointMode.points,
        points,
        Paint()
          ..strokeWidth = .7
          ..color = (light ? Colors.white : Colors.black)
              .withValues(alpha: alpha * strength),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GrainPainter old) =>
      old.density != density || old.strength != strength;
}

/// A few motes of dust drifting slowly upward, like dust caught in a
/// projector beam. Holds still when the system asks for reduced motion.
class DustField extends StatefulWidget {
  const DustField({
    super.key,
    this.count = 14,
    this.color = ShotKitColors.paper,
    this.seed = 7,
  });

  final int count;
  final Color color;
  final int seed;

  @override
  State<DustField> createState() => _DustFieldState();
}

class _Mote {
  _Mote(math.Random rng)
      : x = rng.nextDouble(),
        y = rng.nextDouble(),
        radius = .5 + rng.nextDouble() * 1.4,
        rise = 1 + rng.nextInt(2),
        sway = 4 + rng.nextDouble() * 12,
        swayTurns = 1 + rng.nextInt(3),
        phase = rng.nextDouble(),
        alpha = .18 + rng.nextDouble() * .4,
        soft = rng.nextDouble() < .35;

  final double x;
  final double y;
  final double radius;
  // Whole numbers of loops per period, so the animation repeats seamlessly.
  final int rise;
  final double sway;
  final int swayTurns;
  final double phase;
  final double alpha;
  // Out-of-focus motes are bigger and blurred.
  final bool soft;
}

class _DustFieldState extends State<DustField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 36),
  );
  late final List<_Mote> _motes;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    final rng = math.Random(widget.seed);
    _motes = List.generate(widget.count, (_) => _Mote(rng));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (!motionReduced(context)) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _DustPainter(_motes, _controller, widget.color),
        ),
      ),
    );
  }
}

class _DustPainter extends CustomPainter {
  _DustPainter(this.motes, this.time, this.color) : super(repaint: time);
  final List<_Mote> motes;
  final Animation<double> time;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final t = time.value;
    for (final m in motes) {
      final y = (m.y - t * m.rise * .5 + m.phase) % 1;
      final x = m.x * size.width +
          math.sin((t * m.swayTurns + m.phase) * math.pi * 2) * m.sway;
      // Fade in at the bottom and out at the top, and twinkle a little.
      final edge = (math.min(y, 1 - y) / .18).clamp(0.0, 1.0);
      final twinkle =
          .65 + .35 * math.sin((t * 3 + m.phase) * math.pi * 2 * m.rise);
      final r = m.soft ? m.radius * 2.2 : m.radius;
      canvas.drawCircle(
        Offset(x, y * size.height),
        r,
        Paint()
          ..color = color.withValues(
            alpha: m.alpha * edge * twinkle * (m.soft ? .45 : 1),
          )
          ..maskFilter =
              m.soft ? MaskFilter.blur(BlurStyle.normal, r * .9) : null,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DustPainter old) =>
      old.motes != motes || old.color != color;
}
