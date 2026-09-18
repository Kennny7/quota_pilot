// lib/presentation/screens/about_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

final packageInfoProvider = FutureProvider<PackageInfo>(
  (ref) => PackageInfo.fromPlatform(),
);

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  static const _appName = 'QuotaPilot';
  static const _developer = 'QuotaPilot Team';
  static const _contactEmail = 'hello@quotapilot.app';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final infoAsync = ref.watch(packageInfoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.speed_outlined,
                    size: 44,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 16),
                Text(_appName, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 4),
                infoAsync.when(
                  loading: () => const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, __) => const Text('Version unavailable'),
                  data: (info) => Text(
                    'Version ${info.version} (build ${info.buildNumber})',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text('Developer'),
                  subtitle: Text(_developer),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.mail_outline),
                  title: const Text('Contact'),
                  subtitle: const Text(_contactEmail),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'QuotaPilot helps you keep an eye on the remaining quota of your '
            'AI provider accounts in one place. It is an independent project '
            'and is not affiliated with any of the providers it supports.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}