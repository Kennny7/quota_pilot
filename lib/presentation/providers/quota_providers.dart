// lib/presentation/providers/quota_providers.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../../data/datasources/local/dao/quota_dao.dart';
import '../../data/datasources/remote/quota_api.dart';
import '../../data/repositories/quota_repository.dart';
import '../../domain/entities/quota_info.dart';
import '../../domain/repositories/i_quota_repository.dart';
import '../../domain/usecases/get_quota_history.dart';
import '../../domain/usecases/refresh_quota.dart';
import '../../domain/usecases/update_manual_quota.dart';
import 'account_providers.dart';

// --- HTTP client -------------------------------------------------------------

final dioProvider = Provider<Dio>((ref) {
  final dio = DioClient.create();
  ref.onDispose(dio.close);
  return dio;
});

// --- Remote + local sources --------------------------------------------------

final quotaApiProvider = Provider<QuotaApi>((ref) {
  final api = QuotaApi(ref.watch(dioProvider));
  ref.onDispose(api.dispose);
  return api;
});

final quotaDaoProvider = Provider<QuotaDao>(
  (ref) => QuotaDao(ref.watch(databaseHelperProvider)),
);

// --- Repository --------------------------------------------------------------

final quotaRepositoryProvider = Provider<IQuotaRepository>(
  (ref) => QuotaRepositoryImpl(
    quotaDao: ref.watch(quotaDaoProvider),
    quotaApi: ref.watch(quotaApiProvider),
  ),
);

// --- Use cases ---------------------------------------------------------------

final refreshQuotaProvider = Provider<RefreshQuota>(
  (ref) => RefreshQuota(ref.watch(quotaRepositoryProvider)),
);

final getQuotaHistoryProvider = Provider<GetQuotaHistory>(
  (ref) => GetQuotaHistory(ref.watch(quotaRepositoryProvider)),
);

final updateManualQuotaProvider = Provider<UpdateManualQuota>(
  (ref) => UpdateManualQuota(ref.watch(quotaRepositoryProvider)),
);

// --- Read providers ----------------------------------------------------------

/// Latest snapshot for a single account (null when nothing is stored yet).
final latestQuotaProvider = FutureProvider.family<QuotaInfo?, int?>(
  (ref, accountId) async {
    if (accountId == null) return null;
    final repo = ref.watch(quotaRepositoryProvider);
    return repo.getLatestQuota(accountId);
  },
);

/// Chronological history used by the chart.
final quotaHistoryProvider = FutureProvider.family<List<QuotaInfo>, int?>(
  (ref, accountId) async {
    if (accountId == null) return const [];
    final usecase = ref.watch(getQuotaHistoryProvider);
    return usecase(accountId);
  },
);

// --- Imperative controller ---------------------------------------------------

final quotaRefreshControllerProvider =
    Provider<QuotaRefreshController>(QuotaRefreshController.new);

class QuotaRefreshController {
  QuotaRefreshController(this._ref);

  final Ref _ref;

  Future<void> refreshAccount(int? accountId) async {
    if (accountId == null) return;
    final accounts = _ref.read(accountsProvider).valueOrNull ?? [];
    final account = accounts.where((a) => a.id == accountId).firstOrNull;
    if (account == null) return;

    final usecase = _ref.read(refreshQuotaProvider);
    await usecase(account);
    _ref.invalidate(latestQuotaProvider(accountId));
    _ref.invalidate(quotaHistoryProvider(accountId));
  }

  Future<void> refreshAll(Iterable<int?> accountIds) async {
    await Future.wait(accountIds.whereType<int>().map(refreshAccount));
  }

  Future<void> setManualQuota({
    required int accountId,
    required double used,
    required double limit,
    String? unit,
  }) async {
    final existing =
        await _ref.read(quotaRepositoryProvider).getLatestQuota(accountId);
    final info = QuotaInfo(
      accountId: accountId,
      limit: limit,
      used: used,
      unit: unit ?? existing?.unit ?? 'requests',
      fetchedAt: DateTime.now(),
      isManual: true,
    );
    final usecase = _ref.read(updateManualQuotaProvider);
    await usecase(accountId, info);
    _ref.invalidate(latestQuotaProvider(accountId));
    _ref.invalidate(quotaHistoryProvider(accountId));
  }
}