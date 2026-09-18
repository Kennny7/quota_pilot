// lib/data/datasources/remote/service_adapters/manual_adapter.dart

import '../../../../domain/entities/account.dart';
import '../../../../domain/entities/quota_info.dart';
import 'base_adapter.dart';

class ManualAdapter extends ServiceAdapter {
  ManualAdapter({super.dio});

  @override
  String get serviceId => 'manual';

  @override
  bool get supportsApi => false;

  @override
  bool get supportsManual => true;

  @override
  Future<QuotaInfo?> fetchQuota(Account account) async {
    return null;
  }
}
