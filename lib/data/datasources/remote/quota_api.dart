// lib/data/datasources/remote/quota_api.dart

import 'package:dio/dio.dart';
import 'service_adapters/service_adapters.dart';

class QuotaApi {
  final ServiceAdapterRegistry _registry;

  QuotaApi([Dio? dio]) : _registry = ServiceAdapterRegistry(dio: dio);

  BaseAdapter? adapterFor(String serviceType) =>
      _registry.forService(serviceType);

  void dispose() => _registry.dispose();
}