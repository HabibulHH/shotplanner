import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// True when the system asks apps to skip animations. Every helper here
/// jumps straight to its end state in that case.
bool motionReduced(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context);

/// Fades and slides its child up the first time it is built, so sections
/// appear one after another and lazily built list items appear as they
/// scroll into view. [index] staggers siblings; [delay] adds extra lead time.
class Reveal extends StatefulWidget {
  const Reveal({
    super.key,
    required this.child,
    this.index = 0,
    this.delay = Duration.zero,
    this.offset = 26,
    this.duration = const Duration(milliseconds: 560),
  });

  final Widget child;
  final int index;
  final Duration delay;
  final double offset;
  final Duration duration;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _t;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    final lead =
        widget.delay + Duration(milliseconds: 70 * math.min(widget.index, 9));
    final total = lead + widget.duration;
    _controller = AnimationController(vsync: this, duration: total);
    _t = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        lead.inMilliseconds / total.inMilliseconds,
        1,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (motionReduced(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _t.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, (1 - _t.value) * widget.offset),
          child: child,
        ),
      ),
    );
  }
}

/// A whole number that counts up from zero, and from its old value when it
/// changes later.
class CountUp extends StatefulWidget {
  const CountUp({
    super.key,
    required this.value,
    this.style,
    this.suffix = '',
    this.suffixStyle,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 1000),
  });

  final int value;
  final TextStyle? style;
  final String suffix;

  /// Style for [suffix], e.g. a smaller "%". Defaults to [style].
  final TextStyle? suffixStyle;
  final Duration delay;
  final Duration duration;

  @override
  State<CountUp> createState() => _CountUpState();
}

class _CountUpState extends State<CountUp> {
  Timer? _timer;
  bool _started = false;
  bool _released = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (widget.delay == Duration.zero || motionReduced(context)) {
      _released = true;
    } else {
      _timer = Timer(widget.delay, () {
        if (mounted) setState(() => _released = true);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final target = _released ? widget.value.toDouble() : 0.0;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: target),
      duration: motionReduced(context) ? Duration.zero : widget.duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => Text.rich(
        TextSpan(
          text: '${value.round()}',
          children: [
            if (widget.suffix.isNotEmpty)
              TextSpan(text: widget.suffix, style: widget.suffixStyle),
          ],
        ),
        maxLines: 1,
        style: widget.style,
      ),
    );
  }
}

/// A circular progress ring that sweeps to [value] when it first appears.
class RingProgress extends StatelessWidget {
  const RingProgress({
    super.key,
    required this.value,
    this.size = 92,
    this.stroke = 8,
    this.child,
  });

  final double value;
  final double size;
  final double stroke;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: clamped),
      duration: motionReduced(context)
          ? Duration.zero
          : const Duration(milliseconds: 1300),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _RingPainter(
            value: v,
            stroke: stroke,
            color: clamped >= 1 ? ShotKitColors.success : ShotKitColors.tape,
          ),
          child: Center(child: child),
        ),
      ),
      child: child,
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.value,
    required this.stroke,
    required this.color,
  });
  final double value;
  final double stroke;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final arc = rect.deflate(stroke / 2);
    final radius = arc.width / 2;
    final center = arc.center;
    canvas.drawArc(
      arc,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = const Color(0x17FFFFFF),
    );
    if (value <= 0) {
      // A small start mark so an untouched ring still reads as a ring.
      canvas.drawLine(
        center + Offset(0, -radius - stroke * .55),
        center + Offset(0, -radius + stroke * .55),
        Paint()
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..color = color.withValues(alpha: .7),
      );
      return;
    }
    final sweep = math.pi * 2 * value;
    // Soft glow under the arc, then the arc itself.
    canvas.drawArc(
      arc,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color.withValues(alpha: .45)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, stroke * .9),
    );
    canvas.drawArc(
      arc,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: -math.pi / 2 + sweep,
          colors: [color.withValues(alpha: .55), color],
          transform: const GradientRotation(-math.pi / 2),
        ).createShader(arc),
    );
    if (value < 1) {
      final head = center +
          Offset(math.cos(-math.pi / 2 + sweep),
                  math.sin(-math.pi / 2 + sweep)) *
              radius;
      canvas.drawCircle(
          head, stroke * .28, Paint()..color = ShotKitColors.paper);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.value != value || old.color != color || old.stroke != stroke;
}

/// Squeezes its child slightly while a finger is down. It only listens to the
/// pointer, so the child's own tap handling is untouched.
class PressScale extends StatefulWidget {
  const PressScale({super.key, required this.child, this.scale = .97});
  final Widget child;
  final double scale;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _down = false;

  void _set(bool down) {
    if (_down != down) setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// A red "recording" dot that breathes for a while, then holds still so it
/// never keeps the screen redrawing forever.
class PulseDot extends StatefulWidget {
  const PulseDot({super.key, this.size = 8, this.color = ShotKitColors.record});
  final double size;
  final Color color;

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (!motionReduced(context)) {
      _controller.repeat(reverse: true, count: 16);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_controller.value);
        return SizedBox.square(
          dimension: widget.size * 2.2,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: widget.size * (1 + t * 1.2),
                height: widget.size * (1 + t * 1.2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(alpha: .35 * (1 - t)),
                ),
              ),
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
