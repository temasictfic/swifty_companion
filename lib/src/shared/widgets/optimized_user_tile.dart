import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttery_mate/src/core/models/user_model.dart';


class OptimizedUserTile extends StatelessWidget {
  const OptimizedUserTile({required this.user, super.key});
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      color: Colors.white.withValues(alpha: 0.05),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToProfile(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Optimized avatar
              _buildAvatar(),
              const SizedBox(width: 12),
              // User info
              Expanded(child: _buildUserInfo()),
              // Arrow indicator
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withValues(alpha: 0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: user.imageUrl ?? '',
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        memCacheWidth: 150, // Increased for better quality
        memCacheHeight: 150,
        fadeInDuration: const Duration(milliseconds: 150),
        placeholder: (context, url) => Container(
          width: 50,
          height: 50,
          color: Colors.white.withValues(alpha: 0.1),
        ),
        errorWidget: (context, url, error) => Container(
          width: 50,
          height: 50,
          color: Colors.white.withValues(alpha: 0.1),
          child: const Icon(
            Icons.person,
            color: Colors.white54,
            size: 25,
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          user.displayName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: 2),
        Text(
          user.login,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.7),
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/profile',
      arguments: user.login,
    );
  }
}
