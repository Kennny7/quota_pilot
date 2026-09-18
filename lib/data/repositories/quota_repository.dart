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

    final adapter = _quotaApi.adapterFor(account.serviceId);
    if (adapter == null) {
      return _quotaDao.getLatestForAccount(account.id!);
    }

    try {
      final fetched = await adapter.fetchQuota(account);
      if (fetched != null) {
        final model = QuotaInfoModel.fromEntity(
          fetched.copyWith(accountId: account.id),
        );
        final id = await _quotaDao.insertQuotaHistory(model);
        return model.copyWith(id: id);
      }
      return _quotaDao.getLatestForAccount(account.id!);
    } catch (_) {
      return _quotaDao.getLatestForAccount(account.id!);
    }
  }

  @override
  Future<List<QuotaInfo>> getQuotaHistory(int accountId) async {
    final list = await _quotaDao.getQuotaHistoryForAccount(accountId);
    return list.map((m) => m.toEntity()).toList();
  }

  @override
  Future<QuotaInfo?> getLatestQuota(int accountId) async {
    final latest = await _quotaDao.getLatestForAccount(accountId);
    return latest?.toEntity();
  }

  @override
  Future<void> updateManualQuota(int accountId, QuotaInfo info) async {
    final model = QuotaInfoModel.fromEntity(
      info.copyWith(accountId: accountId, isManual: true),
    );
    await _quotaDao.insertQuotaHistory(model);
  }
}