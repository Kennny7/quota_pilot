// lib/presentation/screens/terms_screen.dart
import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  static const _lastUpdated = 'Last updated: 1 January 2026';

  static const _terms = '''
1. Acceptance of terms
By installing or using QuotaPilot ("the App") you agree to these Terms of
Service. If you do not agree, please uninstall the App.

2. What the App does
The App stores the API credentials you provide locally on your device and
uses them to query the usage endpoints of the AI providers you configure.
Quota figures are provided for convenience only and may differ from the
figures shown in the official provider dashboards.

3. Your responsibilities
You are responsible for keeping your API keys secure, for complying with
the terms of each AI provider, and for any usage costs you incur.

4. No warranty
The App is provided "as is", without warranty of any kind. We do not
guarantee that quota data is accurate, complete, or available at any time.

5. Limitation of liability
To the maximum extent permitted by law, the developers shall not be liable
for any indirect, incidental, or consequential damages arising from the
use of the App.

6. Changes
These terms may be updated from time to time. Continued use of the App
after an update constitutes acceptance of the revised terms.
''';

  static const _privacy = '''
1. Data we store
All data you enter — account labels, API keys, quota history and settings —
is stored locally on your device. We do not operate a backend server and we
do not receive a copy of your data.

2. Network requests
The App sends requests directly from your device to the AI providers you
configure, using your own API credentials. Those providers handle the data
according to their own privacy policies.

3. Analytics and advertising
The App contains no third-party analytics SDKs and no advertising SDKs.

4. Deleting your data
Removing an account deletes its stored credentials and quota history.
Uninstalling the App removes all locally stored data.

5. Children
The App is not directed at children under 13 and we do not knowingly
collect personal information from them.

6. Contact
Questions about this policy can be sent to privacy@quotapilot.app.
''';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Terms & Privacy')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(_lastUpdated, style: theme.textTheme.bodySmall),
          const SizedBox(height: 20),
          Text('Terms of Service', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(_terms, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 32),
          Text('Privacy Policy', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(_privacy, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}