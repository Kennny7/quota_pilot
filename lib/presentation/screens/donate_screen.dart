// lib/presentation/screens/donate_screen.dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class DonateScreen extends StatelessWidget {
  const DonateScreen({super.key});

  /// Shown under the QR code so users can type the address manually.
  /// (Move this into AppStrings.donateHandle if you prefer keeping all copy there.)
  static const String payPalHandle = 'paypal.me/quotapilot';

  Future<void> _openPayPal(BuildContext context) async {
    final uri = Uri.parse(AppStrings.donatePayPalUrl);

    // Capture before the await so we never touch BuildContext across an
    // async gap (avoids the use_build_context_synchronously lint).
    final messenger = ScaffoldMessenger.of(context);

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.donateTitle)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_rounded,
                    size: 56,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.donateHeading,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppStrings.donateDescription,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  // ---- Static QR code ----
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.divider,
                        width: 1,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: QrImageView(
                      data: AppStrings.donatePayPalUrl,
                      version: QrVersions.auto,
                      size: 220,
                      gapless: true,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Colors.black,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Colors.black,
                      ),
                      semanticsLabel: AppStrings.donateQrSemantics,
                    ),
                  ),

                  const SizedBox(height: 16),
                  Text(
                    AppStrings.donateScanHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // ---- Manual entry fallback (from v1) ----
                  Center(
                    child: SelectableText(
                      payPalHandle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ---- Open PayPal button ----
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _openPayPal(context),
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text(AppStrings.donateOpenPayPal),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppStrings.donateFooterNote,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}