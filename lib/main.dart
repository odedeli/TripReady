import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'theme/app_theme.dart';
import 'theme/color_palettes.dart';
import 'screens/dashboard_screen.dart';
import 'screens/trips_screen.dart';
import 'screens/archive/archive_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'services/language_service.dart';
import 'services/theme_service.dart';
import 'services/font_size_service.dart';
import 'services/color_theme_service.dart';
import 'package:tripready/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  await LanguageService.instance.load();
  await ThemeService.instance.load();
  await FontSizeService.instance.load();
  await ColorThemeService.instance.load();
  runApp(const TripReadyApp());
}

class TripReadyApp extends StatefulWidget {
  const TripReadyApp({super.key});
  @override
  State<TripReadyApp> createState() => _TripReadyAppState();
}

class _TripReadyAppState extends State<TripReadyApp> {
  @override
  void initState() {
    super.initState();
    LanguageService.instance.addListener(_rebuild);
    ThemeService.instance.addListener(_rebuild);
    FontSizeService.instance.addListener(_rebuild);
    ColorThemeService.instance.addListener(_rebuild);
  }

  @override
  void dispose() {
    LanguageService.instance.removeListener(_rebuild);
    ThemeService.instance.removeListener(_rebuild);
    FontSizeService.instance.removeListener(_rebuild);
    ColorThemeService.instance.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final lc = LanguageService.instance.locale.languageCode;
    final fs = FontSizeService.instance.scale;
    final palette = AppPalettes.fromTheme(ColorThemeService.instance.colorTheme);
    return MaterialApp(
      title: 'TripReady',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeService.instance.themeMode,
      theme:     TripReadyTheme.theme(languageCode: lc, fontScale: fs, palette: palette),
      darkTheme: TripReadyTheme.darkTheme(languageCode: lc, fontScale: fs, palette: palette),
      locale: LanguageService.instance.locale,
      supportedLocales: LanguageService.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      initialRoute: '/splash',
      routes: {
        '/splash': (ctx) => SplashScreen(onComplete: () =>
            Navigator.of(ctx).pushReplacementNamed('/')),
        '/': (_) => const MainShell(),
      },
    );
  }
}

final tabNotifier = ValueNotifier<int>(0);

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    tabNotifier.addListener(_onTabChange);
  }

  @override
  void dispose() {
    tabNotifier.removeListener(_onTabChange);
    super.dispose();
  }

  void _onTabChange() => setState(() => _currentIndex = tabNotifier.value);

  final List<Widget> _screens = const [
    DashboardScreen(),
    TripsScreen(),
    ArchiveScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() {
          _currentIndex = i;
          tabNotifier.value = i;
        }),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.dashboard_outlined), selectedIcon: const Icon(Icons.dashboard), label: l.navDashboard),
          NavigationDestination(icon: const Icon(Icons.flight_outlined),    selectedIcon: const Icon(Icons.flight),    label: l.navMyTrips),
          NavigationDestination(icon: const Icon(Icons.archive_outlined),   selectedIcon: const Icon(Icons.archive),   label: l.navArchive),
          NavigationDestination(icon: const Icon(Icons.settings_outlined),  selectedIcon: const Icon(Icons.settings),  label: l.navSettings),
        ],
      ),
    );
  }
}
