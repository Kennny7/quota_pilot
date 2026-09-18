// lib/presentation/widgets/quota_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
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

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: AccountTile(
                        account: account,
                        service: service,
                        dense: true,
                      ),
                    ),
                    if (service?.badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          service!.badge!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      )
                    else
                      Icon(
                        Icons.chevron_right_rounded,
                        color: theme.colorScheme.outline,
                        size: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                quotaAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: LinearProgressIndicator(minHeight: 3),
                  ),
                  error: (error, _) => Row(
                    children: [
                      Icon(Icons.error_outline, size: 16, color: theme.colorScheme.error),
                      const SizedBox(width: 6),
                      Text(
                        'Could not load quota',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                  data: (quota) => quota == null
                      ? _NoQuotaYet(account: account)
                      : _QuotaBody(
                          account: account,
                          quota: quota,
                          unit: service?.quotaUnit ?? 'units',
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuotaBody extends ConsumerWidget {
  const _QuotaBody({
    required this.account,
    required this.quota,
    required this.unit,
  });

  final Account account;
  final QuotaInfo quota;
  final String unit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final percent = quota.percentage;

    final Color statusColor = percent >= 40
        ? AppColors.quotaGood
        : (percent >= 20 ? AppColors.quotaWarning : AppColors.quotaCritical);

    final String statusLabel = percent >= 40
        ? 'Healthy'
        : (percent >= 20 ? 'Caution' : 'Critical Low');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '${percent.toStringAsFixed(0)}%',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: statusColor,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ),
            const Spacer(),
            Text(
              '${quota.remaining.toStringAsFixed(1)} / ${quota.limit.toStringAsFixed(1)} $unit',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: (percent / 100).clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Used: ${quota.used.toStringAsFixed(1)} $unit',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            Row(
              children: [
                if (account.authType == AccountAuthType.manual) ...[
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () async {
                      if (account.id != null) {
                        final newUsed = (quota.used + 1).clamp(0.0, quota.limit);
                        await ref.read(quotaRefreshControllerProvider).setManualQuota(
                              accountId: account.id!,
                              used: newUsed,
                              limit: quota.limit,
                              unit: unit,
                            );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '+1 Used',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.sync_rounded, size: 18),
                  tooltip: 'Sync Quota',
                  color: theme.colorScheme.outline,
                  onPressed: () => ref
                      .read(quotaRefreshControllerProvider)
                      .refreshAccount(account.id),
                ),
              ],
            ),
          ],
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
                ? 'Pull down to fetch the latest quota from API.'
                : 'No quota recorded yet. Tap to configure limits.',
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}