// lib/domain/entities/account.dart

enum AccountAuthType {
  apiKey,
  manual,
  oauth;

  String get label => switch (this) {
        AccountAuthType.apiKey => 'API Key',
        AccountAuthType.manual => 'Manual',
        AccountAuthType.oauth => 'OAuth',
      };

  static AccountAuthType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'api_key':
      case 'apikey':
        return AccountAuthType.apiKey;
      case 'oauth':
        return AccountAuthType.oauth;
      case 'manual':
      default:
        return AccountAuthType.manual;
    }
  }

  String toDbString() => switch (this) {
        AccountAuthType.apiKey => 'api_key',
        AccountAuthType.manual => 'manual',
        AccountAuthType.oauth => 'oauth',
      };
}

class Account {
  final int? id;
  final String email;
  final String serviceId;
  final AccountAuthType authType;
  final String? apiKey;
  final String? baseUrl;
  final Map<String, dynamic> authData;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  const Account({
    this.id,
    required this.email,
    required this.serviceId,
    this.authType = AccountAuthType.apiKey,
    this.apiKey,
    this.baseUrl,
    this.authData = const {},
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  // Backwards compatibility aliases
  String get name => email;
  String get serviceType => serviceId;
  String get label => email;

  Account copyWith({
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
  }) =>
      Account(
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Account &&
          other.id == id &&
          other.email == email &&
          other.serviceId == serviceId &&
          other.authType == authType &&
          other.apiKey == apiKey &&
          other.baseUrl == baseUrl &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt &&
          other.isActive == isActive;

  @override
  int get hashCode => Object.hash(
        id,
        email,
        serviceId,
        authType,
        apiKey,
        baseUrl,
        createdAt,
        updatedAt,
        isActive,
      );

  @override
  String toString() =>
      'Account(id: $id, email: $email, serviceId: $serviceId, authType: ${authType.name})';
}