import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../theme/app_theme.dart';

/// Thin diagonal hazard-tape band, the brand's signature edge.
class HazardStripe extends StatelessWidget {
  const HazardStripe({
    super.key,
    this.height = 4,
    this.color = ShotKitColors.tape,
  });
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _StripePainter(color)),
    );
  }
}

class _StripePainter extends CustomPainter {
  const _StripePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final h = size.height;
    for (double x = -h; x < size.width + h; x += 16) {
      canvas.drawPath(
        Path()
          ..moveTo(x, h)
          ..lineTo(x + h, 0)
          ..lineTo(x + h + 8, 0)
          ..lineTo(x + 8, h)
          ..close(),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StripePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Round 44px icon button used in top bars.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color = ShotKitColors.paper,
    this.background = ShotKitColors.surface,
    this.border = ShotKitColors.line,
    this.size = 44,
    this.iconSize = 20,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color color;
  final Color background;
  final Color border;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return IconButton.outlined(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: iconSize),
      style: IconButton.styleFrom(
        fixedSize: Size.square(size),
        minimumSize: Size.square(size),
        padding: EdgeInsets.zero,
        foregroundColor: color,
        backgroundColor: background,
        side: BorderSide(color: border),
      ),
    );
  }
}

/// Back button on the left, actions on the right. Stays fixed above content.
class TopBar extends StatelessWidget {
  const TopBar({super.key, this.showBack = true, this.actions = const []});
  final bool showBack;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
        child: Row(
          children: [
            if (showBack)
              CircleIconButton(
                icon: Icons.arrow_back_rounded,
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            const Spacer(),
            for (var i = 0; i < actions.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              actions[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// Eyebrow + uppercase condensed title + optional meta row.
class TitleBlock extends StatelessWidget {
  const TitleBlock({
    super.key,
    this.eyebrow,
    required this.title,
    this.meta,
  });
  final String? eyebrow;
  final String title;
  final Widget? meta;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (eyebrow != null) ...[
            Text(
              eyebrow!.toUpperCase(),
              style: ShotKitText.mono(
                weight: FontWeight.w700,
                color: ShotKitColors.tape,
                spacing: 1.3,
              ),
            ),
            const SizedBox(height: 6),
          ],
          // Big titles grow less than body text, like Android's own
          // nonlinear font scaling, so single words don't break mid-word.
          MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.3,
            child: Text(title.toUpperCase(), style: ShotKitText.display()),
          ),
          if (meta != null) ...[
            const SizedBox(height: 8),
            meta!,
          ],
        ],
      ),
    );
  }
}

/// Icon + short text, for location / time / counts.
class MetaItem extends StatelessWidget {
  const MetaItem({
    super.key,
    required this.icon,
    required this.text,
    this.color = ShotKitColors.dim,
  });
  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class MetaRow extends StatelessWidget {
  const MetaRow({super.key, required this.items});
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 14, runSpacing: 6, children: items);
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Expanded(child: Text(text.toUpperCase(), style: ShotKitText.label)),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Three numbers in one bordered strip ("2/25 SHOTS DONE · 19 MUST LEFT").
class StatStrip extends StatelessWidget {
  const StatStrip({super.key, required this.stats});
  final List<(String value, String label)> stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ShotKitColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ShotKitColors.line),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var i = 0; i < stats.length; i++) ...[
              if (i > 0)
                const VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: ShotKitColors.line,
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                  child: StatValue(value: stats[i].$1, label: stats[i].$2),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class StatValue extends StatelessWidget {
  const StatValue({super.key, required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.5,
      child: _value(),
    );
  }

  Widget _value() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Numbers shrink rather than clip ("0/25" must never read "0/2").
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            maxLines: 1,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label.toUpperCase(),
          style: ShotKitText.mono(size: 10, spacing: 1),
        ),
      ],
    );
  }
}

/// A main action with a smaller one beside it. With very large text the two
/// stack full-width so neither label breaks mid-word.
class ActionPair extends StatelessWidget {
  const ActionPair({
    super.key,
    required this.primary,
    required this.secondary,
    this.secondaryFirst = false,
  });

  final Widget primary;
  final Widget secondary;
  final bool secondaryFirst;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.textScalerOf(context).scale(10) >= 15) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [primary, const SizedBox(height: 10), secondary],
      );
    }
    final main = Expanded(child: primary);
    return Row(
      children: secondaryFirst
          ? [secondary, const SizedBox(width: 10), main]
          : [main, const SizedBox(width: 10), secondary],
    );
  }
}

