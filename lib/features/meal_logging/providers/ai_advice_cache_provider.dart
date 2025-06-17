import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/ai_advice_response.dart';
import 'ai_advice_provider.dart';

class AiAdviceCacheNotifier extends StateNotifier<AiAdviceResponse?> {
  static const String _cacheKey = 'ai_advice_cache';
  static const String _cacheTimestampKey = 'ai_advice_cache_timestamp';
  static const Duration _cacheValidity = Duration(hours: 3); // 3時間有効

  AiAdviceCacheNotifier() : super(null) {
    _loadFromCache();
  }

  Future<void> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString(_cacheKey);
    final timestampStr = prefs.getString(_cacheTimestampKey);

    if (cachedJson != null && timestampStr != null) {
      try {
        final timestamp = DateTime.parse(timestampStr);
        final now = DateTime.now();

        // キャッシュが有効期限内かチェック
        if (now.difference(timestamp) <= _cacheValidity) {
          final data = jsonDecode(cachedJson);
          state = AiAdviceResponse.fromJson(data);
        } else {
          // 期限切れの場合はキャッシュをクリア
          await _clearCache();
        }
      } catch (e) {
        // パースエラーの場合はキャッシュをクリア
        await _clearCache();
      }
    }
  }

  Future<void> saveToCache(AiAdviceResponse advice) async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final json = jsonEncode(advice.toJson());
      await prefs.setString(_cacheKey, json);
      await prefs.setString(
        _cacheTimestampKey,
        DateTime.now().toIso8601String(),
      );
      state = advice;
    } catch (e) {
      // 保存エラーは無視（キャッシュなので必須ではない）
    }
  }

  Future<void> _clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_cacheTimestampKey);
    state = null;
  }

  bool get hasValidCache => state != null;

  Future<void> invalidateCache() async {
    await _clearCache();
  }
}

final aiAdviceCacheProvider =
    StateNotifierProvider<AiAdviceCacheNotifier, AiAdviceResponse?>((ref) {
      return AiAdviceCacheNotifier();
    });

/// キャッシュ対応版のAIアドバイスプロバイダー
final cachedAiAdviceProvider = Provider<AsyncValue<AiAdviceResponse?>>((ref) {
  final cache = ref.watch(aiAdviceCacheProvider);
  final liveAdvice = ref.watch(aiAdviceProvider);

  // キャッシュがある場合はそれを使用
  if (cache != null) {
    return AsyncValue.data(cache);
  }

  // キャッシュがない場合は新規取得し、成功したらキャッシュに保存
  liveAdvice.whenData((advice) {
    if (advice != null) {
      ref.read(aiAdviceCacheProvider.notifier).saveToCache(advice);
    }
  });

  return liveAdvice;
});
