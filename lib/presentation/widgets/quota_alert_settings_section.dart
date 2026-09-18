// lib/presentation/widgets/quota_alert_settings_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/notification_providers.dart';
import '../providers/settings_providers.dart';

const int _kMinThreshold = 5;
const int _kMaxThreshold = 90;
const int _kThresholdStep = 5;

class QuotaAlertSettingsSection extends ConsumerWidget {
  const QuotaAlertSettingsSection({super.key, required this.settings});

  final UserSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(settingsProvider.notifier);
    final threshold =
        settings.quotaAlertThreshold.clamp(_kMinThreshold, _kMaxThreshold);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.notifications_outlined),
          title: const Text('Low quota alerts'),
          subtitle: const Text(
            'Notify me when an account drops below the threshold',
          ),
          value: settings.quotaAlertsEnabled,
          onChanged: (value) => notifier.setQuotaAlertsEnabled(value),
        ),
        if (settings.quotaAlertsEnabled) ...[
          ListTile(
            title: Text('Alert threshold: $threshold%'),
            subtitle: Slider(
              min: _kMinThreshold.toDouble(),
              max: _kMaxThreshold.toDouble(),
              divisions: (_kMaxThreshold - _kMinThreshold) ~/ _kThresholdStep,
              value: threshold.toDouble(),
              label: '$threshold%',
              onChanged: (value) =>
                  notifier.setQuotaAlertThreshold(value.round()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: OutlinedButton.icon(
              onPressed: () async {
                await ref.read(quotaAlertServiceProvider).sendTestAlert();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Test notification triggered.')),
                  );
                }
              },
              icon: const Icon(Icons.send_outlined, size: 16),
              label: const Text('Send Test Alert'),
            ),
          ),
        ],
      ],
    );
  }
}