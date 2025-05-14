import 'package:flutter/material.dart';

import '../../../core/models/coalition_model.dart';
import '../../../core/models/user_model.dart';
import '../../../shared/widgets/glass_container.dart';

class ProfileStats extends StatelessWidget {
  const ProfileStats({
    required this.user, super.key,
    this.coalition,
  });
  final UserModel user;
  final CoalitionModel? coalition;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.account_balance_wallet,
            value: '${user.wallet}₳',
            label: 'Wallet',
          ),
          _buildDivider(),
          _buildStatItem(
            icon: Icons.check_circle,
            value: user.correctionPoint.toString(),
            label: 'Corrections',
          ),
          _buildDivider(),
          _buildStatItem(
            icon: Icons.emoji_events,
            value: coalition?.score.toString() ?? '0',
            label: 'Score',
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
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
