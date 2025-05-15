class CoalitionUserModel {
  CoalitionUserModel({
    required this.id,
    required this.score,
    required this.rank,
    required this.coalitionId,
    required this.userId,
  });

  factory CoalitionUserModel.fromJson(Map<String, dynamic> json) {
    return CoalitionUserModel(
      id: json['id'] as int,
      score: (json['score'] as num?)?.toInt() ?? 0,
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      coalitionId: json['coalition_id'] as int,
      userId: json['user_id'] as int,
    );
  }

  final int id;
  final int score;
  final int rank;
  final int coalitionId;
  final int userId;
}
