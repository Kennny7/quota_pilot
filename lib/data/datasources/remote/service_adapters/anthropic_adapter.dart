// lib/data/datasources/remote/service_adapters/anthropic_adapter.dart

import '../../../../domain/entities/account.dart';
import '../../../../domain/entities/quota_info.dart';
import 'base_adapter.dart';

class AnthropicAdapter extends ServiceAdapter {
  AnthropicAdapter({super.dio});

  @override
  String get serviceId => 'anthropic';

  @override
  bool get supportsApi => false;

  @override
  bool get supportsManual => true;

  @override
  Future<QuotaInfo?> fetchQuota(Account account) async {
    // Anthropic does not have a public usage API for client accounts;
    // handled via manual tracking mode
    return null;
  }
}