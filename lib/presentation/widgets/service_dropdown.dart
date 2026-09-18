// lib/presentation/widgets/service_dropdown.dart

// lib/presentation/widgets/service_dropdown.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/service_definition.dart';
import '../providers/account_providers.dart';

class ServiceDropdown extends ConsumerWidget {
  const ServiceDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ServiceDefinition? value;
  final ValueChanged<ServiceDefinition?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final services = ref.watch(serviceDefinitionsProvider);

    return DropdownButtonFormField<ServiceDefinition>(
      initialValue: value,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Service',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.hub_outlined),
      ),
      items: [
        for (final service in services)
          DropdownMenuItem<ServiceDefinition>(
            value: service,
            child: Text(service.name, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: onChanged,
      validator: (v) => v == null ? 'Please pick a service' : null,
    );
  }
}