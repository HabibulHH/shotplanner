import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/shot_code.dart';
import '../../core/widgets/shotkit_widgets.dart';
import '../../data/models.dart';
import '../../data/shotkit_store.dart';
import 'onset_screen.dart';

/// Opens on-set mode at the first scene of [project] that still has shots.
void openOnSetForProject(
  BuildContext context,
  ShotKitStore store,
  Project project,
) {
  final scene = project.scenes.cast<Scene?>().firstWhere(
        (scene) => scene!.shots.any((shot) => !shot.isDone),
        orElse: () => null,
      );
  if (scene == null) return;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => OnSetScreen(store: store, project: project, scene: scene),
    ),
  );
}

/// Lets the user pick the scene they are shooting (skipped when there is only
/// one) and opens on-set mode for it.
Future<void> openOnSetPicker(BuildContext context, ShotKitStore store) async {
  final choices = <({Project project, Scene scene, int index})>[];
  for (final project in store.activeProjects) {
    for (var i = 0; i < project.scenes.length; i++) {
      if (project.scenes[i].shots.isNotEmpty) {
        choices.add((project: project, scene: project.scenes[i], index: i));
      }
    }
  }
  if (choices.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add at least one shot before entering On-set mode.'),
      ),
    );
    return;
  }

  var selected = choices.first;
  if (choices.length > 1) {
    final result =
        await showModalBottomSheet<({Project project, Scene scene, int index})>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .75,
          ),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            children: [
              const SheetHandle(),
              const SizedBox(height: 14),
              Text('Go on set',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              const Text(
                'Pick the scene you are shooting now.',
                style: TextStyle(color: ShotKitColors.dim),
              ),
              const SizedBox(height: 14),
              for (final choice in choices)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SceneChoice(
                    code: sceneCode(choice.index),
                    title: choice.scene.title,
                    subtitle: choice.project.title,
                    progress:
                        '${choice.scene.completed}/${choice.scene.shots.length}',
                    onTap: () => Navigator.pop(context, choice),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (result == null) return;
    selected = result;
  }
  if (!context.mounted) return;
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => OnSetScreen(
        store: store,
        project: selected.project,
        scene: selected.scene,
      ),
    ),
  );
}

class SceneChoice extends StatelessWidget {
  const SceneChoice({
    super.key,
    required this.code,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.onTap,
  });
  final String code;
  final String title;
  final String subtitle;
  final String progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ShotKitColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: ShotKitColors.line),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Text(
                code,
                style: ShotKitText.mono(
                  size: 12,
                  weight: FontWeight.w700,
                  color: ShotKitColors.tape,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: ShotKitColors.dim,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Text(progress, style: ShotKitText.mono(size: 12)),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, color: ShotKitColors.dim),
            ],
          ),
        ),
      ),
    );
  }
}
