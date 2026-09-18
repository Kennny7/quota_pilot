// lib/domain/usecases/update_manual_quota.dart

import '../entities/quota_info.dart';
import '../repositories/i_quota_repository.dart';

class UpdateManualQuota {
  final IQuotaRepository _repository;
  UpdateManualQuota(this._repository);

  Future<void> call(int accountId, QuotaInfo info) =>
      _repository.updateManualQuota(accountId, info);
}