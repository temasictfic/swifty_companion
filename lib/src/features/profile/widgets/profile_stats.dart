import 'package:flutter/material.dart';

import '../../../core/models/coalition_model.dart';
import '../../../core/models/coalition_user_model.dart';
import '../../../core/models/user_model.dart';
import '../../../shared/widgets/glass_container.dart';

class ProfileStats extends StatelessWidget {
  const ProfileStats({
    required this.user,
    super.key,
    this.coalition,
    this.coalitionUser,
  });
  final UserModel user;
  final CoalitionModel? coalition;
  final CoalitionUserModel? coalitionUser;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.account_balance_wallet,
              value: '${user.wallet}₳',
              label: 'Wallet',
            ),
          ),
          _buildDivider(),
          Expanded(
            child: _buildStatItem(
              icon: Icons.check_circle,
              value: user.correctionPoint.toString(),
              label: 'Evo Points',
            ),
          ),
          _buildDivider(),
          Expanded(
            child: _buildStatItem(
              icon: Icons.emoji_events,
              value: '${coalitionUser?.score ?? 0}',
              label: 'Score',
            ),
          ),
          _buildDivider(),
          Expanded(
            child: _buildStatItem(
              icon: Icons.leaderboard,
              value: coalitionUser?.rank != null ? '#${coalitionUser!.rank}' : 'N/A',
              label: 'Rank',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: coalition?.colorValue != null ? Color(coalition!.colorValue) : Colors.white,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }
}
