class UserModel {

  UserModel({
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
    this.phone,
    this.imageUrl,
    this.poolYear,
    this.poolMonth,
    this.location,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Parse the current cursus user data
    final cursusUsers = json['cursus_users'] as List<dynamic>? ?? [];
        
    // Find the main 42 cursus (cursus_id: 21 is typically the main cursus)
    Map<String, dynamic>? currentCursus;
    
    // First try to find cursus with id 21 (42cursus)
    for (final cursus in cursusUsers) {
      if (cursus['cursus_id'] == 21 || cursus['cursus_id'] == 9) { // 21 is 42cursus, 9 is C Piscine
        currentCursus = cursus as Map<String, dynamic>;
        break;
      }
    }
    
    // If not found, use the last cursus or the one with the highest level
    if (currentCursus == null && cursusUsers.isNotEmpty) {
      // Sort by level to get the highest one
      final sortedCursus = List<Map<String, dynamic>>.from(cursusUsers)
        ..sort((a, b) {
          final levelA = (a['level'] as num?)?.toDouble() ?? 0.0;
          final levelB = (b['level'] as num?)?.toDouble() ?? 0.0;
          return levelB.compareTo(levelA);
        });
      currentCursus = sortedCursus.first;
    }
    
    // Parse level and skills from cursus data
    final level = currentCursus?['level'] != null ? (currentCursus!['level'] as num).toDouble() : 0.0;
    final skills = currentCursus?['skills'] as List<dynamic>? ?? [];
    
    // If no skills in cursus, check if they're in the main user object
    var finalSkills = skills;
    if (finalSkills.isEmpty && json['skills'] != null) {
      finalSkills = json['skills'] as List<dynamic>;
    }
    
    // Parse achievements
    final achievements = json['achievements'] as List<dynamic>? ?? [];
    
    // Parse cursus users
    final cursusUsersList = cursusUsers.map((cursusData) => CursusUser.fromJson(cursusData as Map<String, dynamic>)).toList();
    
    return UserModel(
      login: json['login']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      displayName: json['displayname']?.toString() ?? json['login']?.toString() ?? '',
      phone: json['phone'] as String?,
      imageUrl: json['image']?['link'] as String?,
      correctionPoint: json['correction_point'] as int? ?? 0,
      wallet: json['wallet'] as int? ?? 0,
      poolYear: json['pool_year'] as String?,
      poolMonth: json['pool_month'] as String?,
      level: level,
      skills: finalSkills.map((skill) => SkillModel.fromJson(skill as Map<String, dynamic>)).toList(),
      achievements: achievements.map((achievement) => AchievementModel.fromJson(achievement as Map<String, dynamic>)).toList(),
      location: json['location'] as String?,
      isActive: json['active?'] == true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'].toString()) : null,
      cursusUsers: cursusUsersList,
    );
  }
  
  final String login;
  final String email;
  final String firstName;
  final String lastName;
  final String displayName;
  final String? phone;
  final String? imageUrl;
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
  final DateTime? updatedAt;
  final List<CursusUser> cursusUsers;

  String get fullName => '$firstName $lastName';
  
  double get levelProgress => level - level.floor();
  
  String get levelDisplay => 'Level ${level.floor()} - ${(levelProgress * 100).toStringAsFixed(0)}%';
}

class CursusUser {
  CursusUser({
    required this.id,
    required this.grade,
    required this.level,
    required this.cursusId,
    required this.cursus,
    this.beginAt,
    this.endAt,
  });

  factory CursusUser.fromJson(Map<String, dynamic> json) {
    return CursusUser(
      id: json['id'] as int,
      grade: json['grade'] as String?,
      level: (json['level'] as num).toDouble(),
      cursusId: json['cursus_id'] as int,
      beginAt: json['begin_at'] != null ? DateTime.parse(json['begin_at'].toString()) : null,
      endAt: json['end_at'] != null ? DateTime.parse(json['end_at'].toString()) : null,
      cursus: json['cursus'] != null ? Cursus.fromJson(json['cursus'] as Map<String, dynamic>) : null,
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
  Cursus({
    required this.id,
    required this.name,
    required this.slug,
    required this.kind,
  });

  factory Cursus.fromJson(Map<String, dynamic> json) {
    return Cursus(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      kind: json['kind'] as String,
    );
  }

  final int id;
  final String name;
  final String slug;
  final String kind;
}

class SkillModel {

  SkillModel({
    required this.name,
    required this.level,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      name: json['name']?.toString() ?? '',
      level: json['level'] != null 
          ? (json['level'] is double 
              ? json['level'] as double 
              : (json['level'] as num).toDouble())
          : 0.0,
    );
  }
  final String name;
  final double level;
}

class AchievementModel {

  AchievementModel({
    required this.name,
    required this.description,
    required this.kind,
    required this.tier,
    this.imageUrl,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      kind: json['kind']?.toString() ?? '',
      tier: json['tier']?.toString() ?? '',
      imageUrl: json['image'] as String?,
    );
  }
  final String name;
  final String description;
  final String kind;
  final String tier;
  final String? imageUrl;
}
