// lib/data/models/account.dart

import 'dart:convert';

import '../../domain/entities/account.dart';

class AccountModel extends Account {
  final String email;
  final String serviceId;
  final String authType; // e.g. 'api_key', 'oauth', 'manual'
  final Map<String, dynamic> authData;

  const AccountModel({
    super.id,
    required super.name,
    required super.serviceType,
    required super.apiKey,
    super.baseUrl,
    required super.createdAt,
    super.updatedAt,
    super.isActive,
    this.email = '',
    this.serviceId = '',
    this.authType = 'manual',
    this.authData = const {},
  });

  factory AccountModel.fromEntity(Account a) {
    if (a is AccountModel) return a;

    return AccountModel(
      id: a.id,
      name: a.name,
      serviceType: a.serviceType,
      apiKey: a.apiKey,
      baseUrl: a.baseUrl,
      createdAt: a.createdAt,
      updatedAt: a.updatedAt,
      isActive: a.isActive,
      email: a.name, // best-effort fallback
      serviceId: a.serviceType,
      authType: 'manual',
      authData: const {},
    );
  }

  AccountModel copyWith({
    int? id,
    String? name,
    String? serviceType,
    String? apiKey,
    String? baseUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? email,
    String? serviceId,
    String? authType,
    Map<String, dynamic>? authData,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      serviceType: serviceType ?? this.serviceType,
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      email: email ?? this.email,
      serviceId: serviceId ?? this.serviceId,
      authType: authType ?? this.authType,
      authData: authData ?? this.authData,
    );
  }

  /// ---------- JSON (remote / domain transport) ----------
  factory AccountModel.fromJson(Map<String, dynamic> json) {
    final email = json['email'] as String? ?? '';
    final serviceId = json['service_id'] as String? ??
        json['service_type'] as String? ??
        '';

    return AccountModel(
      id: json['id'] as int?,
      name: json['name'] as String? ?? email,
      serviceType: json['service_type'] as String? ?? serviceId,
      apiKey: json['api_key'] as String? ?? '',
      baseUrl: json['base_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      isActive: (json['is_active'] as int? ?? 1) == 1,
      email: email,
      serviceId: serviceId,
      authType: json['auth_type'] as String? ?? 'manual',
      authData: _decodeMap(json['auth_data']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
        'service_type': serviceType,
        'api_key': apiKey,
        'base_url': baseUrl,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'is_active': isActive ? 1 : 0,
        'email': email,
        'service_id': serviceId,
        'auth_type': authType,
        'auth_data': jsonEncode(authData),
      };

  /// ---------- SQLite row mapping ----------
  factory AccountModel.fromMap(Map<String, dynamic> map) {
    final email = map['email'] as String? ?? '';
    final serviceId = map['service_id'] as String? ??
        map['service_type'] as String? ??
        '';

    return AccountModel(
      id: map['id'] as int?,
      name: map['name'] as String? ?? email,
      serviceType: map['service_type'] as String? ?? serviceId,
      apiKey: map['api_key'] as String? ?? '',
      baseUrl: map['base_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      isActive: (map['is_active'] as int? ?? 1) == 1,
      email: email,
      serviceId: serviceId,
      authType: map['auth_type'] as String? ?? 'manual',
      authData: _decodeMap(map['auth_data']),
    );
  }

  Map<String, dynamic> toMap({bool includeId = false}) => {
        if (includeId && id != null) 'id': id,
        'name': name,
        'service_type': serviceType,
        'api_key': apiKey,
        'base_url': baseUrl,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'is_active': isActive ? 1 : 0,
        'email': email,
        'service_id': serviceId,
        'auth_type': authType,
        'auth_data': jsonEncode(authData),
      };

  static Map<String, dynamic> _decodeMap(dynamic raw) {
    if (raw == null) return {};
    if (raw is Map<String, dynamic>) return raw;
    if (raw is String && raw.isEmpty) return {};
    if (raw is String) {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : {};
    }
    return {};
  }

  @override
  String toString() =>
      'AccountModel(id: $id, email: $email, serviceId: $serviceId, '
      'authType: $authType, name: $name, serviceType: $serviceType)';
}