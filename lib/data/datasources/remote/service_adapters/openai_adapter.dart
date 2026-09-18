// lib/data/datasources/remote/service_adapters/openai_adapter.dart

import '../../../models/quota_info.dart';
import 'base_adapter.dart';

/// OpenAI exposes a *usage* endpoint but **not** a plan‑limit endpoint, so the
/// caller may pass an optional `monthlyLimit` (tokens) in [credentials] to let
/// us compute `remaining` / `usagePercent`. When it is absent we still return a
/// [QuotaInfo] with the raw usage figures, leaving the derived fields `null`.
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
  Future<QuotaInfo?> fetchQuota({
    required Map<String, dynamic> credentials,
  }) async {
    final apiKey = requireString(
      credentials,
      'apiKey',
      message: 'An OpenAI API key is required.',
    );

    final date = _formatDate(
      credentials['date'] as DateTime? ?? DateTime.now(),
    );

    final payload = await getJson(
      '$_baseUrl/usage',
      query: {'date': date},
      headers: {'Authorization': 'Bearer $apiKey'},
    );

    final data = payload['data'];
    if (data is! List) {
      throw const QuotaFetchException(
        QuotaErrorKind.parse,
        'OpenAI usage payload did not contain a "data" list.',
      );
    }

    double usedTokens = 0;
    double requestCount = 0;

    for (final entry in data) {
      if (entry is! Map) continue;
      usedTokens += _asDouble(entry['n_context_tokens_total']);
      usedTokens += _asDouble(entry['n_generated_tokens_total']);
      requestCount += _asDouble(entry['n_requests']);
    }

    final declaredLimit = _asDouble(credentials['monthlyLimit']);
    final limit = declaredLimit > 0 ? declaredLimit : null;

    return QuotaInfo(
      limit: limit,
      remaining: limit != null ? (limit - usedTokens).clamp(0, limit) : null,
      usagePercent: computeUsagePercent(usedTokens, limit),
      lastUpdated: DateTime.now(),
      raw: {
        'usedTokens': usedTokens,
        'requests': requestCount,
        'date': date,
        'entries': data.length,
      },
    );
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