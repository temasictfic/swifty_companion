import 'package:material_ui/material_ui.dart';

import '../../../core/models/user_model.dart';
import '../../../shared/widgets/surface_card.dart';
import 'section_empty_state.dart';

class SkillsSliver extends StatelessWidget {
  const SkillsSliver({required this.skills, required this.accent, super.key});

  final List<SkillModel> skills;
  final Color accent;

  /// Skill levels are shown against this ceiling.
  static const double maxLevel = 20;

  @override
  Widget build(BuildContext context) {
    if (skills.isEmpty) {
      return const SliverToBoxAdapter(
        child: SectionEmptyState(
          icon: Icons.star_border,
          text: 'No skills available',
        ),
      );
    }
    final barGradient = LinearGradient(
      colors: [accent, accent.withValues(alpha: 0.7)],
    );

    return SliverList.builder(
      itemCount: skills.length,
      itemBuilder: (context, index) {
        final skill = skills[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        skill.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Level ${skill.level.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 8,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0x1AFFFFFF),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: (skill.level / maxLevel).clamp(0.0, 1.0),
                        heightFactor: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: barGradient,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
