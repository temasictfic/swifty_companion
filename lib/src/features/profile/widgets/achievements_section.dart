import 'package:material_ui/material_ui.dart';

import '../../../core/models/user_model.dart';
import '../../../shared/widgets/surface_card.dart';
import 'section_empty_state.dart';

/// Lazily built 2-column achievements grid (replaces the eager
/// flutter_staggered_grid_view grid, which built every tile up front).
class AchievementsSliver extends StatelessWidget {
  const AchievementsSliver({
    required this.achievements,
    required this.accent,
    super.key,
  });

  final List<AchievementModel> achievements;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    if (achievements.isEmpty) {
      return const SliverToBoxAdapter(
        child: SectionEmptyState(
          icon: Icons.emoji_events_outlined,
          text: 'No achievements yet',
        ),
      );
    }
    return SliverGrid.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 168,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) =>
          _AchievementCard(achievement: achievements[index], accent: accent),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.achievement, required this.accent});

  final AchievementModel achievement;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final hasTier = achievement.hasTier;

    return Tooltip(
      message: achievement.description,
      triggerMode: TooltipTriggerMode.tap,
      child: SurfaceCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _icon(achievement.kind),
              size: 32,
              color: hasTier ? accent : Colors.white60,
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
            if (hasTier) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  achievement.tier.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: accent,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static IconData _icon(String kind) => switch (kind) {
    'project' => Icons.article,
    'social' => Icons.people,
    'pedagogy' => Icons.school,
    'scolarity' => Icons.schedule,
    _ => Icons.emoji_events,
  };
}
