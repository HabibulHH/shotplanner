import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/media_service.dart';
import '../../data/models.dart';
import '../theme/app_theme.dart';

/// The silhouette families drawn for a shot size.
enum FramingKind { ecu, cu, ms, ls, wide, insert, two }

FramingKind framingKindFor(String size) => switch (size) {
      'ECU' => FramingKind.ecu,
      'BCU' || 'CU' => FramingKind.cu,
      'MCU' || 'MS' || 'Cowboy' || 'Single' || 'POV' => FramingKind.ms,
      'MLS' || 'FS' || 'LS' => FramingKind.ls,
      'ELS' || 'Establishing' || 'Master' => FramingKind.wide,
      'Two-shot' || 'Three-shot' || 'Group' || 'OTS' => FramingKind.two,
      'Macro' || 'Insert' || 'Cutaway' => FramingKind.insert,
      _ => FramingKind.ms,
    };

/// A small framing drawing used wherever a shot has no reference photo, so
/// every shot list, filmstrip and on-set card stays visual.
class FramingGlyph extends StatelessWidget {
  const FramingGlyph({
    super.key,
    required this.kind,
    this.width,
    this.height,
    this.radius = 8,
    this.background = ShotKitColors.raised,
    this.stroke = ShotKitColors.tape,
    this.fill = const Color(0x24FFB020),
    this.grid = ShotKitColors.grid,
  });

  final FramingKind kind;
  final double? width;
  final double? height;
  final double radius;
  final Color background;
  final Color stroke;
  final Color fill;
  final Color grid;

  @override
  Widget build(BuildContext context) {
    final paint = CustomPaint(
      painter: _FramingPainter(
        kind: kind,
        stroke: stroke,
        fill: fill,
        grid: grid,
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: ColoredBox(
        color: background,
        child: width == null && height == null
            ? SizedBox.expand(child: paint)
            : SizedBox(width: width, height: height, child: paint),
      ),
    );
  }
}

/// Reference photo when the shot has one, otherwise its framing glyph.
class ShotThumb extends StatefulWidget {
  const ShotThumb({
    super.key,
    required this.shot,
    required this.media,
    this.width,
    this.height,
    this.radius = 10,
    this.background = ShotKitColors.raised,
    this.stroke = ShotKitColors.tape,
    this.fill = const Color(0x24FFB020),
    this.grid = ShotKitColors.grid,
  });

  final Shot shot;
  final MediaService media;
  final double? width;
  final double? height;
  final double radius;
  final Color background;
  final Color stroke;
  final Color fill;
  final Color grid;

  @override
  State<ShotThumb> createState() => _ShotThumbState();
}

class _ShotThumbState extends State<ShotThumb> {
  late Future<File?> _file;

  @override
  void initState() {
    super.initState();
    _file = widget.media.resolve(widget.shot.imagePath);
  }

  @override
  void didUpdateWidget(covariant ShotThumb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shot.imagePath != widget.shot.imagePath ||
        oldWidget.media != widget.media) {
      _file = widget.media.resolve(widget.shot.imagePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final glyph = FramingGlyph(
      kind: framingKindFor(widget.shot.size),
      width: widget.width,
      height: widget.height,
      radius: widget.radius,
      background: widget.background,
      stroke: widget.stroke,
      fill: widget.fill,
      grid: widget.grid,
    );
    return FutureBuilder<File?>(
      future: _file,
      builder: (context, snapshot) {
        final file = snapshot.data;
        if (file == null) return glyph;
        final ratio = MediaQuery.devicePixelRatioOf(context);
        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.radius),
          child: Image.file(
            file,
            width: widget.width ?? double.infinity,
            height: widget.height ?? double.infinity,
            fit: BoxFit.cover,
            cacheWidth:
                widget.width == null ? null : (widget.width! * ratio).round(),
            errorBuilder: (_, __, ___) => glyph,
          ),
        );
      },
    );
  }
}

class _FramingPainter extends CustomPainter {
  const _FramingPainter({
    required this.kind,
    required this.stroke,
    required this.fill,
    required this.grid,
  });

  final FramingKind kind;
  final Color stroke;
  final Color fill;
  final Color grid;

  // Drawn in a 160 × 90 (16:9) design space and scaled to cover the box.
  static const _w = 160.0;
  static const _h = 90.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final scale = math.max(size.width / _w, size.height / _h);
    canvas
      ..save()
      ..translate((size.width - _w * scale) / 2, (size.height - _h * scale) / 2)
      ..scale(scale);

    // Keep hairlines visible on tiny thumbnails.
    double weight(double units, double minPx) => math.max(units, minPx / scale);

    final gridPaint = Paint()
      ..color = grid
      ..style = PaintingStyle.stroke
      ..strokeWidth = weight(1, .6);
    for (final x in [_w / 3, _w * 2 / 3]) {
      canvas.drawLine(Offset(x, 0), Offset(x, _h), gridPaint);
    }
    for (final y in [_h / 3, _h * 2 / 3]) {
      canvas.drawLine(Offset(0, y), Offset(_w, y), gridPaint);
    }

