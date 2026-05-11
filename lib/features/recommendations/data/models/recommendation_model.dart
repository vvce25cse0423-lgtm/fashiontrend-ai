class RecommendationModel {
  final String id;
  final String userId;
  final String name;
  final String type;
  final String content;
  final String occasion;
  final String season;
  final DateTime createdAt;

  const RecommendationModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.content,
    required this.occasion,
    required this.season,
    required this.createdAt,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'outfit',
      content: json['content'] as String? ?? '',
      occasion: json['occasion'] as String? ?? '',
      season: json['season'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
