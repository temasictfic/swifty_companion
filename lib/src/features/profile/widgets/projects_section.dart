import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/project_model.dart';
import '../../../shared/widgets/optimized_glass_container.dart';

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
    final coalitionColorParsed = coalitionColor != null
        ? Color(int.parse('0xFF${coalitionColor!.replaceAll('#', '')}'))
        : const Color(0xFF00BABC);
    
    // Use gold color for excellent projects
    final excellentColor = const Color(0xFFFFD700); // Gold color
    final _ = project.isExcellent ? excellentColor : coalitionColorParsed;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: OptimizedGlassContainer(
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
                      color: Colors.white,
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
            if (project.finalMark != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: project.isExcellent 
                      ? excellentColor.withValues(alpha: 0.2)
                      : (project.isSuccess 
                          ? Colors.green.withValues(alpha: 0.2)
                          : Colors.red.withValues(alpha: 0.2)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: project.isExcellent
                        ? excellentColor.withValues(alpha: 0.5)
                        : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    if (project.isExcellent)
                      Icon(
                        Icons.star,
                        size: 16,
                        color: excellentColor,
                      ),
                    if (project.isExcellent) const SizedBox(width: 4),
                    Text(
                      project.finalMark.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: project.isExcellent 
                            ? excellentColor
                            : (project.isSuccess ? Colors.green : Colors.red),
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
        return const Color(0xFFFFD700); // Gold color
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
    return OptimizedGlassContainer(
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
