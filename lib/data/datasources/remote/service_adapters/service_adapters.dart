// lib/data/datasources/remote/service_adapters/service_adapters.dart

import 'base_adapter.dart';
import 'openai_adapter.dart';
import 'google_ai_adapter.dart';
import 'anthropic_adapter.dart';
import 'grok_adapter.dart';

export 'base_adapter.dart';
export 'openai_adapter.dart';
export 'google_ai_adapter.dart';
export 'anthropic_adapter.dart';
export 'grok_adapter.dart';

class ServiceAdapterRegistry {
  ServiceAdapterRegistry({Dio? dio}) : _dio = dio;

  final Dio? _dio;
  final Map<String, ServiceAdapter> _cache = {};

  ServiceAdapter forService(String serviceId) {
    return _cache.putIfAbsent(serviceId, () {
      switch (serviceId) {
        case 'openai':
          return OpenAiAdapter(dio: _dio);
        case 'google_ai':
          return GoogleAiAdapter(dio: _dio);
        case 'anthropic':
          return AnthropicAdapter(dio: _dio);
        case 'grok':
          return GrokAdapter(dio: _dio);
        default:
          throw QuotaFetchException(
            QuotaErrorKind.unsupported,
            'No adapter registered for "$serviceId".',
          );
      }
    });
  }

  void dispose() {
    for (final adapter in _cache.values) {
      adapter.dispose();
    }
    _cache.clear();
  }
}