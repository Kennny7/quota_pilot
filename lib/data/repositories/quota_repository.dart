// lib/data/repositories/quota_repository.dart

import '../../domain/entities/account.dart';
import '../../domain/entities/quota_info.dart';
import '../../domain/repositories/i_quota_repository.dart';
import '../datasources/local/dao/quota_dao.dart';
import '../datasources/remote/quota_api.dart';
import '../models/quota_info.dart';

class QuotaRepositoryImpl implements IQuotaRepository {
  final QuotaDao _quotaDao;
  final QuotaApi _quotaApi;

  QuotaRepositoryImpl({
    required QuotaDao quotaDao,
    required QuotaApi quotaApi,
  })  : _quotaDao = quotaDao,
        _quotaApi = quotaApi;

  @override
  Future<QuotaInfo?> refreshQuota(Account account) async {
    if (account.id == null) return null;

    final adapter = _quotaApi.adapterFor(account.serviceType);
    if (adapter == null) return null;

    try {
      final fetched = await adapter.fetchQuota(account);
      final id = await _quotaDao.insert(fetched);
      return fetched.copyWith(id: id);
    } on UnsupportedError {
      // Provider has no quota API — fall back to the last known snapshot.
      return _quotaDao.getLatest(account.id!);
    } catch (_) {
      return _quotaDao.getLatest(account.id!);
    }
  }

  @override
  Future<List<QuotaInfo>> getQuotaHistory(int accountId) =>
      _quotaDao.getHistory(accountId);

  @override
  Future<QuotaInfo?> getLatestQuota(int accountId) =>
      _quotaDao.getLatest(accountId);

  @override
  Future<void> updateManualQuota(int accountId, QuotaInfo info) async {
    final model = QuotaInfoModel.fromEntity(
      info.copyWith(accountId: accountId, isManual: true),
    );
    await _quotaDao.insert(model);
  }
}