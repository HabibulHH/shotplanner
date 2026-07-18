import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SlateHeader extends StatelessWidget {
  const SlateHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.showBack = false,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final bool showBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ShotKitColors.ink,
      child: SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 13),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: ShotKitColors.line)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SlateStripe(),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (showBack) ...[
                    IconButton.outlined(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded, size: 19),
                      style: IconButton.styleFrom(
                        minimumSize: const Size(42, 42),
                        side: const BorderSide(color: ShotKitColors.line),
                        backgroundColor: ShotKitColors.surface,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title.toUpperCase(),
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: ShotKitColors.dim,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 10),
                    trailing!,
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SlateStripe extends StatelessWidget {
  const SlateStripe({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(height: 7, child: CustomPaint(painter: _StripePainter())),
    );
  }
}

class ShotKitCommandDock extends StatelessWidget {
  const ShotKitCommandDock({
    super.key,
    required this.onSlates,
    required this.onOnSet,
    required this.onCreate,
    required this.onArchive,
    required this.onKit,
    this.active = 'slates',
  });

  final VoidCallback onSlates;
  final VoidCallback onOnSet;
  final VoidCallback onCreate;
  final VoidCallback onArchive;
  final VoidCallback onKit;
  final String active;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ShotKitColors.surface,
      elevation: 18,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: ShotKitColors.line)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 4, child: SlateStripe()),
              SizedBox(
                height: 72,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _DockItem(
                        label: 'SLATES',
                        icon: Icons.view_agenda_outlined,
                        selected: active == 'slates',
                        onTap: onSlates,
                      ),
                    ),
                    Expanded(
                      child: _DockItem(
                        label: 'ON SET',
                        icon: Icons.radio_button_checked_rounded,
                        selected: active == 'onset',
                        live: true,
                        onTap: onOnSet,
                      ),
                    ),
                    SizedBox(
                      width: 78,
                      child: Semantics(
                        button: true,
                        label: 'Create new project',
                        child: InkWell(
                          onTap: onCreate,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 48,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: ShotKitColors.tape,
                                  borderRadius: BorderRadius.circular(11),
                                  boxShadow: [
                                    BoxShadow(
                                      color: ShotKitColors.tape
                                          .withValues(alpha: .18),
                                      blurRadius: 16,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.add_rounded,
                                  size: 27,
                                  color: ShotKitColors.tapeInk,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'NEW',
                                style: TextStyle(
                                  color: ShotKitColors.tape,
                                  fontFamily: 'monospace',
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: .8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _DockItem(
                        label: 'ARCHIVE',
                        icon: Icons.inventory_2_outlined,
                        selected: active == 'archive',
                        onTap: onArchive,
                      ),
                    ),
                    Expanded(
                      child: _DockItem(
                        label: 'KIT',
                        icon: Icons.tune_rounded,
                        selected: active == 'kit',
                        onTap: onKit,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  const _DockItem({
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
      label: label,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: selected
                ? ShotKitColors.tape.withValues(alpha: .07)
                : Colors.transparent,
            border: Border(
              top: BorderSide(
                color: selected ? ShotKitColors.tape : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, color: color, size: 22),
                  if (live)
                    const Positioned(
                      right: -4,
                      top: -2,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: ShotKitColors.record,
                          shape: BoxShape.circle,
                        ),
                        child: SizedBox(width: 6, height: 6),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  color: color,
                  fontFamily: 'monospace',
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = ShotKitColors.tape);
    final paint = Paint()..color = ShotKitColors.ink;
    for (double x = -12; x < size.width + 20; x += 28) {
      final path = Path()
        ..moveTo(x, size.height)
        ..lineTo(x + 8, 0)
        ..lineTo(x + 22, 0)
        ..lineTo(x + 14, size.height)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 6, 2, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class OfflinePill extends StatelessWidget {
  const OfflinePill({super.key, this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: ShotKitColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 3.5,
            backgroundColor: ShotKitColors.success,
          ),
          if (!compact) ...[
            const SizedBox(width: 6),
            const Text(
              'OFFLINE READY',
              style: TextStyle(
                fontSize: 9.5,
                color: ShotKitColors.dim,
                fontWeight: FontWeight.w700,
                letterSpacing: .6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class FilmProgress extends StatelessWidget {
  const FilmProgress({super.key, required this.value, this.height = 5});
  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: height,
        backgroundColor: ShotKitColors.line,
        valueColor: AlwaysStoppedAnimation(
          value >= 1 ? ShotKitColors.success : ShotKitColors.tape,
        ),
      ),
    );
  }
}

class DataPill extends StatelessWidget {
  const DataPill(this.text, {super.key, this.accent = false});
  final String text;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: accent ? ShotKitColors.tape : Colors.transparent,
        border: Border.all(
          color: accent ? ShotKitColors.tape : ShotKitColors.line,
        ),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: accent ? ShotKitColors.tapeInk : ShotKitColors.dim,
          fontFamily: 'monospace',
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class EmptySlate extends StatelessWidget {
  const EmptySlate({
    super.key,
    required this.title,
    required this.body,
    required this.action,
  });
  final String title;
  final String body;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ShotKitColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ShotKitColors.line),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.movie_creation_outlined,
            size: 34,
            color: ShotKitColors.tape,
          ),
          const SizedBox(height: 14),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
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
