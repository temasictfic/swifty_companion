import 'json_utils.dart';

class CoalitionModel {
  const CoalitionModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.color,
    required this.score,
    required this.slug,
    this.coverUrl,
  });

  factory CoalitionModel.fromJson(Map<String, dynamic> json) {
    final cover = asStringOrNull(json['cover_url']);
    return CoalitionModel(
      id: asInt(json['id']),
      name: asString(json['name']),
      imageUrl: asString(json['image_url']),
      color: asString(json['color'], '#00BABC'),
      coverUrl: (cover == null || cover.isEmpty) ? null : cover,
      score: asInt(json['score']),
      slug: asString(json['slug']),
    );
  }

  final int id;
  final String name;
  final String imageUrl;
  final String color;
  final String? coverUrl;
  final int score;
  final String slug;

  /// ARGB value of [color]; falls back to the app's teal for malformed values.
  int get colorValue {
    var hex = color.replaceAll('#', '').trim();
    if (hex.length == 3) hex = hex.split('').map((c) => '$c$c').join();
    final rgb = hex.length == 6 ? int.tryParse(hex, radix: 16) : null;
    return 0xFF000000 | (rgb ?? 0x00BABC);
  }
}
