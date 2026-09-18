// lib/data/datasources/remote/service_adapters/antigravity_adapter.dart

import '../../../../domain/entities/account.dart';
import '../../../../domain/entities/quota_info.dart';
import 'base_adapter.dart';

/// Antigravity Free Tier and Pro LLM Adapter.
///
/// For accounts linked to Antigravity (e.g. free tier with daily prompt/quota limit),
/// this adapter tracks daily/monthly quota limits, remaining requests, and resets.
class AntigravityAdapter extends ServiceAdapter {
  AntigravityAdapter({super.dio});

  static const String _baseUrl = 'https://api.antigravity.dev/v1';

  @override
  String get serviceId => 'antigravity';

  @override
  bool get supportsApi => true;

  @override
  bool get supportsManual => true;

  @override
  Future<QuotaInfo?> fetchQuota(Account account) async {
    final apiKey = account.apiKey?.trim();

    // If an API key is provided, attempt live verification
    if (apiKey != null && apiKey.isNotEmpty) {
      try {
        final payload = await getJson(
          '$_baseUrl/user/quota',
          headers: {'Authorization': 'Bearer $apiKey'},
        );

        final limit = _asDouble(payload['limit'] ?? payload['daily_limit']) > 0
            ? _asDouble(payload['limit'] ?? payload['daily_limit'])
            : 50.0;
        final used = _asDouble(payload['used'] ?? payload['daily_used']);

        return QuotaInfo(
          accountId: account.id ?? 0,
          limit: limit,
          used: used,
          unit: 'prompts',
          fetchedAt: DateTime.now(),
          rawData: payload,
        );
      } catch (_) {
        // Fallback gracefully
      }
    }

    // Default tier defaults: Antigravity Free Tier provides 50 requests/day
    return null;
  }

  double _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
