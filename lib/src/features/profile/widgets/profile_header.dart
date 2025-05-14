import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/models/coalition_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/themes/app_theme.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    required this.user, super.key,
    this.coalition,
  });
  final UserModel user;
  final CoalitionModel? coalition;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Profile picture with coalition badge
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              // Profile picture
              Hero(
                tag: 'user-${user.login}',
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: coalition?.colorValue != null
                          ? Color(coalition!.colorValue)
                          : AppTheme().primaryColor,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (coalition?.colorValue != null
                                ? Color(coalition!.colorValue)
                                : AppTheme().primaryColor)
                            .withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: user.imageUrl ?? '',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.white.withValues(alpha: 0.1),
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Coalition badge
              if (coalition != null)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(coalition!.colorValue),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme().backgroundColor,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: SvgPicture.network(
                      coalition!.imageUrl,
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // User name
          Text(
            user.fullName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 4),

          // Login
          Text(
            '@${user.login}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),

          const SizedBox(height: 16),

          // Level progress bar
          Container(
            width: 200,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: user.levelProgress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          if (coalition?.colorValue != null)
                            Color(coalition!.colorValue)
                          else
                            AppTheme().primaryColor,
                          if (coalition?.colorValue != null)
                            Color(coalition!.colorValue).withValues(alpha: 0.7)
                          else
                            AppTheme().secondaryColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Level text
          Text(
            user.levelDisplay,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),

          // Coalition name
          if (coalition != null) ...[
            const SizedBox(height: 8),
            Text(
              coalition!.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(coalition!.colorValue),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
