// lib/presentation/screens/donate_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_strings.dart';
import '../providers/settings_providers.dart';

class DonateScreen extends ConsumerWidget {
  const DonateScreen({super.key});

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        messenger.showSnackBar(
          const SnackBar(content: Text(AppStrings.donateOpenError)),
        );
      }
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('${AppStrings.donateOpenError}\n$error')),
      );
    }
  }

  void _copyToClipboard(BuildContext context, String label, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settingsAsync = ref.watch(settingsProvider);
    final isSupporter = settingsAsync.valueOrNull?.isSupporter ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.donateTitle),
        actions: [
          if (isSupporter)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Chip(
                avatar: const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                label: const Text('Supporter Active'),
                visualDensity: VisualDensity.compact,
                backgroundColor: theme.colorScheme.primaryContainer,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Supporter Banner
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.tertiary.withAlpha(220),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withAlpha(60),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.favorite_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppStrings.donateHeading,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppStrings.donateDescription,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withAlpha(230),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Supporter Toggle
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SwitchListTile(
                      value: isSupporter,
                      onChanged: (value) async {
                        await ref.read(settingsProvider.notifier).setIsSupporter(value);
                        if (context.mounted && value) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Thank you! Supporter badge unlocked!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      title: const Text(
                        'Unlock Supporter Perks',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text('Shows gold supporter badge & unlocks cosmic theme perks.'),
                      secondary: const Icon(Icons.workspace_premium_rounded, color: Colors.amber),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tier Options
                  Text(
                    'Support Tiers',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _TierCard(
                          price: '\$3',
                          title: 'Espresso',
                          subtitle: 'One coffee',
                          icon: Icons.coffee_rounded,
                          onTap: () => _openUrl(context, 'https://buymeacoffee.com'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TierCard(
                          price: '\$10',
                          title: 'Server Boost',
                          subtitle: 'Maintain APIs',
                          icon: Icons.cloud_done_rounded,
                          isFeatured: true,
                          onTap: () => _openUrl(context, AppStrings.donatePayPalUrl),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TierCard(
                          price: '\$25',
                          title: 'Patron',
                          subtitle: 'VIP backer',
                          icon: Icons.diamond_rounded,
                          onTap: () => _openUrl(context, AppStrings.donatePayPalUrl),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // PayPal QR & Action
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.dividerColor.withAlpha(40)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(8),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Scan PayPal QR',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: QrImageView(
                            data: AppStrings.donatePayPalUrl,
                            version: QrVersions.auto,
                            size: 180,
                            gapless: true,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          AppStrings.donateScanHint,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => _openUrl(context, AppStrings.donatePayPalUrl),
                          icon: const Icon(Icons.open_in_new_rounded, size: 18),
                          label: const Text(AppStrings.donateOpenPayPal),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Crypto Addresses Section
                  Text(
                    'Crypto Addresses',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _CryptoAddressTile(
                    symbol: 'BTC',
                    network: 'Bitcoin Native SegWit',
                    address: AppStrings.btcAddress,
                    onCopy: () => _copyToClipboard(context, 'Bitcoin address', AppStrings.btcAddress),
                  ),
                  const SizedBox(height: 8),
                  _CryptoAddressTile(
                    symbol: 'ETH',
                    network: 'Ethereum / ERC-20',
                    address: AppStrings.ethAddress,
                    onCopy: () => _copyToClipboard(context, 'Ethereum address', AppStrings.ethAddress),
                  ),
                  const SizedBox(height: 8),
                  _CryptoAddressTile(
                    symbol: 'SOL',
                    network: 'Solana Mainnet',
                    address: AppStrings.solAddress,
                    onCopy: () => _copyToClipboard(context, 'Solana address', AppStrings.solAddress),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppStrings.donateFooterNote,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  final String price;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isFeatured;
  final VoidCallback onTap;

  const _TierCard({
    required this.price,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isFeatured = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isFeatured
              ? theme.colorScheme.primaryContainer.withAlpha(120)
              : theme.colorScheme.surfaceContainerHighest.withAlpha(80),
          border: Border.all(
            color: isFeatured ? theme.colorScheme.primary : theme.dividerColor.withAlpha(40),
            width: isFeatured ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isFeatured ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              price,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: isFeatured ? theme.colorScheme.primary : null,
              ),
            ),
            Text(
              title,
              style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CryptoAddressTile extends StatelessWidget {
  final String symbol;
  final String network;
  final String address;
  final VoidCallback onCopy;

  const _CryptoAddressTile({
    required this.symbol,
    required this.network,
    required this.address,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                symbol,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    network,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  Text(
                    address,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 20),
              tooltip: 'Copy address',
              onPressed: onCopy,
            ),
          ],
        ),
      ),
    );
  }
}