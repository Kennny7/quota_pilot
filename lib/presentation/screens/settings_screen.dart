// lib/presentation/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user_settings.dart';
import '../providers/settings_providers.dart';
import '../widgets/quota_alert_settings_section.dart';
import 'about_screen.dart';
import 'donate_screen.dart';
import 'terms_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static String _themeLabel(AppThemeMode mode) => switch (mode) {
        AppThemeMode.system => 'System default',
        AppThemeMode.light => 'Light',
        AppThemeMode.dark => 'Dark',
      };

  Future<void> _pickTheme(
    BuildContext context,
    WidgetRef ref,
    AppThemeMode current,
  ) async {
    final selected = await showDialog<AppThemeMode>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Theme'),
        children: [
          for (final mode in AppThemeMode.values)
            ListTile(
              title: Text(_themeLabel(mode)),
              trailing: mode == current
                  ? Icon(
                      Icons.check,
                      color: Theme.of(dialogContext).colorScheme.primary,
                    )
                  : null,
              onTap: () => Navigator.of(dialogContext).pop(mode),
            ),
        ],
      ),
    );
    if (selected != null) {
      await ref.read(settingsProvider.notifier).setThemeMode(selected);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Could not load settings: $error')),
        data: (settings) => ListView(
          children: [
            const _SectionHeader('General'),
            ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: const Text('Theme'),
              subtitle: Text(_themeLabel(settings.themeMode)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _pickTheme(context, ref, settings.themeMode),
            ),
            const Divider(),
            const _SectionHeader('Notifications'),
            QuotaAlertSettingsSection(settings: settings),
            const Divider(),
            const _SectionHeader('Information'),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Terms & Privacy'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TermsScreen()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.favorite_outline),
              title: const Text('Donate'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DonateScreen()),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          letterSpacing: 1.1,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}