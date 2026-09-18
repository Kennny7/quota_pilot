// lib/data/datasources/remote/service_adapters/base_adapter.dart

import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import '../../../models/quota_info.dart';

/// Categories of failure that the UI layer can react to differently.
enum QuotaErrorKind {
  network,
  timeout,
  unauthorized,
  rateLimited,
  server,
  parse,
  unsupported,
  unknown,
}

class QuotaFetchException implements Exception {
  const QuotaFetchException(this.kind, this.message, {this.cause});

  final QuotaErrorKind kind;
  final String message;
  final Object? cause;

  @override
  String toString() => 'QuotaFetchException(${kind.name}): $message';
}

/// Contract implemented by every provider integration.
///
/// `fetchQuota` returns `null` when the service does **not** expose a machine
/// readable usage endpoint (or when the API is reachable but no quota data is
/// available). The UI is expected to fall back to manual entry in that case.
abstract class ServiceAdapter {
  ServiceAdapter({Dio? dio})
      : _dio = dio ?? _buildDefaultDio(),
        _ownsDio = dio == null;

  final Dio _dio;
  final bool _ownsDio;

  /// Stable identifier used for persistence / registry lookups.
  String get serviceId;

  /// `true` when [fetchQuota] performs a real network call.
  bool get supportsApi;

  /// `true` when the user is allowed to enter the quota by hand.
  bool get supportsManual;

  /// Returns the latest quota snapshot, or `null` to trigger manual entry.
  ///
  /// [credentials] is a free‑form bag per service, e.g. `{'apiKey': '...'}`.
  /// Implementations must throw [QuotaFetchException] on hard failures.
  Future<QuotaInfo?> fetchQuota({
    required Map<String, dynamic> credentials,
  });

  /// Releases the underlying HTTP client. Safe to call once.
  void dispose() {
    if (_ownsDio) {
      _dio.close(force: true);
    }
  }

  // ---------------------------------------------------------------------------
  // Shared helpers
  // ---------------------------------------------------------------------------

  @protected
  Dio get dio => _dio;

  /// Issues a GET request and returns the decoded JSON object.
  ///
  /// All [DioException]s are translated into [QuotaFetchException]s so callers
  /// never have to depend on Dio.
  @protected
  Future<Map<String, dynamic>> getJson(
    String url, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        url,
        queryParameters: query,
        options: Options(headers: headers),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      throw const QuotaFetchException(
        QuotaErrorKind.parse,
        'Expected a JSON object response.',
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    } on QuotaFetchException {
      rethrow;
    } catch (e) {
      throw QuotaFetchException(
        QuotaErrorKind.unknown,
        'Unexpected error: $e',
        cause: e,
      );
    }
  }

  @protected
  String requireString(
    Map<String, dynamic> credentials,
    String key, {
    QuotaErrorKind missingKind = QuotaErrorKind.unauthorized,
    String? message,
  }) {
    final value = credentials[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    throw QuotaFetchException(
      missingKind,
      message ?? 'Missing required credential "$key".',
    );
  }

  /// Clamps a 0–100 percentage and guards against division by zero.
  @protected
  double? computeUsagePercent(double? used, double? limit) {
    if (used == null || limit == null || limit <= 0) return null;
    return (used / limit * 100).clamp(0, 100).toDouble();
  }

  QuotaFetchException _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return QuotaFetchException(
          QuotaErrorKind.timeout,
          'The request to $serviceId timed out.',
          cause: e,
        );
      case DioExceptionType.connectionError:
      case DioExceptionType.badCertificate:
        return QuotaFetchException(
          QuotaErrorKind.network,
          'Unable to reach $serviceId. Check your connection.',
          cause: e,
        );
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode ?? 0;
        if (code == 401 || code == 403) {
          return QuotaFetchException(
            QuotaErrorKind.unauthorized,
            'Invalid or expired $serviceId credentials.',
            cause: e,
          );
        }
        if (code == 429) {
          return QuotaFetchException(
            QuotaErrorKind.rateLimited,
            '$serviceId rate limit reached. Try again later.',
            cause: e,
          );
        }
        if (code >= 500) {
          return QuotaFetchException(
            QuotaErrorKind.server,
            '$serviceId is unavailable (HTTP $code).',
            cause: e,
          );
        }
        return QuotaFetchException(
          QuotaErrorKind.server,
          'Unexpected $serviceId response (HTTP $code).',
          cause: e,
        );
      case DioExceptionType.cancel:
        return QuotaFetchException(
          QuotaErrorKind.unknown,
          'Request to $serviceId was cancelled.',
          cause: e,
        );
      case DioExceptionType.unknown:
        return QuotaFetchException(
          QuotaErrorKind.unknown,
          e.message ?? 'Unknown network error.',
          cause: e,
        );
    }
  }

  static Dio _buildDefaultDio() {
    return Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: const {'Accept': 'application/json'},
        responseType: ResponseType.json,
        // Let the adapter translate non‑2xx responses itself.
        validateStatus: (status) => status != null && status < 500,
      ),
    );
  }
}