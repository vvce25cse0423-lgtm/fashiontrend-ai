/// User profile data model
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final int? age;
  final String? gender;
  final double? height;
  final double? weight;
  final String? skinTone;
  final String? bodyType;
  final String? faceShape;
  final String? fashionStyle;
  final List<String> favoriteColors;
  final String? budgetRange;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.age,
    this.gender,
    this.height,
    this.weight,
    this.skinTone,
    this.bodyType,
    this.faceShape,
    this.fashionStyle,
    this.favoriteColors = const [],
    this.budgetRange,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      skinTone: json['skin_tone'] as String?,
      bodyType: json['body_type'] as String?,
      faceShape: json['face_shape'] as String?,
      fashionStyle: json['fashion_style'] as String?,
      favoriteColors: (json['favorite_colors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      budgetRange: json['budget_range'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'skin_tone': skinTone,
      'body_type': bodyType,
      'face_shape': faceShape,
      'fashion_style': fashionStyle,
      'favorite_colors': favoriteColors,
      'budget_range': budgetRange,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? name,
    String? avatarUrl,
    int? age,
    String? gender,
    double? height,
    double? weight,
    String? skinTone,
    String? bodyType,
    String? faceShape,
    String? fashionStyle,
    List<String>? favoriteColors,
    String? budgetRange,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      skinTone: skinTone ?? this.skinTone,
      bodyType: bodyType ?? this.bodyType,
      faceShape: faceShape ?? this.faceShape,
      fashionStyle: fashionStyle ?? this.fashionStyle,
      favoriteColors: favoriteColors ?? this.favoriteColors,
      budgetRange: budgetRange ?? this.budgetRange,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
