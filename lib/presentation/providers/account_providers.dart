// lib/presentation/providers/account_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/dao/account_dao.dart';
import '../../data/datasources/local/database_helper.dart';
import '../../data/repositories/account_repository.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/service_definition.dart';
import '../../domain/repositories/i_account_repository.dart';
import '../../domain/usecases/add_account.dart';
import '../../domain/usecases/get_all_accounts.dart';
import '../../domain/usecases/remove_account.dart';

/// ---------------------------------------------------------------------------
/// Static catalogue of supported providers.
/// Override [serviceDefinitionsProvider] if this ever comes from a DAO.
/// ---------------------------------------------------------------------------
const kServiceDefinitions = <ServiceDefinition>[
  ServiceDefinition(
    id: 'openai',
    name: 'OpenAI',
    supportsApiKey: true,
    supportsManual: true,
    quotaUnit: 'USD',
    docsUrl: 'https://platform.openai.com/usage',
  ),
  ServiceDefinition(
    id: 'google_ai',
    name: 'Google AI (Gemini)',
    supportsApiKey: true,
    supportsManual: true,
    quotaUnit: 'requests',
    docsUrl: 'https://aistudio.google.com/app/apikey',
  ),
  ServiceDefinition(
    id: 'anthropic',
    name: 'Anthropic (Claude)',
    supportsApiKey: true,
    supportsManual: true,
    quotaUnit: 'USD',
    docsUrl: 'https://console.anthropic.com/settings/usage',
  ),
  ServiceDefinition(
    id: 'grok',
    name: 'xAI (Grok)',
    supportsApiKey: true,
    supportsManual: true,
    quotaUnit: 'USD',
    docsUrl: 'https://console.x.ai/',
  ),
  ServiceDefinition(
    id: 'manual',
    name: 'Other / Manual',
    supportsApiKey: false,
    supportsManual: true,
    quotaUnit: 'units',
    docsUrl: '',
  ),
];

final serviceDefinitionsProvider = Provider<List<ServiceDefinition>>(
  (ref) => kServiceDefinitions,
);

/// Handy lookup used all over the presentation layer.
extension ServiceDefinitionListX on List<ServiceDefinition> {
  ServiceDefinition? byId(String id) {
    for (final s in this) {
      if (s.id == id) return s;
    }
    return null;
  }
}

/// ---------------------------------------------------------------------------
/// Infrastructure
/// ---------------------------------------------------------------------------
final databaseHelperProvider = Provider<DatabaseHelper>(
  (ref) => DatabaseHelper(),
);

final accountDaoProvider = Provider<AccountDao>(
  (ref) => AccountDao(ref.watch(databaseHelperProvider)),
);

/// Default repository wiring.
/// You can still override this in `ProviderScope` / `main.dart` if needed.
final accountRepositoryProvider = Provider<IAccountRepository>(
  (ref) => AccountRepositoryImpl(ref.watch(accountDaoProvider)),
);

/// ---------------------------------------------------------------------------
/// Use cases
/// ---------------------------------------------------------------------------
final getAllAccountsProvider = Provider<GetAllAccounts>(
  (ref) => GetAllAccounts(ref.watch(accountRepositoryProvider)),
);

final addAccountProvider = Provider<AddAccount>(
  (ref) => AddAccount(ref.watch(accountRepositoryProvider)),
);

final removeAccountProvider = Provider<RemoveAccount>(
  (ref) => RemoveAccount(ref.watch(accountRepositoryProvider)),
);

/// ---------------------------------------------------------------------------
/// Reactive accounts state
/// ---------------------------------------------------------------------------
final accountsProvider =
    AsyncNotifierProvider<AccountsNotifier, List<Account>>(AccountsNotifier.new);

class AccountsNotifier extends AsyncNotifier<List<Account>> {
  @override
  Future<List<Account>> build() => _load();

  Future<List<Account>> _load() async {
    final result = await ref.read(getAllAccountsProvider)();
    return result.fold((failure) => throw failure, (accounts) => accounts);
  }

  /// Re-reads the persisted list.
  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> add({
    required String email,
    required String serviceId,
    required AccountAuthType authType,
    String? apiKey,
  }) async {
    final result = await ref.read(addAccountProvider)(
      email: email,
      serviceId: serviceId,
      authType: authType,
      apiKey: apiKey,
    );
    result.fold((failure) => throw failure, (_) => null);
    await reload();
  }

  Future<void> remove(String accountId) async {
    final result = await ref.read(removeAccountProvider)(accountId);
    result.fold((failure) => throw failure, (_) => null);
    await reload();
  }
}

/// Compatibility alias for callers that explicitly expect a [FutureProvider].
///
/// Most UI code can simply watch [accountsProvider], because it already exposes
/// an `AsyncValue<List<Account>>`.
final accountsFutureProvider = FutureProvider<List<Account>>((ref) async {
  final result = await ref.watch(getAllAccountsProvider)();
  return result.fold((failure) => throw failure, (accounts) => accounts);
});