// lib/core/network/dio_client.dart

import 'package:dio/dio.dart';

class DioClient {
  DioClient._();

  static Dio create({
    Duration connectTimeout = const Duration(seconds: 10),
    Duration receiveTimeout = const Duration(seconds: 15),
    Map<String, dynamic>? defaultHeaders,
  }) {
    final options = BaseOptions(
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: connectTimeout,
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'QuotaPilot/1.0.0',
        ...?defaultHeaders,
      },
      responseType: ResponseType.json,
      validateStatus: (status) => status != null && status < 500,
    );

    return Dio(options);
  }
}
