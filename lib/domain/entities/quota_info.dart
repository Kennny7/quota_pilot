// lib/domain/entities/quota_info.dart

class QuotaInfo {
  final int? id;
  final int accountId;
  final double totalQuota;
  final double usedQuota;
  final String unit; // 'usd' | 'tokens' | 'requests'
  final DateTime fetchedAt;
  final bool isManual;

  const QuotaInfo({
    this.id,
    required this.accountId,
    required this.totalQuota,
    required this.usedQuota,
    required this.unit,
    required this.fetchedAt,
    this.isManual = false,
  });

  double get remainingQuota =>
      (totalQuota - usedQuota).clamp(0, double.infinity).toDouble();

  double get usageRatio =>
      totalQuota <= 0 ? 0 : (usedQuota / totalQuota).clamp(0, 1).toDouble();

  QuotaInfo copyWith({
    int? id,
    int? accountId,
    double? totalQuota,
    double? usedQuota,
    String? unit,
    DateTime? fetchedAt,
    bool? isManual,
  }) => QuotaInfo(
        id: id ?? this.id,
        accountId: accountId ?? this.accountId,
        totalQuota: totalQuota ?? this.totalQuota,
        usedQuota: usedQuota ?? this.usedQuota,
        unit: unit ?? this.unit,
        fetchedAt: fetchedAt ?? this.fetchedAt,
        isManual: isManual ?? this.isManual,
      );
}