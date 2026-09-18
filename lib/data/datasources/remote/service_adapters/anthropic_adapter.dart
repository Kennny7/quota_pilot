// lib/data/datasources/remote/service_adapters/anthropic_adapter.dart

import '../../../models/quota_info.dart';
import 'base_adapter.dart';

/// Anthropic Claude.
///
/// There is no public usage/quota API for Claude accounts, so this adapter is
/// manual‑only: [fetchQuota] always returns `null` and the UI prompts the user
/// to enter remaining/limit values by hand.
class AnthropicAdapter extends ServiceAdapter {
  AnthropicAdapter({super.dio});

  @override
  String get serviceId => 'anthropic';

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