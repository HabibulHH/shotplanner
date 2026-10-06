import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/shot_code.dart';
import '../../core/widgets/atmosphere.dart';
import '../../core/widgets/framing_glyph.dart';
import '../../core/widgets/motion.dart';
import '../../core/widgets/shotkit_widgets.dart';
import '../../data/media_service.dart';
import '../../data/models.dart';
import '../../data/shotkit_store.dart';
import '../onset/onset_launcher.dart';
import '../projects/new_project_sheet.dart';
import '../projects/project_row.dart';
import '../projects/project_screen.dart';
import '../projects/projects_screen.dart';
import '../settings/settings_screen.dart';

typedef _Upcoming = ({Project project, int scene, int index, Shot shot});

/// The app's landing screen: what to shoot next, how far along everything is,
/// and quick ways in. Every section animates in as it appears.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.store});
  final ShotKitStore store;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.store.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.store.removeListener(_refresh);
    _scroll.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  /// The first project that still has shots to get, else the newest one.
  Project? get _focus {
    final active = widget.store.activeProjects;
    for (final project in active) {
      if (project.shotCount > project.completed) return project;
    }
    return active.isEmpty ? null : active.first;
  }

  List<_Upcoming> get _upcoming {
    final out = <_Upcoming>[];
    for (final project in widget.store.activeProjects) {
      for (var s = 0; s < project.scenes.length; s++) {
        final shots = project.scenes[s].shots;
        for (var i = 0; i < shots.length; i++) {
          if (shots[i].isDone) continue;
          out.add((project: project, scene: s, index: i, shot: shots[i]));
          if (out.length == 8) return out;
        }
      }
    }
    return out;
  }

  void _openProject(Project project) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProjectScreen(store: widget.store, project: project),
        ),
      );

  void _openProjects() => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProjectsScreen(store: widget.store)),
      );

  Future<void> _newProject({String template = 'Wedding'}) async {
    final created =
        await showNewProjectSheet(context, widget.store, template: template);
    if (created != null && mounted) _openProject(created);
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.store.activeProjects;
    final focus = _focus;
    final upcoming = _upcoming;
    final scenes = active.fold(0, (sum, p) => sum + p.scenes.length);
    final done = active.fold(0, (sum, p) => sum + p.completed);
    final total = active.fold(0, (sum, p) => sum + p.shotCount);
    final musts = active
        .expand((p) => p.scenes)
        .expand((s) => s.shots)
        .where((shot) => shot.mustHave)
        .toList();
    final mustLeft = musts.where((shot) => !shot.isDone).length;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _AmbientGlow()),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const HazardStripe(),
                Expanded(
                  child: ListView(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                    children: [
                      Reveal(
                        child: _Header(
                          activeCount: active.length,
                          onNew: () => _newProject(),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Reveal(
                        index: 1,
                        child: focus == null
                            ? EmptySlate(
                                title: 'Slate your first production',
                                body:
                                    'Start blank or load a field-tested template. Everything works offline.',
                                action: FilledButton.icon(
                                  onPressed: () => _newProject(),
                                  icon: const Icon(Icons.add_rounded),
                                  label: const Text('New project'),
                                ),
                              )
                            : _FocusCard(
                                project: focus,
                                store: widget.store,
                                onSet: () => openOnSetForProject(
                                    context, widget.store, focus),
                                onOpen: () => _openProject(focus),
                              ),
                      ),
                      const SizedBox(height: 16),
                      Reveal(
                        index: 2,
                        child: _TileRow(
                          children: [
                            Expanded(
                              child: _StatTile(
                                icon: Icons.video_library_outlined,
                                value: active.length,
                                label:
                                    active.length == 1 ? 'Project' : 'Projects',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatTile(
                                icon: Icons.view_agenda_outlined,
                                value: scenes,
                                label: scenes == 1 ? 'Scene' : 'Scenes',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Reveal(
                        index: 3,
                        child: _TileRow(
                          children: [
                            Expanded(
                              child: _StatTile(
                                icon: Icons.check_circle_outline_rounded,
                                value: done,
                                outOf: total,
                                label: 'Shots done',
                                tone: ShotKitColors.success,
                                progress: total == 0 ? 0 : done / total,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatTile(
                                icon: Icons.flag_outlined,
                                value: mustLeft,
                                label: 'Must-haves left',
                                tone: ShotKitColors.record,
                                progress: musts.isEmpty
                                    ? 0
                                    : (musts.length - mustLeft) / musts.length,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (upcoming.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Reveal(
                          index: 4,
                          child: SectionLabel(
                            'Next shots',
                            trailing: Text(
                              '${total - done} TO GO',
                              style: ShotKitText.mono(size: 10.5, spacing: 1),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 222,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            clipBehavior: Clip.none,
                            itemCount: upcoming.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, i) => Reveal(
                              index: i,
                              offset: 18,
                              child: _ShotCard(
                                item: upcoming[i],
                                media: widget.store.media,
                                onTap: () => _openProject(upcoming[i].project),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 22),
                      Reveal(
                        index: 5,
                        child: ActionPair(
                          primary: FilledButton.icon(
                            onPressed: () => _newProject(),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('New project'),
                          ),
                          secondary: OutlinedButton(
                            onPressed: () =>
                                openOnSetPicker(context, widget.store),
                            child: const Text('Go on set'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Reveal(
                        index: 6,
                        child: SectionLabel('Start from a template'),
                      ),
                      SizedBox(
                        height: 44,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: kProjectTemplates.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, i) => Reveal(
                            index: i,
                            offset: 14,
                            child: TemplateChip(
                              label: kProjectTemplates[i],
                              onTap: () =>
                                  _newProject(template: kProjectTemplates[i]),
                            ),
                          ),
                        ),
                      ),
                      if (active.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Reveal(
                          index: 7,
                          child: SectionLabel(
                            'Recent projects',
                            trailing: TextButton(
                              onPressed: _openProjects,
                              child: const Text('See all'),
                            ),
                          ),
                        ),
                        for (var i = 0; i < active.length && i < 3; i++)
                          Padding(
                            key: ValueKey(active[i].id),
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Reveal(
                              index: i,
                              child: PressScale(
                                child: ProjectRow(
                                  project: active[i],
                                  onTap: () => _openProject(active[i]),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Positioned.fill(child: FilmGrain()),
        ],
      ),
      bottomNavigationBar: ShotKitNavBar(
        active: NavTab.home,
        onHome: () {
          if (_scroll.hasClients) {
            _scroll.animateTo(
              0,
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOutCubic,
            );
          }
        },
        onProjects: _openProjects,
        onOnSet: () => openOnSetPicker(context, widget.store),
        onKit: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SettingsScreen(store: widget.store),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.activeCount, required this.onNew});
  final int activeCount;
  final VoidCallback onNew;

  static const _days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  static const _months = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', //
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
  ];

  static String _greeting(int hour) {
    if (hour < 5) return 'LATE NIGHT';
    if (hour < 12) return 'GOOD MORNING';
    if (hour < 17) return 'GOOD AFTERNOON';
    return 'GOOD EVENING';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final date =
        '${_days[now.weekday - 1]} ${now.day} ${_months[now.month - 1]}';
    final slates =
        '$activeCount ACTIVE ${activeCount == 1 ? 'SLATE' : 'SLATES'}';
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const PulseDot(),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      _greeting(now.hour),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ShotKitText.mono(
                        weight: FontWeight.w700,
                        color: ShotKitColors.tape,
                        spacing: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (rect) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [ShotKitColors.paper, Color(0xFFB4AFA4)],
                  ).createShader(rect),
                  child: Text(
                    'SHOTKIT',
                    maxLines: 1,
                    style: ShotKitText.display(size: 31).copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: .4,
                      height: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text('$date · $slates', style: ShotKitText.mono(spacing: 1.2)),
            ],
          ),
        ),
        IconButton.filled(
          onPressed: onNew,
          tooltip: 'New project',
          icon: const Icon(Icons.add_rounded, size: 26),
          style: IconButton.styleFrom(
            fixedSize: const Size.square(48),
            backgroundColor: ShotKitColors.tape,
            foregroundColor: ShotKitColors.tapeInk,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }
}

/// The project to shoot next: a progress ring, what is left, the next few
/// shots and the buttons to start.
class _FocusCard extends StatelessWidget {
  const _FocusCard({
    required this.project,
    required this.store,
    required this.onSet,
    required this.onOpen,
  });
  final Project project;
  final ShotKitStore store;
  final VoidCallback onSet;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final shots = project.scenes.expand((scene) => scene.shots).toList();
    final upcoming = shots.where((shot) => !shot.isDone).take(6).toList();
    final mustLeft =
        shots.where((shot) => shot.mustHave && !shot.isDone).length;
    final canShoot = project.shotCount > project.completed;
    final wrapped = project.shotCount > 0 && !canShoot;
    final percent = (project.progress * 100).round();
    final eyebrow = wrapped
        ? 'WRAPPED'
        : project.shotCount == 0
            ? 'NO SHOTS YET'
            : "TODAY'S FOCUS";

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1.2,
              child: RingProgress(
                value: project.progress,
                child: CountUp(
                  value: percent,
                  suffix: '%',
                  style: ShotKitText.headline(size: 25),
                  suffixStyle: ShotKitText.mono(
                    size: 12,
                    weight: FontWeight.w700,
                    color: ShotKitColors.dim,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eyebrow,
                    style: ShotKitText.mono(
                      weight: FontWeight.w700,
                      color:
                          wrapped ? ShotKitColors.success : ShotKitColors.tape,
                      spacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  MediaQuery.withClampedTextScaling(
                    maxScaleFactor: 1.3,
                    child: Text(
                      project.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: ShotKitText.headline(size: 23),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${project.completed}/${project.shotCount} SHOTS · '
                    '${project.scenes.length} '
                    '${project.scenes.length == 1 ? 'SCENE' : 'SCENES'}',
                    style: ShotKitText.mono(size: 10.5, spacing: .8),
                  ),
                  if (canShoot)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        '$mustLeft MUST-HAVES LEFT',
                        style: ShotKitText.mono(
                          size: 10.5,
                          spacing: .8,
                          color: mustLeft == 0
                              ? ShotKitColors.success
                              : ShotKitColors.tape,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        if (upcoming.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              for (var i = 0; i < 6; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: i < upcoming.length
                        ? Reveal(
                            delay: const Duration(milliseconds: 350),
                            index: i,
                            offset: 12,
                            child: ShotThumb(
                              shot: upcoming[i],
                              media: store.media,
                              radius: 6,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ],
          ),
        ],
        const SizedBox(height: 14),
        SceneProgressBar(scenes: project.scenes),
        const SizedBox(height: 16),
        if (canShoot)
          ActionPair(
            primary: FilledButton.icon(
              onPressed: onSet,
              icon: const Icon(Icons.radio_button_checked_rounded, size: 20),
              label: const Text('Start on-set'),
            ),
            secondary:
                OutlinedButton(onPressed: onOpen, child: const Text('Open')),
          )
        else
          FilledButton.icon(
            onPressed: onOpen,
            icon: const Icon(Icons.folder_open_rounded, size: 20),
            label: const Text('Open project'),
          ),
      ],
    );

    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(26)),
        // The 1px gap below shows this as a hairline border that catches
        // the light at the top right.
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0x8CFFB020), Color(0x1FFFFFFF), Color(0x0DFFFFFF)],
          stops: [0, .42, 1],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x73000000),
            blurRadius: 30,
            offset: Offset(0, 14),
          ),
          BoxShadow(
            color: Color(0x14FFB020),
            blurRadius: 48,
            spreadRadius: -10,
            offset: Offset(0, 22),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Stack(
            children: [
              const Positioned.fill(
                child: ColoredBox(color: Color(0xFF131519)),
              ),
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(1.05, -1.15),
                      radius: 1.4,
                      colors: [
                        Color(0x3DFFB020),
                        Color(0x10FFB020),
                        Color(0x00FFB020),
                      ],
                      stops: [0, .42, 1],
                    ),
                  ),
                ),
              ),
              const Positioned.fill(child: DustField()),
              Padding(padding: const EdgeInsets.all(18), child: content),
            ],
          ),
        ),
      ),
    );
  }
}

/// Two stat tiles side by side, always the same height.
class _TileRow extends StatelessWidget {
  const _TileRow({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

const _tileGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF1B1E23), ShotKitColors.surface],
);

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    this.outOf,
    this.progress,
    this.tone = ShotKitColors.tape,
  });
  final IconData icon;
  final int value;
  final int? outOf;
  final String label;
  final double? progress;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      scale: .98,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ShotKitColors.line),
          gradient: _tileGradient,
        ),
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          CountUp(
                            value: value,
                            style: ShotKitText.display(size: 30),
                          ),
                          if (outOf != null) ...[
                            const SizedBox(width: 5),
                            Text('/ $outOf', style: ShotKitText.mono(size: 12)),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Icon(icon, size: 18, color: tone),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                label.toUpperCase(),
                style: ShotKitText.mono(size: 10, spacing: 1),
              ),
              if (progress != null) ...[
                const Spacer(),
                const SizedBox(height: 10),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(end: progress!.clamp(0.0, 1.0)),
                  duration: motionReduced(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 1200),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) =>
                      FilmProgress(value: v, height: 3, color: tone),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ShotCard extends StatelessWidget {
  const _ShotCard({
    required this.item,
    required this.media,
    required this.onTap,
  });
  final _Upcoming item;
  final MediaService media;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shot = item.shot;
    return PressScale(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ShotKitColors.line),
          gradient: _tileGradient,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              width: 176,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: MediaQuery.withClampedTextScaling(
                  maxScaleFactor: 1.15,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 10,
                        child: ShotThumb(shot: shot, media: media, radius: 10),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        shotCode(item.scene, item.index),
                        maxLines: 1,
                        style: ShotKitText.mono(
                          size: 11,
                          weight: FontWeight.w700,
                          color: ShotKitColors.tape,
                          spacing: 1,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        shot.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        shotSpec(shot),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ShotKitText.mono(size: 10, spacing: .6),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A faint warm light from the top right, behind everything.
class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(1.1, -1.05),
            radius: 1.15,
            colors: [Color(0x17FFB020), Color(0x00FFB020)],
          ),
        ),
      ),
    );
  }
}
