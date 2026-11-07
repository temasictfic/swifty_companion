import 'package:material_ui/material_ui.dart';

import '../../../core/models/coalition_user_model.dart';
import '../../../core/models/user_model.dart';
import '../../../shared/widgets/surface_card.dart';

class ProfileStats extends StatelessWidget {
  const ProfileStats({
    required this.user,
    required this.accent,
    this.coalitionUser,
    super.key,
  });

  final UserModel user;
  final CoalitionUserModel? coalitionUser;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final rank = coalitionUser?.rank;
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Row(
        children: [
          _stat(Icons.account_balance_wallet, '${user.wallet}₳', 'Wallet'),
          _divider,
          _stat(Icons.check_circle, '${user.correctionPoint}', 'Evo Points'),
          _divider,
          _stat(Icons.emoji_events, '${coalitionUser?.score ?? 0}', 'Score'),
          _divider,
          _stat(Icons.leaderboard, rank != null ? '#$rank' : 'N/A', 'Rank'),
        ],
      ),
    );
  }

  static const Widget _divider = SizedBox(
    height: 40,
    width: 1,
    child: ColoredBox(color: Color(0x33FFFFFF)),
  );

  Widget _stat(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: accent, size: 24),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
