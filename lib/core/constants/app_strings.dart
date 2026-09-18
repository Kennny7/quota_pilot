// lib/core/constants/app_strings.dart

class AppStrings {
  AppStrings._();

  // App General
  static const String appName = 'QuotaPilot';
  static const String appTagline = 'Know your limits.';
  static const String appDescription =
      'Universal LLM quota tracker for chat services, developer APIs, and manual account tiers.';

  // Home Screen
  static const String homeTitle = 'QuotaPilot';
  static const String searchHint = 'Search accounts or services...';
  static const String allFilter = 'All';
  static const String lowQuotaFilter = 'Low Quota';
  static const String apiFilter = 'API Sync';
  static const String manualFilter = 'Manual';
  static const String emptyAccountsTitle = 'No Accounts Added';
  static const String emptyAccountsSubtitle =
      'Connect your LLM accounts or set up manual limits to monitor quota usage in real time.';
  static const String addFirstAccount = 'Add Account';
  static const String refreshAll = 'Refresh All';

  // Add Account Screen
  static const String addAccountTitle = 'Add Account';
  static const String emailOrLabel = 'Account Email / Label';
  static const String emailHint = 'e.g. khushalpareta9@gmail.com';
  static const String selectService = 'Select Service';
  static const String authTypeLabel = 'Authentication Mode';
  static const String authTypeApiKey = 'API Key';
  static const String authTypeManual = 'Manual Tracking';
  static const String apiKeyLabel = 'API Key';
  static const String apiKeyHint = 'Enter your API key or token';
  static const String manualHint =
      'This service does not require an API key. You can record and adjust your limits manually.';
  static const String initialLimit = 'Total Quota Limit';
  static const String initialUsed = 'Current Used Quota';
  static const String quotaUnit = 'Quota Unit';
  static const String saveAccount = 'Save Account';
  static const String saving = 'Saving...';

  // Account Detail
  static const String currentQuota = 'Current Quota';
  static const String quotaHistory = 'Usage History';
  static const String updateManualQuota = 'Update Quota Manually';
  static const String quickAdjust = 'Quick Adjust';
  static const String removeAccount = 'Remove Account';
  static const String removeAccountConfirm =
      'Are you sure you want to remove this account? All associated quota records will be deleted.';
  static const String openConsole = 'Open Provider Console';

  // Settings
  static const String settingsTitle = 'Settings';
  static const String generalSection = 'General';
  static const String themeLabel = 'Theme';
  static const String accentColorLabel = 'Accent Palette';
  static const String notificationsSection = 'Notifications';
  static const String lowQuotaAlerts = 'Low Quota Alerts';
  static const String lowQuotaAlertsSubtitle =
      'Notify me when remaining quota drops below the specified threshold.';
  static const String alertThreshold = 'Alert Threshold';
  static const String sendTestAlert = 'Send Test Alert';
  static const String testAlertSent = 'Test notification triggered.';
  static const String backupSection = 'Data & Backup';
  static const String exportData = 'Export Backup (JSON)';
  static const String importData = 'Import Backup (JSON)';
  static const String backupExportSuccess = 'Backup copied to clipboard.';
  static const String backupImportSuccess = 'Accounts successfully restored.';
  static const String infoSection = 'Information';
  static const String about = 'About';
  static const String terms = 'Terms & Privacy';
  static const String donate = 'Donate';

  // Donate Screen
  static const String donateTitle = 'Support QuotaPilot';
  static const String donateHeading = 'Fuel Independent AI Tools';
  static const String donateDescription =
      'QuotaPilot is 100% free and open source. Your contributions directly fund active development, new LLM adapters, and maintenance.';
  static const String donatePayPalUrl = 'https://paypal.me/quotapilot';
  static const String donateOpenError = 'Could not open payment link.';
  static const String donateQrSemantics = 'Donation QR Code';
  static const String donateScanHint = 'Scan QR code with your payment app';
  static const String donateOpenPayPal = 'Donate via PayPal';
  static const String donateFooterNote =
      'Thank you for empowering independent development. Every donation counts.';
  static const String btcAddress = 'bc1q9x853v058tq344uwn0j2x4538z4m0e77n6v4s6';
  static const String ethAddress = '0x529d20c57c489E5FDeE390aA2A395c97A4468fCe';
  static const String solAddress = '7sW7dZ4gC3v6y29JgG5gXkL2U4n3BvV9gZ7jF9n4C5m2';
  static const String copiedToClipboard = 'Address copied to clipboard.';

  // About Screen & LazyMoneyLabs
  static const String companyName = 'LazyMoneyLabs';
  static const String companyTagline = 'Creative Software & Digital Automation';
  static const String companyDescription =
      'LazyMoneyLabs designs modern mobile utilities, developer tooling, and productivity applications across diverse digital categories.';
  static const String companyWebsite = 'https://lazymoneylabs.dev';
  static const String supportEmail = 'contact@lazymoneylabs.dev';
  static const String version = 'Version 1.0.0 (Build 1)';
  static const String openSourceLicenses = 'Open Source Licenses';

  // Errors & Validations
  static const String errorGeneric = 'An unexpected error occurred.';
  static const String errorNetwork = 'Network connectivity issue. Please check your connection.';
  static const String errorInvalidApiKey = 'Invalid API key. Please check your credentials.';
  static const String errorRateLimit = 'Rate limit exceeded for this provider.';
  static const String requiredField = 'This field is required.';
  static const String invalidEmail = 'Please enter a valid email or label.';
  static const String invalidNumber = 'Please enter a valid non-negative number.';
}