/// One segment per item, e.g. per shot in a scene.
class SegmentBar extends StatelessWidget {
  const SegmentBar({super.key, required this.colors, this.height = 5});
  final List<Color> colors;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < colors.length; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: height,
              decoration: BoxDecoration(
                color: colors[i],
                borderRadius: BorderRadius.circular(height),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Per-shot progress: done green, next amber, the rest dark. Falls back to a
/// single bar when a scene has too many shots for readable segments.
class ShotProgressBar extends StatelessWidget {
  const ShotProgressBar({
    super.key,
    required this.shots,
    this.next,
    this.done = ShotKitColors.success,
    this.current = ShotKitColors.tape,
    this.empty = ShotKitColors.line,
  });
  final List<Shot> shots;
  final Shot? next;
  final Color done;
  final Color current;
  final Color empty;

  @override
  Widget build(BuildContext context) {
    if (shots.isEmpty || shots.length > 24) {
      final completed = shots.where((shot) => shot.isDone).length;
      return FilmProgress(
        value: shots.isEmpty ? 0 : completed / shots.length,
        height: 5,
        color: done,
        track: empty,
      );
    }
    return SegmentBar(
      colors: [
        for (final shot in shots)
          shot.isDone
              ? done
              : identical(shot, next)
                  ? current
                  : empty,
      ],
    );
  }
}

/// Scenes as weighted segments, each filled by its own progress.
class SceneProgressBar extends StatelessWidget {
  const SceneProgressBar({super.key, required this.scenes});
  final List<Scene> scenes;

  @override
  Widget build(BuildContext context) {
    final withShots = scenes.where((scene) => scene.shots.isNotEmpty).toList();
    if (withShots.isEmpty) return const FilmProgress(value: 0, height: 4);
    return Row(
      children: [
        for (var i = 0; i < withShots.length; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            flex: withShots[i].shots.length,
            child: FilmProgress(
              value: withShots[i].progress,
              height: 4,
              color: ShotKitColors.success,
            ),
          ),
        ],
      ],
    );
  }
}

class FilmProgress extends StatelessWidget {
  const FilmProgress({
    super.key,
    required this.value,
    this.height = 3,
    this.color,
    this.track = ShotKitColors.strong,
  });
  final double value;
  final double height;
  final Color? color;
  final Color track;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: track)),
            FractionallySizedBox(
              widthFactor: clamped,
              heightFactor: 1,
              child: ColoredBox(
                color: color ??
                    (clamped >= 1 ? ShotKitColors.success : ShotKitColors.tape),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum TagTone { accent, outline, cam, success }

/// Tiny mono tag: NEXT UP, OPTIONAL, B-CAM…
class ShotTag extends StatelessWidget {
  const ShotTag(this.text, {super.key, this.tone = TagTone.outline});
  final String text;
  final TagTone tone;

  @override
  Widget build(BuildContext context) {
    final (Color fg, Color? bg) = switch (tone) {
      TagTone.accent => (ShotKitColors.tape, ShotKitColors.tapeSoft),
      TagTone.cam => (ShotKitColors.cam, const Color(0x1F8FB4FF)),
      TagTone.success => (ShotKitColors.success, const Color(0x1F3DDC84)),
      TagTone.outline => (ShotKitColors.dim, null),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
        border: bg == null ? Border.all(color: ShotKitColors.strong) : null,
      ),
      child: Text(
        text.toUpperCase(),
        style: ShotKitText.mono(
          size: 9.5,
          weight: FontWeight.w700,
          color: fg,
          spacing: .8,
        ),
      ),
    );
  }
}

/// Amber shot code chip ("1C").
class CodeBadge extends StatelessWidget {
  const CodeBadge(this.code, {super.key});
  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: ShotKitColors.tape,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        code,
        style: ShotKitText.mono(
          size: 10.5,
          weight: FontWeight.w700,
          color: ShotKitColors.tapeInk,
        ),
      ),
    );
  }
}

/// Rounded pill with mono text, used for small context ("UPDATED 2H AGO").
class OutlinePill extends StatelessWidget {
  const OutlinePill(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: ShotKitColors.line),
      ),
      child: Text(
        text.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: ShotKitText.mono(color: ShotKitColors.subtle, spacing: .6),
      ),
    );
  }
}

/// 44px done toggle.
class CheckButton extends StatelessWidget {
  const CheckButton({
    super.key,
    required this.done,
    required this.onPressed,
    this.doneColor = ShotKitColors.success,
    this.onDoneColor = ShotKitColors.ink,
    this.outline = ShotKitColors.strong,
  });
  final bool done;
  final VoidCallback onPressed;
  final Color doneColor;
  final Color onDoneColor;
  final Color outline;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      checked: done,
      label: done ? 'Mark not done' : 'Mark done',
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: done ? doneColor : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: done ? doneColor : outline,
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.check_rounded,
              size: 24,
              color: done ? onDoneColor : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }
}

