// lib/domain/usecases/get_quota_history.dart

import '../entities/quota_info.dart';
import '../repositories/i_quota_repository.dart';

class GetQuotaHistory {
  final IQuotaRepository _repository;
  GetQuotaHistory(this._repository);

  Future<List<QuotaInfo>> call(int accountId) =>
      _repository.getQuotaHistory(accountId);
}