import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/models/coalition_user_model.dart';
import '../../../core/models/user_model.dart';
import 'profile_section.dart';
import 'profile_stats.dart';

class ProfileInfoTab extends StatelessWidget {
  const ProfileInfoTab({
    required this.user,
    required this.accent,
    this.coalitionUser,
    super.key,
  });

  final UserModel user;
  final CoalitionUserModel? coalitionUser;
  final Color accent;

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    final activeProjects = user.activeProjectCount;
    final poolMonth = user.poolMonth;

    return Column(
      children: [
        ProfileStats(user: user, coalitionUser: coalitionUser, accent: accent),
        const SizedBox(height: 24),
        ProfileSection(
          title: 'Contact Information',
          icon: Icons.contact_mail,
          children: [
            if (user.email.isNotEmpty) _InfoRow(Icons.email, user.email),
            if (user.phone != null) _InfoRow(Icons.phone, user.phone!),
            if (user.location != null)
              _InfoRow(Icons.location_on, user.location!),
          ],
        ),
        const SizedBox(height: 16),
        ProfileSection(
          title: 'Academic Information',
          icon: Icons.school,
          children: [
            _InfoRow(Icons.pool, 'Pool: ${user.poolYear ?? "N/A"}'),
            if (poolMonth != null && poolMonth.isNotEmpty)
              _InfoRow(
                Icons.calendar_month,
                'Pool Month: ${poolMonth[0].toUpperCase()}${poolMonth.substring(1)}',
              ),
            _InfoRow(
              Icons.timeline,
              'Enrolled Cursus: ${user.cursusUsers.length}',
            ),
            _InfoRow(Icons.star, 'Current Grade: ${user.currentGrade}'),
            if (activeProjects > 0)
              _InfoRow(Icons.assignment, 'Active Projects: $activeProjects'),
            _InfoRow(
              Icons.check_circle_outline,
              'Completed Projects: ${user.completedProjectCount}',
            ),
            _InfoRow(
              Icons.today,
              'Member Since: ${user.createdAt == null ? 'N/A' : _dateFormat.format(user.createdAt!)}',
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.value);

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.white54),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
