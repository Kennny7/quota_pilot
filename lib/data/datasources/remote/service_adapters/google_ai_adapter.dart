// lib/data/datasources/remote/service_adapters/google_ai_adapter.dart

import '../../../../domain/entities/account.dart';
import '../../../../domain/entities/quota_info.dart';
import 'base_adapter.dart';

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
  Future<QuotaInfo?> fetchQuota(Account account) async {
    final apiKey = account.apiKey?.trim();
    if (apiKey == null || apiKey.isEmpty) {
      throw const QuotaFetchException(
        QuotaErrorKind.unauthorized,
        'A Google AI Studio API key is required.',
      );
    }

    try {
      final payload = await getJson(
        '$_baseUrl/models',
        query: {'key': apiKey},
      );

      final quota = payload['quota'];
      if (quota is Map) {
        final limit = _asDouble(quota['limit']);
        final used = _asDouble(quota['used']);
        if (limit > 0 || used > 0) {
          return QuotaInfo(
            accountId: account.id ?? 0,
            limit: limit > 0 ? limit : 1000.0,
            used: used,
            unit: 'requests',
            fetchedAt: DateTime.now(),
            rawData: {'quota': quota, 'models': (payload['models'] as List?)?.length},
          );
        }
      }

      // Valid key checked; return null for user-defined quota values
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