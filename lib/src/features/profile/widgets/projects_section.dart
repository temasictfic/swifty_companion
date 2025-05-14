import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/project_model.dart';
import '../../../shared/widgets/glass_container.dart';

class ProjectsSection extends StatelessWidget {
  const ProjectsSection({
    required this.projects, super.key,
    this.coalitionColor,
  });
  final List<ProjectModel> projects;
  final String? coalitionColor;

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: projects.map((project) => _buildProjectItem(project)).toList(),
    );
  }

  Widget _buildProjectItem(ProjectModel project) {
    final color = coalitionColor != null
        ? Color(int.parse('0xFF${coalitionColor!.replaceAll('#', '')}'))
        : const Color(0xFF00BABC);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        child: Row(
          children: [
            // Project status indicator
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getStatusColor(project).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getStatusIcon(project),
                color: _getStatusColor(project),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Project details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: project.isExcellent ? color : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        project.displayStatus,
                        style: TextStyle(
                          fontSize: 14,
                          color: _getStatusColor(project),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• ${DateFormat('dd/MM/yyyy').format(project.createdAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Final mark badge
            if (project.finalMark != null && project.isExcellent)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      project.finalMark.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ProjectModel project) {
    if (project.isInProgress) {
      return Colors.blue;
    }
    if (project.isSuccess) {
      if (project.isExcellent) {
        return coalitionColor != null
            ? Color(int.parse('0xFF${coalitionColor!.replaceAll('#', '')}'))
            : const Color(0xFF00BABC);
      }
      return Colors.green;
    }
    if (project.isFailed) {
      return Colors.red;
    }
    return Colors.grey;
  }

  IconData _getStatusIcon(ProjectModel project) {
    if (project.isInProgress) {
      return Icons.timer;
    }
    if (project.isSuccess) {
      if (project.isExcellent) {
        return Icons.star;
      }
      return Icons.check_circle;
    }
    if (project.isFailed) {
      return Icons.cancel;
    }
    return Icons.help_outline;
  }

  Widget _buildEmptyState() {
    return GlassContainer(
      child: Column(
        children: [
          Icon(
            Icons.folder_open,
            size: 60,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No projects available',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
