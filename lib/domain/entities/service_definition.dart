// lib/domain/entities/service_definition.dart

class ServiceDefinition {
  final String id;
  final String name;
  final bool supportsApiKey;
  final bool supportsManual;
  final String quotaUnit;
  final String docsUrl;
  final String description;
  final String colorHex;
  final String? badge;

  const ServiceDefinition({
    required this.id,
    required this.name,
    this.supportsApiKey = true,
    this.supportsManual = true,
    this.quotaUnit = 'requests',
    this.docsUrl = '',
    this.description = '',
    this.colorHex = '#2563EB',
    this.badge,
  });

  // Aliases for compatibility
  bool get supportsAutoFetch => supportsApiKey;
  bool get supportsApi => supportsApiKey;
  String get adapterKey => id;
  String? get logoUrl => null;

  @override
  String toString() => 'ServiceDefinition(id: $id, name: $name)';
}