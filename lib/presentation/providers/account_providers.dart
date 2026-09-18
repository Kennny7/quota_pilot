// lib/presentation/providers/account_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/dao/account_dao.dart';
import '../../data/datasources/local/database_helper.dart';
import '../../data/repositories/account_repository.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/quota_info.dart';
import '../../domain/entities/service_definition.dart';
import '../../domain/repositories/i_account_repository.dart';
import '../../domain/usecases/add_account.dart';
import '../../domain/usecases/get_all_accounts.dart';
import '../../domain/usecases/remove_account.dart';
import 'quota_providers.dart';

/// ---------------------------------------------------------------------------
/// Static catalogue of supported providers.
/// ---------------------------------------------------------------------------
const kServiceDefinitions = <ServiceDefinition>[
  ServiceDefinition(
    id: 'antigravity',
    name: 'Antigravity LLM',
    supportsApiKey: true,
    supportsManual: true,
    quotaUnit: 'prompts',
    docsUrl: 'https://antigravity.dev',
    description: 'Antigravity Free Tier and Pro tracking with daily limits.',
    colorHex: '#8B5CF6',
    badge: 'Popular',
  ),
  ServiceDefinition(
    id: 'openai',
    name: 'OpenAI (ChatGPT)',
    supportsApiKey: true,
    supportsManual: true,
    quotaUnit: 'USD',
    docsUrl: 'https://platform.openai.com/usage',
    description: 'OpenAI API usage and token limit tracker.',
    colorHex: '#10A37F',
  ),
  ServiceDefinition(
    id: 'google_ai',
    name: 'Google AI (Gemini)',
    supportsApiKey: true,
    supportsManual: true,
    quotaUnit: 'requests',
    docsUrl: 'https://aistudio.google.com/app/apikey',
    description: 'Gemini 1.5/2.0 developer quota and rate limits.',
    colorHex: '#1A73E8',
  ),
  ServiceDefinition(
    id: 'anthropic',
    name: 'Anthropic (Claude)',
    supportsApiKey: true,
    supportsManual: true,
    quotaUnit: 'USD',
    docsUrl: 'https://console.anthropic.com/settings/usage',
    description: 'Claude 3.5 Sonnet / Opus plan quota manager.',
    colorHex: '#D97706',
  ),
  ServiceDefinition(
    id: 'grok',
    name: 'xAI (Grok)',
    supportsApiKey: true,
    supportsManual: true,
    quotaUnit: 'USD',
    docsUrl: 'https://console.x.ai/',
    description: 'Grok 2 / Grok Vision usage and API quotas.',
    colorHex: '#1E293B',
  ),
  ServiceDefinition(
    id: 'openrouter',
    name: 'OpenRouter',
    supportsApiKey: true,
    supportsManual: true,
    quotaUnit: 'USD',
    docsUrl: 'https://openrouter.ai/keys',
    description: 'Real-time multi-model credit and usage monitoring.',
    colorHex: '#6366F1',
    badge: 'Live Sync',
  ),
  ServiceDefinition(
    id: 'deepseek',
    name: 'DeepSeek',
    supportsApiKey: true,
    supportsManual: true,
    quotaUnit: 'tokens',
    docsUrl: 'https://platform.deepseek.com',
    description: 'DeepSeek-V3 / R1 reasoning quota and credit tracker.',
    colorHex: '#0EA5E9',
  ),
  ServiceDefinition(
    id: 'ollama',
    name: 'Ollama (Local)',
    supportsApiKey: false,
    supportsManual: true,
    quotaUnit: 'requests',
    docsUrl: 'https://ollama.com',
    description: 'Self-hosted and local LLM request budget manager.',
    colorHex: '#475569',
  ),
  ServiceDefinition(
    id: 'manual',
    name: 'Custom / Manual Tier',
    supportsApiKey: false,
    supportsManual: true,
    quotaUnit: 'requests',
    docsUrl: '',
    description: 'Track any service with custom limits and units.',
    colorHex: '#64748B',
  ),
];

final serviceDefinitionsProvider = Provider<List<ServiceDefinition>>(
  (ref) => kServiceDefinitions,
);

/// Lookup extension
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
  (ref) => DatabaseHelper.instance,
);

final accountDaoProvider = Provider<AccountDao>(
  (ref) => AccountDao(ref.watch(databaseHelperProvider)),
);

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
    return ref.read(getAllAccountsProvider)();
  }

  /// Re-reads the persisted list.
  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_load);
  }

  Future<int> add({
    required String email,
    required String serviceId,
    required AccountAuthType authType,
    String? apiKey,
    String? baseUrl,
    double initialLimit = 100.0,
    double initialUsed = 0.0,
    String? unit,
  }) async {
    final account = Account(
      email: email,
      serviceId: serviceId,
      authType: authType,
      apiKey: apiKey,
      baseUrl: baseUrl,
      createdAt: DateTime.now(),
    );
    final id = await ref.read(addAccountProvider)(account);

    // Also record initial quota record
    final initialQuota = QuotaInfo(
      accountId: id,
      limit: initialLimit,
      used: initialUsed,
      unit: unit ?? 'requests',
      fetchedAt: DateTime.now(),
      isManual: authType == AccountAuthType.manual,
    );
    await ref.read(updateManualQuotaProvider)(id, initialQuota);

    await reload();
    return id;
  }

  Future<void> remove(int accountId) async {
    await ref.read(removeAccountProvider)(accountId);
    await reload();
  }
}

final accountsFutureProvider = FutureProvider<List<Account>>((ref) async {
  return ref.watch(getAllAccountsProvider)();
});