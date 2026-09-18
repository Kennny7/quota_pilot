// lib/domain/entities/quota_info.dart

class QuotaInfo {
  final int? id;
  final int accountId;
  final double limit;
  final double used;
  final String unit; // 'USD' | 'tokens' | 'requests' | 'credits'
  final DateTime fetchedAt;
  final bool isManual;
  final Map<String, dynamic>? rawData;

  const QuotaInfo({
    this.id,
    required this.accountId,
    required this.limit,
    required this.used,
    required this.unit,
    required this.fetchedAt,
    this.isManual = false,
    this.rawData,
  });

  // Derived properties
  double get remaining =>
      (limit - used).clamp(0.0, double.infinity).toDouble();

  double get percentage =>
      limit <= 0 ? 0.0 : ((limit - used) / limit * 100).clamp(0.0, 100.0).toDouble();

  double get remainingPercent => percentage;

  double get usageRatio =>
      limit <= 0 ? 0.0 : (used / limit).clamp(0.0, 1.0).toDouble();

  double get usagePercent => (usageRatio * 100).clamp(0.0, 100.0).toDouble();

  // Backward-compatibility aliases
  double get totalQuota => limit;
  double get usedQuota => used;
  double get remainingQuota => remaining;
  DateTime get lastUpdated => fetchedAt;
  Map<String, dynamic> get quotaData => rawData ?? const {};

  QuotaInfo copyWith({
    int? id,
    int? accountId,
    double? limit,
    double? used,
    String? unit,
    DateTime? fetchedAt,
    bool? isManual,
    Map<String, dynamic>? rawData,
  }) =>
      QuotaInfo(
        id: id ?? this.id,
        accountId: accountId ?? this.accountId,
        limit: limit ?? this.limit,
        used: used ?? this.used,
        unit: unit ?? this.unit,
        fetchedAt: fetchedAt ?? this.fetchedAt,
        isManual: isManual ?? this.isManual,
        rawData: rawData ?? this.rawData,
      );

  @override
  String toString() =>
      'QuotaInfo(id: $id, accountId: $accountId, used: $used, limit: $limit, remaining: $remaining $unit)';
}