    final fillPaint = Paint()..color = fill;
    final line = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = weight(2.2, 1)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final solid = Paint()..color = stroke;

    void shape(Path path) => canvas
      ..drawPath(path, fillPaint)
      ..drawPath(path, line);
    void head(Offset center, double r) => shape(
          Path()..addOval(Rect.fromCircle(center: center, radius: r)),
        );

    switch (kind) {
      case FramingKind.ecu:
        shape(Path()
          ..moveTo(34, 47)
          ..quadraticBezierTo(55, 30, 76, 47)
          ..quadraticBezierTo(55, 62, 34, 47)
          ..close());
        shape(Path()
          ..moveTo(84, 47)
          ..quadraticBezierTo(105, 30, 126, 47)
          ..quadraticBezierTo(105, 62, 84, 47)
          ..close());
        canvas
          ..drawCircle(const Offset(55, 47), 6.5, solid)
          ..drawCircle(const Offset(105, 47), 6.5, solid)
          ..drawPath(
            Path()
              ..moveTo(36, 29)
              ..quadraticBezierTo(55, 19, 74, 27)
              ..moveTo(86, 27)
              ..quadraticBezierTo(105, 19, 124, 29),
            line,
          );
      case FramingKind.cu:
        shape(Path()
          ..moveTo(36, 94)
          ..quadraticBezierTo(40, 72, 66, 68)
          ..lineTo(72, 62)
          ..lineTo(88, 62)
          ..lineTo(94, 68)
          ..quadraticBezierTo(120, 72, 124, 94)
          ..close());
        head(const Offset(80, 40), 22);
      case FramingKind.ms:
        shape(Path()
          ..moveTo(48, 94)
          ..lineTo(51, 60)
          ..quadraticBezierTo(54, 47, 70, 45)
          ..lineTo(74, 40)
          ..lineTo(86, 40)
          ..lineTo(90, 45)
          ..quadraticBezierTo(106, 47, 109, 60)
          ..lineTo(112, 94)
          ..close());
        head(const Offset(80, 27), 12);
      case FramingKind.ls:
        canvas.drawLine(
          const Offset(28, 78),
          const Offset(132, 78),
          Paint()
            ..color = grid
            ..strokeWidth = weight(2.4, 1)
            ..strokeCap = StrokeCap.round,
        );
        head(const Offset(80, 21), 6.5);
        canvas.drawPath(
          Path()
            ..moveTo(80, 28)
            ..lineTo(80, 54)
            ..moveTo(80, 35)
            ..lineTo(69, 48)
            ..moveTo(80, 35)
            ..lineTo(91, 48)
            ..moveTo(80, 54)
            ..lineTo(72, 76)
            ..moveTo(80, 54)
            ..lineTo(88, 76),
          line..strokeWidth = weight(2.4, 1),
        );
      case FramingKind.wide:
        canvas.drawLine(
          const Offset(6, 62),
          const Offset(154, 62),
          Paint()
            ..color = stroke.withValues(alpha: .6)
            ..strokeWidth = weight(2, 1)
            ..strokeCap = StrokeCap.round,
        );
        shape(Path()..addRect(const Rect.fromLTRB(18, 40, 36, 62)));
        shape(Path()..addRect(const Rect.fromLTRB(40, 28, 56, 62)));
        shape(Path()..addRect(const Rect.fromLTRB(60, 46, 72, 62)));
        head(const Offset(124, 26), 8);
        canvas
          ..drawCircle(const Offset(104, 51), 2.6, solid)
          ..drawLine(const Offset(104, 54), const Offset(104, 62), line);
      case FramingKind.insert:
        head(const Offset(70, 52), 15);
        head(const Offset(90, 52), 15);
        shape(Path()
          ..moveTo(66, 33)
          ..lineTo(70, 27)
          ..lineTo(74, 33)
          ..lineTo(70, 37)
          ..close());
      case FramingKind.two:
        shape(Path()
          ..moveTo(28, 94)
          ..lineTo(31, 66)
          ..quadraticBezierTo(34, 54, 48, 52)
          ..lineTo(51, 47)
          ..lineTo(61, 47)
          ..lineTo(64, 52)
          ..quadraticBezierTo(78, 54, 81, 66)
          ..lineTo(84, 94)
          ..close());
        head(const Offset(56, 34), 11);
        shape(Path()
          ..moveTo(76, 94)
          ..lineTo(79, 64)
          ..quadraticBezierTo(82, 52, 96, 50)
          ..lineTo(99, 45)
          ..lineTo(109, 45)
          ..lineTo(112, 50)
          ..quadraticBezierTo(126, 52, 129, 64)
          ..lineTo(132, 94)
          ..close());
        head(const Offset(104, 32), 11);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FramingPainter oldDelegate) =>
      oldDelegate.kind != kind ||
      oldDelegate.stroke != stroke ||
      oldDelegate.fill != fill ||
      oldDelegate.grid != grid;
}
