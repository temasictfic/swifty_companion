import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';
import '../../../shared/widgets/optimized_glass_container.dart';

class SkillsSection extends StatelessWidget {
  const SkillsSection({
    required this.skills, super.key,
    this.coalitionColor,
  });
  final List<SkillModel> skills;
  final String? coalitionColor;

  @override
  Widget build(BuildContext context) {
    if (skills.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: skills.map((skill) => _buildSkillItem(skill)).toList(),
    );
  }

  Widget _buildSkillItem(SkillModel skill) {
    final color = coalitionColor != null
        ? Color(int.parse('0xFF${coalitionColor!.replaceAll('#', '')}'))
        : const Color(0xFF00BABC);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: OptimizedGlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  skill.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Level ${skill.level.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress bar
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: (skill.level / 20).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color,
                            color.withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
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

  Widget _buildEmptyState() {
    return OptimizedGlassContainer(
      child: Column(
        children: [
          Icon(
            Icons.star_border,
            size: 60,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No skills available',
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
