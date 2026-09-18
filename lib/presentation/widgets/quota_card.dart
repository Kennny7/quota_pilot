// lib/presentation/widgets/quota_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/account.dart';
import '../../domain/entities/quota_info.dart';
import '../providers/account_providers.dart';
import '../providers/quota_providers.dart';
import 'account_tile.dart';

class QuotaCard extends ConsumerWidget {
  const QuotaCard({super.key, required this.account, this.onTap});

  final Account account;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final service = ref.watch(serviceDefinitionsProvider).byId(account.serviceId);
    final quotaAsync = ref.watch(latestQuotaProvider(account.id));

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AccountTile(
                account: account,
                service: service,
                dense: true,
                trailing: Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 8),
              quotaAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(minHeight: 2),
                ),
                error: (error, _) => Text(
                  'Could not load quota',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                data: (quota) => quota == null
                    ? _NoQuotaYet(account: account)
                    : _QuotaBody(
                        quota: quota,
                        unit: service?.quotaUnit ?? '',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuotaBody extends StatelessWidget {
  const _QuotaBody({required this.quota, required this.unit});

  final QuotaInfo quota;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = quota.percentage.clamp(0, 100).toDouble();
    final color = percent >= 50
        ? theme.colorScheme.primary
        : percent >= 20
            ? Colors.orange
            : theme.colorScheme.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${percent.toStringAsFixed(0)}%',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('remaining', style: theme.textTheme.bodySmall),
            ),
            const Spacer(),
            Text(
              '${quota.remaining.toStringAsFixed(2)} / '
              '${quota.limit.toStringAsFixed(2)} $unit',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: percent / 100,
            minHeight: 8,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _NoQuotaYet extends StatelessWidget {
  const _NoQuotaYet({required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(Icons.info_outline, size: 16, color: theme.colorScheme.outline),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            account.authType == AccountAuthType.apiKey
                ? 'Pull down to fetch the latest quota.'
                : 'No quota recorded yet — add one manually.',
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}