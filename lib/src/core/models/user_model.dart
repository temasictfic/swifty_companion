import 'json_utils.dart';
import 'project_model.dart';

/// 42cursus and C Piscine cursus ids on the 42 intra.
const int kMainCursusId = 21;
const int kPiscineCursusId = 9;

class UserModel {
  const UserModel({
    required this.id,
    required this.login,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.displayName,
    required this.correctionPoint,
    required this.wallet,
    required this.level,
    required this.skills,
    required this.achievements,
    required this.isActive,
    required this.cursusUsers,
    this.projects = const [],
    this.phone,
    this.imageUrl,
    this.smallImageUrl,
    this.poolYear,
    this.poolMonth,
    this.location,
    this.createdAt,
  });

  /// Parses both the light objects returned by `/users?search` and the full
  /// object returned by `/users/:login` (which embeds `projects_users`).
  factory UserModel.fromJson(Map<String, dynamic> json) {
    final cursusUsers = asMapList(json['cursus_users']);
    final mainCursus = _pickMainCursus(cursusUsers);

    var skills = asMapList(mainCursus?['skills']);
    if (skills.isEmpty) skills = asMapList(json['skills']);

    final image = asMap(json['image']);
    final versions = asMap(image?['versions']);

    final projects =
        asMapList(json['projects_users']).map(ProjectModel.fromJson).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final login = asString(json['login']);
    final phone = asStringOrNull(json['phone']);

    return UserModel(
      id: asInt(json['id']),
      login: login,
      email: asString(json['email']),
      firstName: asString(json['first_name']),
      lastName: asString(json['last_name']),
      displayName: asString(
        json['displayname'] ?? json['usual_full_name'],
        login,
      ),
      // The intra returns the literal string "hidden" for private phone numbers.
      phone: (phone == null || phone.isEmpty || phone == 'hidden')
          ? null
          : phone,
      imageUrl: asStringOrNull(image?['link']),
      smallImageUrl:
          asStringOrNull(versions?['small']) ?? asStringOrNull(image?['link']),
      correctionPoint: asInt(json['correction_point']),
      wallet: asInt(json['wallet']),
      poolYear: asStringOrNull(json['pool_year']),
      poolMonth: asStringOrNull(json['pool_month']),
      level: asDouble(mainCursus?['level']),
      skills: skills.map(SkillModel.fromJson).toList(growable: false),
      achievements: asMapList(json['achievements'])
          .map(AchievementModel.fromJson)
          .toList(growable: false),
      location: asStringOrNull(json['location']),
      isActive: json['active?'] == true,
      createdAt: asDate(json['created_at']),
      cursusUsers: cursusUsers.map(CursusUser.fromJson).toList(growable: false),
      projects: List.unmodifiable(projects),
    );
  }

  static Map<String, dynamic>? _pickMainCursus(
    List<Map<String, dynamic>> cursusUsers,
  ) {
    if (cursusUsers.isEmpty) return null;
    for (final id in const [kMainCursusId, kPiscineCursusId]) {
      for (final cursus in cursusUsers) {
        if (asInt(cursus['cursus_id']) == id) return cursus;
      }
    }
    return cursusUsers.reduce(
      (a, b) => asDouble(a['level']) >= asDouble(b['level']) ? a : b,
    );
  }

  final int id;
  final String login;
  final String email;
  final String firstName;
  final String lastName;
  final String displayName;
  final String? phone;

  /// Full-resolution avatar (used on the profile header).
  final String? imageUrl;

  /// Smaller avatar variant (used in lists) — far less data to download & decode.
  final String? smallImageUrl;
  final int correctionPoint;
  final int wallet;
  final String? poolYear;
  final String? poolMonth;
  final double level;
  final List<SkillModel> skills;
  final List<AchievementModel> achievements;
  final String? location;
  final bool isActive;
  final DateTime? createdAt;
  final List<CursusUser> cursusUsers;
  final List<ProjectModel> projects;

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? displayName : name;
  }

  double get levelProgress => level - level.floor();

  String get levelDisplay =>
      'Level ${level.floor()} - ${(levelProgress * 100).toStringAsFixed(0)}%';

  int get activeProjectCount => projects.where((p) => p.isActive).length;

  int get completedProjectCount => projects.where((p) => p.isCompleted).length;

  String get currentGrade {
    final now = DateTime.now();
    bool isActive(CursusUser c) => c.endAt == null || c.endAt!.isAfter(now);

    for (final cursus in cursusUsers) {
      if (cursus.cursusId == kMainCursusId && isActive(cursus)) {
        return cursus.grade ?? 'Student';
      }
    }
    final active = cursusUsers.where(isActive).toList()
      ..sort((a, b) => b.level.compareTo(a.level));
    return active.isEmpty ? 'None' : (active.first.grade ?? 'Student');
  }
}

class CursusUser {
  const CursusUser({
    required this.id,
    required this.level,
    required this.cursusId,
    this.grade,
    this.cursus,
    this.beginAt,
    this.endAt,
  });

  factory CursusUser.fromJson(Map<String, dynamic> json) {
    final cursus = asMap(json['cursus']);
    return CursusUser(
      id: asInt(json['id']),
      grade: asStringOrNull(json['grade']),
      level: asDouble(json['level']),
      cursusId: asInt(json['cursus_id']),
      beginAt: asDate(json['begin_at']),
      endAt: asDate(json['end_at']),
      cursus: cursus == null ? null : Cursus.fromJson(cursus),
    );
  }

  final int id;
  final String? grade;
  final double level;
  final int cursusId;
  final DateTime? beginAt;
  final DateTime? endAt;
  final Cursus? cursus;
}

class Cursus {
  const Cursus({
    required this.id,
    required this.name,
    required this.slug,
    required this.kind,
  });

  factory Cursus.fromJson(Map<String, dynamic> json) {
    return Cursus(
      id: asInt(json['id']),
      name: asString(json['name']),
      slug: asString(json['slug']),
      kind: asString(json['kind']),
    );
  }

  final int id;
  final String name;
  final String slug;
  final String kind;
}

class SkillModel {
  const SkillModel({required this.name, required this.level});

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      name: asString(json['name']),
      level: asDouble(json['level']),
    );
  }

  final String name;
  final double level;
}

class AchievementModel {
  const AchievementModel({
    required this.name,
    required this.description,
    required this.kind,
    required this.tier,
    this.imageUrl,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      name: asString(json['name']),
      description: asString(json['description']),
      kind: asString(json['kind']),
      tier: asString(json['tier'], 'none'),
      imageUrl: asStringOrNull(json['image']),
    );
  }

  final String name;
  final String description;
  final String kind;
  final String tier;
  final String? imageUrl;

  bool get hasTier => tier.isNotEmpty && tier != 'none';
}
