import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/shotkit_widgets.dart';
import '../../data/models.dart';

class ProjectRow extends StatelessWidget {
  const ProjectRow({
    super.key,
    required this.project,
    required this.onTap,
    this.trailing,
  });
  final Project project;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final wrapped =
        project.shotCount > 0 && project.completed == project.shotCount;
    final scenes =
        '${project.scenes.length} ${project.scenes.length == 1 ? 'SCENE' : 'SCENES'}';
    return Material(
      color: ShotKitColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: ShotKitColors.line),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: ShotKitColors.raised,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  projectTypeIcon(project.type),
                  color: ShotKitColors.tape,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Expanded(
                          child: Text(
                            project.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          wrapped
                              ? 'WRAPPED'
                              : '${project.completed}/${project.shotCount}',
                          style: ShotKitText.mono(
                            size: 12,
                            weight: wrapped ? FontWeight.w700 : FontWeight.w500,
                            color: wrapped
                                ? ShotKitColors.success
                                : ShotKitColors.dim,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${project.type} · $scenes · ${project.updatedLabel}'
                          .toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ShotKitText.mono(size: 10.5, spacing: .8),
                    ),
                    const SizedBox(height: 8),
                    FilmProgress(value: project.progress),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 6),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
