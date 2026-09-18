// lib/domain/repositories/i_quota_repository.dart

import '../entities/account.dart';
import '../entities/quota_info.dart';

abstract class IQuotaRepository {
  Future<QuotaInfo?> refreshQuota(Account account);
  Future<List<QuotaInfo>> getQuotaHistory(int accountId);
  Future<QuotaInfo?> getLatestQuota(int accountId);
  Future<void> updateManualQuota(int accountId, QuotaInfo info);
}