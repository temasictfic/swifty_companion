import 'json_utils.dart';

class CoalitionUserModel {
  const CoalitionUserModel({
    required this.id,
    required this.score,
    required this.rank,
    required this.coalitionId,
    required this.userId,
  });

  factory CoalitionUserModel.fromJson(Map<String, dynamic> json) {
    return CoalitionUserModel(
      id: asInt(json['id']),
      score: asInt(json['score']),
      rank: asIntOrNull(json['rank']),
      coalitionId: asInt(json['coalition_id']),
      userId: asInt(json['user_id']),
    );
  }

  final int id;
  final int score;
  final int? rank;
  final int coalitionId;
  final int userId;
}
