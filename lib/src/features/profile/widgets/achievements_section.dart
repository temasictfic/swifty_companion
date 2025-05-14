import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../core/models/user_model.dart';
import '../../../shared/widgets/glass_container.dart';

class AchievementsSection extends StatelessWidget {
  const AchievementsSection({
    required this.achievements, super.key,
    this.coalitionColor,
  });
  final List<AchievementModel> achievements;
  final String? coalitionColor;

  @override
  Widget build(BuildContext context) {
    if (achievements.isEmpty) {
      return _buildEmptyState();
    }

    return StaggeredGrid.count(
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: achievements.map((achievement) {
        return StaggeredGridTile.count(
          crossAxisCellCount: 1,
          mainAxisCellCount: 1,
          child: _buildAchievementCard(achievement),
        );
      }).toList(),
    );
  }

  Widget _buildAchievementCard(AchievementModel achievement) {
    final color = coalitionColor != null
        ? Color(int.parse('0xFF${coalitionColor!.replaceAll('#', '')}'))
        : const Color(0xFF00BABC);

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getAchievementIcon(achievement.kind),
            size: 32,
            color: achievement.tier != 'none' ? color : Colors.white.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          Text(
            achievement.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (achievement.tier != 'none') ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                achievement.tier.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getAchievementIcon(String kind) {
    switch (kind) {
      case 'project':
        return Icons.article;
      case 'social':
        return Icons.people;
      case 'pedagogy':
        return Icons.school;
      case 'scolarity':
        return Icons.schedule;
      default:
        return Icons.emoji_events;
    }
  }

  Widget _buildEmptyState() {
    return GlassContainer(
      child: Column(
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 60,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No achievements yet',
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
