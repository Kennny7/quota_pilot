// lib/presentation/providers/quota_providers.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );
  ref.onDispose(dio.close);
  return dio;
});

// --- Remote + local sources --------------------------------------------------

final quotaApiProvider = Provider<QuotaApi>(
  (ref) => QuotaApi(ref.watch(dioProvider)),
);

final quotaDaoProvider = Provider<QuotaDao>(
  (ref) => QuotaDao(ref.watch(databaseHelperProvider)),
);

// --- Repository --------------------------------------------------------------

/// Default concrete implementation. Can still be overridden in a
/// `ProviderScope` (e.g. for tests or alternate environments) by overriding
/// `quotaRepositoryProvider`.
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
final latestQuotaProvider = FutureProvider.family<QuotaInfo?, String>(
  (ref, accountId) async {
    final repo = ref.watch(quotaRepositoryProvider);
    final result = await repo.getLatestQuota(accountId);
    return result.fold((failure) => throw failure, (quota) => quota);
  },
);

/// Chronological history used by the chart.
final quotaHistoryProvider = FutureProvider.family<List<QuotaInfo>, String>(
  (ref, accountId) async {
    final usecase = ref.watch(getQuotaHistoryProvider);
    final result = await usecase(accountId);
    return result.fold((failure) => throw failure, (history) => history);
  },
);

// --- Imperative controller ---------------------------------------------------

/// Imperative controller used by pull-to-refresh / buttons.
final quotaRefreshControllerProvider =
    Provider<QuotaRefreshController>(QuotaRefreshController.new);

class QuotaRefreshController {
  QuotaRefreshController(this._ref);

  final Ref _ref;

  Future<void> refreshAccount(String accountId) async {
    final usecase = _ref.read(refreshQuotaProvider);
    final result = await usecase(accountId);
    result.fold((failure) => throw failure, (_) => null);
    _ref.invalidate(latestQuotaProvider(accountId));
    _ref.invalidate(quotaHistoryProvider(accountId));
  }

  Future<void> refreshAll(Iterable<String> accountIds) async {
    await Future.wait(accountIds.map(refreshAccount));
  }

  Future<void> setManualQuota({
    required String accountId,
    required double used,
    required double limit,
  }) async {
    final usecase = _ref.read(updateManualQuotaProvider);
    final result = await usecase(
      accountId: accountId,
      used: used,
      limit: limit,
    );
    result.fold((failure) => throw failure, (_) => null);
    _ref.invalidate(latestQuotaProvider(accountId));
    _ref.invalidate(quotaHistoryProvider(accountId));
  }
}