// lib/data/datasources/remote/service_adapters/grok_adapter.dart

import '../../../../domain/entities/account.dart';
import '../../../../domain/entities/quota_info.dart';
import 'base_adapter.dart';

class GrokAdapter extends ServiceAdapter {
  GrokAdapter({super.dio});

  @override
  String get serviceId => 'grok';

  @override
  bool get supportsApi => false;

  @override
  bool get supportsManual => true;

  @override
  Future<QuotaInfo?> fetchQuota(Account account) async {
    // xAI Grok does not currently have a public client quota endpoint;
    // handled via manual tracking mode
    return null;
  }
}