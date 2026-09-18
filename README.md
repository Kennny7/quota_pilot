# quota_pilot

Name: QuotaPilot
Tagline: “Know your limits.”

Icon concept:
A circular gauge with a needle pointing slightly above the mid‑point, a small bar chart in the background, and a subtle magnifying glass overlay. Colors: deep blue (#1A73E8) for the gauge, vibrant green (#34A853) for the needle, and a clean white background. Minimalist and modern – suitable for Play Store.


```Project Structure

quota_pilot/
├── android/
├── ios/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_strings.dart
│   │   │   ├── app_colors.dart
│   │   │   └── api_endpoints.dart
│   │   ├── errors/
│   │   │   ├── failures.dart
│   │   │   └── exceptions.dart
│   │   ├── network/
│   │   │   ├── dio_client.dart
│   │   │   └── network_info.dart
│   │   ├── utils/
│   │   │   ├── date_formatter.dart
│   │   │   └── validators.dart
│   │   └── widgets/
│   │       ├── loading_indicator.dart
│   │       └── error_view.dart
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── local/
│   │   │   │   ├── database_helper.dart
│   │   │   │   └── dao/
│   │   │   │       ├── account_dao.dart
│   │   │   │       ├── quota_dao.dart
│   │   │   │       └── service_dao.dart
│   │   │   └── remote/
│   │   │       ├── quota_api.dart
│   │   │       └── service_adapters/
│   │   │           ├── base_adapter.dart
│   │   │           ├── openai_adapter.dart
│   │   │           ├── google_ai_adapter.dart
│   │   │           ├── anthropic_adapter.dart
│   │   │           ├── grok_adapter.dart
│   │   │           └── service_adapters.dart
│   │   ├── models/
│   │   │   ├── account.dart
│   │   │   ├── quota_info.dart
│   │   │   ├── service_definition.dart
│   │   │   └── user_settings.dart
│   │   └── repositories/
│   │       ├── account_repository.dart
│   │       ├── quota_repository.dart
│   │       └── settings_repository.dart
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── account.dart
│   │   │   ├── quota_info.dart
│   │   │   ├── service_definition.dart
│   │   │   └── user_settings.dart
│   │   ├── repositories/
│   │   │   ├── i_account_repository.dart
│   │   │   ├── i_quota_repository.dart
│   │   │   └── i_settings_repository.dart
│   │   └── usecases/
│   │       ├── add_account.dart
│   │       ├── remove_account.dart
│   │       ├── get_all_accounts.dart
│   │       ├── refresh_quota.dart
│   │       ├── get_quota_history.dart
│   │       └── update_manual_quota.dart
│   ├── presentation/
│   │   ├── providers/
│   │   │   ├── account_providers.dart
│   │   │   ├── quota_providers.dart
│   │   │   └── settings_providers.dart
│   │   ├── screens/
│   │   │   ├── splash_screen.dart
│   │   │   ├── home_screen.dart
│   │   │   ├── add_account_screen.dart
│   │   │   ├── account_detail_screen.dart
│   │   │   ├── settings_screen.dart
│   │   │   ├── about_screen.dart
│   │   │   ├── terms_screen.dart
│   │   │   └── donate_screen.dart
│   │   └── widgets/
│   │       ├── quota_card.dart
│   │       ├── account_tile.dart
│   │       ├── service_dropdown.dart
│   │       └── quota_alert_settings_section.dart
│   └── main.dart
├── test/
├── pubspec.yaml
└── README.md

```

Do this to enable notifiationf eature when building app

android/app/src/main/AndroidManifest.xml
Add inside <manifest> (above <application>):

xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
flutter_local_notifications already declares most others through its plugin manifest.



