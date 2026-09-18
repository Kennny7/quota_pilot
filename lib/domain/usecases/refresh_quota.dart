// lib/domain/usecases/refresh_quota.dart

import '../entities/account.dart';
import '../entities/quota_info.dart';
import '../repositories/i_quota_repository.dart';

class RefreshQuota {
  final IQuotaRepository _repository;
  RefreshQuota(this._repository);

  Future<QuotaInfo?> call(Account account) => _repository.refreshQuota(account);
}