import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'ai_service.dart';
import '../core/constants/app_constants.dart';

/// Stores the latest photo analysis result locally + in Supabase
class AnalysisStore {
  static const _localKey = 'last_photo_analysis';

  /// Save analysis result locally and to Supabase
  static Future<void> save(PhotoAnalysisResult result) async {
    // Save locally for instant access
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localKey, jsonEncode(result.toJson()));

    // Also persist to Supabase
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.from(AppConstants.analysisTable).insert({
          'user_id': user.id,
          'image_url': '',
          'face_shape': result.faceShape,
          'skin_tone': result.skinTone,
          'body_type': result.bodyType,
          'hair_texture': result.hairStyle,
          'gender': result.gender,
          'dominant_colors': result.currentOutfitColors,
          'current_style': result.currentStyle,
          'style_score': result.overallScore,
          'raw_data': result.toJson(),
          'created_at': DateTime.now().toIso8601String(),
        });

        // Also update user profile with detected values
        await Supabase.instance.client.from(AppConstants.profilesTable).update({
          'skin_tone': result.skinTone,
          'body_type': result.bodyType,
          'face_shape': result.faceShape,
          'gender': result.gender,
          'style_score': result.overallScore,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', user.id);
      }
    } catch (_) {
      // Local save already done — Supabase failure is non-fatal
    }
  }

  /// Load the most recent analysis result
  static Future<PhotoAnalysisResult?> load() async {
    // Try Supabase first
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final data = await Supabase.instance.client
            .from(AppConstants.analysisTable)
            .select()
            .eq('user_id', user.id)
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();
        if (data != null && data['raw_data'] != null) {
          return PhotoAnalysisResult.fromJson(Map<String, dynamic>.from(data['raw_data']));
        }
      }
    } catch (_) {}

    // Fall back to local cache
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_localKey);
      if (json != null) {
        return PhotoAnalysisResult.fromJson(jsonDecode(json));
      }
    } catch (_) {}

    return null;
  }

  /// Clear stored analysis
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localKey);
  }
}
