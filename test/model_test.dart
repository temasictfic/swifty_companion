import 'package:flutter_test/flutter_test.dart';
import 'package:swifty_companion/src/core/models/coalition_model.dart';
import 'package:swifty_companion/src/core/models/project_model.dart';
import 'package:swifty_companion/src/core/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('should parse user data correctly', () {
      final json = {
        'login': 'testuser',
        'email': 'test@42.fr',
        'first_name': 'Test',
        'last_name': 'User',
        'displayname': 'Test User',
        'phone': '+1234567890',
        'image': {'link': 'https://example.com/avatar.jpg'},
        'correction_point': 5,
        'wallet': 100,
        'pool_year': '2023',
        'location': 'A1',
        'active?': true,
        'created_at': '2023-01-01T00:00:00.000Z',
        'cursus_users': [
          {
            'level': 4.2,
            'skills': [
              {'name': 'Algorithms', 'level': 3.5},
              {'name': 'Graphics', 'level': 2.8},
            ],
          }
        ],
        'achievements': [
          {
            'name': 'First Project',
            'description': 'Complete your first project',
            'kind': 'project',
            'tier': 'easy',
          }
        ],
      };

      final user = UserModel.fromJson(json);

      expect(user.login, 'testuser');
      expect(user.email, 'test@42.fr');
      expect(user.fullName, 'Test User');
      expect(user.level, 4.2);
      expect(user.levelProgress, closeTo(0.2, 0.001));
      expect(user.skills.length, 2);
      expect(user.achievements.length, 1);
    });
  });

  group('ProjectModel', () {
    test('should parse project data correctly', () {
      final json = {
        'project': {
          'name': 'ft_printf',
          'slug': 'ft-printf',
          'image_url': 'https://example.com/project.png',
        },
        'final_mark': 125,
        'status': 'finished',
        'validated?': true,
        'created_at': '2023-06-01T00:00:00.000Z',
        'marked_at': '2023-06-15T00:00:00.000Z',
        'occurrence': 0,
      };

      final project = ProjectModel.fromJson(json);

      expect(project.name, 'ft_printf');
      expect(project.finalMark, 125);
      expect(project.isSuccess, true);
      expect(project.isExcellent, true);
      expect(project.displayStatus, '125');
    });

    test('should handle in-progress projects', () {
      final json = {
        'project': {
          'name': 'webserv',
          'slug': 'webserv',
        },
        'status': 'in_progress',
        'validated?': false,
        'created_at': '2023-07-01T00:00:00.000Z',
        'occurrence': 0,
      };

      final project = ProjectModel.fromJson(json);

      expect(project.isInProgress, true);
      expect(project.finalMark, null);
      expect(project.displayStatus, 'In Progress');
    });
  });

  group('CoalitionModel', () {
    test('should parse coalition data correctly', () {
      final json = {
        'id': 1,
        'name': 'The Federation',
        'image_url': 'https://example.com/coalition.svg',
        'color': '#00FF00',
        'cover_url': 'https://example.com/cover.jpg',
        'score': 42000,
        'slug': 'the-federation',
      };

      final coalition = CoalitionModel.fromJson(json);

      expect(coalition.name, 'The Federation');
      expect(coalition.color, '#00FF00');
      expect(coalition.colorValue, 0xFF00FF00);
      expect(coalition.score, 42000);
    });
  });
}
