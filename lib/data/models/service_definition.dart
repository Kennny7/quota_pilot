// lib/data/models/service_definition.dart

import '../../domain/entities/service_definition.dart';

class ServiceDefinitionModel extends ServiceDefinition {
  const ServiceDefinitionModel({
    required super.id,
    required super.name,
    super.supportsApiKey = true,
    super.supportsManual = true,
    super.quotaUnit = 'requests',
    super.docsUrl = '',
    super.description = '',
    super.colorHex = '#2563EB',
    super.badge,
  });

  factory ServiceDefinitionModel.fromEntity(ServiceDefinition s) {
    if (s is ServiceDefinitionModel) return s;
    return ServiceDefinitionModel(
      id: s.id,
      name: s.name,
      supportsApiKey: s.supportsApiKey,
      supportsManual: s.supportsManual,
      quotaUnit: s.quotaUnit,
      docsUrl: s.docsUrl,
      description: s.description,
      colorHex: s.colorHex,
      badge: s.badge,
    );
  }

  factory ServiceDefinitionModel.fromJson(Map<String, dynamic> json) {
    return ServiceDefinitionModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      supportsApiKey: _toBool(json['supports_api'] ?? json['supportsApiKey']),
      supportsManual: _toBool(json['supports_manual'] ?? json['supportsManual']),
      quotaUnit: json['quota_unit'] as String? ?? json['quotaUnit'] as String? ?? 'requests',
      docsUrl: json['docs_url'] as String? ?? json['docsUrl'] as String? ?? '',
      description: json['description'] as String? ?? '',
      colorHex: json['color_hex'] as String? ?? json['colorHex'] as String? ?? '#2563EB',
      badge: json['badge'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'supports_api': supportsApiKey ? 1 : 0,
        'supports_manual': supportsManual ? 1 : 0,
        'quota_unit': quotaUnit,
        'docs_url': docsUrl,
        'description': description,
        'color_hex': colorHex,
        if (badge != null) 'badge': badge,
      };

  factory ServiceDefinitionModel.fromMap(Map<String, dynamic> map) {
    return ServiceDefinitionModel(
      id: map['id'] as String,
      name: map['name'] as String? ?? '',
      supportsApiKey: _toBool(map['supports_api']),
      supportsManual: _toBool(map['supports_manual']),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'supports_api': supportsApiKey ? 1 : 0,
        'supports_manual': supportsManual ? 1 : 0,
      };

  static bool _toBool(dynamic v) {
    if (v is bool) return v;
    if (v is int) return v != 0;
    if (v is String) return v == '1' || v.toLowerCase() == 'true';
    return false;
  }
}