// lib/data/models/account.dart

import 'dart:convert';

import '../../domain/entities/account.dart';

class AccountModel extends Account {
  const AccountModel({
    super.id,
    required super.email,
    required super.serviceId,
    super.authType = AccountAuthType.apiKey,
    super.apiKey,
    super.baseUrl,
    super.authData = const {},
    required super.createdAt,
    super.updatedAt,
    super.isActive = true,
  });

  factory AccountModel.fromEntity(Account a) {
    if (a is AccountModel) return a;
    return AccountModel(
      id: a.id,
      email: a.email,
      serviceId: a.serviceId,
      authType: a.authType,
      apiKey: a.apiKey,
      baseUrl: a.baseUrl,
      authData: a.authData,
      createdAt: a.createdAt,
      updatedAt: a.updatedAt,
      isActive: a.isActive,
    );
  }

  Account toEntity() => Account(
        id: id,
        email: email,
        serviceId: serviceId,
        authType: authType,
        apiKey: apiKey,
        baseUrl: baseUrl,
        authData: authData,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isActive: isActive,
      );

  @override
  AccountModel copyWith({
    int? id,
    String? email,
    String? serviceId,
    AccountAuthType? authType,
    String? apiKey,
    String? baseUrl,
    Map<String, dynamic>? authData,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return AccountModel(
      id: id ?? this.id,
      email: email ?? this.email,
      serviceId: serviceId ?? this.serviceId,
      authType: authType ?? this.authType,
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      authData: authData ?? this.authData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    final email = json['email'] as String? ?? json['name'] as String? ?? '';
    final serviceId = json['service_id'] as String? ??
        json['service_type'] as String? ??
        json['serviceId'] as String? ??
        '';
    final authTypeRaw = json['auth_type'] as String? ??
        json['authType'] as String? ??
        'api_key';

    return AccountModel(
      id: json['id'] as int?,
      email: email,
      serviceId: serviceId,
      authType: AccountAuthType.fromString(authTypeRaw),
      apiKey: json['api_key'] as String? ?? json['apiKey'] as String?,
      baseUrl: json['base_url'] as String? ?? json['baseUrl'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      isActive: (json['is_active'] as int? ?? (json['isActive'] == false ? 0 : 1)) == 1,
      authData: _decodeMap(json['auth_data'] ?? json['authData']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'email': email,
        'service_id': serviceId,
        'auth_type': authType.toDbString(),
        'api_key': apiKey,
        'base_url': baseUrl,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'is_active': isActive ? 1 : 0,
        'auth_data': jsonEncode(authData),
      };

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    final email = map['email'] as String? ?? map['name'] as String? ?? '';
    final serviceId = map['service_id'] as String? ??
        map['service_type'] as String? ??
        '';
    final authTypeRaw = map['auth_type'] as String? ?? 'api_key';

    return AccountModel(
      id: map['id'] as int?,
      email: email,
      serviceId: serviceId,
      authType: AccountAuthType.fromString(authTypeRaw),
      apiKey: map['api_key'] as String?,
      baseUrl: map['base_url'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      isActive: (map['is_active'] as int? ?? 1) == 1,
      authData: _decodeMap(map['auth_data']),
    );
  }

  Map<String, dynamic> toMap({bool includeId = false}) => {
        if (includeId && id != null) 'id': id,
        'email': email,
        'service_id': serviceId,
        'auth_type': authType.toDbString(),
        if (apiKey != null) 'api_key': apiKey,
        if (baseUrl != null) 'base_url': baseUrl,
        'created_at': createdAt.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
        'is_active': isActive ? 1 : 0,
        'auth_data': jsonEncode(authData),
      };

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
}