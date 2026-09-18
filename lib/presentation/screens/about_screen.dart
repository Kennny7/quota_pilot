// lib/presentation/screens/about_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_strings.dart';

final packageInfoProvider = FutureProvider<PackageInfo>(
  (ref) => PackageInfo.fromPlatform(),
);

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  Future<void> _openUrl(BuildContext context, String urlString) async {
    final uri = Uri.parse(urlString);
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Could not open link.')),
        );
      }
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not open link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final infoAsync = ref.watch(packageInfoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          Center(
            child: Column(
              children: [
                // Geometric Prism Custom Logo
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.tertiary.withAlpha(220),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withAlpha(70),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: CustomPaint(
                      size: const Size(48, 48),
                      painter: _PrismLogoPainter(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  AppStrings.appName,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.appTagline,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                infoAsync.when(
                  loading: () => const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, __) => Text(
                    AppStrings.version,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  data: (info) => Text(
                    'Version ${info.version} (Build ${info.buildNumber})',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // LazyMoneyLabs Studio Card
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withAlpha(100),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.dividerColor.withAlpha(40),
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.rocket_launch_rounded,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.companyName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          AppStrings.companyTagline,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  AppStrings.companyDescription,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openUrl(context, AppStrings.companyWebsite),
                        icon: const Icon(Icons.language_rounded, size: 18),
                        label: const Text('Website'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openUrl(context, 'mailto:${AppStrings.supportEmail}'),
                        icon: const Icon(Icons.alternate_email_rounded, size: 18),
                        label: const Text('Contact'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Legal & Licenses
          Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.shield_outlined),
                  title: const Text('Privacy & Security'),
                  subtitle: const Text('Local-first, no credentials sent to 3rd parties'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).pushNamed('/terms'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.code_rounded),
                  title: const Text(AppStrings.openSourceLicenses),
                  subtitle: const Text('View licenses of third-party packages'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: AppStrings.appName,
                    applicationVersion: AppStrings.version,
                    applicationLegalese: 'Crafted by ${AppStrings.companyName}',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'QuotaPilot helps you monitor remaining quotas across AI APIs and LLM web accounts. '
            'It operates locally on your device and is not affiliated with Google, OpenAI, Anthropic, or xAI.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

/// Custom geometric prism logo painter representing multiple creative facets of LazyMoneyLabs.
class _PrismLogoPainter extends CustomPainter {
  final Color color;

  _PrismLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = color.withAlpha(235)
      ..style = PaintingStyle.fill;

    final paint2 = Paint()
      ..color = color.withAlpha(170)
      ..style = PaintingStyle.fill;

    final paint3 = Paint()
      ..color = color.withAlpha(110)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Top triangle facet
    final path1 = Path()
      ..moveTo(w * 0.5, h * 0.1)
      ..lineTo(w * 0.88, h * 0.45)
      ..lineTo(w * 0.5, h * 0.6)
      ..close();
    canvas.drawPath(path1, paint1);

    // Left triangle facet
    final path2 = Path()
      ..moveTo(w * 0.5, h * 0.1)
      ..lineTo(w * 0.12, h * 0.45)
      ..lineTo(w * 0.5, h * 0.6)
      ..close();
    canvas.drawPath(path2, paint2);

    // Bottom diamond facet
    final path3 = Path()
      ..moveTo(w * 0.12, h * 0.45)
      ..lineTo(w * 0.5, h * 0.9)
      ..lineTo(w * 0.88, h * 0.45)
      ..lineTo(w * 0.5, h * 0.6)
      ..close();
    canvas.drawPath(path3, paint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}