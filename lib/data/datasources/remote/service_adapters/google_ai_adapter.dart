// lib/data/datasources/remote/service_adapters/google_ai_adapter.dart

import '../../../models/quota_info.dart';
import 'base_adapter.dart';

/// Google AI Studio / Gemini.
///
/// The public `v1beta/models` endpoint can validate the API key and list
/// models, but it does **not** return quota/usage numbers. We still hit it so
/// the user gets immediate feedback on a bad key, then return `null` so the UI
/// falls back to manual entry.
///
/// If Google ever ships a usage endpoint, add it here and parse the response
/// into a [QuotaInfo] the same way [OpenAiAdapter] does.
class GoogleAiAdapter extends ServiceAdapter {
  GoogleAiAdapter({super.dio});

  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  @override
  String get serviceId => 'google_ai';

  @override
  bool get supportsApi => true;

  @override
  bool get supportsManual => true;

  @override
  Future<QuotaInfo?> fetchQuota({
    required Map<String, dynamic> credentials,
  }) async {
    final apiKey = requireString(
      credentials,
      'apiKey',
      message: 'A Google AI Studio API key is required.',
    );

    final payload = await getJson(
      '$_baseUrl/models',
      query: {'key': apiKey},
    );

    // Defensive: some private/enterprise builds have been observed returning a
    // `quota` block on this endpoint. Parse it when present.
    final quota = payload['quota'];
    if (quota is Map) {
      final limit = _asDouble(quota['limit']);
      final used = _asDouble(quota['used']);
      if (limit > 0 || used > 0) {
        return QuotaInfo(
          limit: limit > 0 ? limit : null,
          remaining: limit > 0 ? (limit - used).clamp(0, limit) : null,
          usagePercent: computeUsagePercent(used, limit > 0 ? limit : null),
          lastUpdated: DateTime.now(),
          raw: {'quota': quota, 'modelCount': (payload['models'] as List?)?.length},
        );
      }
    }

    // Key is valid (no exception thrown) but no quota data is available.
    return null;
  }

  double _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}