// lib/data/datasources/remote/quota_api.dart

import 'package:dio/dio.dart';
import 'service_adapters/anthropic_adapter.dart';
import 'service_adapters/base_adapter.dart';
import 'service_adapters/google_ai_adapter.dart';
import 'service_adapters/grok_adapter.dart';
import 'service_adapters/openai_adapter.dart';

class QuotaApi {
  final Map<String, BaseAdapter> _adapters;

  QuotaApi(Dio dio)
      : _adapters = {
          'openai': OpenAiAdapter(dio),
          'google': GoogleAiAdapter(dio),
          'anthropic': AnthropicAdapter(dio),
          'grok': GrokAdapter(dio),
        };

  BaseAdapter? adapterFor(String serviceType) => _adapters[serviceType];
}