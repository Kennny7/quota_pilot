// lib/presentation/widgets/quota_alert_settings_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user_settings.dart';
import '../providers/settings_providers.dart';

/// Slider bounds. Deliberately narrower than the entity's documented 1–100:
/// sub-5% alerts are noise, 90%+ fires on essentially every account.
const int _kMinThreshold = 5;
const int _kMaxThreshold = 90;
const int _kThresholdStep = 5;

class QuotaAlertSettingsSection extends ConsumerWidget {
  const QuotaAlertSettingsSection({super.key, required this.settings});

  /// The parent screen already has this from its own `settingsProvider`
  /// watch — passing it in avoids a second subscription and keeps this
  /// widget's rebuilds tied to the caller's.
  final UserSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(settingsProvider.notifier);

    // Guard against a stored value outside the slider range — an old write,
    // or the entity default of 20 surviving a slider range change. Slider
    // asserts if `value` falls outside [min, max].
    final threshold = settings.quotaAlertThreshold
        .clamp(_kMinThreshold, _kMaxThreshold);

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
        if (settings.quotaAlertsEnabled)
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
      ],
    );
  }
}