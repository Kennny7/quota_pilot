// lib/data/datasources/remote/service_adapters/openrouter_adapter.dart

import '../../../../domain/entities/account.dart';
import '../../../../domain/entities/quota_info.dart';
import 'base_adapter.dart';

/// OpenRouter Adapter.
///
/// Hits https://openrouter.ai/api/v1/auth/key which provides live credit usage,
/// monthly limit, and rate limit info for the API key.
class OpenRouterAdapter extends ServiceAdapter {
  OpenRouterAdapter({super.dio});

  static const String _authKeyEndpoint = 'https://openrouter.ai/api/v1/auth/key';

  @override
  String get serviceId => 'openrouter';

  @override
  bool get supportsApi => true;

  @override
  bool get supportsManual => true;

  @override
  Future<QuotaInfo?> fetchQuota(Account account) async {
    final apiKey = account.apiKey?.trim();
    if (apiKey == null || apiKey.isEmpty) {
      throw const QuotaFetchException(
        QuotaErrorKind.unauthorized,
        'An OpenRouter API key is required.',
      );
    }

    try {
      final payload = await getJson(
        _authKeyEndpoint,
        headers: {'Authorization': 'Bearer $apiKey'},
      );

      final data = payload['data'];
      if (data is Map) {
        final usage = _asDouble(data['usage']);
        final limit = _asDouble(data['limit']) > 0
            ? _asDouble(data['limit'])
            : (usage > 0 ? usage * 2 : 20.0);

        return QuotaInfo(
          accountId: account.id ?? 0,
          limit: limit,
          used: usage,
          unit: 'USD',
          fetchedAt: DateTime.now(),
          rawData: Map<String, dynamic>.from(data),
        );
      }
      return null;
    } on QuotaFetchException {
      rethrow;
    } catch (_) {
      return null;
    }
  }

  double _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