/// Two-option pill toggle ("Active 3 | Archived 2").
class SegmentedPill extends StatelessWidget {
  const SegmentedPill({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    // Shrinks to fit narrow screens at very large font sizes.
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: _pill(),
    );
  }

  Widget _pill() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: ShotKitColors.surface,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: ShotKitColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < labels.length; i++)
            Semantics(
              button: true,
              selected: i == selected,
              child: Material(
                color: i == selected ? ShotKitColors.line : Colors.transparent,
                borderRadius: BorderRadius.circular(99),
                child: InkWell(
                  onTap: () => onChanged(i),
                  borderRadius: BorderRadius.circular(99),
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    child: Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            i == selected ? FontWeight.w700 : FontWeight.w600,
                        color: i == selected
                            ? ShotKitColors.paper
                            : ShotKitColors.dim,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Full-width dashed "add" row that ends a list instead of a floating button.
class DashedAddButton extends StatelessWidget {
  const DashedAddButton({super.key, required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: CustomPaint(
          painter: const _DashedBorderPainter(),
          child: SizedBox(
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_rounded, color: ShotKitColors.tape),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: ShotKitColors.tape,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
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

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ShotKitColors.strong
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        (Offset.zero & size).deflate(.75),
        const Radius.circular(18),
      ));
    for (final metric in path.computeMetrics()) {
      for (double d = 0; d < metric.length; d += 12) {
        canvas.drawPath(metric.extractPath(d, d + 6), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class EmptySlate extends StatelessWidget {
  const EmptySlate({
    super.key,
    required this.title,
    required this.body,
    required this.action,
    this.icon = Icons.movie_creation_outlined,
  });
  final String title;
  final String body;
  final Widget action;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
      decoration: BoxDecoration(
        color: ShotKitColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ShotKitColors.line),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: ShotKitColors.tapeSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 26, color: ShotKitColors.tape),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(color: ShotKitColors.dim, height: 1.4),
          ),
          const SizedBox(height: 18),
          action,
        ],
      ),
    );
  }
}

/// Drag handle shown at the top of bottom sheets.
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 4,
        decoration: BoxDecoration(
          color: ShotKitColors.strong,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

enum NavTab { projects, onSet, kit }

class ShotKitNavBar extends StatelessWidget {
  const ShotKitNavBar({
    super.key,
    required this.onProjects,
    required this.onOnSet,
    required this.onKit,
    this.active = NavTab.projects,
  });

  final VoidCallback onProjects;
  final VoidCallback onOnSet;
  final VoidCallback onKit;
  final NavTab active;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: ShotKitColors.nav,
        border: Border(top: BorderSide(color: ShotKitColors.line)),
      ),
      // Tab labels stop growing at 130% so they stay inside the tabs.
      child: MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.3,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Row(
              children: [
                Expanded(
                  child: _NavItem(
                    label: 'Projects',
                    icon: Icons.video_library_outlined,
                    selected: active == NavTab.projects,
                    onTap: onProjects,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _NavItem(
                    label: 'On set',
                    icon: Icons.radio_button_unchecked_rounded,
                    live: true,
                    selected: active == NavTab.onSet,
                    onTap: onOnSet,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _NavItem(
                    label: 'Kit',
                    icon: Icons.tune_rounded,
                    selected: active == NavTab.kit,
                    onTap: onKit,
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

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.live = false,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final bool live;

  @override
  Widget build(BuildContext context) {
    final color = selected ? ShotKitColors.tape : ShotKitColors.dim;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? ShotKitColors.tapeSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 58,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(icon, color: color, size: 23),
                    if (live)
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          color: ShotKitColors.record,
                          shape: BoxShape.circle,
                        ),
                        child: SizedBox(width: 8, height: 8),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
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

IconData timeOfDayIcon(TimeOfDayTag tag) => switch (tag) {
      TimeOfDayTag.day => Icons.wb_sunny_outlined,
      TimeOfDayTag.night => Icons.nightlight_outlined,
      TimeOfDayTag.golden => Icons.wb_twilight_rounded,
      TimeOfDayTag.indoor => Icons.home_outlined,
    };

String timeOfDayName(TimeOfDayTag tag) => switch (tag) {
      TimeOfDayTag.day => 'Day',
      TimeOfDayTag.night => 'Night',
      TimeOfDayTag.golden => 'Golden hour',
      TimeOfDayTag.indoor => 'Indoor',
    };

IconData projectTypeIcon(String type) => switch (type.toUpperCase()) {
      'WEDDING' => Icons.diamond_outlined,
      'INTERVIEW' => Icons.mic_none_rounded,
      'MUSIC VIDEO' => Icons.music_note_outlined,
      'SHORT FILM' => Icons.movie_outlined,
      _ => Icons.movie_creation_outlined,
    };
