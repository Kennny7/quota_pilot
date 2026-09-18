// lib/data/models/quota_info.dart

// lib/data/models/quota_info.dart

import 'dart:convert';

import 'package:meta/meta.dart';

@immutable
class QuotaInfo {
  final int? id;
  final int accountId;

  final Map<String, dynamic>? _quotaData;
  final DateTime? _fetchedAt;
  final DateTime? _lastUpdated;

  final double? remaining;
  final double? limit;
  final double? usagePercent;

  final Map<String, dynamic>? _raw;

  const QuotaInfo({
    this.id,
    this.accountId = 0,
    Map<String, dynamic>? quotaData,
    DateTime? fetchedAt,
    DateTime? lastUpdated,
    this.remaining,
    this.limit,
    this.usagePercent,
    Map<String, dynamic>? raw,
  })  : _quotaData = quotaData,
        _fetchedAt = fetchedAt,
        _lastUpdated = lastUpdated,
        _raw = raw;

  Map<String, dynamic> get quotaData =>
      _quotaData ?? _raw ?? const <String, dynamic>{};

  Map<String, dynamic>? get raw => _raw ?? _quotaData;

  DateTime get fetchedAt =>
      _fetchedAt ??
      _lastUpdated ??
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  DateTime get lastUpdated =>
      _lastUpdated ??
      _fetchedAt ??
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  QuotaInfo copyWith({
    int? id,
    int? accountId,
    Map<String, dynamic>? quotaData,
    DateTime? fetchedAt,
    DateTime? lastUpdated,
    double? remaining,
    double? limit,
    double? usagePercent,
    Map<String, dynamic>? raw,
  }) {
    return QuotaInfo(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      quotaData: quotaData ?? this.quotaData,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      remaining: remaining ?? this.remaining,
      limit: limit ?? this.limit,
      usagePercent: usagePercent ?? this.usagePercent,
      raw: raw ?? this.raw,
    );
  }

  /// ---------- JSON (remote / domain transport) ----------
  factory QuotaInfo.fromJson(Map<String, dynamic> json) {
    final fetchedAtRaw = json['fetched_at'] ?? json['last_updated'];
    final lastUpdatedRaw = json['last_updated'] ?? json['fetched_at'];

    return QuotaInfo(
      id: json['id'] as int?,
      accountId: (json['account_id'] as int?) ?? 0,
      quotaData: _decodeMap(json['quota_data'] ?? json['raw']),
      raw: json.containsKey('raw') ? _decodeMap(json['raw']) : null,
      fetchedAt:
          fetchedAtRaw is String ? DateTime.parse(fetchedAtRaw) : null,
      lastUpdated:
          lastUpdatedRaw is String ? DateTime.parse(lastUpdatedRaw) : null,
      remaining: _toDouble(json['remaining']),
      limit: _toDouble(json['limit']),
      usagePercent: _toDouble(json['usage_percent'] ?? json['usagePercent']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'account_id': accountId,
        'quota_data': jsonEncode(quotaData),
        'fetched_at': fetchedAt.toIso8601String(),
        'last_updated': lastUpdated.toIso8601String(),
        if (remaining != null) 'remaining': remaining,
        if (limit != null) 'limit': limit,
        if (usagePercent != null) 'usage_percent': usagePercent,
        if (_raw != null) 'raw': _raw,
      };

  /// ---------- SQLite row mapping ----------
  factory QuotaInfo.fromMap(Map<String, dynamic> map) {
    final fetchedAtRaw = map['fetched_at'] ?? map['last_updated'];
    final lastUpdatedRaw = map['last_updated'] ?? map['fetched_at'];

    return QuotaInfo(
      id: map['id'] as int?,
      accountId: (map['account_id'] as int?) ?? 0,
      quotaData: _decodeMap(map['quota_data'] ?? map['raw']),
      raw: map.containsKey('raw') ? _decodeMap(map['raw']) : null,
      fetchedAt:
          fetchedAtRaw is String ? DateTime.parse(fetchedAtRaw) : null,
      lastUpdated:
          lastUpdatedRaw is String ? DateTime.parse(lastUpdatedRaw) : null,
      remaining: _toDouble(map['remaining']),
      limit: _toDouble(map['limit']),
      usagePercent: _toDouble(map['usage_percent'] ?? map['usagePercent']),
    );
  }

  Map<String, dynamic> toMap({bool includeId = false}) => {
        if (includeId && id != null) 'id': id,
        'account_id': accountId,
        'quota_data': jsonEncode(quotaData),
        'fetched_at': fetchedAt.toIso8601String(),
        'last_updated': lastUpdated.toIso8601String(),
        if (remaining != null) 'remaining': remaining,
        if (limit != null) 'limit': limit,
        if (usagePercent != null) 'usage_percent': usagePercent,
        if (_raw != null) 'raw': jsonEncode(_raw),
      };

  static Map<String, dynamic> _decodeMap(dynamic raw) {
    if (raw == null) return {};
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is String && raw.isEmpty) return {};
    if (raw is String) {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return {};
    }
    return {};
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  @override
  String toString() =>
      'QuotaInfo(id: $id, accountId: $accountId, '
      'remaining: $remaining, limit: $limit, '
      'usagePercent: $usagePercent, fetchedAt: $fetchedAt, '
      'lastUpdated: $lastUpdated)';
}