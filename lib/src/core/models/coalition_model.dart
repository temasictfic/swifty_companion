class CoalitionModel {

  CoalitionModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.color,
    required this.score,
    required this.slug,
    this.coverUrl,
  });

  factory CoalitionModel.fromJson(Map<String, dynamic> json) {
    return CoalitionModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      color: json['color'] as String? ?? '#000000',
      coverUrl: json['cover_url'] as String?,
      score: (json['score'] as num?)?.toInt() ?? 0,
      slug: json['slug'] as String? ?? '',
    );
  }
  final int id;
  final String name;
  final String imageUrl;
  final String color;
  final String? coverUrl;
  final int score;
  final String slug;

  int get colorValue => int.parse('0xFF${color.replaceAll('#', '')}');
}
