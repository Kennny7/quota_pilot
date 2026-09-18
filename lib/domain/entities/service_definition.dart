// lib/domain/entities/service_definition.dart

class ServiceDefinition {
  final String id;
  final String name;
  final String adapterKey;
  final String? iconAsset;
  final bool supportsAutoFetch;

  const ServiceDefinition({
    required this.id,
    required this.name,
    required this.adapterKey,
    this.iconAsset,
    this.supportsAutoFetch = true,
  });
}