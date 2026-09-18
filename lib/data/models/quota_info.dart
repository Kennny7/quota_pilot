// lib/data/models/quota_info.dart

import 'dart:convert';

import '../../domain/entities/quota_info.dart';

class QuotaInfoModel extends QuotaInfo {
  const QuotaInfoModel({
    super.id,
    required super.accountId,
    required super.limit,
    required super.used,
    required super.unit,
    required super.fetchedAt,
    super.isManual = false,
    super.rawData,
  });

  factory QuotaInfoModel.fromEntity(QuotaInfo q) {
    if (q is QuotaInfoModel) return q;
    return QuotaInfoModel(
      id: q.id,
      accountId: q.accountId,
      limit: q.limit,
      used: q.used,
      unit: q.unit,
      fetchedAt: q.fetchedAt,
      isManual: q.isManual,
      rawData: q.rawData,
    );
  }

  QuotaInfo toEntity() => QuotaInfo(
        id: id,
        accountId: accountId,
        limit: limit,
        used: used,
        unit: unit,
        fetchedAt: fetchedAt,
        isManual: isManual,
        rawData: rawData,
      );

  factory QuotaInfoModel.fromJson(Map<String, dynamic> json) {
    final accountId = (json['account_id'] as int?) ??
        (json['accountId'] as int?) ??
        0;
    final limit = _toDouble(json['limit'] ?? json['total_quota'] ?? json['totalQuota']) ?? 100.0;
    final used = _toDouble(json['used'] ?? json['used_quota'] ?? json['usedQuota']) ?? 0.0;
    final unit = json['unit'] as String? ?? 'requests';
    final fetchedAtRaw = json['fetched_at'] ?? json['last_updated'] ?? json['fetchedAt'];
    final fetchedAt = fetchedAtRaw is String
        ? DateTime.parse(fetchedAtRaw)
        : DateTime.now();
    final isManual = json['is_manual'] == 1 || json['isManual'] == true;

    return QuotaInfoModel(
      id: json['id'] as int?,
      accountId: accountId,
      limit: limit,
      used: used,
      unit: unit,
      fetchedAt: fetchedAt,
      isManual: isManual,
      rawData: _decodeMap(json['quota_data'] ?? json['raw'] ?? json['rawData']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'account_id': accountId,
        'limit': limit,
        'used': used,
        'unit': unit,
        'fetched_at': fetchedAt.toIso8601String(),
        'is_manual': isManual ? 1 : 0,
        if (rawData != null) 'quota_data': jsonEncode(rawData),
      };

  factory QuotaInfoModel.fromMap(Map<String, dynamic> map) {
    final accountId = (map['account_id'] as int?) ?? 0;
    final rawData = _decodeMap(map['quota_data']);

    // Check if limit / used were stored as explicit columns or in quota_data
    final limit = _toDouble(map['limit'] ?? rawData['limit']) ?? 100.0;
    final used = _toDouble(map['used'] ?? rawData['used']) ?? 0.0;
    final unit = map['unit'] as String? ?? (rawData['unit'] as String?) ?? 'requests';
    final fetchedAtRaw = map['fetched_at'] as String?;
    final fetchedAt = fetchedAtRaw != null
        ? DateTime.parse(fetchedAtRaw)
        : DateTime.now();
    final isManual = map['is_manual'] == 1;

    return QuotaInfoModel(
      id: map['id'] as int?,
      accountId: accountId,
      limit: limit,
      used: used,
      unit: unit,
      fetchedAt: fetchedAt,
      isManual: isManual,
      rawData: rawData,
    );
  }

  Map<String, dynamic> toMap({bool includeId = false}) {
    final mapData = <String, dynamic>{
      'used': used,
      'limit': limit,
      'unit': unit,
      'isManual': isManual,
      ...?rawData,
    };

    return {
      if (includeId && id != null) 'id': id,
      'account_id': accountId,
      'quota_data': jsonEncode(mapData),
      'fetched_at': fetchedAt.toIso8601String(),
    };
  }

  static Map<String, dynamic> _decodeMap(dynamic raw) {
    if (raw == null) return {};
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return {};
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}