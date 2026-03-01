import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'theme/app_theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/trips_screen.dart';
import 'screens/archive/archive_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const TripReadyApp());
}

class TripReadyApp extends StatelessWidget {
  const TripReadyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TripReady',
      debugShowCheckedModeBanner: false,
      theme: TripReadyTheme.theme,
      initialRoute: '/',
      routes: {
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
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => tabNotifier.value = i,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.flight_outlined),
            selectedIcon: Icon(Icons.flight),
            label: 'My Trips',
          ),
          NavigationDestination(
            icon: Icon(Icons.archive_outlined),
            selectedIcon: Icon(Icons.archive),
            label: 'Archive',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
