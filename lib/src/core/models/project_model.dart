import 'json_utils.dart';

class ProjectModel {
  const ProjectModel({
    required this.name,
    required this.slug,
    required this.status,
    required this.validated,
    required this.occurrence,
    required this.createdAt,
    this.finalMark,
    this.markedAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    final project = asMap(json['project']) ?? const {};
    return ProjectModel(
      name: asString(project['name']),
      slug: asString(project['slug']),
      finalMark: asIntOrNull(json['final_mark']),
      status: asString(json['status']),
      validated: json['validated?'] == true,
      createdAt:
          asDate(json['created_at']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      markedAt: asDate(json['marked_at']),
      occurrence: asInt(json['occurrence']),
    );
  }

  final String name;
  final String slug;
  final int? finalMark;
  final String status;
  final bool validated;
  final DateTime createdAt;
  final DateTime? markedAt;
  final int occurrence;

  bool get isSuccess => finalMark != null && finalMark! >= 80;
  bool get isExcellent => finalMark != null && finalMark! > 100;
  bool get isInProgress => status == 'in_progress';
  bool get isActive => status == 'in_progress' || status == 'searching_a_group';
  bool get isFailed => status == 'finished' && !validated;
  bool get isCompleted => status == 'finished' && validated;

  String get displayStatus {
    if (isInProgress) return 'In Progress';
    if (status == 'finished') {
      if (finalMark != null) return finalMark.toString();
      return validated ? 'Passed' : 'Failed';
    }
    return status.replaceAll('_', ' ');
  }
}
