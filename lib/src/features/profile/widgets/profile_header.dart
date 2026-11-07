import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/models/coalition_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/themes/app_theme.dart';
import '../../../shared/widgets/user_avatar.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    required this.user,
    required this.accent,
    this.coalition,
    super.key,
  });

  final UserModel user;
  final CoalitionModel? coalition;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final coalition = this.coalition;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 120,
                height: 120,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent,
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Hero(
                  tag: 'avatar-${user.login}',
                  child: UserAvatar(
                    imageUrl: user.imageUrl,
                    placeholderUrl: user.smallImageUrl,
                    size: 114,
                  ),
                ),
              ),
              if (coalition != null && coalition.imageUrl.isNotEmpty)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.backgroundColor,
                      width: 3,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.network(
                    coalition.imageUrl,
                    width: 22,
                    height: 22,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                    errorBuilder: (_, _, _) =>
                        const Icon(Icons.shield, size: 20, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user.fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '@${user.login}',
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 200,
            height: 8,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0x1AFFFFFF),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: user.levelProgress.clamp(0.0, 1.0),
                  heightFactor: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accent, accent.withValues(alpha: 0.7)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.levelDisplay,
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
          if (coalition != null) ...[
            const SizedBox(height: 8),
            Text(
              coalition.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: accent,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
