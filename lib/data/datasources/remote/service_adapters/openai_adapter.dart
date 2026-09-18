// lib/data/datasources/remote/service_adapters/openai_adapter.dart

import '../../../../domain/entities/account.dart';
import '../../../../domain/entities/quota_info.dart';
import 'base_adapter.dart';

class OpenAiAdapter extends ServiceAdapter {
  OpenAiAdapter({super.dio});

  static const String _baseUrl = 'https://api.openai.com/v1';

  @override
  String get serviceId => 'openai';

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
        'An OpenAI API key is required.',
      );
    }

    final date = _formatDate(DateTime.now());

    try {
      final payload = await getJson(
        '$_baseUrl/usage',
        query: {'date': date},
        headers: {'Authorization': 'Bearer $apiKey'},
      );

      final data = payload['data'];
      double usedTokens = 0;
      double requestCount = 0;

      if (data is List) {
        for (final entry in data) {
          if (entry is! Map) continue;
          usedTokens += _asDouble(entry['n_context_tokens_total']);
          usedTokens += _asDouble(entry['n_generated_tokens_total']);
          requestCount += _asDouble(entry['n_requests']);
        }
      }

      // Default monthly token allowance or declared limit
      final limit = _asDouble(account.authData['monthlyLimit']) > 0
          ? _asDouble(account.authData['monthlyLimit'])
          : 500000.0;

      return QuotaInfo(
        accountId: account.id ?? 0,
        limit: limit,
        used: usedTokens,
        unit: 'tokens',
        fetchedAt: DateTime.now(),
        rawData: {
          'usedTokens': usedTokens,
          'requests': requestCount,
          'date': date,
        },
      );
    } on QuotaFetchException {
      rethrow;
    } catch (e) {
      // Return null so UI falls back gracefully to manual
      return null;
    }
  }

  double _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}