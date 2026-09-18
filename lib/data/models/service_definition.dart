// lib/data/models/service_definition.dart

class ServiceDefinition {
  final String id;
  final String name;
  final String? logoUrl;
  final bool supportsApi;
  final bool supportsManual;

  const ServiceDefinition({
    required this.id,
    required this.name,
    this.logoUrl,
    required this.supportsApi,
    required this.supportsManual,
  });

  ServiceDefinition copyWith({
    String? id,
    String? name,
    String? logoUrl,
    bool? supportsApi,
    bool? supportsManual,
  }) {
    return ServiceDefinition(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      supportsApi: supportsApi ?? this.supportsApi,
      supportsManual: supportsManual ?? this.supportsManual,
    );
  }

  /// ---------- JSON (remote / domain transport) ----------
  factory ServiceDefinition.fromJson(Map<String, dynamic> json) {
    return ServiceDefinition(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      logoUrl: json['logo_url'] as String?,
      supportsApi: _toBool(json['supports_api']),
      supportsManual: _toBool(json['supports_manual']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'logo_url': logoUrl,
        'supports_api': supportsApi ? 1 : 0,
        'supports_manual': supportsManual ? 1 : 0,
      };

  /// ---------- SQLite row mapping ----------
  factory ServiceDefinition.fromMap(Map<String, dynamic> map) {
    return ServiceDefinition(
      id: map['id'] as String,
      name: map['name'] as String? ?? '',
      logoUrl: map['logo_url'] as String?,
      supportsApi: _toBool(map['supports_api']),
      supportsManual: _toBool(map['supports_manual']),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'logo_url': logoUrl,
        'supports_api': supportsApi ? 1 : 0,
        'supports_manual': supportsManual ? 1 : 0,
      };

  static bool _toBool(dynamic v) {
    if (v is bool) return v;
    if (v is int) return v != 0;
    if (v is String) return v == '1' || v.toLowerCase() == 'true';
    return false;
  }

  @override
  String toString() => 'ServiceDefinition(id: $id, name: $name)';
}