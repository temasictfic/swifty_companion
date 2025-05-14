class ProjectModel {

  ProjectModel({
    required this.name,
    required this.slug,
    required this.status,
    required this.validated,
    required this.occurrence,
    required this.createdAt,
    this.finalMark,
    this.projectImageUrl,
    this.markedAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    final project = json['project'] as Map<String, dynamic>? ?? {};
    
    return ProjectModel(
      name: project['name']?.toString() ?? '',
      slug: project['slug']?.toString() ?? '',
      finalMark: json['final_mark'] as int?,
      status: json['status']?.toString() ?? '',
      validated: json['validated?'] == true,
      projectImageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'].toString()),
      markedAt: json['marked_at'] != null ? DateTime.parse(json['marked_at'].toString()) : null,
      occurrence: json['occurrence'] as int? ?? 0,
    );
  }
  final String name;
  final String slug;
  final int? finalMark;
  final String status;
  final bool validated;
  final String? projectImageUrl;
  final DateTime createdAt;
  final DateTime? markedAt;
  final int occurrence;

  bool get isSuccess => finalMark != null && finalMark! >= 80;
  bool get isExcellent => finalMark != null && finalMark! > 100;
  bool get isInProgress => status == 'in_progress';
  bool get isFailed => status == 'finished' && !validated;
  
  String get displayStatus {
    if (isInProgress) {
      return 'In Progress';
    }
    if (status == 'finished') {
      if (finalMark != null) {
        return finalMark.toString();
      }
      return validated ? 'Passed' : 'Failed';
    }
    return status;
  }
}
