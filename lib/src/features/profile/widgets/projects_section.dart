import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/models/project_model.dart';
import '../../../core/themes/app_theme.dart';
import '../../../shared/widgets/surface_card.dart';
import 'section_empty_state.dart';

/// Lazily built project list: only the cards on screen are built and laid
/// out, instead of all ~100 projects at once.
class ProjectsSliver extends StatelessWidget {
  const ProjectsSliver({required this.projects, super.key});

  final List<ProjectModel> projects;

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return const SliverToBoxAdapter(
        child: SectionEmptyState(
          icon: Icons.folder_open,
          text: 'No projects available',
        ),
      );
    }
    return SliverList.builder(
      itemCount: projects.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _ProjectCard(project: projects[index]),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project});

  final ProjectModel project;

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(project);

    return SurfaceCard(
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_statusIcon(project), color: statusColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: project.displayStatus,
                        style: TextStyle(
                          fontSize: 14,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: '  •  ${_dateFormat.format(project.createdAt)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (project.finalMark != null) ...[
            const SizedBox(width: 8),
            _MarkBadge(project: project),
          ],
        ],
      ),
    );
  }

  static Color _statusColor(ProjectModel project) {
    if (project.isInProgress) return Colors.blue;
    if (project.isExcellent) return AppTheme.excellentColor;
    if (project.isSuccess) return Colors.green;
    if (project.isFailed) return Colors.red;
    return Colors.grey;
  }

  static IconData _statusIcon(ProjectModel project) {
    if (project.isInProgress) return Icons.timer;
    if (project.isExcellent) return Icons.star;
    if (project.isSuccess) return Icons.check_circle;
    if (project.isFailed) return Icons.cancel;
    return Icons.help_outline;
  }
}

class _MarkBadge extends StatelessWidget {
  const _MarkBadge({required this.project});

  final ProjectModel project;

  @override
  Widget build(BuildContext context) {
    final excellent = project.isExcellent;
    final color = excellent
        ? AppTheme.excellentColor
        : (project.isSuccess ? Colors.green : Colors.red);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: excellent
            ? Border.all(color: color.withValues(alpha: 0.5))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (excellent) ...[
            Icon(Icons.star, size: 16, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            '${project.finalMark}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
