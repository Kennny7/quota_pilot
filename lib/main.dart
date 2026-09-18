// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/notifications/notification_service.dart';
import 'presentation/providers/notification_providers.dart';
import 'presentation/providers/settings_providers.dart';
import 'presentation/screens/about_screen.dart';
import 'presentation/screens/account_detail_screen.dart';
import 'presentation/screens/add_account_screen.dart';
import 'presentation/screens/donate_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/terms_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SharedPreferences is needed synchronously by `ProviderScope` to construct
  // `SettingsRepositoryImpl`, so it has to be awaited before `runApp`.
  final prefs = await SharedPreferences.getInstance();

  // Must complete before the first notification can be shown — otherwise the
  // scheduler may try to post through an uninitialised channel.
  await NotificationService.instance.init();

  // TODO: initialize DatabaseHelper, secure storage, PackageInfo, etc.

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const QuotaPilotApp(),
    ),
  );
}

/// App-wide router.
final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  debugLogDiagnostics: true,
  routes: <RouteBase>[
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/add-account',
      name: 'add-account',
      builder: (context, state) => const AddAccountScreen(),
    ),
    GoRoute(
      path: '/account-detail/:id',
      name: 'account-detail',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return AccountDetailScreen(id: id);
      },
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/about',
      name: 'about',
      builder: (context, state) => const AboutScreen(),
    ),
    GoRoute(
      path: '/terms',
      name: 'terms',
      builder: (context, state) => const TermsScreen(),
    ),
    GoRoute(
      path: '/donate',
      name: 'donate',
      builder: (context, state) => const DonateScreen(),
    ),
  ],
);

class QuotaPilotApp extends ConsumerStatefulWidget {
  const QuotaPilotApp({super.key});

  @override
  ConsumerState<QuotaPilotApp> createState() => _QuotaPilotAppState();
}

class _QuotaPilotAppState extends ConsumerState<QuotaPilotApp> {
  // Brand palette
  static const Color _primary = Color(0xFF1A73E8);
  static const Color _secondary = Color(0xFF34A853);

  @override
  void initState() {
    super.initState();
    // Reading the provider constructs it and its dependencies, which starts
    // the scheduler. Teardown is handled by `ref.onDispose` inside the
    // provider, so we don't need to hold the value.
    ref.read(quotaAlertSchedulerProvider);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primary,
        primary: _primary,
        secondary: _secondary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF7F9FC),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
      ),
    );

    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primary,
        primary: _primary,
        secondary: _secondary,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
      ),
    );

    return MaterialApp.router(
      title: 'QuotaPilot',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}