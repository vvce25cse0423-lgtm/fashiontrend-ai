import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// AI Service — OpenRouter for text + vision-based analysis
class AiService {
  static const _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';
  static const _textModel = 'meta-llama/llama-3.1-8b-instruct:free';
  static const _visionModel = 'meta-llama/llama-3.2-11b-vision-instruct:free';

  String get _apiKey => dotenv.env['OPENROUTER_API_KEY'] ?? '';

  static String _systemPrompt(String language) => '''
You are FashionTrend AI, a personal style assistant made for Indian people.
Give SHORT, PRACTICAL fashion advice in simple English.
Use Indian brands, ₹ rupees, Indian occasions and culture.
${language != 'en' ? 'Also reply in $language language.' : ''}
Keep response under 250 words. Use bullet points.
''';

  // ─────────────────────────────────────────────────────────────
  // PHOTO ANALYSIS — reads actual image and detects style details
  // ─────────────────────────────────────────────────────────────

  /// Analyses a selfie/photo and returns structured style data
  Future<PhotoAnalysisResult> analysePhoto(String imagePath) async {
    if (_apiKey.isEmpty) return _fallbackAnalysis();

    try {
      final imageFile = File(imagePath);
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final ext = imagePath.split('.').last.toLowerCase();
      final mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';

      final prompt = '''
Look at this photo carefully and give a detailed style analysis.
Return ONLY a valid JSON object with these exact keys — no extra text:

{
  "faceShape": "Oval|Round|Square|Heart|Diamond|Oblong",
  "skinTone": "Very Fair|Fair|Wheatish|Medium Brown|Dark Brown|Deep",
  "gender": "Male|Female|Unknown",
  "bodyType": "Slim|Athletic|Average|Plus Size|Petite",
  "hairStyle": "Short|Medium|Long|Curly|Wavy|Straight|Bald",
  "currentOutfitColors": ["color1", "color2"],
  "currentStyle": "Casual|Formal|Traditional|Streetwear|Smart Casual|Indo-Western|Sporty",
  "outfitScore": <number 1-100 based on how well dressed they look>,
  "colorHarmonyScore": <number 1-100 for color matching>,
  "groomingScore": <number 1-100 for grooming and neatness>,
  "overallScore": <number 1-100 overall style score>,
  "positives": ["what they are doing well style-wise"],
  "improvements": ["specific things to improve"],
  "recommendedColors": ["colors that suit their skin tone"],
  "recommendedStyle": "best fashion style for their body/face"
}

Be accurate based on what you actually see in the photo. 
Score honestly — don't just give high scores.
''';

      final res = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'HTTP-Referer': 'https://fashiontrend.ai',
          'X-Title': 'FashionTrend AI',
        },
        body: jsonEncode({
          'model': _visionModel,
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'image_url',
                  'image_url': {'url': 'data:$mimeType;base64,$base64Image'},
                },
                {'type': 'text', 'text': prompt},
              ],
            },
          ],
          'max_tokens': 600,
          'temperature': 0.3,
        }),
      ).timeout(const Duration(seconds: 45));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final content = data['choices'][0]['message']['content'] as String;
        return _parseAnalysisJson(content);
      }
      return _fallbackAnalysis();
    } catch (e) {
      return _fallbackAnalysis();
    }
  }

  PhotoAnalysisResult _parseAnalysisJson(String raw) {
    try {
      // Extract JSON block from response
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(raw);
      if (jsonMatch == null) return _fallbackAnalysis();
      final json = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;

      return PhotoAnalysisResult(
        faceShape: json['faceShape'] as String? ?? 'Oval',
        skinTone: json['skinTone'] as String? ?? 'Wheatish',
        gender: json['gender'] as String? ?? 'Unknown',
        bodyType: json['bodyType'] as String? ?? 'Average',
        hairStyle: json['hairStyle'] as String? ?? 'Medium',
        currentOutfitColors: (json['currentOutfitColors'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            ['Blue', 'White'],
        currentStyle: json['currentStyle'] as String? ?? 'Casual',
        outfitScore: (json['outfitScore'] as num?)?.toInt() ?? 70,
        colorHarmonyScore: (json['colorHarmonyScore'] as num?)?.toInt() ?? 70,
        groomingScore: (json['groomingScore'] as num?)?.toInt() ?? 70,
        overallScore: (json['overallScore'] as num?)?.toInt() ?? 70,
        positives: (json['positives'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            ['Good colour choices'],
        improvements: (json['improvements'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            ['Try adding accessories'],
        recommendedColors: (json['recommendedColors'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            ['Navy', 'White', 'Olive'],
        recommendedStyle: json['recommendedStyle'] as String? ?? 'Smart Casual',
        aiPowered: true,
      );
    } catch (_) {
      return _fallbackAnalysis();
    }
  }

  PhotoAnalysisResult _fallbackAnalysis() {
    return PhotoAnalysisResult(
      faceShape: 'Oval',
      skinTone: 'Wheatish',
      gender: 'Unknown',
      bodyType: 'Average',
      hairStyle: 'Medium',
      currentOutfitColors: ['Blue', 'White'],
      currentStyle: 'Casual',
      outfitScore: 68,
      colorHarmonyScore: 72,
      groomingScore: 70,
      overallScore: 70,
      positives: ['Decent colour selection', 'Clean and neat appearance'],
      improvements: [
        'Add your OpenRouter API key for real AI analysis',
        'Try accessories to elevate your look',
        'Ensure clothes are well-fitted',
      ],
      recommendedColors: ['Navy', 'White', 'Olive', 'Beige'],
      recommendedStyle: 'Smart Casual',
      aiPowered: false,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // OUTFIT RECOMMENDATIONS
  // ─────────────────────────────────────────────────────────────

  Future<String> getOutfitRecommendation({
    required String gender,
    required String skinTone,
    required String bodyType,
    required String occasion,
    required String season,
    required String budget,
    required String style,
    String language = 'en',
  }) async {
    final prompt = '''
Give a complete outfit for:
- Gender: $gender
- Skin tone: $skinTone
- Body type: $bodyType
- Occasion: $occasion
- Season: $season
- Budget: $budget
- Style: $style

Include: Top, Bottom, Footwear, 1 Accessory, best colours for their skin tone, where to buy in India.
Be specific to their skin tone and body type.
''';
    return _textCall(prompt, language);
  }

  Future<String> getShoeRecommendation({
    required String gender,
    required String occasion,
    required String outfitStyle,
    required String budget,
    String language = 'en',
  }) async {
    return _textCall('''Recommend 3 footwear options for $gender, $occasion, $outfitStyle style, budget $budget. Include brand names available in India and ₹ price.''', language);
  }

  Future<String> getWatchRecommendation({
    required String gender,
    required String occasion,
    required String budget,
    String language = 'en',
  }) async {
    return _textCall('''Recommend 2-3 watches for $gender, $occasion, budget $budget. Indian brands/options with ₹ price.''', language);
  }

  Future<String> getPerfumeRecommendation({
    required String gender,
    required String occasion,
    required String season,
    String language = 'en',
  }) async {
    return _textCall('''Recommend perfumes for $gender, $occasion, $season. Give affordable (under ₹500), mid-range (₹500-₹2000), premium (₹2000+) options available in India.''', language);
  }

  Future<String> getHairstyleRecommendation({
    required String gender,
    required String faceShape,
    required String occasion,
    String language = 'en',
  }) async {
    return _textCall('''Best hairstyles for $gender with $faceShape face shape for $occasion. Give 3 options with Indian celebrity examples.''', language);
  }

  /// Get AI improvement tips based on photo analysis scores
  Future<String> getImprovementTips({
    required String gender,
    required String skinTone,
    required String bodyType,
    required String currentStyle,
    required int outfitScore,
    required int colorScore,
    required int groomingScore,
    required List<String> improvements,
    String language = 'en',
  }) async {
    final prompt = '''
This person has:
- Gender: $gender, Skin: $skinTone, Body: $bodyType, Style: $currentStyle
- Outfit score: $outfitScore/100
- Colour score: $colorScore/100
- Grooming score: $groomingScore/100
- Areas to improve: ${improvements.join(', ')}

Give 5 specific, actionable style improvement tips for an Indian person.
Each tip should be practical, affordable, and easy to follow.
Format as numbered list.
''';
    return _textCall(prompt, language);
  }

  Future<Map<String, int>> getFashionScore({
    required String gender,
    required String skinTone,
    required String bodyType,
    required String style,
    required int closetItems,
    required int savedLooks,
    PhotoAnalysisResult? lastAnalysis,
    String language = 'en',
  }) async {
    // If we have real photo analysis, use those scores
    if (lastAnalysis != null && lastAnalysis.aiPowered) {
      return {
        'outfitMatch': lastAnalysis.outfitScore,
        'colorHarmony': lastAnalysis.colorHarmonyScore,
        'trendiness': _trendinessScore(style),
        'grooming': lastAnalysis.groomingScore,
        'accessories': 70 + (closetItems * 2).clamp(0, 25),
        'overall': lastAnalysis.overallScore,
      };
    }
    // Otherwise compute from profile
    int outfitMatch = 65 + (closetItems * 2).clamp(0, 20);
    int colorHarmony = skinTone.contains('Wheatish') ? 82 : skinTone.contains('Fair') ? 85 : 78;
    int trendiness = _trendinessScore(style);
    int grooming = 70 + (savedLooks * 3).clamp(0, 20);
    int accessories = 68 + (closetItems).clamp(0, 25);
    int overall = ((outfitMatch + colorHarmony + trendiness + grooming + accessories) / 5).round();
    return {
      'outfitMatch': outfitMatch.clamp(0, 100),
      'colorHarmony': colorHarmony.clamp(0, 100),
      'trendiness': trendiness.clamp(0, 100),
      'grooming': grooming.clamp(0, 100),
      'accessories': accessories.clamp(0, 100),
      'overall': overall.clamp(0, 100),
    };
  }

  int _trendinessScore(String style) {
    const map = {'Streetwear': 92, 'Indo-Western': 88, 'Smart Casual': 85, 'Casual': 78, 'Formal': 80, 'Traditional': 74, 'Festive': 82, 'Minimalist': 83};
    return map[style] ?? 78;
  }

  Future<String> chat(List<Map<String, String>> history, String userMessage, {String language = 'en'}) async {
    return _textCall(userMessage, language, history: history);
  }

  Future<String> _textCall(String userMessage, String language, {List<Map<String, String>> history = const []}) async {
    if (_apiKey.isEmpty) return _fallbackText(userMessage);
    try {
      final messages = [
        {'role': 'system', 'content': _systemPrompt(language)},
        ...history,
        {'role': 'user', 'content': userMessage},
      ];
      final res = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_apiKey', 'HTTP-Referer': 'https://fashiontrend.ai', 'X-Title': 'FashionTrend AI'},
        body: jsonEncode({'model': _textModel, 'messages': messages, 'max_tokens': 400, 'temperature': 0.7}),
      ).timeout(const Duration(seconds: 30));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['choices'][0]['message']['content'] as String).trim();
      }
      return _fallbackText(userMessage);
    } catch (_) {
      return _fallbackText(userMessage);
    }
  }

  String _fallbackText(String msg) {
    final lower = msg.toLowerCase();
    if (lower.contains('outfit') || lower.contains('wear')) {
      return '👔 Add your OpenRouter API key in .env to get real AI outfit advice!\n\nQuick tip: White/light blue shirt + dark trousers + white sneakers works for most occasions. 💡';
    }
    return '✨ Add your OpenRouter API key for personalized AI fashion advice!\n\nCheck your .env file and add OPENROUTER_API_KEY. Get a free key at openrouter.ai 🔑';
  }
}

/// Result from photo analysis
class PhotoAnalysisResult {
  final String faceShape;
  final String skinTone;
  final String gender;
  final String bodyType;
  final String hairStyle;
  final List<String> currentOutfitColors;
  final String currentStyle;
  final int outfitScore;
  final int colorHarmonyScore;
  final int groomingScore;
  final int overallScore;
  final List<String> positives;
  final List<String> improvements;
  final List<String> recommendedColors;
  final String recommendedStyle;
  final bool aiPowered;

  const PhotoAnalysisResult({
    required this.faceShape,
    required this.skinTone,
    required this.gender,
    required this.bodyType,
    required this.hairStyle,
    required this.currentOutfitColors,
    required this.currentStyle,
    required this.outfitScore,
    required this.colorHarmonyScore,
    required this.groomingScore,
    required this.overallScore,
    required this.positives,
    required this.improvements,
    required this.recommendedColors,
    required this.recommendedStyle,
    required this.aiPowered,
  });

  Map<String, dynamic> toJson() => {
        'face_shape': faceShape,
        'skin_tone': skinTone,
        'gender': gender,
        'body_type': bodyType,
        'hair_style': hairStyle,
        'current_outfit_colors': currentOutfitColors,
        'current_style': currentStyle,
        'outfit_score': outfitScore,
        'color_harmony_score': colorHarmonyScore,
        'grooming_score': groomingScore,
        'overall_score': overallScore,
        'positives': positives,
        'improvements': improvements,
        'recommended_colors': recommendedColors,
        'recommended_style': recommendedStyle,
        'ai_powered': aiPowered,
      };

  factory PhotoAnalysisResult.fromJson(Map<String, dynamic> j) => PhotoAnalysisResult(
        faceShape: j['face_shape'] ?? 'Oval',
        skinTone: j['skin_tone'] ?? 'Wheatish',
        gender: j['gender'] ?? 'Unknown',
        bodyType: j['body_type'] ?? 'Average',
        hairStyle: j['hair_style'] ?? 'Medium',
        currentOutfitColors: List<String>.from(j['current_outfit_colors'] ?? []),
        currentStyle: j['current_style'] ?? 'Casual',
        outfitScore: j['outfit_score'] ?? 70,
        colorHarmonyScore: j['color_harmony_score'] ?? 70,
        groomingScore: j['grooming_score'] ?? 70,
        overallScore: j['overall_score'] ?? 70,
        positives: List<String>.from(j['positives'] ?? []),
        improvements: List<String>.from(j['improvements'] ?? []),
        recommendedColors: List<String>.from(j['recommended_colors'] ?? []),
        recommendedStyle: j['recommended_style'] ?? 'Smart Casual',
        aiPowered: j['ai_powered'] ?? false,
      );
}

final aiService = AiService();
