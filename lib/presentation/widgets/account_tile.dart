// lib/presentation/widgets/account_tile.dart
import 'package:flutter/material.dart';

import '../../domain/entities/account.dart';
import '../../domain/entities/service_definition.dart';

class AccountTile extends StatelessWidget {
  const AccountTile({
    super.key,
    required this.account,
    this.service,
    this.dense = false,
    this.trailing,
    this.onTap,
  });

  final Account account;
  final ServiceDefinition? service;
  final bool dense;
  final Widget? trailing;
  final VoidCallback? onTap;

  String get _initials {
    final source = account.email.trim();
    if (source.isEmpty) return '?';
    return source.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: dense,
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        child: Text(
          _initials,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      title: Text(
        account.email,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        service?.name ?? account.serviceId,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall,
      ),
      trailing: trailing,
    );
  }
}