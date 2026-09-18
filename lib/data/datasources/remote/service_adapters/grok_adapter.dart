// lib/data/datasources/remote/service_adapters/grok_adapter.dart

import '../../../models/quota_info.dart';
import 'base_adapter.dart';

/// xAI Grok.
///
/// Grok does not currently expose a public quota endpoint, so the adapter is
/// manual‑only and [fetchQuota] returns `null`.
class GrokAdapter extends ServiceAdapter {
  GrokAdapter({super.dio});

  @override
  String get serviceId => 'grok';

  @override
  bool get supportsApi => false;

  @override
  bool get supportsManual => true;

  @override
  Future<QuotaInfo?> fetchQuota({
    required Map<String, dynamic> credentials,
  }) async {
    // Manual-only service: no network call is performed.
    return null;
  }
}