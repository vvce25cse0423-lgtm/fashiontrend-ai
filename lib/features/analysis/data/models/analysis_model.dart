/// Model for storing AI selfie analysis results
class AiAnalysis {
  final String id;
  final String userId;
  final String imageUrl;
  final String faceShape;
  final String skinTone;
  final String bodyType;
  final String hairTexture;
  final String gender;
  final List<String> dominantColors;
  final String currentStyle;
  final int styleScore;
  final Map<String, dynamic> rawData;
  final DateTime createdAt;

  const AiAnalysis({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.faceShape,
    required this.skinTone,
    required this.bodyType,
    required this.hairTexture,
    required this.gender,
    required this.dominantColors,
    required this.currentStyle,
    required this.styleScore,
    required this.rawData,
    required this.createdAt,
  });

  factory AiAnalysis.fromJson(Map<String, dynamic> json) {
    return AiAnalysis(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      imageUrl: json['image_url'] as String,
      faceShape: json['face_shape'] as String? ?? 'Unknown',
      skinTone: json['skin_tone'] as String? ?? 'Unknown',
      bodyType: json['body_type'] as String? ?? 'Unknown',
      hairTexture: json['hair_texture'] as String? ?? 'Unknown',
      gender: json['gender'] as String? ?? 'Unknown',
      dominantColors: (json['dominant_colors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      currentStyle: json['current_style'] as String? ?? 'Casual',
      styleScore: json['style_score'] as int? ?? 0,
      rawData: json['raw_data'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'image_url': imageUrl,
      'face_shape': faceShape,
      'skin_tone': skinTone,
      'body_type': bodyType,
      'hair_texture': hairTexture,
      'gender': gender,
      'dominant_colors': dominantColors,
      'current_style': currentStyle,
      'style_score': styleScore,
      'raw_data': rawData,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Model for a single outfit recommendation
class OutfitRecommendation {
  final String id;
  final String userId;
  final String name;
  final List<String> items;
  final List<String> colors;
  final String occasion;
  final String season;
  final int styleScore;
  final List<String> tags;
  final bool isSaved;
  final DateTime createdAt;

  const OutfitRecommendation({
    required this.id,
    required this.userId,
    required this.name,
    required this.items,
    required this.colors,
    required this.occasion,
    required this.season,
    required this.styleScore,
    required this.tags,
    this.isSaved = false,
    required this.createdAt,
  });

  factory OutfitRecommendation.fromJson(Map<String, dynamic> json) {
    return OutfitRecommendation(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      items: (json['items'] as List<dynamic>).map((e) => e.toString()).toList(),
      colors: (json['colors'] as List<dynamic>).map((e) => e.toString()).toList(),
      occasion: json['occasion'] as String? ?? 'Casual',
      season: json['season'] as String? ?? 'All',
      styleScore: json['style_score'] as int? ?? 0,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isSaved: json['is_saved'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'items': items,
      'colors': colors,
      'occasion': occasion,
      'season': season,
      'style_score': styleScore,
      'tags': tags,
      'is_saved': isSaved,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Chat message model for AI stylist
class ChatMessage {
  final String id;
  final String userId;
  final String content;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.userId,
    required this.content,
    required this.isUser,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      isUser: json['is_user'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'content': content,
      'is_user': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
