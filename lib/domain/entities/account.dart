// lib/domain/entities/account.dart

class Account {
  final int? id;
  final String name;
  final String serviceType; // 'openai' | 'google' | 'anthropic' | 'grok'
  final String apiKey;
  final String? baseUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  const Account({
    this.id,
    required this.name,
    required this.serviceType,
    required this.apiKey,
    this.baseUrl,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  Account copyWith({
    int? id,
    String? name,
    String? serviceType,
    String? apiKey,
    String? baseUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) => Account(
        id: id ?? this.id,
        name: name ?? this.name,
        serviceType: serviceType ?? this.serviceType,
        apiKey: apiKey ?? this.apiKey,
        baseUrl: baseUrl ?? this.baseUrl,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isActive: isActive ?? this.isActive,
      );

  @override
  bool operator ==(Object other) =>
      other is Account &&
      other.id == id &&
      other.name == name &&
      other.serviceType == serviceType &&
      other.apiKey == apiKey &&
      other.baseUrl == baseUrl &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt &&
      other.isActive == isActive;

  @override
  int get hashCode =>
      Object.hash(id, name, serviceType, apiKey, baseUrl, createdAt, updatedAt, isActive);
}