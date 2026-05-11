import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/profile/data/models/user_profile_model.dart';
import '../core/constants/app_constants.dart';

class ProfileService {
  final _db = Supabase.instance.client;

  Future<UserProfile?> getProfile(String userId) async {
    try {
      final data = await _db
          .from(AppConstants.profilesTable)
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (data == null) return null;
      return UserProfile.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _db
        .from(AppConstants.profilesTable)
        .upsert(profile.toJson());
  }

  Future<String?> uploadAvatar(String userId, File imageFile) async {
    try {
      final ext = imageFile.path.split('.').last;
      final path = '$userId/avatar.$ext';
      await _db.storage
          .from(AppConstants.avatarsBucket)
          .upload(path, imageFile, fileOptions: const FileOptions(upsert: true));
      return _db.storage.from(AppConstants.avatarsBucket).getPublicUrl(path);
    } catch (_) {
      return null;
    }
  }

  Future<int> getSavedLooksCount(String userId) async {
    try {
      final data = await _db
          .from(AppConstants.savedLooksTable)
          .select('id')
          .eq('user_id', userId);
      return (data as List).length;
    } catch (_) {
      return 0;
    }
  }

  Future<int> getClosetItemsCount(String userId) async {
    try {
      final data = await _db
          .from(AppConstants.closetItemsTable)
          .select('id')
          .eq('user_id', userId);
      return (data as List).length;
    } catch (_) {
      return 0;
    }
  }

  Future<int> getAnalysisCount(String userId) async {
    try {
      final data = await _db
          .from(AppConstants.analysisTable)
          .select('id')
          .eq('user_id', userId);
      return (data as List).length;
    } catch (_) {
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> getSavedLooks(String userId) async {
    try {
      final data = await _db
          .from(AppConstants.savedLooksTable)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }

  Future<void> saveLook(String userId, Map<String, dynamic> lookData) async {
    await _db.from(AppConstants.savedLooksTable).insert({
      'user_id': userId,
      ...lookData,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteLook(String lookId) async {
    await _db.from(AppConstants.savedLooksTable).delete().eq('id', lookId);
  }

  Future<List<Map<String, dynamic>>> getClosetItems(String userId) async {
    try {
      final data = await _db
          .from(AppConstants.closetItemsTable)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }

  Future<void> addClosetItem(Map<String, dynamic> item) async {
    await _db.from(AppConstants.closetItemsTable).insert(item);
  }

  Future<void> deleteClosetItem(String itemId) async {
    await _db.from(AppConstants.closetItemsTable).delete().eq('id', itemId);
  }
}

final profileServiceProvider = Provider<ProfileService>((ref) => ProfileService());

final userProfileProvider = FutureProvider.autoDispose<UserProfile?>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return null;
  final service = ref.read(profileServiceProvider);
  return service.getProfile(user.id);
});

final profileStatsProvider = FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return {};
  final service = ref.read(profileServiceProvider);
  final results = await Future.wait([
    service.getSavedLooksCount(user.id),
    service.getClosetItemsCount(user.id),
    service.getAnalysisCount(user.id),
  ]);
  return {
    'savedLooks': results[0],
    'closetItems': results[1],
    'analyses': results[2],
  };
});
