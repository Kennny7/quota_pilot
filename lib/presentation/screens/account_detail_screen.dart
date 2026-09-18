// lib/presentation/screens/account_detail_screen.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/quota_info.dart';
import '../providers/account_providers.dart';
import '../providers/quota_providers.dart';
import '../widgets/account_tile.dart';

class AccountDetailScreen extends ConsumerWidget {
  const AccountDetailScreen({
    super.key,
    this.account,
    this.id,
  }) : assert(account != null || id != null, 'Either account or id must be provided');

  final Account? account;
  final dynamic id;

  Account? _resolveAccount(WidgetRef ref) {
    if (account != null) return account;
    final intId = id is int ? id as int : int.tryParse(id?.toString() ?? '');
    if (intId == null) return null;
    final accounts = ref.watch(accountsProvider).valueOrNull ?? [];
    try {
      return accounts.firstWhere((a) => a.id == intId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _refresh(WidgetRef ref, Account targetAccount) async {
    final accountId = targetAccount.id;
    if (accountId == null) return;
    try {
      await ref.read(quotaRefreshControllerProvider).refreshAccount(accountId);
    } catch (error) {
      // surfaced by the provider state; nothing else to do here
    }
  }

  Future<void> _editManually(BuildContext context, WidgetRef ref, Account targetAccount) async {
    final accountId = targetAccount.id;
    if (accountId == null) return;
    final current = ref.read(latestQuotaProvider(accountId)).valueOrNull;
    final result = await showDialog<_ManualQuotaResult>(
      context: context,
      builder: (_) => _ManualQuotaDialog(
        initialUsed: current?.used ?? 0,
        initialLimit: current?.limit ?? 100,
      ),
    );
    if (result == null) return;
    try {
      await ref.read(quotaRefreshControllerProvider).setManualQuota(
            accountId: accountId,
            used: result.used,
            limit: result.limit,
          );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save quota: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final targetAccount = _resolveAccount(ref);

    if (targetAccount == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Account Detail')),
        body: const Center(
          child: Text('Account not found.'),
        ),
      );
    }

    final targetAccountId = targetAccount.id;
    final service = ref.watch(serviceDefinitionsProvider).byId(targetAccount.serviceId);
    final latestAsync = ref.watch(latestQuotaProvider(targetAccountId));
    final historyAsync = ref.watch(quotaHistoryProvider(targetAccountId));

    return Scaffold(
      appBar: AppBar(
        title: Text(service?.name ?? 'Account'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => _refresh(ref, targetAccount),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'delete') {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Remove account?'),
                    content: Text(
                      'Quota history for ${targetAccount.email} will be deleted.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Remove'),
                      ),
                    ],
                  ),
                );
                if (confirmed ?? false) {
                  final id = targetAccount.id;
                  if (id != null) {
                    await ref.read(accountsProvider.notifier).remove(id);
                  }
                  if (context.mounted) Navigator.of(context).pop();
                }
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'delete', child: Text('Remove account')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AccountTile(account: targetAccount, service: service),
            ),
          ),
          const SizedBox(height: 16),
          Text('Current quota', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: latestAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: LoadingIndicator(),
                ),
                error: (error, _) => ErrorView(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(latestQuotaProvider(targetAccountId)),
                ),
                data: (quota) => _CurrentQuota(
                  quota: quota,
                  unit: service?.quotaUnit ?? '',
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('History', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
              child: SizedBox(
                height: 220,
                child: historyAsync.when(
                  loading: () => const LoadingIndicator(),
                  error: (error, _) => ErrorView(
                    message: error.toString(),
                    onRetry: () =>
                        ref.invalidate(quotaHistoryProvider(targetAccountId)),
                  ),
                  data: (history) => _QuotaHistoryChart(history: history),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.tonalIcon(
            onPressed: () => _editManually(context, ref, targetAccount),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Update quota manually'),
          ),
        ],
      ),
    );
  }
}

class _CurrentQuota extends StatelessWidget {
  const _CurrentQuota({required this.quota, required this.unit});

  final QuotaInfo? quota;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (quota == null) {
      return Text(
        'No quota recorded yet.',
        style: theme.textTheme.bodyMedium,
      );
    }
    final value = quota!;
    final percent = value.percentage.clamp(0, 100).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${percent.toStringAsFixed(1)}%',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              DateFormat('d MMM, HH:mm').format(value.fetchedAt),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percent / 100,
            minHeight: 10,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _Metric(
              label: 'Used',
              value: '${value.used.toStringAsFixed(2)} $unit',
            ),
            _Metric(
              label: 'Remaining',
              value: '${value.remaining.toStringAsFixed(2)} $unit',
            ),
            _Metric(
              label: 'Limit',
              value: '${value.limit.toStringAsFixed(2)} $unit',
            ),
          ],
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuotaHistoryChart extends StatelessWidget {
  const _QuotaHistoryChart({required this.history});

  final List<QuotaInfo> history;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (history.length < 2) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Not enough data yet.\nRefresh a few times to build a trend.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ),
      );
    }

    final sorted = [...history]
      ..sort((a, b) => a.fetchedAt.compareTo(b.fetchedAt));

    final spots = <FlSpot>[
      for (var i = 0; i < sorted.length; i++)
        FlSpot(i.toDouble(), sorted[i].percentage.clamp(0, 100).toDouble()),
    ];

    final bottomInterval =
        (sorted.length / 4).ceilToDouble().clamp(1.0, double.infinity);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (sorted.length - 1).toDouble(),
        minY: 0,
        maxY: 100,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: theme.dividerColor, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 25,
              reservedSize: 42,
              getTitlesWidget: (value, meta) => Text(
                '${value.toInt()}%',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: bottomInterval,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.round();
                if (index < 0 || index >= sorted.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    DateFormat('d/M').format(sorted[index].fetchedAt),
                    style: theme.textTheme.bodySmall,
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touched) => [
              for (final spot in touched)
                LineTooltipItem(
                  '${spot.y.toStringAsFixed(1)}%\n'
                  '${DateFormat('d MMM HH:mm').format(sorted[spot.x.round()].fetchedAt)}',
                  theme.textTheme.bodySmall!
                      .copyWith(color: theme.colorScheme.onInverseSurface),
                ),
            ],
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.25,
            barWidth: 3,
            color: theme.colorScheme.primary,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManualQuotaResult {
  const _ManualQuotaResult({required this.used, required this.limit});

  final double used;
  final double limit;
}

class _ManualQuotaDialog extends StatefulWidget {
  const _ManualQuotaDialog({
    required this.initialUsed,
    required this.initialLimit,
  });

  final double initialUsed;
  final double initialLimit;

  @override
  State<_ManualQuotaDialog> createState() => _ManualQuotaDialogState();
}

class _ManualQuotaDialogState extends State<_ManualQuotaDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usedController;
  late final TextEditingController _limitController;

  @override
  void initState() {
    super.initState();
    _usedController =
        TextEditingController(text: widget.initialUsed.toStringAsFixed(2));
    _limitController =
        TextEditingController(text: widget.initialLimit.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _usedController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      _ManualQuotaResult(
        used: double.parse(_usedController.text.trim()),
        limit: double.parse(_limitController.text.trim()),
      ),
    );
  }

  String? _validateNumber(String? value) {
    final parsed = double.tryParse(value?.trim() ?? '');
    if (parsed == null) return 'Enter a number';
    if (parsed < 0) return 'Must be 0 or greater';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update quota'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _usedController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Used',
                border: OutlineInputBorder(),
              ),
              validator: _validateNumber,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _limitController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Limit',
                border: OutlineInputBorder(),
              ),
              validator: _validateNumber,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}